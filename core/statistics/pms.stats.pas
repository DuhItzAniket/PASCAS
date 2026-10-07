{ Descriptive statistics and regression (Phase 28): mean/median/mode,
  population + sample variance/std, quartiles/percentiles (linear
  interpolation), covariance/correlation, linear + polynomial regression
  (normal equations solved by PMS.Matrix), residuals. Empty input is a
  domain error, never a crash. }
unit PMS.Stats;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Math, PMS.Types, PMS.Matrix;

type
  TLinFit = record
    Slope, Intercept, R2: Double;
  end;

function StatMean(const X: array of Double; out Err: TCalcError): Double;
function StatMedian(const X: array of Double; out Err: TCalcError): Double;
function StatMode(const X: array of Double; out Count: Integer;
  out Err: TCalcError): Double;
function StatVarPop(const X: array of Double; out Err: TCalcError): Double;
function StatVarSamp(const X: array of Double; out Err: TCalcError): Double;
function StatStdPop(const X: array of Double; out Err: TCalcError): Double;
function StatStdSamp(const X: array of Double; out Err: TCalcError): Double;
function StatPercentile(const X: array of Double; P: Double;
  out Err: TCalcError): Double;
procedure StatQuartiles(const X: array of Double; out Q1, Q2, Q3: Double;
  out Err: TCalcError);
function StatCov(const X, Y: array of Double; out Err: TCalcError): Double;
function StatCorr(const X, Y: array of Double; out Err: TCalcError): Double;
function StatLinReg(const X, Y: array of Double; out Err: TCalcError): TLinFit;
function StatPolyReg(const X, Y: array of Double; Deg: Integer;
  out Coeffs: TDoubleArray; out Err: TCalcError): Boolean;
function StatResiduals(const X, Y, Coeffs: array of Double;
  out Err: TCalcError): TDoubleArray;

implementation

procedure SortCopy(const X: array of Double; out S: TDoubleArray);
var
  I, J: Integer;
  T: Double;
begin
  SetLength(S, Length(X));
  for I := 0 to High(X) do
    S[I] := X[I];
  // insertion sort: O(n^2) but allocation-free and exact; stats vectors
  // are user-sized (bounded by input limits), never millions of points
  for I := 1 to High(S) do
  begin
    T := S[I];
    J := I - 1;
    while (J >= 0) and (S[J] > T) do
    begin
      S[J + 1] := S[J];
      Dec(J);
    end;
    S[J + 1] := T;
  end;
end;

function StatMean(const X: array of Double; out Err: TCalcError): Double;
var
  I: Integer;
begin
  Err := ceNone;
  if Length(X) = 0 then
  begin
    Err := ceDomain;
    Exit(0);
  end;
  Result := 0;
  for I := 0 to High(X) do
    Result := Result + X[I];
  Result := Result / Length(X);
end;

function StatMedian(const X: array of Double; out Err: TCalcError): Double;
var
  S: TDoubleArray;
  N: Integer;
begin
  Err := ceNone;
  if Length(X) = 0 then
  begin
    Err := ceDomain;
    Exit(0);
  end;
  SortCopy(X, S);
  N := Length(S);
  if Odd(N) then
    Result := S[N div 2]
  else
    Result := (S[N div 2 - 1] + S[N div 2]) / 2;
end;

function StatMode(const X: array of Double; out Count: Integer;
  out Err: TCalcError): Double;
var
  S: TDoubleArray;
  I, Run, Best: Integer;
begin
  Err := ceNone;
  Count := 0;
  if Length(X) = 0 then
  begin
    Err := ceDomain;
    Exit(0);
  end;
  SortCopy(X, S);
  Result := S[0];
  Best := 1;
  Run := 1;
  for I := 1 to High(S) do
  begin
    if S[I] = S[I - 1] then
      Inc(Run)
    else
    begin
      if Run > Best then
      begin
        Best := Run;
        Result := S[I - 1];
      end;
      Run := 1;
    end;
  end;
  if Run > Best then
  begin
    Best := Run;
    Result := S[High(S)];
  end;
  Count := Best;
end;

function StatVarPop(const X: array of Double; out Err: TCalcError): Double;
var
  M: Double;
  I: Integer;
begin
  M := StatMean(X, Err);
  if Err <> ceNone then
    Exit(0);
  Result := 0;
  for I := 0 to High(X) do
    Result := Result + Sqr(X[I] - M);
  Result := Result / Length(X);
end;

function StatVarSamp(const X: array of Double; out Err: TCalcError): Double;
var
  M: Double;
  I: Integer;
begin
  if Length(X) < 2 then
  begin
    Err := ceDomain;
    Exit(0);
  end;
  M := StatMean(X, Err);
  if Err <> ceNone then
    Exit(0);
  Result := 0;
  for I := 0 to High(X) do
    Result := Result + Sqr(X[I] - M);
  Result := Result / (Length(X) - 1);
end;

function StatStdPop(const X: array of Double; out Err: TCalcError): Double;
begin
  Result := Sqrt(StatVarPop(X, Err));
end;

function StatStdSamp(const X: array of Double; out Err: TCalcError): Double;
begin
  Result := Sqrt(StatVarSamp(X, Err));
end;

function StatPercentile(const X: array of Double; P: Double;
  out Err: TCalcError): Double;
