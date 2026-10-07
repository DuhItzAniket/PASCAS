{ Assert-runner for PMS.Complex (Phase 15). }
program test_complex;

{$mode objfpc}{$H+}

uses
  SysUtils, Math, PMS.Types, PMS.Complex;

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

procedure CheckC(const Got, Want: TComplex; Tol: Double; const Msg: string);
begin
  Check(CApprox(Got, Want, Tol), Msg + ' got ' + CFormat(Got));
end;

var
  E: TCalcError;
  I, A, B, R: TComplex;
begin
  I := CInit(0, 1);
  A := CInit(3, 4);
  B := CInit(1, -2);
  CheckC(CAdd(A, B), CInit(4, 2), 0, 'add');
  CheckC(CSub(A, B), CInit(2, 6), 0, 'sub');
  CheckC(CMul(A, B), CInit(11, -2), 0, 'mul (3+4i)(1-2i)=11-2i');
  CheckC(CMul(I, I), CInit(-1, 0), 0, 'i^2 = -1');
  Check(CAbs(A) = 5, '|3+4i| = 5');
  Check(Abs(CArg(CInit(1, 1)) - Pi / 4) < 1e-15, 'arg(1+i) = pi/4');
  CheckC(CNeg(A), CInit(-3, -4), 0, 'neg');
  CheckC(CConj(A), CInit(3, -4), 0, 'conj');
  R := CDiv(A, B, E);
  Check((E = ceNone) and CApprox(R, CInit(-1, 2), 1e-12), 'div (3+4i)/(1-2i)=-1+2i');
  R := CDiv(A, CInit(0, 0), E);
  Check(E = ceDivisionByZero, 'complex div by zero');
  CheckC(CExp(CInit(0, Pi)), CInit(-1, 0), 1e-12, 'euler e^{i pi} = -1');
  R := CLn(CInit(0, 0), E);
  Check(E = ceDomain, 'ln(0) domain');
  CheckC(CLn(CInit(2.71828182845905, 0), E), CInit(1, 0), 1e-12, 'ln(e) = 1');
  Check(E = ceNone, 'ln(e) no error');
  CheckC(CSqrt(CInit(-1, 0)), CInit(0, 1), 1e-12, 'sqrt(-1) = i');
  CheckC(CSqrt(CInit(3, 4)), CInit(2, 1), 1e-12, 'sqrt(3+4i) = 2+i');
  CheckC(CSin(CInit(0, 0)), CInit(0, 0), 0, 'sin(0) = 0');
  CheckC(CCos(CInit(0, 0)), CInit(1, 0), 0, 'cos(0) = 1');
  R := CPow(A, CInit(2, 0), E);
  Check((E = ceNone) and CApprox(R, CMul(A, A), 1e-9), 'pow(z,2) = z*z');
  R := CPowReal(I, 4, E);
  Check((E = ceNone) and CApprox(R, CInit(1, 0), 1e-12), 'i^4 = 1 (int path)');
  R := CPow(CInit(0, 0), CInit(0, 0), E);
  Check((E = ceNone) and CApprox(R, CInit(1, 0), 0), '0^0 = 1 convention');
  Check(CFormat(CInit(3, 4)) = '3+4i', 'format 3+4i');
  Check(CFormat(CInit(3, -4)) = '3-4i', 'format 3-4i');
  Check(CFormat(CInit(0, 1)) = 'i', 'format i');
  Check(CFormat(CInit(0, -1)) = '-i', 'format -i');
  Check(CFormat(CInit(2.5, 0)) = '2.5', 'format real');
  if Fails > 0 then
  begin
    WriteLn(Fails, ' FAILURES');
    Halt(1);
  end;
  WriteLn('All complex tests passed.');
end.
