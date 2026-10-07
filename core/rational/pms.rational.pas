{ Exact rational arithmetic (Phase 16): canonical Num/Den (Den > 0,
  divided by gcd), cross-cancelled multiply, continued-fraction import.
  The simplifier (Phase 18) uses this for constant folding — e.g.exact
  1/3+1/6 -> 1/2 — while the Double evaluator stays the display path. }
unit PMS.Rational;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Math, PMS.Types;

type
  TRational = record
    Num, Den: Int64; // Den > 0 always; Den = 0 marks invalid
  end;

function RGCD(A, B: Int64): Int64;
function RMake(N, D: Int64; out Err: TCalcError): TRational;
function RFromInt(X: Int64): TRational;
function RFromFloat(X: Double; MaxDen: Int64; out Err: TCalcError): TRational;
function RIsValid(const R: TRational): Boolean;
function RIsZero(const R: TRational): Boolean;
function RAdd(const A, B: TRational; out Err: TCalcError): TRational;
function RSub(const A, B: TRational; out Err: TCalcError): TRational;
function RMul(const A, B: TRational; out Err: TCalcError): TRational;
function RDiv(const A, B: TRational; out Err: TCalcError): TRational;
function RNeg(const A: TRational): TRational;
function RInv(const A: TRational; out Err: TCalcError): TRational;
function REqual(const A, B: TRational): Boolean;
function RCmp(const A, B: TRational): Integer; // -1, 0, 1; no overflow
function RToFloat(const R: TRational): Double;
function RFormat(const R: TRational): string;

implementation

function RGCD(A, B: Int64): Int64;
var
  T: Int64;
begin
  A := Abs(A);
  B := Abs(B);
  while B <> 0 do
  begin
    T := A mod B;
    A := B;
    B := T;
  end;
  Result := A;
end;

function MulOverflow(A, B: Int64): Boolean;
begin
  if (A = 0) or (B = 0) then
    Exit(False);
  if A > 0 then
  begin
    if B > 0 then
      Result := A > High(Int64) div B
    else
      Result := B < Low(Int64) div A;
  end
  else
  begin
    if B > 0 then
      Result := A < Low(Int64) div B
    else
      Result := (A <> 0) and (B < High(Int64) div A);
  end;
end;

function AddOverflow(A, B: Int64): Boolean;
begin
  if B > 0 then
    Result := A > High(Int64) - B
  else
    Result := A < Low(Int64) - B;
end;

function RMake(N, D: Int64; out Err: TCalcError): TRational;
var
  G: Int64;
begin
  Err := ceNone;
  if D = 0 then
  begin
    Err := ceDivisionByZero;
    Result.Num := 0;
    Result.Den := 0;
    Exit;
  end;
  if D < 0 then
  begin
    N := -N;
    D := -D;
  end;
  G := RGCD(N, D);
  if G > 1 then
  begin
    N := N div G;
    D := D div G;
  end;
  Result.Num := N;
  Result.Den := D;
end;

function RFromInt(X: Int64): TRational;
begin
  Result.Num := X;
  Result.Den := 1;
end;

function RFromFloat(X: Double; MaxDen: Int64; out Err: TCalcError): TRational;
var
  N0, N1, D0, D1, Q, T: Int64;
  R, F: Double;
  I: Integer;
begin
  Err := ceNone;
  if IsNan(X) or IsInfinite(X) then
  begin
    Err := ceDomain;
    Result.Num := 0;
    Result.Den := 0;
    Exit;
  end;
  if MaxDen < 1 then
    MaxDen := 1;
  // continued-fraction convergents
  N0 := 0; N1 := 1; D0 := 1; D1 := 0;
  R := X;
  for I := 1 to 64 do
  begin
    F := Floor(R);
    if (F > High(Int64)) or (F < Low(Int64)) then
      Break;
    Q := Trunc(F);
    T := N0 + Q * N1;
    if (Q <> 0) and ((Q * N1) div Q <> N1) then
      Break;
    N0 := N1; N1 := T;
    T := D0 + Q * D1;
    if (Q <> 0) and ((Q * D1) div Q <> D1) then
      Break;
    D0 := D1; D1 := T;
    if D1 > MaxDen then
    begin
      N1 := N0;
      D1 := D0;
      Break;
    end;
    if Abs(R - F) < 1e-15 then
      Break;
    R := 1 / (R - F);
    if Abs(R) > 1e15 then
      Break;
  end;
  Result := RMake(N1, D1, Err);
end;

function RIsValid(const R: TRational): Boolean;
begin
  Result := R.Den <> 0;
end;

function RIsZero(const R: TRational): Boolean;
begin
  Result := RIsValid(R) and (R.Num = 0);
