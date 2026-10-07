{ Adaptive function sampler (Phases 33-34) + parametric/polar/implicit
  modes (Phase 37). Emits screen-space polylines with move/draw flags —
  LCL and Canvas2D just stroke them (ADR-007). Strategy: one evaluation
  per pixel column, recursive midpoint subdivision where the curve bends
  (cap PMSMaxSamples), pen-up gaps on errors/NaN/Infinity/asymptotes. }
unit PMS.Sampler;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Math, PMS.Types, PMS.AST, PMS.Eval, PMS.DiffNum, PMS.Viewport;

type
  TSamplePt = record
    SX, SY: Double; // screen pixels
    Pen: Boolean;   // False = move (gap), True = draw
    X, Y: Double;   // world coords (for inspection)
  end;

  TSampleLine = array of TSamplePt;
  TSampleLines = array of TSampleLine;

function SampleFunc(Node: TASTNode; const VarName: string;
  const V: TViewport; Ctx: TEvalContext; out Err: TCalcError): TSampleLine;
function SampleParam(XNode, YNode: TASTNode; const TName: string;
  T0, T1: Double; const V: TViewport; Ctx: TEvalContext;
  out Err: TCalcError): TSampleLine;
function SamplePolar(RNode: TASTNode; const TName: string;
  T0, T1: Double; const V: TViewport; Ctx: TEvalContext;
  out Err: TCalcError): TSampleLine;
procedure SampleImplicit(Node: TASTNode; const XName, YName: string;
  const V: TViewport; NX, NY: Integer; Ctx: TEvalContext;
  out Lines: TSampleLines; out Err: TCalcError);

implementation

const
  JumpTol = 25.0; // world-height multiples that smell like asymptotes
  BendTol = 0.002; // fraction of world height worth subdividing for

function EvalOK(Node: TASTNode; const VarName: string; At: Double;
  Ctx: TEvalContext; out Y: Double): Boolean;
var
  E: TCalcError;
begin
  Y := EvalAt(Node, VarName, At, Ctx, E);
  Result := (E = ceNone) and not IsNan(Y) and not IsInfinite(Y);
end;

procedure EmitPt(var Line: TSampleLine; const V: TViewport; X, Y: Double;
  Pen: Boolean);
begin
  if Length(Line) >= PMSMaxSamples then
    Exit;
  SetLength(Line, Length(Line) + 1);
  VWorldToScreen(V, X, Y, Line[High(Line)].SX, Line[High(Line)].SY);
  Line[High(Line)].X := X;
  Line[High(Line)].Y := Y;
  if Length(Line) = 1 then
    Line[High(Line)].Pen := False // first point of a run always moves
  else
    Line[High(Line)].Pen := Pen;
end;

function SampleFunc(Node: TASTNode; const VarName: string;
  const V: TViewport; Ctx: TEvalContext; out Err: TCalcError): TSampleLine;
var
  Line: TSampleLine;
  YRange: Double;
  N, I: Integer;
  X0, Y0, X1, Y1: Double;
  OK0, OK1: Boolean;

  procedure Walk(AX0, AY0: Double; AOK0: Boolean; AX1, AY1: Double;
    AOK1: Boolean; D: Integer);
  var
    XM, YM, YLin: Double;
    OKM: Boolean;
  begin
    if (D <= 0) or (Length(Line) >= PMSMaxSamples) then
      Exit;
    if not (AOK0 and AOK1) then
      Exit;
    if Abs(AY1 - AY0) > JumpTol * YRange then
    begin
      // possible asymptote: verify the middle before stroking across
      XM := (AX0 + AX1) / 2;
      OKM := EvalOK(Node, VarName, XM, Ctx, YM);
      if not OKM or (Abs(YM - (AY0 + AY1) / 2) > Abs(AY1 - AY0)) then
        Exit; // leave the gap
    end;
    XM := (AX0 + AX1) / 2;
    OKM := EvalOK(Node, VarName, XM, Ctx, YM);
    if not OKM then
      Exit;
    YLin := (AY0 + AY1) / 2;
    if Abs(YM - YLin) > BendTol * YRange then
    begin
      Walk(AX0, AY0, AOK0, XM, YM, True, D - 1);
      EmitPt(Line, V, XM, YM, True);
      Walk(XM, YM, True, AX1, AY1, AOK1, D - 1);
    end;
  end;

