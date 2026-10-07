{ Probability distributions (Phase 29): Normal, Binomial, Poisson,
  Uniform, Exponential, Student-t, Chi-square — each with PDF/PMF and CDF
  (Normal also has a quantile). Special functions implemented once here:
  Lanczos lnGamma, A&S erf, regularized gamma P, continued-fraction
  incomplete beta. Tested against textbook values. }
unit PMS.Prob;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Math, PMS.Types;

function LnGamma(X: Double): Double;
function ErfC(X: Double): Double;
function GammaP(A, X: Double; out Err: TCalcError): Double;
function BetaI(X, A, B: Double; out Err: TCalcError): Double;

function NormalPDF(X, Mu, Sigma: Double; out Err: TCalcError): Double;
function NormalCDF(X, Mu, Sigma: Double; out Err: TCalcError): Double;
function NormalQ(P, Mu, Sigma: Double; out Err: TCalcError): Double;
function BinomialPMF(K, N: Integer; P: Double; out Err: TCalcError): Double;
function BinomialCDF(K, N: Integer; P: Double; out Err: TCalcError): Double;
function PoissonPMF(K: Integer; Lambda: Double; out Err: TCalcError): Double;
function PoissonCDF(K: Integer; Lambda: Double; out Err: TCalcError): Double;
function UniformPDF(X, A, B: Double; out Err: TCalcError): Double;
function UniformCDF(X, A, B: Double; out Err: TCalcError): Double;
function ExponPDF(X, Lambda: Double; out Err: TCalcError): Double;
function ExponCDF(X, Lambda: Double; out Err: TCalcError): Double;
function StudentPDF(T: Double; Nu: Double; out Err: TCalcError): Double;
function StudentCDF(T: Double; Nu: Double; out Err: TCalcError): Double;
function ChiSqPDF(X: Double; K: Double; out Err: TCalcError): Double;
function ChiSqCDF(X: Double; K: Double; out Err: TCalcError): Double;

implementation

const
  // Lanczos g=7, 9 coefficients (Godfrey), ~15 digits
  LC: array[0..8] of Double = (0.99999999999980993, 676.5203681218851,
    -1259.1392167224028, 771.32342877765313, -176.61502916214059,
    12.507343278686905, -0.13857109526572012, 9.9843695780195716e-6,
    1.5056327351493116e-7);

function LnGamma(X: Double): Double;
var
  Y, T, S: Double;
  I: Integer;
begin
  if X <= 0 then
    Exit(NaN);
  if X < 0.5 then
    // reflection: Gamma(x)Gamma(1-x) = pi/sin(pi x)
    Exit(Ln(Pi / Sin(Pi * X)) - LnGamma(1 - X));
  Y := X - 1;
  S := LC[0];
  for I := 1 to 8 do
    S := S + LC[I] / (Y + I);
  T := Y + 7.5;
  Result := 0.5 * Ln(2 * Pi) + (Y + 0.5) * Ln(T) - T + Ln(S);
end;

function ErfC(X: Double): Double;
var
  T, P: Double;
begin
  // Abramowitz-Stegun 7.1.26, |error| <= 1.5e-7
  T := 1 / (1 + 0.3275911 * Abs(X));
  P := ((((1.061405429 * T - 1.453152027) * T) + 1.421413741) * T -
    0.284496736) * T + 0.254829592;
  P := P * T * Exp(-X * X);
  if X >= 0 then
    Result := 1 - P
  else
    Result := P - 1;
end;

function GammaP(A, X: Double; out Err: TCalcError): Double;
var
  N: Integer;
  AN, B, C, D, DEL, H, G: Double;
begin
  Err := ceNone;
  if (A <= 0) or (X < 0) then
  begin
    Err := ceDomain;
    Exit(0);
  end;
  if X = 0 then
    Exit(0);
  G := LnGamma(A);
  if X < A + 1 then
  begin
    // series for P (Numerical Recipes gamser)
    AN := A;
    DEL := 1 / A;
    H := DEL;
    for N := 1 to 500 do
    begin
      AN := AN + 1;
      DEL := DEL * X / AN;
      H := H + DEL;
      if Abs(DEL) < Abs(H) * 1e-14 then
        Break;
    end;
    Result := H * Exp(-X + A * Ln(X) - G);
  end
  else
  begin
    // continued fraction for Q, return 1 - Q
    B := X + 1 - A;
    C := 1e300;
    D := 1 / B;
    H := D;
    for N := 1 to 500 do
    begin
      AN := -N * (N - A);
      B := B + 2;
      D := AN * D + B;
      if Abs(D) < 1e-300 then
        D := 1e-300;
      C := B + AN / C;
      if Abs(C) < 1e-300 then
        C := 1e-300;
      D := 1 / D;
      DEL := D * C;
      H := H * DEL;
      if Abs(DEL - 1) < 1e-14 then
        Break;
    end;
    Result := 1 - Exp(-X + A * Ln(X) - G) * H;
  end;
  if Result < 0 then
    Result := 0;
  if Result > 1 then
    Result := 1;
