{ Robust complex arithmetic (Phase 15). Pure value library: records in,
  records out, no globals. Failable ops (div, ln, pow) report structured
  TCalcError; total ops stay total. Expression-level complex display and
  `i` integration land with the consumers (solver/workspace); the nmComplex
  mode flag (PMS.Types) is the branch point. }
unit PMS.Complex;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Math, PMS.Types;

type
  TComplex = record
    Re, Im: Double;
  end;

function CInit(Re, Im: Double): TComplex;
function CAdd(const A, B: TComplex): TComplex;
function CSub(const A, B: TComplex): TComplex;
function CMul(const A, B: TComplex): TComplex;
function CNeg(const A: TComplex): TComplex;
function CConj(const A: TComplex): TComplex;
function CAbs(const A: TComplex): Double;
function CArg(const A: TComplex): Double;
function CIsZero(const A: TComplex): Boolean;
function CApprox(const A, B: TComplex; Tol: Double): Boolean;
function CDiv(const A, B: TComplex; out Err: TCalcError): TComplex;
function CExp(const A: TComplex): TComplex;
function CLn(const A: TComplex; out Err: TCalcError): TComplex;
function CSqrt(const A: TComplex): TComplex;
function CSin(const A: TComplex): TComplex;
function CCos(const A: TComplex): TComplex;
function CPow(const A, B: TComplex; out Err: TCalcError): TComplex;
function CPowReal(const A: TComplex; X: Double; out Err: TCalcError): TComplex;
function CFormat(const A: TComplex): string;

implementation

function CInit(Re, Im: Double): TComplex;
begin
  Result.Re := Re;
  Result.Im := Im;
end;

function CAdd(const A, B: TComplex): TComplex;
begin
  Result.Re := A.Re + B.Re;
  Result.Im := A.Im + B.Im;
end;

function CSub(const A, B: TComplex): TComplex;
begin
  Result.Re := A.Re - B.Re;
  Result.Im := A.Im - B.Im;
end;

function CMul(const A, B: TComplex): TComplex;
begin
  Result.Re := A.Re * B.Re - A.Im * B.Im;
  Result.Im := A.Re * B.Im + A.Im * B.Re;
end;

function CNeg(const A: TComplex): TComplex;
begin
  Result.Re := -A.Re;
  Result.Im := -A.Im;
end;

function CConj(const A: TComplex): TComplex;
begin
  Result.Re := A.Re;
  Result.Im := -A.Im;
end;

function CAbs(const A: TComplex): Double;
begin
  Result := Hypot(A.Re, A.Im);
end;

function CArg(const A: TComplex): Double;
begin
  Result := ArcTan2(A.Im, A.Re);
end;

function CIsZero(const A: TComplex): Boolean;
begin
  Result := (A.Re = 0) and (A.Im = 0);
end;

function CApprox(const A, B: TComplex; Tol: Double): Boolean;
begin
  Result := (Abs(A.Re - B.Re) <= Tol) and (Abs(A.Im - B.Im) <= Tol);
end;

function CDiv(const A, B: TComplex; out Err: TCalcError): TComplex;
var
  D: Double;
begin
  Err := ceNone;
  D := B.Re * B.Re + B.Im * B.Im;
  if D = 0 then
  begin
    Err := ceDivisionByZero;
    Result := CInit(0, 0);
    Exit;
  end;
  Result.Re := (A.Re * B.Re + A.Im * B.Im) / D;
  Result.Im := (A.Im * B.Re - A.Re * B.Im) / D;
end;

function CExp(const A: TComplex): TComplex;
var
  E: Double;
begin
  E := Exp(A.Re);
  Result.Re := E * Cos(A.Im);
  Result.Im := E * Sin(A.Im);
end;

function CLn(const A: TComplex; out Err: TCalcError): TComplex;
begin
  Err := ceNone;
  if CIsZero(A) then
  begin
    Err := ceDomain;
    Result := CInit(0, 0);
    Exit;
  end;
  Result.Re := Ln(CAbs(A));
  Result.Im := CArg(A);
end;

function CSqrt(const A: TComplex): TComplex;
var
  R, T: Double;
begin
  // principal root via half-angle; total on all inputs
  R := CAbs(A);
  T := CArg(A) / 2;
  Result.Re := Sqrt(R) * Cos(T);
  Result.Im := Sqrt(R) * Sin(T);
end;

function CSin(const A: TComplex): TComplex;
begin
  Result.Re := Sin(A.Re) * Cosh(A.Im);
  Result.Im := Cos(A.Re) * Sinh(A.Im);
end;

function CCos(const A: TComplex): TComplex;
begin
  Result.Re := Cos(A.Re) * Cosh(A.Im);
  Result.Im := -Sin(A.Re) * Sinh(A.Im);
end;

function CPow(const A, B: TComplex; out Err: TCalcError): TComplex;
var
  L: TComplex;
begin
  Err := ceNone;
  if CIsZero(A) then
  begin
    if CIsZero(B) then
    begin
      Result := CInit(1, 0); // 0^0 convention, matches real evaluator
      Exit;
    end;
    if B.Im = 0 then
    begin
      if B.Re > 0 then
      begin
        Result := CInit(0, 0);
        Exit;
      end;
      Err := ceDivisionByZero;
      Result := CInit(0, 0);
      Exit;
    end;
    Err := ceDomain;
    Result := CInit(0, 0);
    Exit;
  end;
  L := CLn(A, Err);
  if Err <> ceNone then
  begin
    Result := CInit(0, 0);
    Exit;
  end;
  Result := CExp(CMul(B, L));
end;

function CPowReal(const A: TComplex; X: Double; out Err: TCalcError): TComplex;
var
  N, I: Integer;
begin
  Err := ceNone;
  if (Frac(X) = 0) and (Abs(X) <= 1000000) then
  begin
    // exact integer path: no log-branch error, negative powers invert
    N := Trunc(X);
    Result := CInit(1, 0);
    if N < 0 then
    begin
      for I := 1 to -N do
        Result := CMul(Result, A);
      Result := CDiv(CInit(1, 0), Result, Err);
    end
    else
      for I := 1 to N do
        Result := CMul(Result, A);
    Exit;
  end;
  Result := CPow(A, CInit(X, 0), Err);
end;

function NumPart(X: Double): string;
begin
  Result := Format('%.10g', [X]);
end;

function CFormat(const A: TComplex): string;
begin
  if A.Im = 0 then
    Result := NumPart(A.Re)
  else if A.Re = 0 then
  begin
    if A.Im = 1 then
      Result := 'i'
    else if A.Im = -1 then
      Result := '-i'
    else
      Result := NumPart(A.Im) + 'i';
  end
  else if A.Im > 0 then
  begin
    if A.Im = 1 then
      Result := NumPart(A.Re) + '+i'
    else
      Result := NumPart(A.Re) + '+' + NumPart(A.Im) + 'i';
  end
  else
  begin
    if A.Im = -1 then
      Result := NumPart(A.Re) + '-i'
    else
      Result := NumPart(A.Re) + NumPart(A.Im) + 'i';
  end;
end;

end.
