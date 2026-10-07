{ Reusable polynomial abstraction (Phase 19): coefficient arrays (C[i]
  is the x^i coefficient), Horner eval, exact-arithmetic-free ops,
  Euclidean GCD (monic, tolerance-guarded), Lagrange interpolation —
  which doubles as the solver's coefficient extractor (Phase 24). }
unit PMS.Poly;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Math, PMS.Types;

type
  TPoly = record
    C: array of Double;
  end;

function PolyDeg(const P: TPoly): Integer; // -1 for the zero polynomial
function PolyFrom(const Cs: array of Double): TPoly;
function PolyVarX(Power: Integer): TPoly;
function PNorm(const P: TPoly; Tol: Double): TPoly;
function PAdd(const A, B: TPoly): TPoly;
function PSub(const A, B: TPoly): TPoly;
function PMul(const A, B: TPoly): TPoly;
procedure PDivMod(const A, B: TPoly; Tol: Double; out Q, R: TPoly;
  out Err: TCalcError);
function PDeriv(const P: TPoly): TPoly;
function PInteg(const P: TPoly): TPoly; // integration constant 0
function PEval(const P: TPoly; X: Double): Double;
function PGCD(const A, B: TPoly; Tol: Double; out Err: TCalcError): TPoly;
function Lagrange(const Xs, Ys: array of Double; out Err: TCalcError): TPoly;
function PToStr(const P: TPoly): string;

implementation

function PolyDeg(const P: TPoly): Integer;
var
  I: Integer;
begin
  for I := High(P.C) downto 0 do
    if P.C[I] <> 0 then
      Exit(I);
  Result := -1;
end;

function PolyFrom(const Cs: array of Double): TPoly;
var
  I: Integer;
begin
  SetLength(Result.C, Length(Cs));
  for I := 0 to High(Cs) do
    Result.C[I] := Cs[I];
  Result := PNorm(Result, 0);
end;

function PolyVarX(Power: Integer): TPoly;
var
  I: Integer;
begin
  SetLength(Result.C, Power + 1);
  for I := 0 to Power - 1 do
    Result.C[I] := 0;
  Result.C[Power] := 1;
end;

function PNorm(const P: TPoly; Tol: Double): TPoly;
var
  D, I: Integer;
begin
  D := High(P.C);
  while (D >= 0) and (Abs(P.C[D]) <= Tol) do
    Dec(D);
  SetLength(Result.C, D + 1);
  for I := 0 to D do
    Result.C[I] := P.C[I];
end;

function PAdd(const A, B: TPoly): TPoly;
var
  I, N: Integer;
begin
  N := High(A.C);
  if High(B.C) > N then
    N := High(B.C);
  SetLength(Result.C, N + 1);
  for I := 0 to N do
    Result.C[I] := 0;
  for I := 0 to High(A.C) do
    Result.C[I] := Result.C[I] + A.C[I];
  for I := 0 to High(B.C) do
    Result.C[I] := Result.C[I] + B.C[I];
  Result := PNorm(Result, 0);
end;

function PSub(const A, B: TPoly): TPoly;
var
  I, N: Integer;
begin
  N := High(A.C);
  if High(B.C) > N then
    N := High(B.C);
  SetLength(Result.C, N + 1);
  for I := 0 to N do
    Result.C[I] := 0;
  for I := 0 to High(A.C) do
    Result.C[I] := Result.C[I] + A.C[I];
  for I := 0 to High(B.C) do
    Result.C[I] := Result.C[I] - B.C[I];
  Result := PNorm(Result, 0);
end;

function PMul(const A, B: TPoly): TPoly;
var
  I, J: Integer;
begin
  if (PolyDeg(A) < 0) or (PolyDeg(B) < 0) then
  begin
    SetLength(Result.C, 0);
    Exit;
  end;
  SetLength(Result.C, High(A.C) + High(B.C) + 1);
  for I := 0 to High(Result.C) do
    Result.C[I] := 0;
  for I := 0 to High(A.C) do
    for J := 0 to High(B.C) do
      Result.C[I + J] := Result.C[I + J] + A.C[I] * B.C[J];
  Result := PNorm(Result, 0);
end;

procedure PDivMod(const A, B: TPoly; Tol: Double; out Q, R: TPoly;
  out Err: TCalcError);
var
  D, I, K: Integer;
  F: Double;
begin
  Err := ceNone;
  SetLength(Q.C, 0);
  R := PNorm(A, Tol);
  D := PolyDeg(PNorm(B, Tol));
  if D < 0 then
  begin
    Err := ceDivisionByZero;
    Exit;
  end;
  SetLength(Q.C, High(R.C) + 1);
  for I := 0 to High(Q.C) do
    Q.C[I] := 0;
  while PolyDeg(R) >= D do
  begin
    K := PolyDeg(R) - D;
    F := R.C[PolyDeg(R)] / B.C[D];
    Q.C[K] := Q.C[K] + F;
    for I := 0 to D do
      R.C[K + I] := R.C[K + I] - F * B.C[I];
    R := PNorm(R, Tol);
  end;
  Q := PNorm(Q, Tol);
end;

function PDeriv(const P: TPoly): TPoly;
var
  I: Integer;
begin
  if High(P.C) <= 0 then
  begin
    SetLength(Result.C, 0);
    Exit;
  end;
  SetLength(Result.C, High(P.C));
  for I := 1 to High(P.C) do
    Result.C[I - 1] := P.C[I] * I;
  Result := PNorm(Result, 0);
end;

function PInteg(const P: TPoly): TPoly;
var
  I: Integer;
begin
  SetLength(Result.C, High(P.C) + 2);
  Result.C[0] := 0;
  for I := 0 to High(P.C) do
    Result.C[I + 1] := P.C[I] / (I + 1);
end;

function PEval(const P: TPoly; X: Double): Double;
var
  I: Integer;
begin
  Result := 0;
  for I := High(P.C) downto 0 do
    Result := Result * X + P.C[I];
end;

function Monic(const P: TPoly): TPoly;
var
  D, I: Integer;
begin
  D := PolyDeg(P);
  if D < 0 then
  begin
    SetLength(Result.C, 0);
    Exit;
  end;
  SetLength(Result.C, D + 1);
  for I := 0 to D do
    Result.C[I] := P.C[I] / P.C[D];
end;

function PGCD(const A, B: TPoly; Tol: Double; out Err: TCalcError): TPoly;
var
  X, Y, Q, R: TPoly;
begin
  Err := ceNone;
  X := PNorm(A, Tol);
  Y := PNorm(B, Tol);
  if (PolyDeg(X) < 0) and (PolyDeg(Y) < 0) then
  begin
    Err := ceDomain;
    SetLength(Result.C, 0);
    Exit;
  end;
  if PolyDeg(X) < 0 then
  begin
    Result := Monic(Y);
    Exit;
  end;
  while PolyDeg(Y) >= 0 do
  begin
    PDivMod(X, Y, Tol, Q, R, Err);
    if Err <> ceNone then
    begin
      SetLength(Result.C, 0);
      Exit;
    end;
    X := Y;
    Y := R;
  end;
  Result := Monic(X);
end;

function Lagrange(const Xs, Ys: array of Double; out Err: TCalcError): TPoly;
var
  N, I, J: Integer;
  Basis, Term, Acc: TPoly;
  Den: Double;
begin
  Err := ceNone;
  N := Length(Xs);
  SetLength(Result.C, 0);
  if (N = 0) or (Length(Ys) <> N) then
  begin
    Err := ceDomain;
    Exit;
  end;
  Acc := PolyFrom([]);
  for I := 0 to N - 1 do
  begin
    Basis := PolyFrom([1.0]);
    Den := 1;
    for J := 0 to N - 1 do
    begin
      if J = I then
        Continue;
      if Xs[I] = Xs[J] then
      begin
        Err := ceDomain; // duplicate abscissa
        Exit;
      end;
      // multiply by (x - xj)/(xi - xj)
      Basis := PMul(Basis, PolyFrom([-Xs[J], 1.0]));
      Den := Den * (Xs[I] - Xs[J]);
    end;
    Term := Basis;
    for J := 0 to High(Term.C) do
      Term.C[J] := Term.C[J] * Ys[I] / Den;
    Acc := PAdd(Acc, Term);
  end;
  Result := Acc;
end;

function PToStr(const P: TPoly): string;
var
  D, I: Integer;
  S, T: string;
begin
  D := PolyDeg(P);
  if D < 0 then
    Exit('0');
  S := '';
  for I := D downto 0 do
  begin
    if P.C[I] = 0 then
      Continue;
    if S = '' then
    begin
      if P.C[I] < 0 then
        S := '-';
    end
    else if P.C[I] < 0 then
      S := S + '-'
    else
      S := S + '+';
    T := Format('%.10g', [Abs(P.C[I])]);
    if I = 0 then
      S := S + T
    else
    begin
      if T <> '1' then
        S := S + T;
      S := S + 'x';
      if I > 1 then
        S := S + '^' + IntToStr(I);
    end;
  end;
  Result := S;
end;

end.