end;

function BetaCF(X, A, B: Double): Double;
var
  M: Integer;
  AA, C, D, DEL, H, QAB, QAP, QAM: Double;
begin
  QAB := A + B;
  QAP := A + 1;
  QAM := A - 1;
  C := 1;
  D := 1 - QAB * X / QAP;
  if Abs(D) < 1e-300 then
    D := 1e-300;
  D := 1 / D;
  H := D;
  for M := 1 to 500 do
  begin
    AA := M * (B - M) * X / ((QAM + 2 * M) * (A + 2 * M));
    D := 1 + AA * D;
    if Abs(D) < 1e-300 then
      D := 1e-300;
    C := 1 + AA / C;
    if Abs(C) < 1e-300 then
      C := 1e-300;
    D := 1 / D;
    H := H * D * C;
    AA := -(A + M) * (QAB + M) * X / ((A + 2 * M) * (QAP + 2 * M));
    D := 1 + AA * D;
    if Abs(D) < 1e-300 then
      D := 1e-300;
    C := 1 + AA / C;
    if Abs(C) < 1e-300 then
      C := 1e-300;
    D := 1 / D;
    DEL := D * C;
    H := H * DEL;
    if Abs(DEL - 1) < 1e-14 then
      Break;
  end;
  Result := H;
end;

function BetaI(X, A, B: Double; out Err: TCalcError): Double;
var
  BT: Double;
begin
  Err := ceNone;
  if (A <= 0) or (B <= 0) then
  begin
    Err := ceDomain;
    Exit(0);
  end;
  if (X <= 0) then
    Exit(0);
  if (X >= 1) then
    Exit(1);
  BT := Exp(LnGamma(A + B) - LnGamma(A) - LnGamma(B) + A * Ln(X) +
    B * Ln(1 - X));
  if X < (A + 1) / (A + B + 2) then
    Result := BT * BetaCF(X, A, B) / A
  else
    Result := 1 - BT * BetaCF(1 - X, B, A) / B;
  if Result < 0 then
    Result := 0;
  if Result > 1 then
    Result := 1;
end;

function NormalPDF(X, Mu, Sigma: Double; out Err: TCalcError): Double;
var
  Z: Double;
begin
  Err := ceNone;
  if Sigma <= 0 then
  begin
    Err := ceDomain;
    Exit(0);
  end;
  Z := (X - Mu) / Sigma;
  Result := Exp(-Z * Z / 2) / (Sigma * Sqrt(2 * Pi));
end;

function NormalCDF(X, Mu, Sigma: Double; out Err: TCalcError): Double;
begin
  Err := ceNone;
  if Sigma <= 0 then
  begin
    Err := ceDomain;
    Exit(0);
  end;
  Result := 0.5 * (1 + ErfC((X - Mu) / (Sigma * Sqrt(2))));
end;

function NormalQ(P, Mu, Sigma: Double; out Err: TCalcError): Double;
var
  Q, R, Z: Double;
begin
  Err := ceNone;
  if (Sigma <= 0) or (P <= 0) or (P >= 1) then
  begin
    Err := ceDomain;
    Exit(0);
  end;
  // Acklam's approximation, ~1e-9
  if P < 0.02425 then
  begin
    Q := Sqrt(-2 * Ln(P));
    Z := (((((-7.784894002430293e-03 * Q - 0.3223964580411365) * Q -
      2.400758277161838) * Q - 2.549732539343734) * Q + 4.374664141287968) *
      Q + 2.938163982698783) / ((((7.784695709041462e-03 * Q +
      0.3224671290700398) * Q + 2.445134137142996) * Q + 3.754408661907416) *
      Q + 1);
  end
  else if P > 1 - 0.02425 then
  begin
    Q := Sqrt(-2 * Ln(1 - P));
    Z := -(((((-7.784894002430293e-03 * Q - 0.3223964580411365) * Q -
      2.400758277161838) * Q - 2.549732539343734) * Q + 4.374664141287968) *
      Q + 2.938163982698783) / ((((7.784695709041462e-03 * Q +
      0.3224671290700398) * Q + 2.445134137142996) * Q + 3.754408661907416) *
      Q + 1);
  end
  else
  begin
    Q := P - 0.5;
    R := Q * Q;
    // Acklam central region (rational 6/5, ~1e-9)
    Z := (((((-39.69683028665376 * R + 220.9460984245205) * R -
      275.9285104469687) * R + 138.3577518672690) * R - 30.66479806614716) *
      R + 2.506628277459239) * Q / (((((-54.47609879822406 * R +
      161.5858368580409) * R - 155.6989798598866) * R + 66.80131188771972) *
      R - 13.28068155288572) * R + 1);
  end;
  Result := Mu + Sigma * Z;
