{ Numerical integration (Phase 22): trapezoidal, Simpson, adaptive
  Simpson with error estimate. Integrand is an AST in a variable;
  limits are plain Doubles. Adaptive recursion capped at 20 levels with
  a minimum-interval guard; non-convergence is reported, never hidden. }
unit PMS.IntNum;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Math, PMS.Types, PMS.AST, PMS.DiffNum;

function ITrap(Node: TASTNode; const VarName: string; A, B: Double; N: Integer;
  Ctx: TEvalContext; out Err: TCalcError): Double;
function ISimp(Node: TASTNode; const VarName: string; A, B: Double; N: Integer;
  Ctx: TEvalContext; out Err: TCalcError): Double;
function IAdaptSimp(Node: TASTNode; const VarName: string; A, B, Tol: Double;
  Ctx: TEvalContext; out Err: TCalcError): Double;

implementation

function ITrap(Node: TASTNode; const VarName: string; A, B: Double; N: Integer;
  Ctx: TEvalContext; out Err: TCalcError): Double;
var
  H, S, X: Double;
  I: Integer;
begin
  Err := ceNone;
  Result := 0;
  if (N < 1) or IsNan(A) or IsNan(B) or IsInfinite(A) or IsInfinite(B) then
  begin
    Err := ceDomain;
    Exit;
  end;
  if A = B then
    Exit;
  H := (B - A) / N;
  S := 0;
  for I := 1 to N - 1 do
  begin
    X := A + I * H;
    S := S + EvalAt(Node, VarName, X, Ctx, Err);
    if Err <> ceNone then
      Exit;
  end;
  S := S + (EvalAt(Node, VarName, A, Ctx, Err) +
    EvalAt(Node, VarName, B, Ctx, Err)) / 2;
  if Err <> ceNone then
    Exit;
  Result := S * H;
end;

function ISimp(Node: TASTNode; const VarName: string; A, B: Double; N: Integer;
  Ctx: TEvalContext; out Err: TCalcError): Double;
var
  H, S, X: Double;
  I: Integer;
begin
  Err := ceNone;
  Result := 0;
  if (N < 2) or IsNan(A) or IsNan(B) or IsInfinite(A) or IsInfinite(B) then
  begin
    Err := ceDomain;
    Exit;
  end;
  if A = B then
    Exit;
  if Odd(N) then
    Inc(N); // Simpson needs even panels
  H := (B - A) / N;
  S := EvalAt(Node, VarName, A, Ctx, Err) + EvalAt(Node, VarName, B, Ctx, Err);
  if Err <> ceNone then
    Exit;
  for I := 1 to N - 1 do
  begin
    X := A + I * H;
    if Odd(I) then
      S := S + 4 * EvalAt(Node, VarName, X, Ctx, Err)
    else
      S := S + 2 * EvalAt(Node, VarName, X, Ctx, Err);
    if Err <> ceNone then
      Exit;
  end;
  Result := S * H / 3;
end;

function SimpOnce(Node: TASTNode; const VarName: string; A, B, FA, FM, FB: Double;
  Ctx: TEvalContext; out Err: TCalcError): Double;
begin
  Err := ceNone;
  Result := (B - A) / 6 * (FA + 4 * FM + FB);
end;

function AdaptRec(Node: TASTNode; const VarName: string; A, B, Tol, Whole,
  FA, FM, FB: Double; Depth: Integer; Ctx: TEvalContext;
  out Err: TCalcError): Double;
var
  M, LM, RM, FLM, FRM, Left, Right, Delta: Double;
begin
  Err := ceNone;
  M := (A + B) / 2;
  if (Depth <= 0) or ((B - A) < 1e-15) then
  begin
    if Depth <= 0 then
      Err := ceNoConvergence;
    Result := Whole;
    Exit;
  end;
  LM := (A + M) / 2;
  RM := (M + B) / 2;
  FLM := EvalAt(Node, VarName, LM, Ctx, Err);
  if Err <> ceNone then
    Exit;
  FRM := EvalAt(Node, VarName, RM, Ctx, Err);
  if Err <> ceNone then
    Exit;
  Left := (M - A) / 6 * (FA + 4 * FLM + FM);
  Right := (B - M) / 6 * (FM + 4 * FRM + FB);
  Delta := Left + Right - Whole;
  if Abs(Delta) <= 15 * Tol then
  begin
    Result := Left + Right + Delta / 15; // Richardson correction
    Exit;
  end;
  Left := AdaptRec(Node, VarName, A, M, Tol / 2, Left, FA, FLM, FM,
    Depth - 1, Ctx, Err);
  if Err <> ceNone then
    Exit;
  Right := AdaptRec(Node, VarName, M, B, Tol / 2, Right, FM, FRM, FB,
    Depth - 1, Ctx, Err);
  if Err <> ceNone then
    Exit;
  Result := Left + Right;
end;

function IAdaptSimp(Node: TASTNode; const VarName: string; A, B, Tol: Double;
  Ctx: TEvalContext; out Err: TCalcError): Double;
var
  M, FA, FM, FB, Whole: Double;
begin
  Err := ceNone;
  Result := 0;
  if IsNan(A) or IsNan(B) or IsInfinite(A) or IsInfinite(B) or (Tol <= 0) then
  begin
    Err := ceDomain;
    Exit;
  end;
  if A = B then
    Exit;
  M := (A + B) / 2;
  FA := EvalAt(Node, VarName, A, Ctx, Err);
  if Err <> ceNone then
    Exit;
  FM := EvalAt(Node, VarName, M, Ctx, Err);
  if Err <> ceNone then
    Exit;
  FB := EvalAt(Node, VarName, B, Ctx, Err);
  if Err <> ceNone then
    Exit;
  Whole := SimpOnce(Node, VarName, A, B, FA, FM, FB, Ctx, Err);
  if Err <> ceNone then
    Exit;
  Result := AdaptRec(Node, VarName, A, B, Tol, Whole, FA, FM, FB, 20, Ctx, Err);
end;

end.
