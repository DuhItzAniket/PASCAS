{ Numerical differentiation (Phase 21): forward/backward/central finite
  differences of an AST in a variable at a point. No procedural types —
  the expression + context are the function, so this works everywhere the
  evaluator does (and documents its truncation error honestly). }
unit PMS.DiffNum;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, PMS.Types, PMS.AST, PMS.Eval;

function EvalAt(Node: TASTNode; const VarName: string; At: Double;
  Ctx: TEvalContext; out Err: TCalcError): Double;
function NDiffForward(Node: TASTNode; const VarName: string; At, H: Double;
  Ctx: TEvalContext; out Err: TCalcError): Double;
function NDiffBackward(Node: TASTNode; const VarName: string; At, H: Double;
  Ctx: TEvalContext; out Err: TCalcError): Double;
function NDiffCentral(Node: TASTNode; const VarName: string; At, H: Double;
  Ctx: TEvalContext; out Err: TCalcError): Double;
function DefaultH(At: Double): Double;

implementation

function DefaultH(At: Double): Double;
begin
  // sqrt(eps) * scale: balances truncation vs cancellation for central diff
  if At = 0 then
    Result := 1.49e-8
  else
    Result := 1.49e-8 * Abs(At);
  if Result = 0 then
    Result := 1.49e-8;
end;

function EvalAt(Node: TASTNode; const VarName: string; At: Double;
  Ctx: TEvalContext; out Err: TCalcError): Double;
var
  Had: Boolean;
  Old: Double;
begin
  Had := Ctx.GetVar(VarName, Old);
  Ctx.SetVar(VarName, At);
  try
    Result := EvalNode(Node, Ctx, Err);
  finally
    if Had then
      Ctx.SetVar(VarName, Old)
    else
      Ctx.DelVar(VarName);
  end;
end;

function NDiffForward(Node: TASTNode; const VarName: string; At, H: Double;
  Ctx: TEvalContext; out Err: TCalcError): Double;
var
  F0, F1: Double;
begin
  Err := ceNone;
  Result := 0;
  if H = 0 then
  begin
    Err := ceDomain;
    Exit;
  end;
  F0 := EvalAt(Node, VarName, At, Ctx, Err);
  if Err <> ceNone then
    Exit;
  F1 := EvalAt(Node, VarName, At + H, Ctx, Err);
  if Err <> ceNone then
    Exit;
  Result := (F1 - F0) / H; // O(h) truncation; use central for O(h^2)
end;

function NDiffBackward(Node: TASTNode; const VarName: string; At, H: Double;
  Ctx: TEvalContext; out Err: TCalcError): Double;
var
  F0, F1: Double;
begin
  Err := ceNone;
  Result := 0;
  if H = 0 then
  begin
    Err := ceDomain;
    Exit;
  end;
  F0 := EvalAt(Node, VarName, At, Ctx, Err);
  if Err <> ceNone then
    Exit;
  F1 := EvalAt(Node, VarName, At - H, Ctx, Err);
  if Err <> ceNone then
    Exit;
  Result := (F0 - F1) / H;
end;

function NDiffCentral(Node: TASTNode; const VarName: string; At, H: Double;
  Ctx: TEvalContext; out Err: TCalcError): Double;
var
  F0, F1: Double;
begin
  Err := ceNone;
  Result := 0;
  if H = 0 then
  begin
    Err := ceDomain;
    Exit;
  end;
  F1 := EvalAt(Node, VarName, At + H, Ctx, Err);
  if Err <> ceNone then
    Exit;
  F0 := EvalAt(Node, VarName, At - H, Ctx, Err);
  if Err <> ceNone then
    Exit;
  Result := (F1 - F0) / (2 * H); // O(h^2)
end;

end.
