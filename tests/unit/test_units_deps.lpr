{ Assert-runner for PMS.Units + PMS.Deps (Phases 30-31). }
program test_units_deps;

{$mode objfpc}{$H+}

uses
  SysUtils, PMS.Types, PMS.Units, PMS.Deps;

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
  E: TCalcError;
  P: Integer;
  A, B, C: TQty;
  V: Double;
  S: TDepStore;
begin
  // the spec example: 5 kg * 9.81 m/s^2 = 49.05 N
  Check(QMake(5, 'kg', A, E), 'make 5 kg');
  Check(QMake(9.81, 'm/s^2', B, E), 'make 9.81 m/s^2');
  C := QMul(A, B);
  Check((Abs(C.V - 49.05) < 1e-9) and (QFormat(C) = '49.05 N'),
    'force: ' + QFormat(C));
  Check(QMake(100, 'cm', A, E) and QConvert(A, 'm', V, E) and
    (Abs(V - 1) < 1e-12), '100 cm = 1 m');
  Check(QMake(32, 'degF', A, E) and QConvert(A, 'K', V, E) and
    (Abs(V - 273.15) < 1e-9), '32 degF = 273.15 K');
  Check(QMake(0, 'degC', A, E) and QConvert(A, 'K', V, E) and
    (Abs(V - 273.15) < 1e-9), '0 degC = 273.15 K');
  Check(QMake(1, 'mile', A, E) and QConvert(A, 'km', V, E) and
    (Abs(V - 1.609344) < 1e-9), 'mile to km');
  Check(QMake(1, 'kWh', A, E) and QConvert(A, 'J', V, E) and
    (Abs(V - 3.6e6) < 1), 'kWh to J');
  A := QAdd(A, A, E);
  Check(E = ceNone, 'same-dim add');
  Check(QMake(1, 'm', A, E) and QMake(1, 's', B, E), 'length + time units');
  C := QAdd(A, B, E);
  Check(E = ceDomain, 'incompatible add refused');
  Check(not QMake(1, 'furlong', A, E), 'unknown unit refused');
  Check(QMake(5, 'kg', A, E) and (QFormat(A) = '5 kg'), 'alias format kg');

  // dependency engine: a=2, b=3, f(x)=a*x+b
  S := TDepStore.Create;
  try
    Check(S.Define('a = 2', E, P), 'define a');
    Check(S.Define('b = 3', E, P), 'define b');
    Check(S.Define('f(x) = a*x+b', E, P), 'define f');
    Check(S.EvalFunc('f', [4], V, E) and (Abs(V - 11) < 1e-12), 'f(4) = 11');
    Check(S.SetVar('a', 5), 'slide a to 5');
    Check(S.EvalFunc('f', [4], V, E) and (Abs(V - 23) < 1e-12),
      'reactive f(4) = 23');
    Check(S.EvalExpr('a*10+b', V, E, P) and (Abs(V - 53) < 1e-12),
      'expr with deps = 53');
    Check(S.Define('g(y) = f(y)+b', E, P), 'nested def g');
    Check(S.EvalFunc('g', [4], V, E) and (Abs(V - 26) < 1e-12), 'g(4) = 26');
    Check(S.Define('c = a', E, P) and S.EvalVar('c', V, E) and
      (Abs(V - 5) < 1e-12), 'chained var c = a');
    Check(S.Define('a = c', E, P), 'cycle defs accepted (lazy)');
    Check(not S.EvalVar('a', V, E) and (E = ceUnsupported), 'cycle refused');
    Check(not S.EvalVar('nosuch', V, E), 'unknown var refused');
    Check(S.EntryCount = 5, 'entry count');
  finally
    S.Free;
  end;
  if Fails > 0 then
  begin
    WriteLn(Fails, ' FAILURES');
    Halt(1);
  end;
  WriteLn('All units/deps tests passed.');
end.
