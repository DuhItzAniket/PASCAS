{ Dependency and reactive evaluation engine (Phase 31): named variables
  and single-expression functions with a dependency graph. User function
  calls are *inlined by substitution* (pure tree transform, depth-capped),
  so the Double evaluator stays the only numeric path — no duplicated
  evaluation logic. Cycles are ceUnsupported, never infinite loops.
  User identifiers are case-SENSITIVE (evaluator parity). }
unit PMS.Deps;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, PMS.Types, PMS.AST, PMS.ASTUtils, PMS.Parser, PMS.Eval;

type
  TDepKind = (dkVar, dkFunc);

  TDepEntry = record
    Kind: TDepKind;
    Name: string;
    Params: array of string;
    Body: TASTNode; // owned; nil until defined
    Value: Double;  // cached (vars)
    HasValue: Boolean;
    Dirty: Boolean;
  end;

  TDepStore = class
  private
    FEntries: array of TDepEntry;
    FCtx: TEvalContext;
    FVisiting: array of string;
    function Find(const Name: string): Integer;
    function RefsName(Node: TASTNode; const Name: string): Boolean;
    procedure MarkDirty(const Name: string);
    function EvalVarIdx(Idx: Integer; out V: Double;
      out Err: TCalcError): Boolean;
    function PushVisit(const Name: string): Boolean;
    procedure PopVisit;
  public
    constructor Create;
    destructor Destroy; override;
    function Define(const Text: string; out Err: TCalcError;
      out ErrPos: Integer): Boolean;
    function SetVar(const Name: string; V: Double): Boolean;
    function EvalVar(const Name: string; out V: Double;
      out Err: TCalcError): Boolean;
    function EvalFunc(const Name: string; const Args: array of Double;
      out V: Double; out Err: TCalcError): Boolean;
    function EvalExpr(const Text: string; out V: Double; out Err: TCalcError;
      out ErrPos: Integer): Boolean;
    function EnsureRefs(Node: TASTNode; out Err: TCalcError): Boolean;
    function ExpandCalls(Node: TASTNode; Depth: Integer;
      out Err: TCalcError): TASTNode;
    function EntryCount: Integer;
    function EntryName(I: Integer): string;
    function EntryText(I: Integer): string;
    function EntryKind(I: Integer): TDepKind;
    property Ctx: TEvalContext read FCtx;
  end;

implementation

constructor TDepStore.Create;
begin
  inherited Create;
  FCtx := TEvalContext.Create;
  SetLength(FEntries, 0);
  SetLength(FVisiting, 0);
end;

destructor TDepStore.Destroy;
var
  I: Integer;
begin
  for I := 0 to High(FEntries) do
    FEntries[I].Body.Free;
  FCtx.Free;
  inherited Destroy;
end;

function TDepStore.Find(const Name: string): Integer;
var
  I: Integer;
begin
  for I := 0 to High(FEntries) do
    if FEntries[I].Name = Name then
      Exit(I);
  Result := -1;
end;

function TDepStore.RefsName(Node: TASTNode; const Name: string): Boolean;
var
  I: Integer;
begin
  if Node = nil then
    Exit(False);
  if Node is TVarNode then
    Exit(TVarNode(Node).Name = Name);
  if (Node is TFuncNode) and (TFuncNode(Node).Name = Name) then
    Exit(True);
  if Node is TFuncNode then
  begin
    for I := 0 to High(TFuncNode(Node).Args) do
      if RefsName(TFuncNode(Node).Args[I], Name) then
        Exit(True);
    Exit(False);
  end;
  if Node is TBinaryNode then
    Exit(RefsName(TBinaryNode(Node).Left, Name) or
      RefsName(TBinaryNode(Node).Right, Name));
  if Node is TUnaryNode then
    Exit(RefsName(TUnaryNode(Node).Child, Name));
  Result := False;
end;

procedure TDepStore.MarkDirty(const Name: string);
var
  I: Integer;
