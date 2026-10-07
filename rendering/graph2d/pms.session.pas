{ Session management and sharing (Phase 40): versioned JSON save/load
  plus URL-hash share states — no backend. JSON is hand-rolled (writer +
  recursive parser, depth-capped): zero RTL/header dependencies so the
  same unit compiles under FPC and Pas2JS, with locale-independent
  number formatting either way. Definitions persist as *text*
  (re-parsed on load), so sessions survive grammar evolution. }
unit PMS.Session;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Classes, PMS.Types, PMS.AST, PMS.Workspace, PMS.Viewport;

type
  TJsonKind = (jkNull, jkBool, jkNum, jkStr, jkArr, jkObj);

  TJsonVal = record
    Kind: TJsonKind;
    B: Boolean;
    N: Double;
    S: string;
    A: array of TJsonVal;
    K: array of string;
    V: array of TJsonVal;
  end;

function JsonParse(const Text: string; out V: TJsonVal;
  out ErrPos: Integer): Boolean;
function JsonStringify(const V: TJsonVal): string;
function JsonStr(const S: string): TJsonVal;
function JsonNum(N: Double): TJsonVal;
function JsonBool(B: Boolean): TJsonVal;
function JsonArr: TJsonVal;
function JsonObj: TJsonVal;
procedure JsonArrAdd(var A: TJsonVal; const Item: TJsonVal);
procedure JsonObjAdd(var O: TJsonVal; const Key: string; const Item: TJsonVal);
function JsonObjGet(const O: TJsonVal; const Key: string;
  out Item: TJsonVal): Boolean;

function SessionSave(WS: TWorkspace; const V: TViewport; AngleMode: Integer;
  out JSON: string): Boolean;
function SessionLoad(const JSON: string; WS: TWorkspace; out V: TViewport;
  out AngleMode: Integer; out Err: TCalcError): Boolean;
function SessionToHash(const JSON: string): string;
function SessionFromHash(const Hash: string; out JSON: string;
  out Err: TCalcError): Boolean;

implementation

var
  DotFS: TFormatSettings;

function JsonStr(const S: string): TJsonVal;
begin
  Result.Kind := jkStr;
  Result.S := S;
end;

function JsonNum(N: Double): TJsonVal;
begin
  Result.Kind := jkNum;
  Result.N := N;
end;

function JsonBool(B: Boolean): TJsonVal;
begin
  Result.Kind := jkBool;
  Result.B := B;
end;

function JsonArr: TJsonVal;
begin
  Result.Kind := jkArr;
  SetLength(Result.A, 0);
end;

function JsonObj: TJsonVal;
begin
  Result.Kind := jkObj;
  SetLength(Result.K, 0);
  SetLength(Result.V, 0);
end;

procedure JsonArrAdd(var A: TJsonVal; const Item: TJsonVal);
begin
  SetLength(A.A, Length(A.A) + 1);
  A.A[High(A.A)] := Item;
end;

procedure JsonObjAdd(var O: TJsonVal; const Key: string; const Item: TJsonVal);
begin
  SetLength(O.K, Length(O.K) + 1);
  SetLength(O.V, Length(O.V) + 1);
  O.K[High(O.K)] := Key;
  O.V[High(O.V)] := Item;
end;

function JsonObjGet(const O: TJsonVal; const Key: string;
  out Item: TJsonVal): Boolean;
var
  I: Integer;
begin
  if O.Kind <> jkObj then
    Exit(False);
  for I := 0 to High(O.K) do
    if O.K[I] = Key then
    begin
      Item := O.V[I];
      Exit(True);
    end;
  Result := False;
end;

procedure EscStr(const S: string; out R: string);
var
  I: Integer;
  C: Char;
begin
  R := '"';
  for I := 1 to Length(S) do
  begin
    C := S[I];
    case C of
      '"': R := R + '\"';
      '\': R := R + '\\';
      #8: R := R + '\b';
      #9: R := R + '\t';
      #10: R := R + '\n';
      #12: R := R + '\f';
      #13: R := R + '\r';
    else
      if Ord(C) < 32 then
        R := R + '\u' + IntToHex(Ord(C), 4)
      else
        R := R + C;
    end;
  end;
  R := R + '"';
end;

function JsonStringify(const V: TJsonVal): string;
var
  I: Integer;
  S: string;
