{ Assert-runner for PMS.ASTUtils (Phase 09). }
program test_astutils;

{$mode objfpc}{$H+}

uses
  SysUtils, PMS.Types, PMS.AST, PMS.Parser, PMS.ASTUtils;

var
  Fails: Integer = 0;
  WalkSeen: Integer = 0;

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

function TreeOf(const Src: string): TASTNode;
var
  E: TCalcError;
  P: Integer;
begin
  if not ParseExpression(Src, Result, E, P) then
  begin
    WriteLn('  (parse failed: ', Src, ')');
    Result := nil;
  end;
end;

procedure Counter(N: TASTNode);
begin
  Inc(WalkSeen);
end;

var
  N: TASTNode;
begin
  N := TreeOf('2 + 3 * 4');
  Check(Pretty(N) = '2+3*4', 'pretty precedence: ' + Pretty(N));
  Check(Serialize(N) = '(+ 2 (* 3 4))', 'sexpr: ' + Serialize(N));
  Check(NodeCount(N) = 5, 'count 5');
  Check(TreeDepth(N) = 3, 'depth 3');
  WalkSeen := 0;
  Walk(N, @Counter);
  Check(WalkSeen = 5, 'walk visits 5');
  N.Free;

  N := TreeOf('(2+3)*4');
  Check(Pretty(N) = '(2+3)*4', 'pretty parens: ' + Pretty(N));
  N.Free;

  N := TreeOf('-2^2');
  Check(Pretty(N) = '-(2^2)', 'pretty unary power: ' + Pretty(N));
  N.Free;

  N := TreeOf('2sin(x)');
  Check(Pretty(N) = '2*sin(x)', 'pretty implicit: ' + Pretty(N));
  N.Free;

  N := TreeOf('a=2');
  Check(Pretty(N) = 'a=2', 'pretty assign');
  Check(NodeCount(N) = 2, 'assign count');
  N.Free;

  N := TreeOf('7 mod 3');
  Check(Pretty(N) = '7 mod 3', 'pretty mod');
  N.Free;

  if Fails > 0 then
  begin
    WriteLn(Fails, ' FAILURES');
    Halt(1);
  end;
  WriteLn('All astutils tests passed.');
end.
