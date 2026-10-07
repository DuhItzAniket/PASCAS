{ Assert-runner for PMS.Stats + PMS.Prob (Phases 28-29). }
program test_stats;

{$mode objfpc}{$H+}

uses
  SysUtils, PMS.Types, PMS.Matrix, PMS.Stats, PMS.Prob;

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
  Q1, Q2, Q3, M: Double;
  Cnt: Integer;
  Fit: TLinFit;
  Coeffs, Res: TDoubleArray;
begin
  Check(Abs(StatMean([1, 2, 3, 4, 5], E) - 3) < 1e-12, 'mean');
  Check(Abs(StatMedian([3, 1, 2], E) - 2) < 1e-12, 'median odd');
  Check(Abs(StatMedian([4, 1, 3, 2], E) - 2.5) < 1e-12, 'median even');
  M := StatMode([1, 2, 2, 3], Cnt, E);
  Check((Abs(M - 2) < 1e-12) and (Cnt = 2), 'mode');
  Check(Abs(StatVarPop([2, 4, 4, 4, 5, 5, 7, 9], E) - 4) < 1e-9, 'varpop = 4');
  Check(Abs(StatVarSamp([2, 4, 4, 4, 5, 5, 7, 9], E) - 4.57142857142857) < 1e-9,
    'varsamp');
  Check(Abs(StatStdPop([2, 4, 4, 4, 5, 5, 7, 9], E) - 2) < 1e-9, 'stdpop');
  StatQuartiles([1, 2, 3, 4, 5, 6, 7, 8], Q1, Q2, Q3, E);
  Check((Abs(Q1 - 2.75) < 1e-9) and (Abs(Q2 - 4.5) < 1e-9) and
    (Abs(Q3 - 6.25) < 1e-9), 'quartiles');
  StatMean([], E);
  Check(E = ceDomain, 'empty mean domain error');
  Fit := StatLinReg([1, 2, 3, 4], [2, 4, 6, 8], E);
  Check((E = ceNone) and (Abs(Fit.Slope - 2) < 1e-9) and
    (Abs(Fit.Intercept) < 1e-9) and (Abs(Fit.R2 - 1) < 1e-9), 'perfect linreg');
  Check(StatPolyReg([0, 1, 2], [1, 3, 7], 2, Coeffs, E) and
    (Abs(Coeffs[0] - 1) < 1e-9) and (Abs(Coeffs[1] - 1) < 1e-9) and
    (Abs(Coeffs[2] - 1) < 1e-9), 'polyreg x^2+x+1');
  Res := StatResiduals([0, 1, 2], [1, 3, 7], [1, 1, 1], E);
  Check((E = ceNone) and (Abs(Res[0]) + Abs(Res[1]) + Abs(Res[2]) < 1e-9),
    'zero residuals on fit');
  Check(Abs(StatCorr([1, 2, 3], [2, 4, 6], E) - 1) < 1e-9, 'corr = 1');
  // distributions: textbook values
  Check(Abs(NormalCDF(0, 0, 1, E)) - 0.5 < 1e-6, 'phi(0)');
  Check(Abs(NormalCDF(1.96, 0, 1, E) - 0.975) < 1e-4, 'phi(1.96)');
  Check(Abs(NormalQ(0.975, 0, 1, E) - 1.96) < 1e-3, 'quantile .975');
  Check(Abs(NormalQ(0.001, 0, 1, E) + 3.09023230616781) < 1e-4, 'tail quantile');
  Q3 := 0; // roundtrip fail flag
  for Cnt := -6 to 6 do
  begin
    M := Cnt * 0.5;
    Q1 := NormalCDF(M, 0, 1, E);
    Q2 := NormalQ(Q1, 0, 1, E);
    // documented accuracy: ~1e-9 central, ~1e-6 tails, ~1e-4 far tails
    if Abs(M) >= 2.5 then
      Q1 := 1e-4
    else if Abs(M) >= 1.5 then
      Q1 := 5e-6
    else
      Q1 := 1e-6;
    if Abs(Q2 - M) > Q1 then
    begin
      Check(False, 'quantile roundtrip at ' + FloatToStr(M));
      Q3 := 1;
      Break;
    end;
  end;
  Check(Q3 = 0, 'quantile roundtrip -3..3');
  Check(Abs(NormalPDF(0, 0, 1, E) - 0.398942280401433) < 1e-6, 'normal pdf');
  Check(Abs(BinomialPMF(5, 10, 0.5, E) - 0.24609375) < 1e-9, 'coin 5/10');
  Check(Abs(BinomialCDF(5, 10, 0.5, E) - 0.623046875) < 1e-6, 'binom cdf');
  Check(Abs(PoissonPMF(3, 2, E) - 0.180447044315484) < 1e-9, 'poisson pmf');
  Check(Abs(PoissonCDF(3, 2, E) - 0.857123460498547) < 1e-6, 'poisson cdf');
  Check(Abs(UniformCDF(0.5, 0, 1, E) - 0.5) < 1e-12, 'uniform cdf');
  Check(Abs(ExponCDF(1, 1, E) - 0.632120558828558) < 1e-9, 'expon cdf');
  Check(Abs(StudentCDF(0, 5, E) - 0.5) < 1e-12, 't(0) = 0.5');
  Check(Abs(StudentCDF(2.015, 5, E) - 0.95) < 1e-3, 't critical 2.015');
  Check(Abs(ChiSqCDF(3.841, 1, E) - 0.95) < 1e-3, 'chisq critical 3.841');
  Check(Abs(LnGamma(5) - Ln(24)) < 1e-9, 'lngamma(5) = ln24');
  if Fails > 0 then
  begin
    WriteLn(Fails, ' FAILURES');
    Halt(1);
  end;
  WriteLn('All stats/prob tests passed.');
end.