begin
  case V.Kind of
    jkNull: Result := 'null';
    jkBool:
      if V.B then
        Result := 'true'
      else
        Result := 'false';
    jkNum: Result := Format('%.15g', [V.N], DotFS);
    jkStr:
    begin
      EscStr(V.S, S);
      Result := S;
    end;
    jkArr:
    begin
      Result := '[';
      for I := 0 to High(V.A) do
      begin
        if I > 0 then
          Result := Result + ',';
        Result := Result + JsonStringify(V.A[I]);
      end;
      Result := Result + ']';
    end;
    jkObj:
    begin
      Result := '{';
      for I := 0 to High(V.K) do
      begin
        if I > 0 then
          Result := Result + ',';
        EscStr(V.K[I], S);
        Result := Result + S + ':' + JsonStringify(V.V[I]);
      end;
      Result := Result + '}';
    end;
  end;
end;

type
  TJsonParser = class
  public
    Text: string;
    Pos: Integer;
    constructor Create(const T: string);
    procedure SkipWS;
    function AtEnd: Boolean;
    function ParseValue(Depth: Integer; out V: TJsonVal): Boolean;
    function ParseStr(out S: string): Boolean;
    function ParseNum(out N: Double): Boolean;
    function ParseLit(const Lit: string): Boolean;
  end;

constructor TJsonParser.Create(const T: string);
begin
  inherited Create;
  Text := T;
  Pos := 1;
end;

