{ Core domain model: structured errors + evaluation context.
  No GUI, no I/O, no globals holding user state. }
unit PMS.Types;

{$mode objfpc}{$H+}

interface

const
  PMSMaxInputLen = 4096;
  PMSMaxDepth = 64;
  PMSMaxOps = 10000;
  PMSMaxMatrixDim = 64;
  PMSMaxIterations = 200;
  PMSMaxSamples = 4096;

type
  TAngleMode = (amRadian, amDegree, amGrad);

  { Real mode: domain errors for sqrt/log of negatives etc.
    Complex mode: reserved for Phase 15 (evaluator branches there). }
  TNumberMode = (nmReal, nmComplex);

  TCalcError = (ceNone, ceSyntax, ceUnknownFunction, ceUnknownVariable,
    ceDivisionByZero, ceDomain, ceOverflow, ceUnderflow, ceInvalidMatrixDim,
    ceNoConvergence, ceUnsupported, ceRecursionLimit, ceCancelled, ceTooComplex);

function CalcErrorMessage(E: TCalcError): string;

type
  TBinding = record
    Name: string;
    Value: Double;
  end;

  { Explicit evaluation state. Owner creates, uses, frees. }
  TEvalContext = class
  private
    FVars: array of TBinding;
    function Find(const Name: string): Integer;
  public
    AngleMode: TAngleMode;
    NumberMode: TNumberMode;
    Ans: Double;
    HasAns: Boolean;
    OpCount: Integer;
    Cancelled: Boolean;
    constructor Create;
    procedure SetVar(const Name: string; Value: Double);
    function GetVar(const Name: string; out Value: Double): Boolean;
    procedure DelVar(const Name: string); // for scoped solving/limits
    { True while inside the op budget; increments the counter. }
    function CheckOps: Boolean;
  end;

implementation

function CalcErrorMessage(E: TCalcError): string;
begin
  case E of
    ceNone: Result := 'ok';
    ceSyntax: Result := 'Syntax error: could not parse the expression.';
    ceUnknownFunction: Result := 'Unknown function.';
    ceUnknownVariable: Result := 'Unknown variable.';
    ceDivisionByZero: Result := 'Division by zero.';
    ceDomain: Result := 'Value outside the function domain (e.g. log of a negative number in real mode).';
    ceOverflow: Result := 'Numeric overflow.';
    ceUnderflow: Result := 'Numeric underflow.';
    ceInvalidMatrixDim: Result := 'Incompatible matrix dimensions.';
    ceNoConvergence: Result := 'Method did not converge.';
    ceUnsupported: Result := 'Operation not supported (yet).';
    ceRecursionLimit: Result := 'Expression too deeply nested.';
    ceCancelled: Result := 'Computation cancelled.';
    ceTooComplex: Result := 'Expression exceeds safety limits (length/operations).';
  end;
end;

constructor TEvalContext.Create;
begin
  inherited Create;
  AngleMode := amRadian;
  NumberMode := nmReal;
  Ans := 0;
  HasAns := False;
  OpCount := 0;
  Cancelled := False;
  SetLength(FVars, 0);
end;

function TEvalContext.Find(const Name: string): Integer;
var
  I: Integer;
begin
  for I := 0 to High(FVars) do
    if FVars[I].Name = Name then
      Exit(I);
  Result := -1;
end;

procedure TEvalContext.SetVar(const Name: string; Value: Double);
var
  I: Integer;
begin
  I := Find(Name);
  if I >= 0 then
    FVars[I].Value := Value
  else
  begin
    SetLength(FVars, Length(FVars) + 1);
    FVars[High(FVars)].Name := Name;
    FVars[High(FVars)].Value := Value;
  end;
end;

function TEvalContext.GetVar(const Name: string; out Value: Double): Boolean;
var
  I: Integer;
begin
  I := Find(Name);
  Result := I >= 0;
  if Result then
    Value := FVars[I].Value
  else
    Value := 0;
end;

function TEvalContext.CheckOps: Boolean;
begin
  Inc(OpCount);
  Result := (OpCount <= PMSMaxOps) and not Cancelled;
end;

procedure TEvalContext.DelVar(const Name: string);
var
  I, J: Integer;
begin
  I := Find(Name);
  if I < 0 then
    Exit;
  for J := I to High(FVars) - 1 do
    FVars[J] := FVars[J + 1];
  SetLength(FVars, Length(FVars) - 1);
end;

end.
