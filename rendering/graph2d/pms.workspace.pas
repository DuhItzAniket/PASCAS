{ Multi-expression workspace (Phase 35): the Desmos-style list behind
  the graph. Owns a TDepStore (variables/functions, reactive), holds one
  entry per plotted expression with its own AST, caches samples per
  viewport+variable-version. Sliders (Phase 36) bind here: a param is a
  store variable with a range; setting it bumps the version and every
  dependent expression re-samples lazily. }
unit PMS.Workspace;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Classes, PMS.Types, PMS.AST, PMS.Parser, PMS.Eval, PMS.Deps,
  PMS.Viewport, PMS.Sampler;

type
  TWSKind = (wkFuncY, wkParam, wkPolar, wkImplicit);

  TWSEntry = record
    Text: string;
    Kind: TWSKind;
    AST1, AST2: TASTNode; // owned; AST2 only for parametric
    VarX: string;         // 'x' | 't' | 't' | 'x'
    VarY: string;         // '' | '' | '' | 'y'
    T0, T1: Double;       // param/polar range
    ColorIdx: Integer;
    Visible: Boolean;
    CacheLines: TSampleLines;
    CacheV: TViewport;
    CacheVer: Integer;
  end;

  TParamBinding = record
    Name: string;
    Lo, Hi, Step: Double;
  end;

  TWorkspace = class
  private
    FEntries: array of TWSEntry;
    FParams: array of TParamBinding;
    FVersion: Integer;
    FNextColor: Integer;
    function KindVarX(K: TWSKind): string;
    procedure FreeEntry(var E: TWSEntry);
    function SameViewport(const A, B: TViewport): Boolean;
  public
    Store: TDepStore;
    constructor Create;
    destructor Destroy; override;
    function AddExpr(const Text: string; Kind: TWSKind; out Err: TCalcError;
      out ErrPos: Integer): Integer;
    function DefineVar(const Text: string; out Err: TCalcError;
      out ErrPos: Integer): Boolean;
    function EnsureVar(const Name: string; V: Double): Boolean;
    function SetVar(const Name: string; V: Double): Boolean;
    function GetVar(const Name: string; out V: Double): Boolean;
    procedure DeleteEntry(I: Integer);
    procedure ClearEntries;
    procedure SetVisible(I: Integer; V: Boolean);
    procedure SetRange(I: Integer; T0, T1: Double);
    function BindParam(const Name: string; Lo, Hi, Step: Double): Boolean;
    procedure UnbindParam(const Name: string);
    function ParamCount: Integer;
    function ParamInfo(I: Integer): TParamBinding;
    function EntryCount: Integer;
    function EntryText(I: Integer): string;
    function EntryRawText(I: Integer): string;
    function EntryKind(I: Integer): TWSKind;
    function EntryVisible(I: Integer): Boolean;
    function EntryColor(I: Integer): Integer;
    function ExpandEntry(I: Integer; Part: Integer; out Err: TCalcError): TASTNode;
    function RefreshEntry(I: Integer; out Err: TCalcError): Boolean;
    function SampleEntry(I: Integer; const V: TViewport;
      out Err: TCalcError): TSampleLines;
    property Version: Integer read FVersion;
  end;

implementation

constructor TWorkspace.Create;
begin
  inherited Create;
  Store := TDepStore.Create;
  SetLength(FEntries, 0);
  SetLength(FParams, 0);
  FVersion := 0;
  FNextColor := 0;
end;

destructor TWorkspace.Destroy;
var
  I: Integer;
begin
  for I := 0 to High(FEntries) do
    FreeEntry(FEntries[I]);
  Store.Free;
  inherited Destroy;
end;

procedure TWorkspace.FreeEntry(var E: TWSEntry);
begin
  E.AST1.Free;
  E.AST2.Free;
  E.AST1 := nil;
  E.AST2 := nil;
  SetLength(E.CacheLines, 0);
end;

function TWorkspace.KindVarX(K: TWSKind): string;
begin
  case K of
    wkFuncY:
      Result := 'x';
    wkImplicit:
      Result := 'x';
  else
    Result := 't';
  end;
end;

function TWorkspace.SameViewport(const A, B: TViewport): Boolean;
begin
  Result := (A.XMin = B.XMin) and (A.XMax = B.XMax) and
    (A.YMin = B.YMin) and (A.YMax = B.YMax) and (A.W = B.W) and (A.H = B.H);
end;

function ParseOne(const Text: string; out N: TASTNode; out Err: TCalcError;
  out ErrPos: Integer): Boolean;
begin
  N := nil;
  Result := ParseExpression(Text, N, Err, ErrPos);
end;

function TWorkspace.AddExpr(const Text: string; Kind: TWSKind;
  out Err: TCalcError; out ErrPos: Integer): Integer;
var
  E: TWSEntry;
  Semi: Integer;
  T1, T2: string;
