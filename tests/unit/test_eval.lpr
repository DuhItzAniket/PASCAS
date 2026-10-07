{ Assert-runner for PMS.Eval + PMS.Funcs + PMS.Consts (Phases 10-12). }
program test_eval;

{$mode objfpc}{$H+}

uses
  SysUtils, PMS.Types, PMS.Eval;

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

var
  Ctx: TEvalContext;

function Eval(const Src: string; out V: Double): TCalcError;
var
  E: TCalcError;
  P: Integer;
begin
  if EvalText(Src, Ctx, V, E, P) then
    Result := ceNone
  else
  begin
    Result := E;
    WriteLn('  (eval failed: ', Src, ' err=', Ord(E), ' pos=', P, ')');
  end;
end;

procedure CheckNear(const Src: string; Expected, Tol: Double);
var
  V: Double;
  E: TCalcError;
begin
  E := Eval(Src, V);
  Check((E = ceNone) and (Abs(V - Expected) <= Tol),
    Src + ' ~= ' + FloatToStr(Expected) + ' (got ' + FloatToStr(V) + ')');
end;

procedure CheckErr(const Src: string; Expected: TCalcError);
var
  V: Double;
  E: TCalcError;
  P: Integer;
begin
  if EvalText(Src, Ctx, V, E, P) then
    E := ceNone;
  Check(E = Expected, Src + ' -> err ' + IntToStr(Ord(Expected)));
end;

var
  V: Double;
begin
  Ctx := TEvalContext.Create;
  try
    // golden arithmetic
    CheckNear('2 + 2', 4, 0);
    CheckNear('2 + 3 * 4', 14, 0);
    CheckNear('2^3^2', 512, 0);
    CheckNear('-2^2', -4, 0);
    CheckNear('sqrt(25)', 5, 0);
    CheckNear('5!', 120, 0);
    CheckNear('0!', 1, 0);
    CheckNear('50%', 0.5, 1e-12);
    CheckNear('7 mod 3', 1, 0);
    CheckNear('10/4', 2.5, 0);
    CheckNear('1/3 + 1/6', 0.5, 1e-12);
    // functions + constants
    CheckNear('sin(pi/2)', 1, 1e-12);
    CheckNear('cos(0)', 1, 1e-12);
    CheckNear('SIN(PI/2)', 1, 1e-12);
    CheckNear('2pi', 2 * Pi, 1e-12);
    CheckNear('ln(e)', 1, 1e-12);
    CheckNear('log(100)', 2, 1e-12);
    CheckNear('exp(0)', 1, 0);
    CheckNear('cbrt(-8)', -2, 1e-9);
    CheckNear('cbrt(27)', 3, 1e-9);
    CheckNear('abs(0-7)', 7, 0);
    CheckNear('floor(2.9)', 2, 0);
    CheckNear('floor(0-2.1)', -3, 0);
    CheckNear('ceil(2.1)', 3, 0);
    CheckNear('round(2.5)', 3, 0);
    CheckNear('round(0-2.5)', -3, 0);
    CheckNear('phi', 1.61803398874989, 1e-12);
    CheckNear('tau', 2 * Pi, 1e-12);
    // variables + ans
    CheckNear('a = 2', 2, 0);
    CheckNear('a*3', 6, 0);
    CheckNear('ans+1', 7, 0);
    // degree mode
    Ctx.AngleMode := amDegree;
    CheckNear('sin(90)', 1, 1e-12);
    CheckNear('asin(1)', 90, 1e-9);
    Ctx.AngleMode := amRadian;
    // structured errors, never crashes
    CheckErr('1/0', ceDivisionByZero);
    CheckNear('0^0', 1, 0); // 0^0 is 1 by convention (documented)
    CheckErr('0^(-1)', ceDivisionByZero);
    CheckErr('sqrt(0-1)', ceDomain);
    CheckErr('ln(0-1)', ceDomain);
    CheckErr('log(0)', ceDomain);
    CheckErr('asin(2)', ceDomain);
    CheckErr('nosuchvar + 1', ceUnknownVariable);
    CheckErr('nosuchfn(1)', ceUnknownFunction);
    CheckErr('5.5!', ceDomain);
    CheckErr('f(x) = x^2', ceUnsupported);
    CheckErr('(0-8)^0.3333333333', ceDomain);
    CheckErr('2 +', ceSyntax);
  finally
    Ctx.Free;
  end;
  if Fails > 0 then
  begin
    WriteLn(Fails, ' FAILURES');
    Halt(1);
  end;
  WriteLn('All eval tests passed.');
end.
