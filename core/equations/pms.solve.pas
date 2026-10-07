{ Equation solver (Phase 24): bisection / Newton / secant on AST
  expressions, plus exact linear and quadratic extraction. Polynomial
  coefficients come from *fitting* (evaluate at 0, ±1) and every result
  is verified by back-substitution — non-polynomial inputs are rejected
  with ceUnsupported instead of returning fiction. Complex quadratic
  roots use PMS.Complex. Iteration counts reported for honesty. }
unit PMS.Solve;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Math, PMS.Types, PMS.AST, PMS.Eval, PMS.DiffNum, PMS.Complex;

function SolveBisection(Node: TASTNode; const VarName: string; A, B, Tol: Double;
  Ctx: TEvalContext; out Root: Double; out Iters: Integer;
  out Err: TCalcError): Boolean;
function SolveNewton(Node: TASTNode; const VarName: string; X0, Tol: Double;
  Ctx: TEvalContext; out Root: Double; out Iters: Integer;
  out Err: TCalcError): Boolean;
function SolveSecant(Node: TASTNode; const VarName: string; X0, X1, Tol: Double;
  Ctx: TEvalContext; out Root: Double; out Iters: Integer;
  out Err: TCalcError): Boolean;
function SolveLinear(Node: TASTNode; const VarName: string;
  Ctx: TEvalContext; out Root: Double; out Err: TCalcError): Boolean;
procedure SolveQuadratic(A, B, C: Double; out R1, R2: TComplex;
  out NRoots: Integer; out Err: TCalcError);
function SolvePoly2(Node: TASTNode; const VarName: string;
  Ctx: TEvalContext; out R1, R2: TComplex; out NRoots: Integer;
  out Err: TCalcError): Boolean;

implementation

function SolveBisection(Node: TASTNode; const VarName: string; A, B, Tol: Double;
  Ctx: TEvalContext; out Root: Double; out Iters: Integer;
  out Err: TCalcError): Boolean;
var
  FA, FM, M: Double;
begin
  Result := False;
  Root := 0;
  Iters := 0;
  FA := EvalAt(Node, VarName, A, Ctx, Err);
  if Err <> ceNone then
    Exit;
  FM := EvalAt(Node, VarName, B, Ctx, Err);
  if Err <> ceNone then
    Exit;
  if FA * FM > 0 then
  begin
    Err := ceNoConvergence; // no bracket: say so
    Exit;
  end;
  while (Iters < PMSMaxIterations) and ((B - A) / 2 > Tol) do
  begin
    M := (A + B) / 2;
    FM := EvalAt(Node, VarName, M, Ctx, Err);
    if Err <> ceNone then
      Exit;
    if FM = 0 then
    begin
      A := M;
      B := M;
      Break;
    end;
    if FA * FM < 0 then
      B := M
    else
    begin
      A := M;
      FA := FM;
    end;
    Inc(Iters);
  end;
  Root := (A + B) / 2;
  Err := ceNone;
  Result := True;
end;

function SolveNewton(Node: TASTNode; const VarName: string; X0, Tol: Double;
  Ctx: TEvalContext; out Root: Double; out Iters: Integer;
  out Err: TCalcError): Boolean;
var
  X, F, D: Double;
begin
  Result := False;
  Root := X0;
  Iters := 0;
  X := X0;
  while Iters < PMSMaxIterations do
  begin
    F := EvalAt(Node, VarName, X, Ctx, Err);
    if Err <> ceNone then
      Exit;
    if Abs(F) <= Tol then
    begin
      Root := X;
      Err := ceNone;
      Exit(True);
    end;
    D := NDiffCentral(Node, VarName, X, DefaultH(X), Ctx, Err);
    if (Err <> ceNone) or (D = 0) then
    begin
      if Err = ceNone then
        Err := ceNoConvergence;
      Exit;
    end;
    X := X - F / D;
    Inc(Iters);
  end;
  Err := ceNoConvergence;
end;

function SolveSecant(Node: TASTNode; const VarName: string; X0, X1, Tol: Double;
  Ctx: TEvalContext; out Root: Double; out Iters: Integer;
  out Err: TCalcError): Boolean;
var
  F0, F1, T: Double;