begin
  for I := 0 to High(FEntries) do
  begin
    if (FEntries[I].Kind = dkVar) and RefsName(FEntries[I].Body, Name) then
    begin
      if not FEntries[I].Dirty then
      begin
        FEntries[I].Dirty := True;
        MarkDirty(FEntries[I].Name); // propagate transitively
      end;
    end;
  end;
end;

function TDepStore.PushVisit(const Name: string): Boolean;
var
  I: Integer;
begin
  for I := 0 to High(FVisiting) do
    if FVisiting[I] = Name then
      Exit(False); // cycle
  SetLength(FVisiting, Length(FVisiting) + 1);
  FVisiting[High(FVisiting)] := Name;
  Result := True;
end;

procedure TDepStore.PopVisit;
begin
  SetLength(FVisiting, Length(FVisiting) - 1);
end;

function TDepStore.Define(const Text: string; out Err: TCalcError;
  out ErrPos: Integer): Boolean;
var
  Root: TASTNode;
  Idx, I: Integer;
begin
  Result := False;
  if not ParseExpression(Text, Root, Err, ErrPos) then
    Exit;
  try
    if Root is TAssignNode then
    begin
      Idx := Find(TAssignNode(Root).Name);
      if (Idx >= 0) and (FEntries[Idx].Kind = dkFunc) then
      begin
        Err := ceUnsupported; // cannot shadow a function with a variable
        ErrPos := 1;
        Exit;
      end;
      if Idx < 0 then
      begin
        SetLength(FEntries, Length(FEntries) + 1);
        Idx := High(FEntries);
        FEntries[Idx].Kind := dkVar;
        FEntries[Idx].Name := TAssignNode(Root).Name;
        FEntries[Idx].Body := nil;
        FEntries[Idx].HasValue := False;
      end
      else
        FEntries[Idx].Body.Free;
      FEntries[Idx].Body := TAssignNode(Root).Expr.Clone();
      SetLength(FEntries[Idx].Params, 0);
      FEntries[Idx].Dirty := True;
      FEntries[Idx].HasValue := False;
      MarkDirty(FEntries[Idx].Name);
      Err := ceNone;
      ErrPos := 0;
      Result := True;
    end
    else if Root is TFuncDefNode then
    begin
      Idx := Find(TFuncDefNode(Root).Name);
      if Idx < 0 then
      begin
        SetLength(FEntries, Length(FEntries) + 1);
        Idx := High(FEntries);
        FEntries[Idx].Name := TFuncDefNode(Root).Name;
        FEntries[Idx].HasValue := False;
      end
      else
        FEntries[Idx].Body.Free;
      FEntries[Idx].Kind := dkFunc;
      FEntries[Idx].Body := TFuncDefNode(Root).Body.Clone();
      SetLength(FEntries[Idx].Params, Length(TFuncDefNode(Root).Params));
      for I := 0 to High(TFuncDefNode(Root).Params) do
        FEntries[Idx].Params[I] := TFuncDefNode(Root).Params[I];
      FEntries[Idx].Dirty := False;
      Err := ceNone;
      ErrPos := 0;
      Result := True;
    end
    else
    begin
      Err := ceSyntax; // Define takes definitions; use EvalExpr for values
      ErrPos := 1;
    end;
  finally
    Root.Free;
  end;
end;

function TDepStore.SetVar(const Name: string; V: Double): Boolean;
var
  Idx: Integer;
begin
  Idx := Find(Name);
  if (Idx < 0) or (FEntries[Idx].Kind <> dkVar) then
    Exit(False);
  FEntries[Idx].Value := V;
  FEntries[Idx].HasValue := True;
  FEntries[Idx].Dirty := False;
  FCtx.SetVar(Name, V);
  MarkDirty(Name);
  Result := True;
end;

function Substitute(Node: TASTNode; const Params: array of string;
  const Args: array of TASTNode): TASTNode;
var
  I, P: Integer;
  F: TFuncNode;
