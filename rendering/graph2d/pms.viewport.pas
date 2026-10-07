{ 2D coordinate system and viewport (Phase 32): world<->screen mapping,
  zoom-around-point, pixel panning, and "nice" axis ticks. Pure math —
  the LCL/Canvas side only strokes what this computes. }
unit PMS.Viewport;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Math, PMS.Matrix;

type
  TViewport = record
    XMin, XMax, YMin, YMax: Double;
    W, H: Integer; // screen size in pixels
  end;

function VDefault(W, H: Integer): TViewport;
procedure VWorldToScreen(const V: TViewport; X, Y: Double;
  out SX, SY: Double);
procedure VScreenToWorld(const V: TViewport; SX, SY: Double;
  out X, Y: Double);
procedure VZoom(var V: TViewport; Factor, CX, CY: Double);
procedure VPanPixels(var V: TViewport; DX, DY: Integer);
procedure VNiceTicks(Lo, Hi: Double; MaxTicks: Integer;
  out Ticks: TDoubleArray);

implementation

function VDefault(W, H: Integer): TViewport;
begin
  Result.XMin := -10;
  Result.XMax := 10;
  Result.YMin := -10;
  Result.YMax := 10;
  Result.W := W;
  Result.H := H;
end;

procedure VWorldToScreen(const V: TViewport; X, Y: Double;
  out SX, SY: Double);
begin
  SX := (X - V.XMin) / (V.XMax - V.XMin) * V.W;
  SY := V.H - (Y - V.YMin) / (V.YMax - V.YMin) * V.H;
end;

procedure VScreenToWorld(const V: TViewport; SX, SY: Double;
  out X, Y: Double);
begin
  X := V.XMin + SX / V.W * (V.XMax - V.XMin);
  Y := V.YMin + (V.H - SY) / V.H * (V.YMax - V.YMin);
end;

procedure VZoom(var V: TViewport; Factor, CX, CY: Double);
begin
  // Factor < 1 zooms in. CX/CY (world) stays fixed on screen.
  if Factor <= 0 then
    Exit;
  V.XMin := CX + (V.XMin - CX) * Factor;
  V.XMax := CX + (V.XMax - CX) * Factor;
  V.YMin := CY + (V.YMin - CY) * Factor;
  V.YMax := CY + (V.YMax - CY) * Factor;
end;

procedure VPanPixels(var V: TViewport; DX, DY: Integer);
var
  Wx, Wy: Double;
begin
  Wx := (V.XMax - V.XMin) / V.W * DX;
  Wy := (V.YMax - V.YMin) / V.H * DY;
  V.XMin := V.XMin - Wx;
  V.XMax := V.XMax - Wx;
  V.YMin := V.YMin + Wy;
  V.YMax := V.YMax + Wy;
end;

procedure VNiceTicks(Lo, Hi: Double; MaxTicks: Integer;
  out Ticks: TDoubleArray);
var
  Span, Raw, Mag, Norm, Step, T: Double;
  N: Integer;
begin
  SetLength(Ticks, 0);
  if (MaxTicks < 2) or (Hi <= Lo) or IsNan(Lo) or IsNan(Hi) or
    IsInfinite(Lo) or IsInfinite(Hi) then
    Exit;
  Span := Hi - Lo;
  Raw := Span / MaxTicks;
  Mag := Power(10, Floor(Log10(Raw)));
  Norm := Raw / Mag;
  // smallest nice step >= raw: tick count stays within budget
  if Norm <= 1 then
    Step := 1
  else if Norm <= 2 then
    Step := 2
  else if Norm <= 5 then
    Step := 5
  else
    Step := 10;
  Step := Step * Mag;
  T := Ceil(Lo / Step) * Step;
  if T < Lo then
    T := Lo; // float safety
  N := 0;
  while (T <= Hi) and (N <= MaxTicks + 1) do
  begin
    SetLength(Ticks, N + 1);
    Ticks[N] := T;
    Inc(N);
    T := T + Step;
  end;
end;

end.
