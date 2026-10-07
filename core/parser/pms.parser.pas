{ Hand-written recursive-descent parser (ADR-003). Implicit multiplication
  is grammar, not preprocessing: `2x`, `3(x+1)`, `2sin(x)` parse as `*`.
  Ownership: every created node is Own()ed; linking a child into a parent
  Disown()s it. On error, owned orphans are freed exactly once; on success
  the root is released to the caller. }
unit PMS.Parser;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, PMS.Types, PMS.Lexer, PMS.AST;

{ True + Root on success (caller frees Root). False + Err/ErrPos otherwise. }
function ParseExpression(const Src: string; out Root: TASTNode;
  out Err: TCalcError; out ErrPos: Integer): Boolean;

implementation

type
  EParseError = class(Exception)
  public
    Code: TCalcError;
    Pos: Integer;
  end;

  TParser = class
  private
    FTokens: TTokenArray;
    FPos: Integer;
    FDepth: Integer;
    FOwned: array of TASTNode;
    function Peek: TToken;
    function PeekAt(Offset: Integer): TToken;
    function Next: TToken;
    function Own(N: TASTNode): TASTNode;
    procedure Disown(N: TASTNode);
    procedure FreeOwned;
    procedure CheckDepth(Pos: Integer);
    procedure Fail(Code: TCalcError; Pos: Integer);
    function IsModOp: Boolean;
    function ParseAssign: TASTNode;
    function TryParseFuncDef: TASTNode;
    function ParseAdditive: TASTNode;
    function ParseMultiplicative: TASTNode;
    function ParseImplicit: TASTNode;
    function ParseUnary: TASTNode;
    function ParsePower: TASTNode;
    function ParsePostfix: TASTNode;
    function ParsePrimary: TASTNode;
  public
    constructor Create(const Tokens: TTokenArray);
    function Run: TASTNode;
  end;

function ParseExpression(const Src: string; out Root: TASTNode;
  out Err: TCalcError; out ErrPos: Integer): Boolean;
var
  Tokens: TTokenArray;
  P: TParser;
begin
  Root := nil;
  if not Tokenize(Src, Tokens, Err, ErrPos) then
    Exit(False);
  P := TParser.Create(Tokens);
  try
    try
      Root := P.Run;
      Err := ceNone;
      ErrPos := 0;
      Result := True;
    except
      on E: EParseError do
      begin
        Root := nil;
        Err := E.Code;
        ErrPos := E.Pos;
        Result := False;
      end;
    end;
  finally
    P.Free;
  end;
end;

constructor TParser.Create(const Tokens: TTokenArray);
begin
  inherited Create;
  FTokens := Tokens;
  FPos := 0;
  FDepth := 0;
  SetLength(FOwned, 0);
end;

function TParser.Peek: TToken;
begin
  Result := PeekAt(0);
end;

function TParser.PeekAt(Offset: Integer): TToken;
var
  I: Integer;
begin
  I := FPos + Offset;
  if I >= Length(FTokens) then
    Result := FTokens[High(FTokens)]
  else
    Result := FTokens[I];
end;

function TParser.Next: TToken;
begin
  Result := Peek;
  if FPos < Length(FTokens) then
    Inc(FPos);
end;

function TParser.Own(N: TASTNode): TASTNode;
begin
  SetLength(FOwned, Length(FOwned) + 1);
  FOwned[High(FOwned)] := N;
  Result := N;
end;

procedure TParser.Disown(N: TASTNode);
var
  I: Integer;
begin
  for I := High(FOwned) downto 0 do
    if FOwned[I] = N then
    begin
      FOwned[I] := FOwned[High(FOwned)];
      SetLength(FOwned, Length(FOwned) - 1);
      Exit;
    end;
end;

procedure TParser.FreeOwned;
var
  I: Integer;
begin
  for I := High(FOwned) downto 0 do
    FOwned[I].Free;
  SetLength(FOwned, 0);
end;

