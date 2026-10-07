{ Assert-runner for PMS.Rational (Phase 16). }
program test_rational;

{$mode objfpc}{$H+}

uses
  SysUtils, PMS.Types, PMS.Rational;

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

function R(N, D: Int64): TRational;
var
  E: TCalcError;
begin
  Result := RMake(N, D, E);
  if E <> ceNone then
  begin
    WriteLn('  (RMake failed: ', N, '/', D, ')');
    Result.Num := 0;
    Result.Den := 0;
  end;
end;

var
  E: TCalcError;
  A, B, C: TRational;
begin
  Check(RGCD(12, 18) = 6, 'gcd');
  Check(RGCD(-12, 18) = 6, 'gcd sign');
  C := R(2, 4);
  Check((C.Num = 1) and (C.Den = 2), '2/4 reduces to 1/2');
  C := R(1, -3);
  Check((C.Num = -1) and (C.Den = 3), 'sign canonical to numerator');
  C := RMake(1, 0, E);
  Check((E = ceDivisionByZero) and not RIsValid(C), 'zero denominator');
  // the spec example: 1/3 + 1/6 = 1/2 exactly
  A := R(1, 3);
  B := R(1, 6);
  C := RAdd(A, B, E);
  Check((E = ceNone) and (C.Num = 1) and (C.Den = 2), '1/3+1/6 = 1/2, got ' + RFormat(C));
  C := RSub(R(3, 4), R(1, 4), E);
  Check((E = ceNone) and REqual(C, R(1, 2)), '3/4-1/4 = 1/2');
  C := RMul(R(2, 7), R(7, 4), E);
  Check((E = ceNone) and REqual(C, R(1, 2)), '2/7*7/4 = 1/2 (cross-cancel)');
  C := RDiv(R(3, 4), R(2, 3), E);
  Check((E = ceNone) and REqual(C, R(9, 8)), 'div 3/4 : 2/3 = 9/8');
  C := RDiv(R(1, 2), R(0, 1), E);
  Check(E = ceDivisionByZero, 'rational div by zero');
  Check(RCmp(R(1, 3), R(1, 2)) < 0, 'compare 1/3 < 1/2');
  Check(RCmp(R(2, 4), R(1, 2)) = 0, 'compare equal');
  Check(Abs(RToFloat(R(1, 2)) - 0.5) < 1e-15, 'to float');
  C := RFromFloat(0.5, 1000, E);
  Check((E = ceNone) and REqual(C, R(1, 2)), 'from float 0.5');
  C := RFromFloat(-2.5, 1000, E);
  Check((E = ceNone) and REqual(C, R(-5, 2)), 'from float -2.5, got ' + RFormat(C));
  C := RFromFloat(3.14159265358979, 1000, E);
  Check((E = ceNone) and REqual(C, R(355, 113)), 'pi best approximant 355/113, got ' + RFormat(C));
  Check(RFormat(R(7, 1)) = '7', 'format integer');
  Check(RFormat(R(-3, 4)) = '-3/4', 'format fraction');
  A := RFromInt(High(Int64) div 2 + 1);
  C := RMul(A, RFromInt(4), E);
  Check(E = ceOverflow, 'mul overflow detected');
  if Fails > 0 then
  begin
    WriteLn(Fails, ' FAILURES');
    Halt(1);
  end;
  WriteLn('All rational tests passed.');
end.