begin
  Err := ceNone;
  SetLength(Line, 0);
  Result := nil;
  if (V.W < 8) or (V.H < 8) or (V.XMax <= V.XMin) or (V.YMax <= V.YMin) then
  begin
    Err := ceDomain;
    Exit;
  end;
  YRange := V.YMax - V.YMin;
  N := V.W;
  if N < 64 then
    N := 64;
  if N > 1024 then
    N := 1024;
  X0 := V.XMin;
  OK0 := EvalOK(Node, VarName, X0, Ctx, Y0);
  if OK0 then
    EmitPt(Line, V, X0, Y0, False);
  for I := 1 to N do
  begin
    X1 := V.XMin + (V.XMax - V.XMin) * I / N;
    OK1 := EvalOK(Node, VarName, X1, Ctx, Y1);
    if OK0 and OK1 then
      Walk(X0, Y0, True, X1, Y1, True, 4);
    if OK1 then
      EmitPt(Line, V, X1, Y1, OK0); // Pen=False after a gap: moves
    OK0 := OK1;
    X0 := X1;
    Y0 := Y1;
  end;
  Err := ceNone;
  Result := Line;
end;

function SampleParam(XNode, YNode: TASTNode; const TName: string;
  T0, T1: Double; const V: TViewport; Ctx: TEvalContext;
  out Err: TCalcError): TSampleLine;
var
  N, I: Integer;
  T, X, Y: Double;
  PrevOK: Boolean;
begin
  Err := ceNone;
  SetLength(Result, 0);
  if (T1 <= T0) or (V.W < 8) then
  begin
    Err := ceDomain;
    Exit;
  end;
  N := 1024;
  PrevOK := False;
  for I := 0 to N do
  begin
    T := T0 + (T1 - T0) * I / N;
    if EvalOK(XNode, TName, T, Ctx, X) and EvalOK(YNode, TName, T, Ctx, Y) then
    begin
      EmitPt(Result, V, X, Y, PrevOK);
      PrevOK := True;
    end
    else
      PrevOK := False;
  end;
end;

function SamplePolar(RNode: TASTNode; const TName: string;
  T0, T1: Double; const V: TViewport; Ctx: TEvalContext;
  out Err: TCalcError): TSampleLine;
var
  N, I: Integer;
  T, R: Double;
  PrevOK: Boolean;
begin
  Err := ceNone;
  SetLength(Result, 0);
  if (T1 <= T0) or (V.W < 8) then
  begin
    Err := ceDomain;
    Exit;
  end;
  N := 1024;
  PrevOK := False;
  for I := 0 to N do
  begin
    T := T0 + (T1 - T0) * I / N;
    if EvalOK(RNode, TName, T, Ctx, R) then
    begin
      EmitPt(Result, V, R * Cos(T), R * Sin(T), PrevOK);
      PrevOK := True;
    end
    else
      PrevOK := False;
  end;
end;

procedure SampleImplicit(Node: TASTNode; const XName, YName: string;
  const V: TViewport; NX, NY: Integer; Ctx: TEvalContext;
  out Lines: TSampleLines; out Err: TCalcError);
