{ Foundational limit engine (Phase 25): direct substitution first,
  simplifier-assisted retry second, two-sided numeric approach with a
  stability check third. Heuristic by nature — documented tolerances,
  honest ceNoConvergence otherwise. Infinite limits surface as ±Inf. }
unit PMS.Limits;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Math, PMS.Types, PMS.AST, PMS.Eval, PMS.DiffNum, PMS.Simplify;

function Limit(Node: TASTNode; const VarName: string; At: Double;
  Ctx: TEvalContext; out Value: Double; out Err: TCalcError): Boolean;

implementation

function TryEvalBound(Node: TASTNode; const VarName: string; At: Double;
  Ctx: TEvalContext; out V: Double): Boolean;
var
  E: TCalcError;
begin
  V := EvalAt(Node, VarName, At, Ctx, E);
  Result := E = ceNone;
end;

function Limit(Node: TASTNode; const VarName: string; At: Double;
  Ctx: TEvalContext; out Value: Double; out Err: TCalcError): Boolean;
var
  S: TASTNode;
  H, L, R, PrevL, PrevR: Double;
  I: Integer;
  Stable: Boolean;
begin
  Result := False;
  Value := 0;
  // 1) direct substitution
  if TryEvalBound(Node, VarName, At, Ctx, Value) then
  begin
    Err := ceNone;
    Exit(True);
  end;
  // 2) simplify (cancels removable factors) and retry
  S := Simplify(Node, Ctx);
  try
    if TryEvalBound(S, VarName, At, Ctx, Value) then
    begin
      Err := ceNone;
      Exit(True);
    end;
  finally
    S.Free;
  end;
  // 3) two-sided numeric approach with stability requirement
  PrevL := 0;
  PrevR := 0;
  Stable := False;
  H := 1e-4;
  for I := 1 to 8 do
  begin
    if not TryEvalBound(Node, VarName, At - H, Ctx, L) then
    begin
      Err := ceNoConvergence;
      Exit;
    end;
    if not TryEvalBound(Node, VarName, At + H, Ctx, R) then
    begin
      Err := ceNoConvergence;
      Exit;
    end;
    // blowup with consistent sign: infinite limit
    if (Abs(L) > 1e12) and (Abs(R) > 1e12) and ((L > 0) = (R > 0)) then
    begin
      if L > 0 then
        Value := Infinity
      else
        Value := NegInfinity;
      Err := ceNone;
      Exit(True);
    end;
    if I > 1 then
    begin
      if (Abs(L - R) <= 1e-6 * (1 + (Abs(L) + Abs(R)) / 2)) and
        (Abs(L - PrevL) <= 1e-6 * (1 + Abs(L))) and
        (Abs(R - PrevR) <= 1e-6 * (1 + Abs(R))) then
      begin
        Stable := True;
        Break;
      end;
    end;
    PrevL := L;
    PrevR := R;
    H := H / 10;
  end;
  if not Stable then
  begin
    Err := ceNoConvergence;
    Exit;
  end;
  Value := (L + R) / 2;
  Err := ceNone;
  Result := True;
end;

end.