begin
  Result := False;
  Root := X1;
  Iters := 0;
  F0 := EvalAt(Node, VarName, X0, Ctx, Err);
  if Err <> ceNone then
    Exit;
  while Iters < PMSMaxIterations do
  begin
    F1 := EvalAt(Node, VarName, X1, Ctx, Err);
    if Err <> ceNone then
      Exit;
    if Abs(F1) <= Tol then
    begin
      Root := X1;
      Err := ceNone;
      Exit(True);
    end;
    if F1 = F0 then
    begin
      Err := ceNoConvergence;
      Exit;
    end;
    T := X1 - F1 * (X1 - X0) / (F1 - F0);
    X0 := X1;
    F0 := F1;
    X1 := T;
    Inc(Iters);
  end;
  Err := ceNoConvergence;
end;

function SolveLinear(Node: TASTNode; const VarName: string;
  Ctx: TEvalContext; out Root: Double; out Err: TCalcError): Boolean;
var
  C, A1, F2: Double;
begin
  Result := False;
  Root := 0;
  C := EvalAt(Node, VarName, 0, Ctx, Err);
  if Err <> ceNone then
    Exit;
  A1 := EvalAt(Node, VarName, 1, Ctx, Err) - C;
  if Err <> ceNone then
    Exit;
  if A1 = 0 then
  begin
    Err := ceNoConvergence; // constant: zero or no root
    if C = 0 then
      Err := ceUnsupported; // 0 = 0: infinite roots, say so
    Exit;
  end;
  // verify linearity before trusting the fit
  F2 := EvalAt(Node, VarName, 2, Ctx, Err);
  if Err <> ceNone then
    Exit;
  if Abs(F2 - (2 * A1 + C)) > 1e-6 * (1 + Abs(F2)) then
  begin
    Err := ceUnsupported; // not linear: not our department
    Exit;
  end;
  Root := -C / A1;
  Err := ceNone;
  Result := True;
end;

procedure SolveQuadratic(A, B, C: Double; out R1, R2: TComplex;
  out NRoots: Integer; out Err: TCalcError);
var
  D, Q: Double;
begin
  Err := ceNone;
  NRoots := 0;
  R1 := CInit(0, 0);
  R2 := CInit(0, 0);
  if A = 0 then
  begin
    if B = 0 then
    begin
      if C = 0 then
        Err := ceUnsupported // identity: infinite roots
      else
        Err := ceNoConvergence; // contradiction: no roots
      Exit;
    end;
    R1 := CInit(-C / B, 0);
    R2 := R1;
    NRoots := 1;
    Exit;
  end;
  D := B * B - 4 * A * C;
  if D >= 0 then
  begin
    // stable Citizen-q form avoids cancellation
    if B >= 0 then
      Q := (-B - Sqrt(D)) / 2
    else
      Q := (-B + Sqrt(D)) / 2;
    if Q = 0 then
    begin
      R1 := CInit(0, 0);
      R2 := CInit(-B / A, 0);
    end
    else
    begin
      R1 := CInit(Q / A, 0);
      R2 := CInit(C / Q, 0);
    end;
    if D = 0 then
      NRoots := 1
    else
      NRoots := 2;
  end
  else
  begin
    R1 := CInit(-B / (2 * A), Sqrt(-D) / (2 * A));
    R2 := CInit(-B / (2 * A), -Sqrt(-D) / (2 * A));
    NRoots := 2;
  end;
end;

function SolvePoly2(Node: TASTNode; const VarName: string;
  Ctx: TEvalContext; out R1, R2: TComplex; out NRoots: Integer;
  out Err: TCalcError): Boolean;
var
  F0, F1, FM1, F2, A, B, C: Double;
begin
  Result := False;
  NRoots := 0;
  F0 := EvalAt(Node, VarName, 0, Ctx, Err);
  if Err <> ceNone then
    Exit;
  F1 := EvalAt(Node, VarName, 1, Ctx, Err);
  if Err <> ceNone then
    Exit;
  FM1 := EvalAt(Node, VarName, -1, Ctx, Err);
  if Err <> ceNone then
    Exit;
  C := F0;
  B := (F1 - FM1) / 2;
  A := (F1 + FM1) / 2 - F0;
  // verify quadratic shape before trusting the fit
  F2 := EvalAt(Node, VarName, 2, Ctx, Err);
  if Err <> ceNone then
    Exit;
  if Abs(F2 - (4 * A + 2 * B + C)) > 1e-6 * (1 + Abs(F2)) then
  begin
    Err := ceUnsupported;
    Exit;
  end;
  SolveQuadratic(A, B, C, R1, R2, NRoots, Err);
  Result := Err = ceNone;
end;

end.