begin
  if Node is TVarNode then
  begin
    for P := 0 to High(Params) do
      if TVarNode(Node).Name = Params[P] then
        Exit(Args[P].Clone());
    Exit(TVarNode.Create(TVarNode(Node).Name));
  end;
  if Node is TNumberNode then
    Exit(TNumberNode.Create(TNumberNode(Node).Value));
  if Node is TUnaryNode then
    Exit(TUnaryNode.Create(TUnaryNode(Node).Op,
      Substitute(TUnaryNode(Node).Child, Params, Args)));
  if Node is TBinaryNode then
    Exit(TBinaryNode.Create(TBinaryNode(Node).Op,
      Substitute(TBinaryNode(Node).Left, Params, Args),
      Substitute(TBinaryNode(Node).Right, Params, Args)));
  if Node is TFuncNode then
  begin
    F := TFuncNode.Create(TFuncNode(Node).Name);
    for I := 0 to High(TFuncNode(Node).Args) do
      F.AddArg(Substitute(TFuncNode(Node).Args[I], Params, Args));
    Exit(F);
  end;
  // assigns/defs never appear inside inlined bodies meaningfully; clone
  Exit(Node.Clone());
end;

function TDepStore.ExpandCalls(Node: TASTNode; Depth: Integer;
  out Err: TCalcError): TASTNode;
var
  I, J, Idx: Integer;
  F: TFuncNode;
  ArgTrees: array of TASTNode;
  Sub, Exp: TASTNode;
begin
  Err := ceNone;
  Result := nil;
  if Depth > PMSMaxDepth then
  begin
    Err := ceRecursionLimit;
    Exit;
  end;
  if Node is TFuncNode then
  begin
    Idx := Find(TFuncNode(Node).Name);
    if (Idx >= 0) and (FEntries[Idx].Kind = dkFunc) then
    begin
      if Length(TFuncNode(Node).Args) <> Length(FEntries[Idx].Params) then
      begin
        Err := ceSyntax; // arity mismatch
        Exit;
      end;
      SetLength(ArgTrees, Length(TFuncNode(Node).Args));
      for I := 0 to High(ArgTrees) do
      begin
        ArgTrees[I] := ExpandCalls(TFuncNode(Node).Args[I], Depth + 1, Err);
        if Err <> ceNone then
        begin
          for J := 0 to I - 1 do
            ArgTrees[J].Free;
          Exit(nil);
        end;
      end;
      Sub := Substitute(FEntries[Idx].Body, FEntries[Idx].Params, ArgTrees);
      for I := 0 to High(ArgTrees) do
        ArgTrees[I].Free;
      Exp := ExpandCalls(Sub, Depth + 1, Err); // nested user calls
      Sub.Free;
      if Err <> ceNone then
      begin
        Exp.Free;
        Exit(nil);
      end;
      Exit(Exp);
    end;
    // builtin or unknown: expand args, keep call (evaluator decides)
    F := TFuncNode.Create(TFuncNode(Node).Name);
    for I := 0 to High(TFuncNode(Node).Args) do
    begin
      Sub := ExpandCalls(TFuncNode(Node).Args[I], Depth + 1, Err);
      if Err <> ceNone then
      begin
        F.Free;
        Exit(nil);
      end;
      F.AddArg(Sub);
    end;
    Exit(F);
  end;
  if Node is TBinaryNode then
  begin
    Sub := ExpandCalls(TBinaryNode(Node).Left, Depth + 1, Err);
    if Err <> ceNone then
    begin
      Sub.Free;
      Exit(nil);
    end;
    Exp := ExpandCalls(TBinaryNode(Node).Right, Depth + 1, Err);
    if Err <> ceNone then
    begin
      Sub.Free;
      Exp.Free;
      Exit(nil);
    end;
    Exit(TBinaryNode.Create(TBinaryNode(Node).Op, Sub, Exp));
  end;
  if Node is TUnaryNode then
  begin
    Sub := ExpandCalls(TUnaryNode(Node).Child, Depth + 1, Err);
    if Err <> ceNone then
    begin
      Sub.Free;
      Exit(nil);
    end;
    Exit(TUnaryNode.Create(TUnaryNode(Node).Op, Sub));
  end;
  if Node is TVarNode then
    Exit(TVarNode.Create(TVarNode(Node).Name));
  if Node is TNumberNode then
    Exit(TNumberNode.Create(TNumberNode(Node).Value));
  if Node is TAssignNode then
  begin
    Sub := ExpandCalls(TAssignNode(Node).Expr, Depth + 1, Err);
    if Err <> ceNone then
    begin
      Sub.Free;
      Exit(nil);
    end;
    Exit(TAssignNode.Create(TAssignNode(Node).Name, Sub));
  end;
  // definitions are stored, not expanded
  Exit(Node.Clone());
