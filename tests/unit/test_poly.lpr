{ Assert-runner for PMS.Poly (Phase 19). }
program test_poly;

{$mode objfpc}{$H+}

uses
  SysUtils, PMS.Types, PMS.Poly;

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
  A, B, Q, R, G, L: TPoly;
begin
  A := PolyFrom([1, 2, 1]); // x^2+2x+1
  Check(PolyDeg(A) = 2, 'degree');
  Check(Abs(PEval(A, -1)) < 1e-12, 'eval (x+1)^2 at -1 = 0');
  B := PDeriv(A);
  Check(PToStr(B) = '2x+2', 'derivative: ' + PToStr(B));
  B := PInteg(PolyFrom([2])); // ∫2 dx
  Check(PToStr(B) = '2x', 'integral: ' + PToStr(B));
  B := PMul(PolyFrom([1, 1]), PolyFrom([-1, 1])); // (x+1)(x-1)
  Check(PToStr(B) = 'x^2-1', 'multiply: ' + PToStr(B));
  PDivMod(PolyFrom([-1, 0, 1]), PolyFrom([-1, 1]), 1e-9, Q, R, E);
  Check((E = ceNone) and (PToStr(Q) = 'x+1') and (PolyDeg(R) < 0),
    'divmod (x^2-1)/(x-1): q=' + PToStr(Q));
  G := PGCD(PolyFrom([-1, 0, 1]), PolyFrom([-1, 1]), 1e-9, E);
  Check((E = ceNone) and (PToStr(G) = 'x-1'), 'gcd = x-1: ' + PToStr(G));
  L := Lagrange([0.0, 1.0, 2.0], [1.0, 3.0, 7.0], E); // x^2+x+1
  Check((E = ceNone) and (Abs(PEval(L, 3) - 13) < 1e-9), 'lagrange through quad');
  Check(PToStr(PolyFrom([0, 0])) = '0', 'zero poly prints 0');
  PDivMod(A, PolyFrom([]), 1e-9, Q, R, E);
  Check(E = ceDivisionByZero, 'divmod by zero poly');
  if Fails > 0 then
  begin
    WriteLn(Fails, ' FAILURES');
    Halt(1);
  end;
  WriteLn('All poly tests passed.');
end.
