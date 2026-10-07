{ Graph analysis (Phase 38): roots, intersections, extrema, tangents,
  area, point inspection — over *expanded* workspace expressions with
  the store context. Numeric, tolerance-honest, never crashing on
  pathological input. }
unit PMS.Analysis;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Math, PMS.Types, PMS.AST, PMS.Eval, PMS.Matrix, PMS.DiffNum,
  PMS.IntNum, PMS.Solve;

function ANRoots(Node: TASTNode; Ctx: TEvalContext; const VarName: string;
  XMin, XMax: Double; out Roots: TDoubleArray; out Err: TCalcError): Boolean;
function ANIntersect(A, B: TASTNode; Ctx: TEvalContext; const VarName: string;
  XMin, XMax: Double; out Xs: TDoubleArray; out Err: TCalcError): Boolean;
function ANExtrema(Node: TASTNode; Ctx: TEvalContext; const VarName: string;
  XMin, XMax: Double; out XMinPt, XMaxPt: Double; out HasMin, HasMax: Boolean;
  out Err: TCalcError): Boolean;
function ANTangent(Node: TASTNode; Ctx: TEvalContext; const VarName: string;
  At: Double; out Y, Slope: Double; out Err: TCalcError): Boolean;
function ANArea(Node: TASTNode; Ctx: TEvalContext; const VarName: string;
  A, B: Double; out Area: Double; out Err: TCalcError): Boolean;
function ANInspect(Node: TASTNode; Ctx: TEvalContext; const VarName: string;
  At: Double; out Y: Double; out Err: TCalcError): Boolean;

implementation

function ANRoots(Node: TASTNode; Ctx: TEvalContext; const VarName: string;
  XMin, XMax: Double; out Roots: TDoubleArray; out Err: TCalcError): Boolean;
var
  N, I: Integer;
  A, B, FA, FB, R: Double;
  It: Integer;
begin
  Result := False;
  SetLength(Roots, 0);
  if (XMax <= XMin) then
  begin
    Err := ceDomain;
    Exit;
  end;
  N := 256;
  A := XMin;
  FA := EvalAt(Node, VarName, A, Ctx, Err);
  if Err <> ceNone then
    Exit;
  for I := 1 to N do
  begin
    B := XMin + (XMax - XMin) * I / N;
    FB := EvalAt(Node, VarName, B, Ctx, Err);
    if Err <> ceNone then
      Exit;
    if (FA = 0) then
    begin
      SetLength(Roots, Length(Roots) + 1);
      Roots[High(Roots)] := A;
    end;
    if FA * FB < 0 then
    begin
      if not SolveBisection(Node, VarName, A, B, 1e-9, Ctx, R, It, Err) then
        Exit;
      SetLength(Roots, Length(Roots) + 1);
      Roots[High(Roots)] := R;
    end;
    A := B;
    FA := FB;
  end;
  Err := ceNone;
  Result := True;
end;

function ANIntersect(A, B: TASTNode; Ctx: TEvalContext; const VarName: string;
  XMin, XMax: Double; out Xs: TDoubleArray; out Err: TCalcError): Boolean;
var
  D: TASTNode;
begin
  D := TBinaryNode.Create('-', A.Clone(), B.Clone());
  try
    Result := ANRoots(D, Ctx, VarName, XMin, XMax, Xs, Err);
  finally
    D.Free;
  end;
end;

function GoldenMax(Node: TASTNode; Ctx: TEvalContext; const VarName: string;
  A, B: Double; WantMax: Boolean; out X: Double;
  out Err: TCalcError): Boolean;
const
  GR = 0.6180339887498949;
var
  C, D, FC, FD: Double;
  I: Integer;
begin
  Result := False;
  X := A;
  for I := 1 to 60 do
  begin
    C := B - GR * (B - A);
    D := A + GR * (B - A);
    FC := EvalAt(Node, VarName, C, Ctx, Err);
    if Err <> ceNone then
      Exit;
    FD := EvalAt(Node, VarName, D, Ctx, Err);
    if Err <> ceNone then
      Exit;
    if (FC > FD) = WantMax then
      B := D
    else
      A := C;
    if Abs(B - A) < 1e-9 * (1 + Abs(A) + Abs(B)) then
      Break;
  end;
  X := (A + B) / 2;
  Err := ceNone;
  Result := True;
end;

function ANExtrema(Node: TASTNode; Ctx: TEvalContext; const VarName: string;
  XMin, XMax: Double; out XMinPt, XMaxPt: Double; out HasMin, HasMax: Boolean;
  out Err: TCalcError): Boolean;
var
  N, I: Integer;
  X0, X1, X2, Y0, Y1, Y2, BX: Double;
begin
  Result := False;
  HasMin := False;
  HasMax := False;
  XMinPt := 0;
  XMaxPt := 0;
  if XMax <= XMin then
  begin
    Err := ceDomain;
    Exit;
  end;
  N := 512;
  X0 := XMin;
  Y0 := EvalAt(Node, VarName, X0, Ctx, Err);
  if Err <> ceNone then
    Exit;
  X1 := XMin + (XMax - XMin) / N;
  Y1 := EvalAt(Node, VarName, X1, Ctx, Err);
  if Err <> ceNone then
    Exit;
  for I := 2 to N do
  begin
    X2 := XMin + (XMax - XMin) * I / N;
    Y2 := EvalAt(Node, VarName, X2, Ctx, Err);
    if Err <> ceNone then
      Exit;
    if (Y1 < Y0) and (Y1 < Y2) then
    begin
      if GoldenMax(Node, Ctx, VarName, X0, X2, False, BX, Err) and (Err = ceNone) then
      begin
        XMinPt := BX;
        HasMin := True;
      end;
    end;
    if (Y1 > Y0) and (Y1 > Y2) then
    begin
      if GoldenMax(Node, Ctx, VarName, X0, X2, True, BX, Err) and (Err = ceNone) then
      begin
        XMaxPt := BX;
        HasMax := True;
      end;
    end;
    X0 := X1;
    Y0 := Y1;
    X1 := X2;
    Y1 := Y2;
  end;
  Err := ceNone;
  Result := True;
end;

function ANTangent(Node: TASTNode; Ctx: TEvalContext; const VarName: string;
  At: Double; out Y, Slope: Double; out Err: TCalcError): Boolean;
begin
  Result := False;
  Y := EvalAt(Node, VarName, At, Ctx, Err);
  if Err <> ceNone then
    Exit;
  Slope := NDiffCentral(Node, VarName, At, DefaultH(At), Ctx, Err);
  if Err <> ceNone then
    Exit;
  Result := True;
end;

function ANArea(Node: TASTNode; Ctx: TEvalContext; const VarName: string;
  A, B: Double; out Area: Double; out Err: TCalcError): Boolean;
begin
  Area := IAdaptSimp(Node, VarName, A, B, 1e-9, Ctx, Err);
  Result := Err = ceNone;
end;

function ANInspect(Node: TASTNode; Ctx: TEvalContext; const VarName: string;
  At: Double; out Y: Double; out Err: TCalcError): Boolean;
begin
  Y := EvalAt(Node, VarName, At, Ctx, Err);
  Result := Err = ceNone;
end;

end.