begin
  Result := -1;
  // explicit init (no FillChar/SizeOf: pas2js-clean and managed-safe)
  E.Text := '';
  E.AST1 := nil;
  E.AST2 := nil;
  E.ColorIdx := 0;
  E.Visible := True;
  E.CacheVer := -1;
  SetLength(E.CacheLines, 0);
  E.CacheV := VDefault(0, 0);
  E.Kind := Kind;
  E.VarX := KindVarX(Kind);
  E.VarY := '';
  E.T0 := -10;
  E.T1 := 10;
  case Kind of
    wkFuncY:
      if not ParseOne(Text, E.AST1, Err, ErrPos) then
        Exit;
    wkParam:
    begin
      Semi := Pos(';', Text);
      if Semi < 1 then
      begin
        Err := ceSyntax;
        ErrPos := Length(Text) + 1;
        Exit;
      end;
      T1 := Trim(Copy(Text, 1, Semi - 1));
      T2 := Trim(Copy(Text, Semi + 1, Length(Text)));
      if not ParseOne(T1, E.AST1, Err, ErrPos) then
        Exit;
      if not ParseOne(T2, E.AST2, Err, ErrPos) then
      begin
        E.AST1.Free;
        E.AST1 := nil;
        Exit;
      end;
    end;
    wkPolar:
    begin
      if not ParseOne(Text, E.AST1, Err, ErrPos) then
        Exit;
      E.T0 := 0;
      E.T1 := 2 * Pi;
    end;
    wkImplicit:
    begin
      if not ParseOne(Text, E.AST1, Err, ErrPos) then
        Exit;
      E.VarY := 'y';
    end;
  end;
  E.Text := Text;
  E.ColorIdx := FNextColor;
  FNextColor := (FNextColor + 1) mod 8;
  E.Visible := True;
  E.CacheVer := -1;
  SetLength(FEntries, Length(FEntries) + 1);
  FEntries[High(FEntries)] := E;
  Inc(FVersion);
  Err := ceNone;
  ErrPos := 0;
  Result := High(FEntries);
end;

function TWorkspace.DefineVar(const Text: string; out Err: TCalcError;
  out ErrPos: Integer): Boolean;
begin
  Result := Store.Define(Text, Err, ErrPos);
  if Result then
    Inc(FVersion);
end;

function TWorkspace.EnsureVar(const Name: string; V: Double): Boolean;
var
  E: TCalcError;
  P: Integer;
  Dummy: Double;
begin
  if Store.EvalVar(Name, Dummy, E) then
  begin
    Store.SetVar(Name, V);
    Inc(FVersion);
    Exit(True);
  end;
  Result := Store.Define(Name + '=' + Format('%.10g', [V]), E, P);
  if Result then
  begin
    Store.SetVar(Name, V);
    Inc(FVersion);
  end;
end;

function TWorkspace.SetVar(const Name: string; V: Double): Boolean;
begin
  if not EnsureVar(Name, V) then
    Exit(False);
  Inc(FVersion);
  Result := True;
end;

function TWorkspace.GetVar(const Name: string; out V: Double): Boolean;
var
  E: TCalcError;
begin
  Result := Store.EvalVar(Name, V, E);
end;

procedure TWorkspace.DeleteEntry(I: Integer);
var
  J: Integer;
begin
  if (I < 0) or (I > High(FEntries)) then
    Exit;
  FreeEntry(FEntries[I]);
  for J := I to High(FEntries) - 1 do
    FEntries[J] := FEntries[J + 1];
  SetLength(FEntries, Length(FEntries) - 1);
  Inc(FVersion);
end;

procedure TWorkspace.ClearEntries;
var
  I: Integer;
begin
  for I := 0 to High(FEntries) do
    FreeEntry(FEntries[I]);
  SetLength(FEntries, 0);
  Inc(FVersion);
end;

procedure TWorkspace.SetVisible(I: Integer; V: Boolean);
begin
  if (I < 0) or (I > High(FEntries)) then
    Exit;
  FEntries[I].Visible := V;
  Inc(FVersion);
end;

procedure TWorkspace.SetRange(I: Integer; T0, T1: Double);
begin
  if (I < 0) or (I > High(FEntries)) then
    Exit;
  FEntries[I].T0 := T0;
  FEntries[I].T1 := T1;
  FEntries[I].CacheVer := -1;
  Inc(FVersion);
end;

function TWorkspace.BindParam(const Name: string; Lo, Hi, Step: Double): Boolean;
var
  I: Integer;
  V: Double;
  E: TCalcError;
begin
  for I := 0 to High(FParams) do
    if FParams[I].Name = Name then
    begin
      FParams[I].Lo := Lo;
      FParams[I].Hi := Hi;
      FParams[I].Step := Step;
      Exit(True);
    end;
  if not Store.EvalVar(Name, V, E) then
    Exit(False); // bind existing variables only
  SetLength(FParams, Length(FParams) + 1);
  FParams[High(FParams)].Name := Name;
  FParams[High(FParams)].Lo := Lo;
  FParams[High(FParams)].Hi := Hi;
  FParams[High(FParams)].Step := Step;
  Result := True;
end;

procedure TWorkspace.UnbindParam(const Name: string);
var
  I, J: Integer;