procedure TJsonParser.SkipWS;
begin
  while (Pos <= Length(Text)) and (Text[Pos] in [' ', #9, #10, #13]) do
    Inc(Pos);
end;

function TJsonParser.AtEnd: Boolean;
begin
  Result := Pos > Length(Text);
end;

function TJsonParser.ParseLit(const Lit: string): Boolean;
begin
  if Copy(Text, Pos, Length(Lit)) = Lit then
  begin
    Inc(Pos, Length(Lit));
    Exit(True);
  end;
  Result := False;
end;

function TJsonParser.ParseStr(out S: string): Boolean;
var
  C: Char;
  Code: Integer;
  Hex: string;
begin
  Result := False;
  S := '';
  if AtEnd or (Text[Pos] <> '"') then
    Exit;
  Inc(Pos);
  while not AtEnd do
  begin
    C := Text[Pos];
    if C = '"' then
    begin
      Inc(Pos);
      Exit(True);
    end;
    if C = '\' then
    begin
      Inc(Pos);
      if AtEnd then
        Exit;
      case Text[Pos] of
        '"': S := S + '"';
        '\': S := S + '\';
        '/': S := S + '/';
        'b': S := S + #8;
        'f': S := S + #12;
        'n': S := S + #10;
        'r': S := S + #13;
        't': S := S + #9;
        'u':
        begin
          if Pos + 4 > Length(Text) then
            Exit;
          Hex := Copy(Text, Pos + 1, 4);
          if not TryStrToInt('$' + Hex, Code) then
            Exit;
          if Code < $80 then
            S := S + Chr(Code)
          else if Code < $800 then
            S := S + Chr($C0 or (Code shr 6)) + Chr($80 or (Code and $3F))
          else
            S := S + Chr($E0 or (Code shr 12)) +
              Chr($80 or ((Code shr 6) and $3F)) + Chr($80 or (Code and $3F));
          Inc(Pos, 4);
        end;
      else
        Exit; // invalid escape
      end;
      Inc(Pos);
      Continue;
    end;
    if Ord(C) < 32 then
      Exit; // raw control chars are invalid JSON
    S := S + C;
    Inc(Pos);
  end;
end;

function TJsonParser.ParseNum(out N: Double): Boolean;
var
  Start: Integer;
begin
  Result := False;
  Start := Pos;
  if (Pos <= Length(Text)) and ((Text[Pos] = '-') or (Text[Pos] = '+')) then
    Inc(Pos);
  while (Pos <= Length(Text)) and (Text[Pos] in ['0'..'9']) do
    Inc(Pos);
  if (Pos <= Length(Text)) and (Text[Pos] = '.') then
  begin
    Inc(Pos);
    while (Pos <= Length(Text)) and (Text[Pos] in ['0'..'9']) do
      Inc(Pos);
  end;
  if (Pos <= Length(Text)) and ((Text[Pos] = 'e') or (Text[Pos] = 'E')) then
  begin
    Inc(Pos);
    if (Pos <= Length(Text)) and ((Text[Pos] = '-') or (Text[Pos] = '+')) then
      Inc(Pos);
    while (Pos <= Length(Text)) and (Text[Pos] in ['0'..'9']) do
      Inc(Pos);
  end;
  if Pos = Start then
    Exit;
  Result := TryStrToFloat(Copy(Text, Start, Pos - Start), N, DotFS);
end;

function TJsonParser.ParseValue(Depth: Integer; out V: TJsonVal): Boolean;
var
  K: string;
  Item: TJsonVal;
begin
  Result := False;
  if Depth > 32 then
    Exit;
  SkipWS;
  if AtEnd then
    Exit;
  case Text[Pos] of
    '{':
    begin
      Inc(Pos);
      V := JsonObj;
      SkipWS;
      if not AtEnd and (Text[Pos] = '}') then
      begin
        Inc(Pos);
        Exit(True);
      end;
      while True do
      begin
        SkipWS;
        if not ParseStr(K) then
          Exit;
        SkipWS;
        if AtEnd or (Text[Pos] <> ':') then
          Exit;
        Inc(Pos);
        if not ParseValue(Depth + 1, Item) then
          Exit;
        JsonObjAdd(V, K, Item);
        SkipWS;
        if AtEnd then
          Exit;
        if Text[Pos] = '}' then
        begin
          Inc(Pos);
          Exit(True);
        end;
        if Text[Pos] <> ',' then
          Exit;
        Inc(Pos);
      end;
    end;
    '[':
    begin
      Inc(Pos);
      V := JsonArr;
      SkipWS;
      if not AtEnd and (Text[Pos] = ']') then
      begin
        Inc(Pos);
        Exit(True);
      end;
      while True do
      begin
        if not ParseValue(Depth + 1, Item) then
          Exit;
        JsonArrAdd(V, Item);
        SkipWS;
        if AtEnd then
          Exit;
        if Text[Pos] = ']' then
        begin
          Inc(Pos);
          Exit(True);
        end;
        if Text[Pos] <> ',' then
          Exit;
        Inc(Pos);
      end;
    end;
    '"':
    begin
      if not ParseStr(K) then
        Exit;
      V := JsonStr(K);
      Exit(True);
    end;
    't':
    begin
      if not ParseLit('true') then
        Exit;
      V := JsonBool(True);
      Exit(True);
    end;
    'f':
    begin
      if not ParseLit('false') then
        Exit;
      V := JsonBool(False);
      Exit(True);
    end;
    'n':
    begin
      if not ParseLit('null') then
        Exit;
      V.Kind := jkNull;
      Exit(True);
    end;
  else
    if not ParseNum(V.N) then
      Exit;
    V.Kind := jkNum;
    Exit(True);
  end;
end;

function JsonParse(const Text: string; out V: TJsonVal;
  out ErrPos: Integer): Boolean;
var
  P: TJsonParser;
begin
  P := TJsonParser.Create(Text);
  try
    Result := P.ParseValue(0, V);
    if Result then
    begin
      P.SkipWS;
      if not P.AtEnd then
        Result := False; // trailing garbage
    end;
    if Result then
      ErrPos := 0
    else
      ErrPos := P.Pos;
  finally
    P.Free;
  end;
end;

function SessionSave(WS: TWorkspace; const V: TViewport; AngleMode: Integer;
  out JSON: string): Boolean;
var
  Root, E, J, Vp: TJsonVal;
  I: Integer;
begin
  Result := False;
  Root := JsonObj;
  JsonObjAdd(Root, 'schemaVersion', JsonNum(1));
  JsonObjAdd(Root, 'app', JsonStr('PascalMath Studio'));
  E := JsonArr;
  for I := 0 to WS.EntryCount - 1 do
  begin
    J := JsonObj;
    JsonObjAdd(J, 'text', JsonStr(WS.EntryRawText(I)));
    JsonObjAdd(J, 'kind', JsonNum(Ord(WS.EntryKind(I))));
    JsonObjAdd(J, 'visible', JsonBool(WS.EntryVisible(I)));
    JsonArrAdd(E, J);
  end;
  JsonObjAdd(Root, 'entries', E);
  E := JsonArr;
  for I := 0 to WS.Store.EntryCount - 1 do
    JsonArrAdd(E, JsonStr(WS.Store.EntryText(I)));
  JsonObjAdd(Root, 'vars', E);
  Vp := JsonObj;
  JsonObjAdd(Vp, 'xmin', JsonNum(V.XMin));
  JsonObjAdd(Vp, 'xmax', JsonNum(V.XMax));
  JsonObjAdd(Vp, 'ymin', JsonNum(V.YMin));
  JsonObjAdd(Vp, 'ymax', JsonNum(V.YMax));
  JsonObjAdd(Root, 'viewport', Vp);
  JsonObjAdd(Root, 'angle', JsonNum(AngleMode));
  JSON := JsonStringify(Root);
  Result := True;
end;

function GetNum(const O: TJsonVal; const Key: string; out N: Double): Boolean;
var
  It: TJsonVal;
begin
  Result := JsonObjGet(O, Key, It) and (It.Kind = jkNum);
  if Result then
    N := It.N;
end;

function SessionLoad(const JSON: string; WS: TWorkspace; out V: TViewport;
  out AngleMode: Integer; out Err: TCalcError): Boolean;
var
  Root, It, E2: TJsonVal;
  P, I: Integer;
  Ver, N: Double;
  Tx: string;
  Kind: Integer;
  Vis: Boolean;
begin
  Result := False;
  Err := ceNone;
  if not JsonParse(JSON, Root, P) then
  begin
    Err := ceSyntax;
    Exit;
  end;
  if (Root.Kind <> jkObj) or not GetNum(Root, 'schemaVersion', Ver) or
    (Trunc(Ver) <> 1) then
  begin
    Err := ceUnsupported; // unknown schema: refuse, don't guess
    Exit;
  end;
  WS.ClearEntries;
  if JsonObjGet(Root, 'vars', It) and (It.Kind = jkArr) then
  begin
    for I := 0 to High(It.A) do
    begin
      if It.A[I].Kind <> jkStr then
        Continue; // forward-compatible: skip what we don't know
      if not WS.DefineVar(It.A[I].S, Err, P) then
        Exit(False);
    end;
  end;
  if JsonObjGet(Root, 'entries', It) and (It.Kind = jkArr) then
  begin
    for I := 0 to High(It.A) do
    begin
      if (It.A[I].Kind <> jkObj) or not JsonObjGet(It.A[I], 'text', E2) or
        (E2.Kind <> jkStr) then
        Continue;
      Tx := E2.S;
      Kind := 0;
      if JsonObjGet(It.A[I], 'kind', E2) and (E2.Kind = jkNum) then
        Kind := Trunc(E2.N);
      if (Kind < 0) or (Kind > 3) then
        Kind := 0;
      if WS.AddExpr(Tx, TWSKind(Kind), Err, P) < 0 then
        Exit(False);
      Vis := True;
      if JsonObjGet(It.A[I], 'visible', E2) and (E2.Kind = jkBool) then
        Vis := E2.B;
      WS.SetVisible(WS.EntryCount - 1, Vis);
    end;
  end;
  if JsonObjGet(Root, 'viewport', It) and (It.Kind = jkObj) then
  begin
    if GetNum(It, 'xmin', N) then
      V.XMin := N;
    if GetNum(It, 'xmax', N) then
      V.XMax := N;
    if GetNum(It, 'ymin', N) then
      V.YMin := N;
    if GetNum(It, 'ymax', N) then
      V.YMax := N;
  end;
  AngleMode := 0;
  if GetNum(Root, 'angle', N) and (Trunc(N) >= 0) and (Trunc(N) <= 2) then
    AngleMode := Trunc(N);
  Result := True;
end;

function UrlEncode(const S: string): string;
var
  I: Integer;
  C: Byte;
const
  Unres = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_.~';
begin
  Result := '';
  for I := 1 to Length(S) do
  begin
    C := Byte(S[I]);
    if Pos(Char(C), Unres) > 0 then
      Result := Result + Char(C)
    else
      Result := Result + '%' + IntToHex(C, 2);
  end;
end;

function UrlDecode(const S: string; out R: string): Boolean;
var
  I, Code: Integer;
begin
  Result := False;
  R := '';
  I := 1;
  while I <= Length(S) do
  begin
    if S[I] = '%' then
    begin
      if (I + 2 > Length(S)) or not TryStrToInt('$' + Copy(S, I + 1, 2), Code) then
        Exit;
      R := R + Chr(Code);
      Inc(I, 3);
    end
    else
    begin
      R := R + S[I];
      Inc(I);
    end;
  end;
  Result := True;
end;

function SessionToHash(const JSON: string): string;
begin
  Result := '#' + UrlEncode(JSON);
end;

function SessionFromHash(const Hash: string; out JSON: string;
  out Err: TCalcError): Boolean;
var
  S: string;
begin
  Result := False;
  Err := ceNone;
  S := Hash;
  if (S <> '') and (S[1] = '#') then
    Delete(S, 1, 1);
  if not UrlDecode(S, JSON) then
  begin
    Err := ceSyntax;
    Exit;
  end;
  Result := True;
end;

initialization
  DotFS := DefaultFormatSettings;
  DotFS.DecimalSeparator := '.';

end.
