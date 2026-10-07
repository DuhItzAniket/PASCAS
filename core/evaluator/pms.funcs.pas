{ Scientific functions with domain checking. Identifiers are matched
  case-insensitively. Trig honors the context angle mode; inverse trig
  returns in the context mode. log = base 10, ln = natural.
  Conventions (documented, Casio-like): round() is half-away-from-zero,
  cbrt() is real for negatives, 0^0 is handled by the evaluator. }
unit PMS.Funcs;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Math, PMS.Types;

function IsFunction(const Name: string): Boolean;
{ Args must contain exactly 1 value. Returns value; Err = ceNone on success. }
function ApplyFunc(const Name: string; X: Double; Ctx: TEvalContext;
  out Err: TCalcError): Double;
function ToRad(X: Double; M: TAngleMode): Double;
function FromRad(X: Double; M: TAngleMode): Double;

implementation

function ToRad(X: Double; M: TAngleMode): Double;
begin
  case M of
    amDegree: Result := X * Pi / 180.0;
    amGrad: Result := X * Pi / 200.0;
  else
    Result := X;
  end;
end;

function FromRad(X: Double; M: TAngleMode): Double;
begin
  case M of
    amDegree: Result := X * 180.0 / Pi;
    amGrad: Result := X * 200.0 / Pi;
  else
    Result := X;
  end;
end;

function IsFunction(const Name: string): Boolean;
var
  L: string;
begin
  L := LowerCase(Name);
  Result := (L = 'sin') or (L = 'cos') or (L = 'tan') or (L = 'asin') or
    (L = 'acos') or (L = 'atan') or (L = 'sinh') or (L = 'cosh') or
    (L = 'tanh') or (L = 'ln') or (L = 'log') or (L = 'exp') or
    (L = 'sqrt') or (L = 'cbrt') or (L = 'abs') or (L = 'floor') or
    (L = 'ceil') or (L = 'round');
end;

function CbrtReal(X: Double): Double;
var
  I: Integer;
begin
  if X = 0 then
    Exit(0);
  if X < 0 then
    Exit(-CbrtReal(-X));
  Result := Power(X, 1.0 / 3.0);
  // Newton polish on r^3-x=0: Power() alone errs ~1e-7 on exact cubes.
  for I := 1 to 3 do
  begin
    if (Result = 0) or IsInfinite(Result * Result * Result) then
      Break;
    Result := Result - (Result * Result * Result - X) / (3 * Result * Result);
  end;
end;

function PMSFloor(X: Double): Double;
begin
  Result := Int(X);
  if (X < 0) and (Frac(X) <> 0) then
    Result := Result - 1;
end;

function PMSCeil(X: Double): Double;
begin
  Result := Int(X);
  if (X > 0) and (Frac(X) <> 0) then
    Result := Result + 1;
end;

function PMSRound(X: Double): Double;
begin
  if X >= 0 then
    Result := PMSFloor(X + 0.5)
  else
    Result := PMSCeil(X - 0.5);
end;

function ApplyFunc(const Name: string; X: Double; Ctx: TEvalContext;
  out Err: TCalcError): Double;
var
  L: string;
begin
  Err := ceNone;
  Result := 0;
  L := LowerCase(Name);
  if L = 'sin' then
    Result := Sin(ToRad(X, Ctx.AngleMode))
  else if L = 'cos' then
    Result := Cos(ToRad(X, Ctx.AngleMode))
  else if L = 'tan' then
    Result := Tan(ToRad(X, Ctx.AngleMode))
  else if L = 'asin' then
  begin
    if Abs(X) > 1 then
    begin
      Err := ceDomain;
      Exit;
    end;
    Result := FromRad(ArcSin(X), Ctx.AngleMode);
  end
  else if L = 'acos' then
  begin
    if Abs(X) > 1 then
    begin
      Err := ceDomain;
      Exit;
    end;
    Result := FromRad(ArcCos(X), Ctx.AngleMode);
  end
  else if L = 'atan' then
    Result := FromRad(ArcTan(X), Ctx.AngleMode)
  else if L = 'sinh' then
    Result := Sinh(X)
  else if L = 'cosh' then
    Result := Cosh(X)
  else if L = 'tanh' then
    Result := Tanh(X)
  else if L = 'ln' then
  begin
    if X <= 0 then
    begin
      Err := ceDomain;
      Exit;
    end;
    Result := Ln(X);
  end
  else if L = 'log' then
  begin
    if X <= 0 then
    begin
      Err := ceDomain;
      Exit;
    end;
    Result := Log10(X);
  end
  else if L = 'exp' then
  begin
    Result := Exp(X);
    if IsInfinite(Result) then
    begin
      Err := ceOverflow;
      Exit;
    end;
  end
  else if L = 'sqrt' then
  begin
    if X < 0 then
    begin
      Err := ceDomain;
      Exit;
    end;
    Result := Sqrt(X);
  end
  else if L = 'cbrt' then
    Result := CbrtReal(X)
  else if L = 'abs' then
    Result := Abs(X)
  else if L = 'floor' then
    Result := PMSFloor(X)
  else if L = 'ceil' then
    Result := PMSCeil(X)
  else if L = 'round' then
    Result := PMSRound(X)
  else
    Err := ceUnknownFunction;
  if (Err = ceNone) and (IsNan(Result) or IsInfinite(Result)) then
    Err := ceOverflow;
end;

end.