var
  S: TDoubleArray;
  Pos, Fr: Double;
  Lo: Integer;
begin
  Err := ceNone;
  if (Length(X) = 0) or (P < 0) or (P > 100) then
  begin
    Err := ceDomain;
    Exit(0);
  end;
  SortCopy(X, S);
  if Length(S) = 1 then
    Exit(S[0]);
  Pos := P / 100 * (Length(S) - 1);
  Lo := Trunc(Pos);
  Fr := Pos - Lo;
  if Lo >= High(S) then
    Exit(S[High(S)]);
  Result := S[Lo] + Fr * (S[Lo + 1] - S[Lo]);
end;

procedure StatQuartiles(const X: array of Double; out Q1, Q2, Q3: Double;
  out Err: TCalcError);
begin
  Q1 := StatPercentile(X, 25, Err);
  if Err <> ceNone then
    Exit;
  Q2 := StatPercentile(X, 50, Err);
  if Err <> ceNone then
    Exit;
  Q3 := StatPercentile(X, 75, Err);
end;

function StatCov(const X, Y: array of Double; out Err: TCalcError): Double;
var
  Mx, My: Double;
  I: Integer;
begin
  Err := ceNone;
  if (Length(X) <> Length(Y)) or (Length(X) < 2) then
  begin
    Err := ceDomain;
    Exit(0);
  end;
  Mx := StatMean(X, Err);
  My := StatMean(Y, Err);
  Result := 0;
  for I := 0 to High(X) do
    Result := Result + (X[I] - Mx) * (Y[I] - My);
  Result := Result / (Length(X) - 1);
end;

function StatCorr(const X, Y: array of Double; out Err: TCalcError): Double;
var
  C, Sx, Sy: Double;
begin
  C := StatCov(X, Y, Err);
  if Err <> ceNone then
    Exit(0);
  Sx := StatStdSamp(X, Err);
  if Err <> ceNone then
    Exit(0);
  Sy := StatStdSamp(Y, Err);
  if Err <> ceNone then
    Exit(0);
  if (Sx = 0) or (Sy = 0) then
  begin
    Err := ceDomain;
    Exit(0);
  end;
  Result := C / (Sx * Sy);
end;

function StatLinReg(const X, Y: array of Double; out Err: TCalcError): TLinFit;
var
  Mx, My, Sxx, Sxy: Double;
  I: Integer;
begin
  Err := ceNone;
  Result.Slope := 0;
  Result.Intercept := 0;
  Result.R2 := 0;
  if (Length(X) <> Length(Y)) or (Length(X) < 2) then
  begin
    Err := ceDomain;
    Exit;
  end;
  Mx := StatMean(X, Err);
  My := StatMean(Y, Err);
  Sxx := 0;
  Sxy := 0;
  for I := 0 to High(X) do
  begin
    Sxx := Sxx + Sqr(X[I] - Mx);
    Sxy := Sxy + (X[I] - Mx) * (Y[I] - My);
  end;
  if Sxx = 0 then
  begin
    Err := ceDomain;
    Exit;
  end;
  Result.Slope := Sxy / Sxx;
  Result.Intercept := My - Result.Slope * Mx;
  Result.R2 := Sqr(StatCorr(X, Y, Err)); // errs if X or Y is constant
end;

function StatPolyReg(const X, Y: array of Double; Deg: Integer;
  out Coeffs: TDoubleArray; out Err: TCalcError): Boolean;
var
  N, I, J, K: Integer;
  A, B, C: TMatrix;
  S: Double;
begin
  Result := False;
  SetLength(Coeffs, 0);
  if (Length(X) <> Length(Y)) or (Length(X) = 0) or (Deg < 0) or
    (Deg >= Length(X)) then
  begin
    Err := ceDomain;
    Exit;
  end;
  N := Deg + 1;
  A := MMake(N, N, Err);
  if Err <> ceNone then
    Exit;
  B := MMake(N, 1, Err);
  if Err <> ceNone then
    Exit;
  // normal equations: A[j,k] = sum x^(j+k), B[j] = sum y*x^j
  for J := 0 to Deg do
    for K := 0 to Deg do
    begin
      S := 0;
      for I := 0 to High(X) do
        S := S + Power(X[I], J + K);
      MSet(A, J, K, S);
    end;
  for J := 0 to Deg do
  begin
    S := 0;
    for I := 0 to High(X) do
      S := S + Y[I] * Power(X[I], J);
    MSet(B, J, 0, S);
  end;
  C := MSolve(A, B, 1e-9, Err);
  if Err <> ceNone then
    Exit;
  SetLength(Coeffs, N);
  for I := 0 to N - 1 do
    Coeffs[I] := MGet(C, I, 0);
  Result := True;
end;

function StatResiduals(const X, Y, Coeffs: array of Double;
  out Err: TCalcError): TDoubleArray;
var
  I, J: Integer;
  P: Double;
begin
  Err := ceNone;
  SetLength(Result, 0);
  if (Length(X) <> Length(Y)) or (Length(Coeffs) = 0) then
  begin
    Err := ceDomain;
    Exit;
  end;
  SetLength(Result, Length(X));
  for I := 0 to High(X) do
  begin
    P := 0;
    for J := 0 to High(Coeffs) do
      P := P + Coeffs[J] * Power(X[I], J);
    Result[I] := Y[I] - P;
  end;
end;

end.
