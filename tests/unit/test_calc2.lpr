{ Assert-runner: NDiff + IntNum + Solve + Limits (Phases 21, 22, 24, 25). }
program test_calc2;

{$mode objfpc}{$H+}

uses
  SysUtils, Math, PMS.Types, PMS.AST, PMS.Parser, PMS.Eval, PMS.DiffNum,
  PMS.IntNum, PMS.Solve, PMS.Limits, PMS.Complex;

var
  Fails: Integer = 0;
  Ctx: TEvalContext;

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

procedure CheckNDiff;
var
  N: TASTNode;
  E: TCalcError;
begin
  N := TreeOf('x^2');
  Check(Abs(NDiffCentral(N, 'x', 3, DefaultH(3), Ctx, E) - 6) < 1e-4, 'central d/dx x^2 at 3');
  Check(E = ceNone, 'central no error');
  Check(Abs(NDiffForward(N, 'x', 3, 1e-5, Ctx, E) - 6) < 1e-3, 'forward diff');
  Check(Abs(NDiffBackward(N, 'x', 3, 1e-5, Ctx, E) - 6) < 1e-3, 'backward diff');
  N.Free;
  N := TreeOf('sin(x)');
  Check(Abs(NDiffCentral(N, 'x', 0, DefaultH(0), Ctx, E) - 1) < 1e-6, 'central d/dx sin at 0');
  N.Free;
end;

procedure CheckIntNum;
var
  N: TASTNode;
  E: TCalcError;
begin
  N := TreeOf('x^2');
  Check(Abs(ISimp(N, 'x', 0, 1, 100, Ctx, E) - 1 / 3) < 1e-9, 'simpson x^2');
  Check(Abs(ITrap(N, 'x', 0, 1, 1000, Ctx, E) - 1 / 3) < 1e-4, 'trapezoid x^2');
  Check(Abs(IAdaptSimp(N, 'x', 0, 1, 1e-9, Ctx, E) - 1 / 3) < 1e-9, 'adaptive x^2');
  N.Free;
  N := TreeOf('sin(x)');
  Check(Abs(IAdaptSimp(N, 'x', 0, Pi, 1e-9, Ctx, E) - 2) < 1e-7, 'adaptive sin 0..pi');
  N.Free;
end;

procedure CheckSolve;
var
  N: TASTNode;
  E: TCalcError;
  Root: Double;
  Iters: Integer;
  R1, R2: TComplex;
  NR: Integer;
begin
  N := TreeOf('x^2-4');
  Check(SolveBisection(N, 'x', 1, 3, 1e-9, Ctx, Root, Iters, E) and
    (Abs(Root - 2) < 1e-7), 'bisection sqrt(4)');
  N.Free;
  N := TreeOf('x^2-2');
  Check(SolveNewton(N, 'x', 1, 1e-9, Ctx, Root, Iters, E) and
    (Abs(Root - Sqrt(2)) < 1e-7), 'newton sqrt(2), iters=' + IntToStr(Iters));
  Check(SolveSecant(N, 'x', 1, 2, 1e-9, Ctx, Root, Iters, E) and
    (Abs(Root - Sqrt(2)) < 1e-7), 'secant sqrt(2)');
  N.Free;
  N := TreeOf('2*x+5');
  Check(SolveLinear(N, 'x', Ctx, Root, E) and (Abs(Root + 2.5) < 1e-9),
    'linear 2x+5 root -2.5');
  N.Free;
  N := TreeOf('sin(x)');
  Check(not SolveLinear(N, 'x', Ctx, Root, E) and (E = ceUnsupported),
    'linear rejects sin(x)');
  N.Free;
  N := TreeOf('x^2-5*x+6');
  Check(SolvePoly2(N, 'x', Ctx, R1, R2, NR, E) and (NR = 2) and
    (Abs(R1.Re - 3) < 1e-9) and (Abs(R2.Re - 2) < 1e-9) and
    (Abs(R1.Im) < 1e-9) and (Abs(R2.Im) < 1e-9), 'quadratic roots 3,2');
  N.Free;
  N := TreeOf('x^2+1');
  Check(SolvePoly2(N, 'x', Ctx, R1, R2, NR, E) and (NR = 2) and
    (Abs(R1.Re) < 1e-9) and (Abs(R1.Im - 1) < 1e-9) and
    (Abs(R2.Im + 1) < 1e-9), 'quadratic roots +i,-i');
  N.Free;
end;

procedure CheckLimits;
var
  N: TASTNode;
  E: TCalcError;
  V: Double;
begin
  N := TreeOf('sin(x)/x');
  Check(Limit(N, 'x', 0, Ctx, V, E) and (Abs(V - 1) < 1e-4), 'lim sin(x)/x = 1');
  N.Free;
  N := TreeOf('x^2');
  Check(Limit(N, 'x', 3, Ctx, V, E) and (Abs(V - 9) < 1e-9), 'direct limit');
  N.Free;
  N := TreeOf('1/x');
  Check(not Limit(N, 'x', 0, Ctx, V, E) and (E = ceNoConvergence),
    'two-sided 1/x honestly diverges');
  N.Free;
end;

begin
  Ctx := TEvalContext.Create;
  try
    CheckNDiff;
    CheckIntNum;
    CheckSolve;
    CheckLimits;
  finally
    Ctx.Free;
  end;
  if Fails > 0 then
  begin
    WriteLn(Fails, ' FAILURES');
    Halt(1);
  end;
  WriteLn('All calculus/solver tests passed.');
end.
