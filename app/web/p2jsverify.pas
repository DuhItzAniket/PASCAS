{ Pas2JS verification: runs the Pascal core IN JavaScript (Node) and
  checks golden behavior. Executed by scripts/verify_web.py in CI. }
program p2jsverify;
{$mode objfpc}{$H+}
uses
  SysUtils, PMS.Types, PMS.AST, PMS.Parser, PMS.ASTUtils, PMS.Eval,
  PMS.Simplify, PMS.DiffSym, PMS.Workspace, PMS.Viewport, PMS.Sampler,
  PMS.Session;

var
  Fails: Integer = 0;
  Ctx: TEvalContext;

procedure Check(C: Boolean; const M: string);
begin
  if C then
    WriteLn('ok: ', M)
  else
  begin
    Inc(Fails);
    WriteLn('FAIL: ', M);
  end;
end;

function EV(const S: string; out V: Double): TCalcError;
var
  E: TCalcError;
  P: Integer;
begin
  if EvalText(S, Ctx, V, E, P) then
    Result := ceNone
  else
    Result := E;
end;

var
  V: Double;
  E: TCalcError;
  P: Integer;
  N, S, D: TASTNode;
  W: TWorkspace;
  Vw: TViewport;
  Lines: TSampleLines;
  J: string;
begin
  Ctx := TEvalContext.Create;
  Check((EV('2 + 3 * 4', V) = ceNone) and (V = 14), 'arith');
  Check((EV('sin(pi/2)', V) = ceNone) and (Abs(V - 1) < 1e-12), 'sin');
  Check((EV('1/3 + 1/6', V) = ceNone) and (Abs(V - 0.5) < 1e-12), 'thirds');
  Check((EV('5!', V) = ceNone) and (V = 120), 'fact');
  Check(EV('1/0', V) = ceDivisionByZero, 'div0');
  Check(EV('nope+1', V) = ceUnknownVariable, 'unkvar');
  Check(EV('a = 7', V) = ceNone, 'assign');
  Check((EV('a*2', V) = ceNone) and (V = 14), 'var');

  ParseExpression('x + 0', N, E, P);
  S := Simplify(N, Ctx);
  Check(Pretty(S) = 'x', 'simplify');
  S.Free;
  N.Free;
  ParseExpression('x^2', N, E, P);
  D := Differentiate(N, 'x', Ctx, E);
  Check((E = ceNone) and (Pretty(D) = '2*x'), 'diff');
  D.Free;
  N.Free;

  W := TWorkspace.Create;
  Vw := VDefault(800, 600);
  Check(W.AddExpr('sin(x)', wkFuncY, E, P) = 0, 'ws add');
  Lines := W.SampleEntry(0, Vw, E);
  Check((E = ceNone) and (Length(Lines) > 0) and (Length(Lines[0]) > 700),
    'ws sample');
  Check(SessionSave(W, Vw, 0, J) and (Length(J) > 50), 'session save');
  W.Free;

  Ctx.Free;
  if Fails = 0 then
    WriteLn('WEB-VERIFY ALL PASS')
  else
    WriteLn('WEB-VERIFY FAILURES=', Fails);
end.