end;

function BinomialPMF(K, N: Integer; P: Double; out Err: TCalcError): Double;
begin
  Err := ceNone;
  if (N < 0) or (K < 0) or (K > N) or (P < 0) or (P > 1) then
  begin
    Err := ceDomain;
    Exit(0);
  end;
  if P = 0 then
    Exit(Ord(K = 0));
  if P = 1 then
    Exit(Ord(K = N));
  Result := Exp(LnGamma(N + 1) - LnGamma(K + 1) - LnGamma(N - K + 1) +
    K * Ln(P) + (N - K) * Ln(1 - P));
end;

function BinomialCDF(K, N: Integer; P: Double; out Err: TCalcError): Double;
begin
  Err := ceNone;
  if (N < 0) or (P < 0) or (P > 1) then
  begin
    Err := ceDomain;
    Exit(0);
  end;
  if K < 0 then
    Exit(0);
  if K >= N then
    Exit(1);
  // P(X <= k) = I_{1-p}(n-k, k+1)
  Result := BetaI(1 - P, N - K, K + 1, Err);
end;

function PoissonPMF(K: Integer; Lambda: Double; out Err: TCalcError): Double;
begin
  Err := ceNone;
  if (K < 0) or (Lambda <= 0) then
  begin
    Err := ceDomain;
    Exit(0);
  end;
  Result := Exp(-Lambda + K * Ln(Lambda) - LnGamma(K + 1));
end;

function PoissonCDF(K: Integer; Lambda: Double; out Err: TCalcError): Double;
begin
  Err := ceNone;
  if Lambda <= 0 then
  begin
    Err := ceDomain;
    Exit(0);
  end;
  if K < 0 then
    Exit(0);
  // P(X <= k) = Q(k+1, lambda) = 1 - P(k+1, lambda)
  Result := 1 - GammaP(K + 1, Lambda, Err);
end;

function UniformPDF(X, A, B: Double; out Err: TCalcError): Double;
begin
  Err := ceNone;
  if B <= A then
  begin
    Err := ceDomain;
    Exit(0);
  end;
  if (X < A) or (X > B) then
    Exit(0);
  Result := 1 / (B - A);
end;

function UniformCDF(X, A, B: Double; out Err: TCalcError): Double;
begin
  Err := ceNone;
  if B <= A then
  begin
    Err := ceDomain;
    Exit(0);
  end;
  if X <= A then
    Exit(0);
  if X >= B then
    Exit(1);
  Result := (X - A) / (B - A);
end;

function ExponPDF(X, Lambda: Double; out Err: TCalcError): Double;
begin
  Err := ceNone;
  if Lambda <= 0 then
  begin
    Err := ceDomain;
    Exit(0);
  end;
  if X < 0 then
    Exit(0);
  Result := Lambda * Exp(-Lambda * X);
end;

function ExponCDF(X, Lambda: Double; out Err: TCalcError): Double;
begin
  Err := ceNone;
  if Lambda <= 0 then
  begin
    Err := ceDomain;
    Exit(0);
  end;
  if X <= 0 then
    Exit(0);
  Result := 1 - Exp(-Lambda * X);
end;

function StudentPDF(T: Double; Nu: Double; out Err: TCalcError): Double;
begin
  Err := ceNone;
  if Nu <= 0 then
  begin
    Err := ceDomain;
    Exit(0);
  end;
  Result := Exp(LnGamma((Nu + 1) / 2) - LnGamma(Nu / 2) -
    0.5 * Ln(Nu * Pi) - (Nu + 1) / 2 * Ln(1 + T * T / Nu));
end;

function StudentCDF(T: Double; Nu: Double; out Err: TCalcError): Double;
var
  X: Double;
begin
  Err := ceNone;
  if Nu <= 0 then
  begin
    Err := ceDomain;
    Exit(0);
  end;
  if T = 0 then
    Exit(0.5);
  X := Nu / (Nu + T * T);
  if T > 0 then
    Result := 1 - 0.5 * BetaI(X, Nu / 2, 0.5, Err)
  else
    Result := 0.5 * BetaI(X, Nu / 2, 0.5, Err);
end;

function ChiSqPDF(X: Double; K: Double; out Err: TCalcError): Double;
begin
  Err := ceNone;
  if K <= 0 then
  begin
    Err := ceDomain;
    Exit(0);
  end;
  if X <= 0 then
    Exit(0);
  Result := Exp((K / 2 - 1) * Ln(X) - X / 2 - (K / 2) * Ln(2) - LnGamma(K / 2));
end;

function ChiSqCDF(X: Double; K: Double; out Err: TCalcError): Double;
begin
  Err := ceNone;
  if K <= 0 then
  begin
    Err := ceDomain;
    Exit(0);
  end;
  if X <= 0 then
    Exit(0);
  Result := GammaP(K / 2, X / 2, Err);
end;

end.