procedure TParser.CheckDepth(Pos: Integer);
begin
  Inc(FDepth);
  if FDepth > PMSMaxDepth then
    Fail(ceRecursionLimit, Pos);
end;

procedure TParser.Fail(Code: TCalcError; Pos: Integer);
var
  E: EParseError;
begin
  FreeOwned;
  E := EParseError.Create('parse');
  E.Code := Code;
  E.Pos := Pos;
  raise E;
end;

function TParser.IsModOp: Boolean;
begin
  Result := (Peek.Kind = tkIdent) and (LowerCase(Peek.Text) = 'mod');
end;

function TParser.Run: TASTNode;
begin
  if Peek.Kind = tkEOF then
    Fail(ceSyntax, Peek.Pos);
  Result := ParseAssign;
  if Peek.Kind <> tkEOF then
    Fail(ceSyntax, Peek.Pos);
  Disown(Result);
  FreeOwned;
end;

function TParser.ParseAssign: TASTNode;
var
  Name: string;
  Child: TASTNode;
begin
  Result := TryParseFuncDef;
  if Assigned(Result) then
    Exit;
  if (Peek.Kind = tkIdent) and (PeekAt(1).Kind = tkEquals) then
  begin
    Name := Next.Text;
    Next;
    // NOTE (FPC objfpc): a bare self-name reads the result variable instead
    // of recursing. Parentheses force the recursive call.
    Child := ParseAssign();
    Result := Own(TAssignNode.Create(Name, Child));
    Disown(Child);
    Exit;
  end;
  Result := ParseAdditive;
end;

function TParser.TryParseFuncDef: TASTNode;
var
  I, J: Integer;
  Name: string;
  Params: array of string;
  Body: TASTNode;
  Def: TFuncDefNode;
begin
  Result := nil;
  if (PeekAt(0).Kind <> tkIdent) or (PeekAt(1).Kind <> tkLParen) then
    Exit;
  I := FPos + 2;
  SetLength(Params, 0);
  if FTokens[I].Kind <> tkRParen then
  begin
    while True do
    begin
      if (I >= Length(FTokens)) or (FTokens[I].Kind <> tkIdent) then
        Exit; // a call like f(x+1): leave FPos untouched
      SetLength(Params, Length(Params) + 1);
      Params[High(Params)] := FTokens[I].Text;
      Inc(I);
      if (I < Length(FTokens)) and (FTokens[I].Kind = tkComma) then
      begin
        Inc(I);
        Continue;
      end;
      Break;
    end;
  end;
  if (I >= Length(FTokens)) or (FTokens[I].Kind <> tkRParen) then
    Exit;
  Inc(I);
  if (I >= Length(FTokens)) or (FTokens[I].Kind <> tkEquals) then
    Exit;
  Name := FTokens[FPos].Text;
  FPos := I + 1;
  CheckDepth(FTokens[I].Pos);
  Body := ParseAssign;
  Dec(FDepth);
  Def := TFuncDefNode.Create(Name, Body);
  for J := 0 to High(Params) do
    Def.AddParam(Params[J]);
  Result := Own(Def);
  Disown(Body);
end;

function TParser.ParseAdditive: TASTNode;
var
  Left, Right: TASTNode;
  Op: Char;
begin
  Left := ParseMultiplicative;
  while (Peek.Kind = tkPlus) or (Peek.Kind = tkMinus) do
  begin
    if Peek.Kind = tkPlus then
      Op := '+'
    else
      Op := '-';
    Next;
    Right := ParseMultiplicative;
    Left := Own(TBinaryNode.Create(Op, Left, Right));
    // Left/Right now linked: drop stale entries (Left may equal old Left)
    Disown(TBinaryNode(Left).Left);
    Disown(TBinaryNode(Left).Right);
  end;
  Result := Left;
end;

function TParser.ParseMultiplicative: TASTNode;
var
  Left, Right: TASTNode;
  Op: Char;