begin
  for I := 0 to High(FParams) do
    if FParams[I].Name = Name then
    begin
      for J := I to High(FParams) - 1 do
        FParams[J] := FParams[J + 1];
      SetLength(FParams, Length(FParams) - 1);
      Exit;
    end;
end;

function TWorkspace.ParamCount: Integer;
begin
  Result := Length(FParams);
end;

function TWorkspace.ParamInfo(I: Integer): TParamBinding;
begin
  Result := FParams[I];
end;

function TWorkspace.EntryCount: Integer;
begin
  Result := Length(FEntries);
end;

function TWorkspace.EntryText(I: Integer): string;
const
  KindTag: array[TWSKind] of string = ('', ' (param)', ' (polar)', ' (implicit)');
begin
  Result := FEntries[I].Text + KindTag[FEntries[I].Kind];
end;

function TWorkspace.EntryRawText(I: Integer): string;
begin
  Result := FEntries[I].Text;
end;

function TWorkspace.EntryKind(I: Integer): TWSKind;
begin
  Result := FEntries[I].Kind;
end;

function TWorkspace.EntryVisible(I: Integer): Boolean;
begin
  Result := FEntries[I].Visible;
end;

function TWorkspace.EntryColor(I: Integer): Integer;
begin
  Result := FEntries[I].ColorIdx;
end;

function TWorkspace.ExpandEntry(I: Integer; Part: Integer;
  out Err: TCalcError): TASTNode;
begin
  Err := ceNone;
  Result := nil;
  if (I < 0) or (I > High(FEntries)) then
  begin
    Err := ceDomain;
    Exit;
  end;
  if Part = 2 then
  begin
    if FEntries[I].AST2 = nil then
    begin
      Err := ceDomain;
      Exit;
    end;
    Result := Store.ExpandCalls(FEntries[I].AST2, 0, Err);
  end
  else
    Result := Store.ExpandCalls(FEntries[I].AST1, 0, Err);
end;

function TWorkspace.RefreshEntry(I: Integer; out Err: TCalcError): Boolean;
begin
  Result := False;
  if (I < 0) or (I > High(FEntries)) then
  begin
    Err := ceDomain;
    Exit;
  end;
  if not Store.EnsureRefs(FEntries[I].AST1, Err) then
    Exit;
  if (FEntries[I].AST2 <> nil) and not Store.EnsureRefs(FEntries[I].AST2, Err) then
    Exit;
  Result := True;
end;

function TWorkspace.SampleEntry(I: Integer; const V: TViewport;
  out Err: TCalcError): TSampleLines;
var
  Exp1, Exp2: TASTNode;
  Line: TSampleLine;
begin
  Err := ceNone;
  SetLength(Result, 0);
  if (I < 0) or (I > High(FEntries)) or not FEntries[I].Visible then
    Exit;
  if (FEntries[I].CacheVer = FVersion) and
    SameViewport(FEntries[I].CacheV, V) then
  begin
    Result := FEntries[I].CacheLines;
    Exit;
  end;
  if not RefreshEntry(I, Err) then
    Exit;
  case FEntries[I].Kind of
    wkFuncY:
    begin
      Exp1 := ExpandEntry(I, 1, Err);
      if Err <> ceNone then
      begin
        Exp1.Free;
        Exit;
      end;
      Line := SampleFunc(Exp1, 'x', V, Store.Ctx, Err);
      Exp1.Free;
      if Err <> ceNone then
        Exit;
      SetLength(Result, 1);
      Result[0] := Line;
    end;
    wkParam:
    begin
      Exp1 := ExpandEntry(I, 1, Err);
      if Err <> ceNone then
      begin
        Exp1.Free;
        Exit;
      end;
      Exp2 := ExpandEntry(I, 2, Err);
      if Err <> ceNone then
      begin
        Exp1.Free;
        Exp2.Free;
        Exit;
      end;
      Line := SampleParam(Exp1, Exp2, 't', FEntries[I].T0, FEntries[I].T1,
        V, Store.Ctx, Err);
      Exp1.Free;
      Exp2.Free;
      if Err <> ceNone then
        Exit;
      SetLength(Result, 1);
      Result[0] := Line;
    end;
    wkPolar:
    begin
      Exp1 := ExpandEntry(I, 1, Err);
      if Err <> ceNone then
      begin
        Exp1.Free;
        Exit;
      end;
      Line := SamplePolar(Exp1, 't', FEntries[I].T0, FEntries[I].T1,
        V, Store.Ctx, Err);
      Exp1.Free;
      if Err <> ceNone then
        Exit;
      SetLength(Result, 1);
      Result[0] := Line;
    end;
    wkImplicit:
    begin
      Exp1 := ExpandEntry(I, 1, Err);
      if Err <> ceNone then
      begin
        Exp1.Free;
        Exit;
      end;
      SampleImplicit(Exp1, 'x', 'y', V, 120, 120, Store.Ctx, Result, Err);
      Exp1.Free;
      if Err <> ceNone then
        Exit;
    end;
  end;
  FEntries[I].CacheLines := Result;
  FEntries[I].CacheV := V;
  FEntries[I].CacheVer := FVersion;
end;

end.
