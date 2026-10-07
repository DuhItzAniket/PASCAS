{ Tree-walking numeric evaluator. One entry for whole expressions
  (EvalText: parse + eval + Ans), one for subtrees (EvalNode).
  Operators honor the op budget and real/complex mode; funcdefs wait for
  Phase 31 (structured ceUnsupported, never a guess). }
unit PMS.Eval;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Math, PMS.Types, PMS.AST, PMS.Parser, PMS.Funcs, PMS.Consts;

{ EvalNode is unit-level; every recursive descent uses parentheses so the
  FPC objfpc self-name quirk (see PHASE-08) can never silently bite. }
function EvalNode(Node: TASTNode; Ctx: TEvalContext; out Err: TCalcError): Double;
function EvalText(const Src: string; Ctx: TEvalContext; out Value: Double;
  out Err: TCalcError; out ErrPos: Integer): Boolean;

implementation

function NeedOps(Ctx: TEvalContext; out Err: TCalcError): Boolean;
begin
  if Ctx.Cancelled then
  begin
    Err := ceCancelled;
    Exit(False);
  end;
  if not Ctx.CheckOps() then
  begin
    Err := ceTooComplex;
    Exit(False);
  end;
  Err := ceNone;
  Result := True;
end;

function Factorial(X: Double; out Err: TCalcError): Double;
var
  I, N: Integer;
begin
  Err := ceNone;
  Result := 0;
  if IsNan(X) or IsInfinite(X) then
  begin
    Err := ceDomain;
    Exit;
  end;
  if X > 170 then
  begin
    Err := ceOverflow;
    Exit;
  end;
  if (X < 0) or (Frac(X) <> 0) then
  begin
    Err := ceDomain;
    Exit;
  end;
  N := Trunc(X);
  Result := 1;
  for I := 2 to N do
    Result := Result * I;
end;

function PowerReal(Base, Expo: Double; out Err: TCalcError): Double;
begin
  Err := ceNone;
  Result := 0;
  if (Base = 0) and (Expo = 0) then
  begin
    Result := 1; // combinatorial convention, documented
    Exit;
  end;
  if (Base = 0) and (Expo < 0) then
  begin
    Err := ceDivisionByZero;
    Exit;
  end;
  if (Base < 0) and (Frac(Expo) <> 0) then
  begin
    Err := ceDomain; // real mode; complex lands in Phase 15
    Exit;
  end;
  Result := Power(Base, Expo);
  if IsNan(Result) then
    Err := ceDomain
  else if IsInfinite(Result) then
    Err := ceOverflow;
end;

function EvalNode(Node: TASTNode; Ctx: TEvalContext; out Err: TCalcError): Double;
var
  A, B: Double;
  F: TFuncNode;
  Args: array of Double;
begin
  Result := 0;
  Err := ceNone;
  if not NeedOps(Ctx, Err) then
    Exit;
  if Node is TNumberNode then
    Result := TNumberNode(Node).Value
  else if Node is TVarNode then
  begin
    if Ctx.GetVar(TVarNode(Node).Name, Result) then
      Exit
    else if SameText(TVarNode(Node).Name, 'ans') and Ctx.HasAns then
    begin
      Result := Ctx.Ans;
      Exit;
    end
    else if GetConstant(TVarNode(Node).Name, Result) then
      Exit
    else
      Err := ceUnknownVariable;
  end
  else if Node is TUnaryNode then
  begin
    A := EvalNode(TUnaryNode(Node).Child, Ctx, Err);
    if Err <> ceNone then
      Exit;
    case TUnaryNode(Node).Op of
      '-': Result := -A;
      '+': Result := A;
      '%': Result := A / 100.0;
      '!': Result := Factorial(A, Err);
    else
      Err := ceUnsupported;
    end;
  end
  else if Node is TBinaryNode then
  begin
    A := EvalNode(TBinaryNode(Node).Left, Ctx, Err);
    if Err <> ceNone then
      Exit;
    B := EvalNode(TBinaryNode(Node).Right, Ctx, Err);
    if Err <> ceNone then
      Exit;
    case TBinaryNode(Node).Op of
      '+': Result := A + B;
      '-': Result := A - B;
      '*': Result := A * B;
      '/':
        if B = 0 then
          Err := ceDivisionByZero
        else
          Result := A / B;
      '^': Result := PowerReal(A, B, Err);
      'm':
        if B = 0 then
          Err := ceDivisionByZero
        else
          Result := A - Trunc(A / B) * B;
    else
      Err := ceUnsupported;
    end;
    if (Err = ceNone) and (IsNan(Result) or IsInfinite(Result)) then
      Err := ceOverflow;
  end
  else if Node is TFuncNode then
  begin
    F := TFuncNode(Node);
    if Length(F.Args) <> 1 then
    begin
      Err := ceSyntax; // all v1 functions are single-argument
      Exit;
    end;
    SetLength(Args, 1);
    Args[0] := EvalNode(F.Args[0], Ctx, Err);
    if Err <> ceNone then
      Exit;
    Result := ApplyFunc(F.Name, Args[0], Ctx, Err);
  end
  else if Node is TAssignNode then
  begin
    Result := EvalNode(TAssignNode(Node).Expr, Ctx, Err);
    if Err <> ceNone then
      Exit;
    Ctx.SetVar(TAssignNode(Node).Name, Result);
  end
  else if Node is TFuncDefNode then
    Err := ceUnsupported // definitions evaluate in Phase 31
  else
    Err := ceUnsupported;
end;

function EvalText(const Src: string; Ctx: TEvalContext; out Value: Double;
  out Err: TCalcError; out ErrPos: Integer): Boolean;
var
  Root: TASTNode;
begin
  Value := 0;
  if not ParseExpression(Src, Root, Err, ErrPos) then
    Exit(False);
  try
    Value := EvalNode(Root, Ctx, Err);
    if Err <> ceNone then
      Exit(False);
    Ctx.Ans := Value;
    Ctx.HasAns := True;
    ErrPos := 0;
    Result := True;
  finally
    Root.Free;
  end;
end;

end.