begin
  Left := ParseImplicit;
  while (Peek.Kind = tkStar) or (Peek.Kind = tkSlash) or IsModOp do
  begin
    if Peek.Kind = tkStar then
      Op := '*'
    else if Peek.Kind = tkSlash then
      Op := '/'
    else
      Op := 'm';
    Next;
    Right := ParseImplicit;
    Left := Own(TBinaryNode.Create(Op, Left, Right));
    Disown(TBinaryNode(Left).Left);
    Disown(TBinaryNode(Left).Right);
  end;
  Result := Left;
end;

function TParser.ParseImplicit: TASTNode;
var
  Left, Right: TASTNode;
begin
  Left := ParseUnary;
  while Peek.Kind in [tkNumber, tkIdent, tkLParen] do
  begin
    if IsModOp then
      Break;
    CheckDepth(Peek.Pos);
    Right := ParseUnary;
    Left := Own(TBinaryNode.Create('*', Left, Right));
    Disown(TBinaryNode(Left).Left);
    Disown(TBinaryNode(Left).Right);
    Dec(FDepth);
  end;
  Result := Left;
end;

function TParser.ParseUnary: TASTNode;
var
  Neg: Boolean;
  Inner: TASTNode;
begin
  // Loop, not self-recursion: '--x' is '+x'. No stack growth on '-----x'.
  Neg := False;
  while (Peek.Kind = tkPlus) or (Peek.Kind = tkMinus) do
  begin
    if Peek.Kind = tkMinus then
      Neg := not Neg;
    Next;
  end;
  Inner := ParsePower;
  if Neg then
  begin
    Result := Own(TUnaryNode.Create('-', Inner));
    Disown(Inner);
  end
  else
    Result := Inner;
end;

function TParser.ParsePower: TASTNode;
var
  Base, Expo: TASTNode;
  Caret: TToken;
begin
  Base := ParsePostfix;
  if Peek.Kind = tkCaret then
  begin
    Caret := Next;
    CheckDepth(Caret.Pos);
    Expo := ParseUnary; // right-associative; 2^-3 works
    Dec(FDepth);
    Result := Own(TBinaryNode.Create('^', Base, Expo));
    Disown(Base);
    Disown(Expo);
  end
  else
    Result := Base;
end;

function TParser.ParsePostfix: TASTNode;
var
  N, Old: TASTNode;
  T: TToken;
begin
  N := ParsePrimary;
  while (Peek.Kind = tkBang) or (Peek.Kind = tkPercent) do
  begin
    T := Next;
    Old := N;
    if T.Kind = tkBang then
      N := Own(TUnaryNode.Create('!', Old))
    else
      N := Own(TUnaryNode.Create('%', Old));
    Disown(Old);
  end;
  Result := N;
end;

function TParser.ParsePrimary: TASTNode;
var
  T: TToken;
  F: TFuncNode;
  Arg: TASTNode;
begin
  T := Peek;
  case T.Kind of
    tkNumber:
    begin
      Next;
      Result := Own(TNumberNode.Create(T.NumValue));
    end;
    tkIdent:
    begin
      Next;
      if Peek.Kind = tkLParen then
      begin
        Next;
        F := TFuncNode.Create(T.Text);
        Own(F);
        if Peek.Kind <> tkRParen then
        begin
          while True do
          begin
            Arg := ParseAssign;
            F.AddArg(Arg);
            Disown(Arg);
            if Peek.Kind = tkComma then
            begin
              Next;
              Continue;
            end;
            Break;
          end;
        end;
        if Peek.Kind <> tkRParen then
          Fail(ceSyntax, Peek.Pos);
        Next;
        Result := F;
      end
      else
        Result := Own(TVarNode.Create(T.Text));
    end;
    tkLParen:
    begin
      Next;
      Result := ParseAssign;
      if Peek.Kind <> tkRParen then
        Fail(ceSyntax, Peek.Pos);
      Next;
    end;
  else
    Fail(ceSyntax, T.Pos);
    Result := nil;
  end;
end;

end.
