{ Assert-runner for PMS.Parser (+ PMS.AST shapes). }
program test_parser;

{$mode objfpc}{$H+}

uses
  SysUtils, PMS.Types, PMS.AST, PMS.Parser;

var
  Fails: Integer = 0;

procedure Check(Cond: Boolean; const Msg: string);
begin
  if Cond then
    WriteLn('ok: ', Msg)
  else
  begin
    Inc(Fails);
    WriteLn('FAIL: ', Msg);
  end;
end;

function ParseOk(const Src: string; out Root: TASTNode): Boolean;
var
  E: TCalcError;
  P: Integer;
begin
  Result := ParseExpression(Src, Root, E, P);
  if not Result then
    WriteLn('  (parse failed: ', Src, ' err=', Ord(E), ' pos=', P, ')');
end;

function AsBin(N: TASTNode; Op: Char; out L, R: TASTNode): Boolean;
begin
  Result := (N is TBinaryNode) and (TBinaryNode(N).Op = Op);
  if Result then
  begin
    L := TBinaryNode(N).Left;
    R := TBinaryNode(N).Right;
  end
  else
  begin
    L := nil;
    R := nil;
  end;
end;

function IsNum(N: TASTNode; V: Double): Boolean;
begin
  Result := (N is TNumberNode) and (Abs(TNumberNode(N).Value - V) < 1e-12);
end;

var
  N, L, R: TASTNode;
  E: TCalcError;
  P: Integer;
  F: TFuncNode;
begin
  // precedence: 2 + 3 * 4 -> +(2, *(3,4))
  Check(ParseOk('2 + 3 * 4', N), 'parse 2+3*4');
  Check(AsBin(N, '+', L, R) and IsNum(L, 2) and AsBin(R, '*', L, R) and IsNum(L, 3) and IsNum(R, 4),
    'precedence shape');
  N.Free;

  // right assoc: 2^3^2 -> ^(2, ^(3,2))
  Check(ParseOk('2^3^2', N), 'parse 2^3^2');
  Check(AsBin(N, '^', L, R) and IsNum(L, 2) and AsBin(R, '^', L, R), 'power right-assoc');
  N.Free;

  // implicit mult: 2x -> *(2,x); 3(x+1); 2sin(x)
  Check(ParseOk('2x + 5', N), 'parse 2x+5');
  Check(AsBin(N, '+', L, R) and AsBin(L, '*', L, R), 'implicit 2x');
  N.Free;
  Check(ParseOk('3(x+1)', N), 'parse 3(x+1)');
  Check(AsBin(N, '*', L, R) and IsNum(L, 3), 'implicit 3(x+1)');
  N.Free;
  Check(ParseOk('2sin(x)', N), 'parse 2sin(x)');
  Check(AsBin(N, '*', L, R) and (R is TFuncNode), 'implicit 2sin(x)');
  N.Free;

  // unary: -2^2 -> -(^(2,2)); 2^-3
  Check(ParseOk('-2^2', N), 'parse -2^2');
  Check((N is TUnaryNode) and (TUnaryNode(N).Op = '-'), 'leading minus is unary');
  N.Free;
  Check(ParseOk('2^-3', N), 'parse 2^-3');
  Check(AsBin(N, '^', L, R) and (R is TUnaryNode), 'negative exponent');
  N.Free;
  Check(ParseOk('--2', N), 'parse double negation');
  Check(IsNum(N, 2), 'double negation collapses');
  N.Free;

  // postfix + mod + percent
  Check(ParseOk('5! + 50% + 7 mod 3', N), 'parse postfix/mod');
  N.Free;

  // assignment + funcdef (child shapes verified — guards FPC self-call quirk)
  Check(ParseOk('a = 2', N), 'parse a=2');
  Check((N is TAssignNode) and (TAssignNode(N).Name = 'a') and
    IsNum(TAssignNode(N).Expr, 2), 'assign shape + real child');
  N.Free;
  Check(ParseOk('a=b=2', N), 'parse chained assign');
  Check((N is TAssignNode) and (TAssignNode(N).Expr is TAssignNode) and
    IsNum(TAssignNode(TAssignNode(N).Expr).Expr, 2), 'chained assign nests right');
  N.Free;
  Check(ParseOk('f(x) = a*x^2', N), 'parse f(x)=a*x^2');
  Check((N is TFuncDefNode) and (TFuncDefNode(N).Name = 'f') and
    (Length(TFuncDefNode(N).Params) = 1), 'funcdef shape');
  N.Free;
  Check(ParseOk('f(x+1)', N), 'call with expr arg still parses');
  Check((N is TFuncNode) and (Length(TFuncNode(N).Args) = 1), 'call shape');
  N.Free;
  Check(ParseOk('max(1, 2, 3)', N), 'multi-arg call');
  F := N as TFuncNode;
  Check((F.Name = 'max') and (Length(F.Args) = 3), 'three args');
  N.Free;

  // malformed inputs must fail, never crash
  Check(not ParseExpression('', N, E, P), 'empty fails');
  Check(not ParseExpression('2+', N, E, P), 'dangling op fails');
  Check(not ParseExpression('(3', N, E, P), 'unclosed paren fails');
  Check(not ParseExpression('2**3', N, E, P), 'double star fails');
  Check(not ParseExpression('sin(,)', N, E, P), 'empty arg fails');
  Check(not ParseExpression('2 3 4 +', N, E, P), 'trailing op fails');
  N := nil;
  Check(ParseOk('2 3', N), 'juxtaposed numbers parse as mult (documented)');
  if Assigned(N) then
    N.Free;
  Check(not ParseExpression('f(x) = ', N, E, P), 'empty body fails');

  if Fails > 0 then
  begin
    WriteLn(Fails, ' FAILURES');
    Halt(1);
  end;
  WriteLn('All parser tests passed.');
end.