end;

function TDepStore.EvalVarIdx(Idx: Integer; out V: Double;
  out Err: TCalcError): Boolean;
var
  I: Integer;
  Exp: TASTNode;
begin
  Result := False;
  V := 0;
  if not FEntries[Idx].Dirty and FEntries[Idx].HasValue then
  begin
    V := FEntries[Idx].Value;
    Err := ceNone;
    Exit(True);
  end;
  if not PushVisit(FEntries[Idx].Name) then
  begin
    Err := ceUnsupported; // dependency cycle
    Exit;
  end;
  try
    // recompute transitive var dependencies first
    for I := 0 to High(FEntries) do
    begin
      if (I <> Idx) and (FEntries[I].Kind = dkVar) and
        RefsName(FEntries[Idx].Body, FEntries[I].Name) then
      begin
        if not EvalVarIdx(I, V, Err) then
          Exit;
        FCtx.SetVar(FEntries[I].Name, FEntries[I].Value);
      end;
    end;
    Exp := ExpandCalls(FEntries[Idx].Body, 0, Err);
    if Err <> ceNone then
    begin
      Exp.Free;
      Exit;
    end;
    try
      V := EvalNode(Exp, FCtx, Err);
      if Err <> ceNone then
        Exit;
    finally
      Exp.Free;
    end;
    FEntries[Idx].Value := V;
    FEntries[Idx].HasValue := True;
    FEntries[Idx].Dirty := False;
    FCtx.SetVar(FEntries[Idx].Name, V);
    Result := True;
  finally
    PopVisit;
  end;
end;

function TDepStore.EvalVar(const Name: string; out V: Double;
  out Err: TCalcError): Boolean;
var
  Idx: Integer;
begin
  Idx := Find(Name);
  if (Idx < 0) or (FEntries[Idx].Kind <> dkVar) then
  begin
    V := 0;
    Err := ceUnknownVariable;
    Exit(False);
  end;
  Result := EvalVarIdx(Idx, V, Err);
end;

function TDepStore.EvalFunc(const Name: string; const Args: array of Double;
  out V: Double; out Err: TCalcError): Boolean;
var
  Idx, I: Integer;
  Had: array of Boolean;
  Old: array of Double;
  Exp: TASTNode;
  ArgNodes: array of TASTNode;
  Sub: TASTNode;