end;

function RAdd(const A, B: TRational; out Err: TCalcError): TRational;
var
  G, AM, BM, T1, T2, N, D: Int64;
begin
  Err := ceNone;
  // a/b + c/d via lcm with pre-reduction: N/G math stays small
  G := RGCD(A.Den, B.Den);
  AM := A.Den div G;
  BM := B.Den div G;
  if MulOverflow(A.Num, BM) or MulOverflow(B.Num, AM) then
  begin
    Err := ceOverflow;
    Result.Num := 0;
    Result.Den := 0;
    Exit;
  end;
  T1 := A.Num * BM;
  T2 := B.Num * AM;
  if AddOverflow(T1, T2) or MulOverflow(AM, B.Den) then
  begin
    Err := ceOverflow;
    Result.Num := 0;
    Result.Den := 0;
    Exit;
  end;
  N := T1 + T2;
  D := AM * B.Den;
  Result := RMake(N, D, Err);
end;

function RSub(const A, B: TRational; out Err: TCalcError): TRational;
var
  N: TRational;
begin
  N.Num := -B.Num;
  N.Den := B.Den;
  Result := RAdd(A, N, Err);
end;

function RMul(const A, B: TRational; out Err: TCalcError): TRational;
var
  G1, G2, A1, B1, A2, B2: Int64;
begin
  Err := ceNone;
  // cross-cancel before multiplying: (a1/b1)*(a2/b2), cancel a1/b2 and a2/b1
  G1 := RGCD(A.Num, B.Den);
  G2 := RGCD(B.Num, A.Den);
  if G1 = 0 then
    G1 := 1;
  if G2 = 0 then
    G2 := 1;
  A1 := A.Num div G1;
  B1 := B.Den div G1;
  A2 := B.Num div G2;
  B2 := A.Den div G2;
  if MulOverflow(A1, A2) or MulOverflow(B1, B2) then
  begin
    Err := ceOverflow;
    Result.Num := 0;
    Result.Den := 0;
    Exit;
  end;
  Result := RMake(A1 * A2, B1 * B2, Err);
end;

function RInv(const A: TRational; out Err: TCalcError): TRational;
begin
  Err := ceNone;
  if not RIsValid(A) then
  begin
    Err := ceDomain;
    Result := A;
    Exit;
  end;
  Result := RMake(A.Den, A.Num, Err); // zero num -> zero den -> divzero err
end;

function RDiv(const A, B: TRational; out Err: TCalcError): TRational;
var
  I: TRational;
begin
  I := RInv(B, Err);
  if Err <> ceNone then
  begin
    Result.Num := 0;
    Result.Den := 0;
    Exit;
  end;
  Result := RMul(A, I, Err);
end;

function RNeg(const A: TRational): TRational;
begin
  Result.Num := -A.Num;
  Result.Den := A.Den;
end;

function REqual(const A, B: TRational): Boolean;
begin
  Result := RCmp(A, B) = 0;
end;

function RCmp(const A, B: TRational): Integer;
var
  G1, G2, L, R: Int64;
begin
  // a/b ? c/d with denominators > 0: compare reduced cross products
  // (a1*d1) ? (c1*b1); float fallback only on genuine overflow.
  if (not RIsValid(A)) or (not RIsValid(B)) then
  begin
    if RToFloat(A) < RToFloat(B) then
      Exit(-1);
    if RToFloat(A) > RToFloat(B) then
      Exit(1);
    Exit(0);
  end;
  G1 := RGCD(A.Num, B.Den);
  if G1 = 0 then
    G1 := 1;
  G2 := RGCD(B.Num, A.Den);
  if G2 = 0 then
    G2 := 1;
  if MulOverflow(A.Num div G1, B.Den div G1) or
    MulOverflow(B.Num div G2, A.Den div G2) then
  begin
    if RToFloat(A) < RToFloat(B) then
      Exit(-1);
    if RToFloat(A) > RToFloat(B) then
      Exit(1);
    Exit(0);
  end;
  L := (A.Num div G1) * (B.Den div G1);
  R := (B.Num div G2) * (A.Den div G2);
  if L < R then
    Result := -1
  else if L > R then
    Result := 1
  else
    Result := 0;
end;

function RToFloat(const R: TRational): Double;
begin
  if not RIsValid(R) then
    Result := 0
  else
    Result := R.Num / R.Den;
end;

function RFormat(const R: TRational): string;
begin
  if not RIsValid(R) then
    Result := 'invalid'
  else if R.Den = 1 then
    Result := IntToStr(R.Num)
  else
    Result := IntToStr(R.Num) + '/' + IntToStr(R.Den);
end;

end.