var
  FX: array of array of Double;
  FOK: array of array of Boolean;
  I, J: Integer;
  HadX, HadY: Boolean;
  OldX, OldY: Double;

  function FAt(XX, YY: Double; out VV: Double): Boolean;
  var
    E: TCalcError;
    SavedCount: Integer;
  begin
    // same per-point budget rule as EvalAt (see PMS.DiffNum)
    SavedCount := Ctx.OpCount;
    Ctx.OpCount := 0;
    Ctx.SetVar(XName, XX);
    Ctx.SetVar(YName, YY);
    VV := EvalNode(Node, Ctx, E);
    Ctx.OpCount := SavedCount;
    Result := (E = ceNone) and not IsNan(VV) and not IsInfinite(VV);
  end;

  procedure AddSeg(X1, Y1, X2, Y2: Double);
  var
    L: TSampleLine;
  begin
    if Length(Lines) >= PMSMaxSamples then
      Exit;
    SetLength(L, 2);
    VWorldToScreen(V, X1, Y1, L[0].SX, L[0].SY);
    L[0].X := X1;
    L[0].Y := Y1;
    L[0].Pen := False;
    VWorldToScreen(V, X2, Y2, L[1].SX, L[1].SY);
    L[1].X := X2;
    L[1].Y := Y2;
    L[1].Pen := True;
    SetLength(Lines, Length(Lines) + 1);
    Lines[High(Lines)] := L;
  end;

  function CellX(K: Integer): Double;
  begin
    Result := V.XMin + (V.XMax - V.XMin) * K / NX;
  end;

  function CellY(K: Integer): Double;
  begin
    Result := V.YMin + (V.YMax - V.YMin) * K / NY;
  end;

  // crossing on the edge between grid nodes A and B (True + point if so)
  function Edge(JA, IA, JB, IB: Integer; out XX, YY: Double): Boolean;
  var
    FA, FB, T: Double;
  begin
    Result := False;
    if not (FOK[JA][IA] and FOK[JB][IB]) then
      Exit;
    FA := FX[JA][IA];
    FB := FX[JB][IB];
    if (FA < 0) = (FB < 0) then
      Exit; // same side (zeros: both non-negative is fine to skip)
    if FA = FB then
      Exit;
    T := Abs(FA) / (Abs(FA) + Abs(FB));
    XX := CellX(IA) * (1 - T) + CellX(IB) * T;
    YY := CellY(JA) * (1 - T) + CellY(JB) * T;
    Result := True;
  end;

var
  Pts: array[0..3] of Double; // x0,y0,x1,y1,... as flat pairs
  NP: Integer;
  X, Y, F: Double;
  CX, CY: Double;
  K: Integer;
begin
  Err := ceNone;
  SetLength(Lines, 0);
  if (NX < 8) or (NY < 8) or (NX > 300) or (NY > 300) then
  begin
    NX := 120;
    NY := 120;
  end;
  HadX := Ctx.GetVar(XName, OldX);
  HadY := Ctx.GetVar(YName, OldY);
  try
    SetLength(FX, NY + 1, NX + 1);
    SetLength(FOK, NY + 1, NX + 1);
    for J := 0 to NY do
      for I := 0 to NX do
      begin
        X := CellX(I);
        Y := CellY(J);
        FOK[J][I] := FAt(X, Y, F);
        FX[J][I] := F;
      end;
    for J := 0 to NY - 1 do
      for I := 0 to NX - 1 do
      begin
        // corners: BL=(J,I) BR=(J,I+1) TR=(J+1,I+1) TL=(J+1,I)
        NP := 0;
        if Edge(J, I, J, I + 1, X, Y) then
        begin
          Pts[0] := X;
          Pts[1] := Y;
          Inc(NP);
        end;
        if Edge(J, I + 1, J + 1, I + 1, X, Y) then
        begin
          Pts[NP * 2] := X;
          Pts[NP * 2 + 1] := Y;
          Inc(NP);
        end;
        if Edge(J + 1, I + 1, J + 1, I, X, Y) then
        begin
          Pts[NP * 2] := X;
          Pts[NP * 2 + 1] := Y;
          Inc(NP);
        end;
        if Edge(J + 1, I, J, I, X, Y) then
        begin
          Pts[NP * 2] := X;
          Pts[NP * 2 + 1] := Y;
          Inc(NP);
        end;
        if NP = 2 then
          AddSeg(Pts[0], Pts[1], Pts[2], Pts[3])
        else if NP > 2 then
        begin
          CX := 0;
          CY := 0;
          for K := 0 to NP - 1 do
          begin
            CX := CX + Pts[K * 2];
            CY := CY + Pts[K * 2 + 1];
          end;
          CX := CX / NP;
          CY := CY / NP;
          for K := 0 to NP - 1 do
            AddSeg(Pts[K * 2], Pts[K * 2 + 1], CX, CY);
        end;
      end;
  finally
    if HadX then
      Ctx.SetVar(XName, OldX)
    else
      Ctx.DelVar(XName);
    if HadY then
      Ctx.SetVar(YName, OldY)
    else
      Ctx.DelVar(YName);
  end;
end;

end.