begin
  Result := False;
  V := 0;
  Idx := Find(Name);
  if (Idx < 0) or (FEntries[Idx].Kind <> dkFunc) then
  begin
    Err := ceUnknownFunction;
    Exit;
  end;
  if Length(Args) <> Length(FEntries[Idx].Params) then
  begin
    Err := ceSyntax;
    Exit;
  end;
  if not PushVisit(Name) then
  begin
    Err := ceUnsupported; // recursive call cycle
    Exit;
  end;
  // materialize variable dependencies first (Define is lazy; the context
  // may not have them yet). Params bind after, so they win on collision.
  for I := 0 to High(FEntries) do
  begin
    if (FEntries[I].Kind = dkVar) and
      RefsName(FEntries[Idx].Body, FEntries[I].Name) then
    begin
      if not EvalVarIdx(I, V, Err) then
        Exit;
    end;
  end;
  SetLength(Had, Length(Args));
  SetLength(Old, Length(Args));
  SetLength(ArgNodes, Length(Args));
  try
    for I := 0 to High(Args) do
    begin
      Had[I] := FCtx.GetVar(FEntries[Idx].Params[I], Old[I]);
      FCtx.SetVar(FEntries[Idx].Params[I], Args[I]);
      ArgNodes[I] := TNumberNode.Create(Args[I]);
    end;
    Sub := Substitute(FEntries[Idx].Body, FEntries[Idx].Params, ArgNodes);
    for I := 0 to High(ArgNodes) do
      ArgNodes[I].Free;
    Exp := ExpandCalls(Sub, 0, Err);
    Sub.Free;
    if Err <> ceNone then
    begin
      Exp.Free;
      Exit;
    end;
    try
      V := EvalNode(Exp, FCtx, Err);
      if Err <> ceNone then
        Exit;
    finally
      Exp.Free;
    end;
    Result := True;
  finally
    for I := 0 to High(Args) do
    begin
      if Had[I] then
        FCtx.SetVar(FEntries[Idx].Params[I], Old[I])
      else
        FCtx.DelVar(FEntries[Idx].Params[I]);
    end;
    PopVisit;
  end;
end;

function TDepStore.EnsureRefs(Node: TASTNode; out Err: TCalcError): Boolean;
var
  I: Integer;
  V: Double;
begin
  Result := False;
  Err := ceNone;
  for I := 0 to High(FEntries) do
  begin
    if (FEntries[I].Kind = dkVar) and RefsName(Node, FEntries[I].Name) then
    begin
      if not EvalVarIdx(I, V, Err) then
        Exit;
    end;
  end;
  Result := True;
end;

function TDepStore.EvalExpr(const Text: string; out V: Double;
  out Err: TCalcError; out ErrPos: Integer): Boolean;
var
  Root, Exp: TASTNode;
  I: Integer;
begin
  Result := False;
  V := 0;
  if not ParseExpression(Text, Root, Err, ErrPos) then
    Exit;
  try
    // refresh dirty vars that this expression references
    for I := 0 to High(FEntries) do
    begin
      if (FEntries[I].Kind = dkVar) and RefsName(Root, FEntries[I].Name) then
      begin
        if not EvalVarIdx(I, V, Err) then
        begin
          ErrPos := 0;
          Exit;
        end;
      end;
    end;
    Exp := ExpandCalls(Root, 0, Err);
    if Err <> ceNone then
    begin
      Exp.Free;
      ErrPos := 0;
      Exit;
    end;
    try
      V := EvalNode(Exp, FCtx, Err);
      if Err <> ceNone then
      begin
        ErrPos := 0;
        Exit;
      end;
    finally
      Exp.Free;
    end;
    FCtx.Ans := V;
    FCtx.HasAns := True;
    ErrPos := 0;
    Result := True;
  finally
    Root.Free;
  end;
end;

function TDepStore.EntryCount: Integer;
begin
  Result := Length(FEntries);
end;

function TDepStore.EntryName(I: Integer): string;
begin
  Result := FEntries[I].Name;
end;

function TDepStore.EntryKind(I: Integer): TDepKind;
begin
  Result := FEntries[I].Kind;
end;

function TDepStore.EntryText(I: Integer): string;
var
  J: Integer;
begin
  if FEntries[I].Kind = dkFunc then
  begin
    Result := FEntries[I].Name + '(';
    for J := 0 to High(FEntries[I].Params) do
    begin
      if J > 0 then
        Result := Result + ',';
      Result := Result + FEntries[I].Params[J];
    end;
    Result := Result + ') = ' + Pretty(FEntries[I].Body);
  end
  else
    Result := FEntries[I].Name + ' = ' + Pretty(FEntries[I].Body);
end;

end.
