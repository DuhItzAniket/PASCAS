{ 3D graphing foundation (Phase 39): z = f(x,y) as a heightfield with
  software projection (azimuth/elevation, orthographic). No GPU: the
  desktop strokes projected row-polylines on a Canvas (ADR-007); a real
  accelerated renderer only if measured drawing ever demands it.
  Architecture for full 3D interaction lands here; surface shading and
  picking are the documented next steps. }
unit PMS.Graph3D;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Math, PMS.Types, PMS.AST, PMS.Eval;

type
  TView3D = record
    AzimDeg: Double;  // rotation about Z (0 = looking down +X)
    ElevDeg: Double;  // elevation above XY plane (90 = top-down)
  end;

  THeightField = record
    NX, NY: Integer;
    X0, X1, Y0, Y1: Double;
    H: array of array of Double;
    OK: array of array of Boolean;
  end;

function P3Default: TView3D;
procedure P3Project(X, Y, Z: Double; const VW: TView3D; W, H: Integer;
  Span: Double; out SX, SY: Double);
function P3Sample(Node: TASTNode; const XName, YName: string;
  X0, X1, Y0, Y1: Double; NX, NY: Integer; Ctx: TEvalContext;
  out HF: THeightField; out Err: TCalcError): Boolean;
function P3GoodCount(const HF: THeightField): Integer;

implementation

function P3Default: TView3D;
begin
  Result.AzimDeg := -60;
  Result.ElevDeg := 30;
end;

procedure P3Project(X, Y, Z: Double; const VW: TView3D; W, H: Integer;
  Span: Double; out SX, SY: Double);
var
  Az, El, X1, Y1, Z1, X2: Double;
begin
  Az := VW.AzimDeg * Pi / 180;
  El := VW.ElevDeg * Pi / 180;
  // rotate about Z, then tilt about the new X axis; orthographic drop
  X1 := X * Cos(Az) - Y * Sin(Az);
  Y1 := X * Sin(Az) + Y * Cos(Az);
  Z1 := Z;
  X2 := X1;
  Y1 := Y1 * Cos(El) - Z1 * Sin(El);
  if Span <= 0 then
    Span := 1;
  SX := W / 2 + X2 / Span * (W / 2);
  SY := H / 2 - Y1 / Span * (H / 2);
end;

function P3Sample(Node: TASTNode; const XName, YName: string;
  X0, X1, Y0, Y1: Double; NX, NY: Integer; Ctx: TEvalContext;
  out HF: THeightField; out Err: TCalcError): Boolean;
var
  I, J: Integer;
  X, Y, V: Double;
  HadX, HadY: Boolean;
  OldX, OldY: Double;
  SavedCount: Integer;
begin
  Result := False;
  Err := ceNone;
  if (NX < 4) or (NY < 4) or (NX > 300) or (NY > 300) or (X1 <= X0) or
    (Y1 <= Y0) then
  begin
    Err := ceDomain;
    Exit;
  end;
  HF.NX := NX;
  HF.NY := NY;
  HF.X0 := X0;
  HF.X1 := X1;
  HF.Y0 := Y0;
  HF.Y1 := Y1;
  SetLength(HF.H, NY + 1, NX + 1);
  SetLength(HF.OK, NY + 1, NX + 1);
  HadX := Ctx.GetVar(XName, OldX);
  HadY := Ctx.GetVar(YName, OldY);
  SavedCount := Ctx.OpCount;
  try
    for J := 0 to NY do
      for I := 0 to NX do
      begin
        X := X0 + (X1 - X0) * I / NX;
        Y := Y0 + (Y1 - Y0) * J / NY;
        Ctx.OpCount := 0;
        Ctx.SetVar(XName, X);
        Ctx.SetVar(YName, Y);
        V := EvalNode(Node, Ctx, Err);
        HF.OK[J][I] := (Err = ceNone) and not IsNan(V) and not IsInfinite(V);
        HF.H[J][I] := V;
        if Err <> ceNone then
          Err := ceNone; // per-point failure = hole, not abort
      end;
  finally
    Ctx.OpCount := SavedCount;
    if HadX then
      Ctx.SetVar(XName, OldX)
    else
      Ctx.DelVar(XName);
    if HadY then
      Ctx.SetVar(YName, OldY)
    else
      Ctx.DelVar(YName);
  end;
  Result := True;
end;

function P3GoodCount(const HF: THeightField): Integer;
var
  I, J: Integer;
begin
  Result := 0;
  for J := 0 to HF.NY do
    for I := 0 to HF.NX do
      if HF.OK[J][I] then
        Inc(Result);
end;

end.
