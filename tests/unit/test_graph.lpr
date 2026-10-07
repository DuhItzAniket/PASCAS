{ Assert-runner: PMS.Viewport + PMS.Sampler (Phases 32-34, 37). }
program test_graph;

{$mode objfpc}{$H+}

uses
  SysUtils, Math, PMS.Types, PMS.AST, PMS.Parser, PMS.Matrix, PMS.Viewport,
  PMS.Sampler, PMS.Eval;

var
  Fails: Integer = 0;
  Ctx: TEvalContext;

procedure Check(Cond: Boolean; const Msg: string);
begin
  if Cond then
    WriteLn('ok: ', Msg)
  else
  begin
    Inc(Fails);
    WriteLn('FAIL: ', Msg);
  end;
end;

function TreeOf(const Src: string): TASTNode;
var
  E: TCalcError;
  P: Integer;
begin
  if not ParseExpression(Src, Result, E, P) then
  begin
    WriteLn('  (parse failed: ', Src, ')');
    Result := nil;
  end;
end;

var
  V: TViewport;
  SX, SY, X, Y: Double;
  Ticks: TDoubleArray;
  N: TASTNode;
  Line: TSampleLine;
  Lines: TSampleLines;
  E: TCalcError;
  I, Moves: Integer;
  FoundR, FoundT, FoundB: Boolean;
begin
  Ctx := TEvalContext.Create;
  try
    V := VDefault(800, 600);
    VWorldToScreen(V, 0, 0, SX, SY);
    Check((Abs(SX - 400) < 1e-9) and (Abs(SY - 300) < 1e-9), 'origin maps center');
    VScreenToWorld(V, SX, SY, X, Y);
    Check((Abs(X) < 1e-9) and (Abs(Y) < 1e-9), 'roundtrip');
    VZoom(V, 0.5, 0, 0);
    Check((Abs(V.XMax - 5) < 1e-9) and (Abs(V.XMin + 5) < 1e-9), 'zoom halves span');
    VPanPixels(V, 400, 0);
    // drag-style: content follows the cursor, world shifts left by 5 units
    Check((Abs(V.XMin + 10) < 1e-9) and (Abs(V.XMax - 0) < 1e-9), 'pan drags content');
    VNiceTicks(0, 10, 8, Ticks);
    Check((Length(Ticks) = 6) and (Abs(Ticks[1] - 2) < 1e-9), 'nice ticks 0..10');

    V := VDefault(800, 600);
    N := TreeOf('x^2');
    Line := SampleFunc(N, 'x', V, Ctx, E);
    Check((E = ceNone) and (Length(Line) > 700), 'parabola sampled');
    Check(not Line[0].Pen, 'first point moves');
    N.Free;
    N := TreeOf('1/x');
    Line := SampleFunc(N, 'x', V, Ctx, E);
    Moves := 0;
    for I := 0 to High(Line) do
      if not Line[I].Pen then
        Inc(Moves);
    Check((E = ceNone) and (Moves >= 2), 'asymptote gap detected');
    N.Free;
    N := TreeOf('sin(x)');
    Line := SampleFunc(N, 'x', V, Ctx, E);
    Check((E = ceNone) and (Length(Line) > 700), 'sine sampled');
    N.Free;
    // polar: unit circle r=1
    N := TreeOf('1');
    Line := SamplePolar(N, 't', 0, 2 * Pi, V, Ctx, E);
    Check((E = ceNone) and (Length(Line) > 900), 'polar circle sampled');
    for I := 0 to High(Line) do
      if Line[I].Pen then
      begin
        Check(Abs(Sqrt(Sqr(Line[I].X) + Sqr(Line[I].Y)) - 1) < 0.05,
          'polar radius ~1');
        Break;
      end;
    N.Free;
    // implicit: unit circle x^2+y^2-1
    N := TreeOf('x^2+y^2-1');
    SampleImplicit(N, 'x', 'y', V, 120, 120, Ctx, Lines, E);
    // 120x120 over [-10,10]^2: ~44 crossings for the unit circle
    Check((E = ceNone) and (Length(Lines) > 30), 'implicit circle segments');
    FoundR := False;
    FoundT := False;
    FoundB := False;
    for I := 0 to High(Lines) do
    begin
      if Abs(Lines[I][0].X - 1) + Abs(Lines[I][0].Y) < 0.2 then
        FoundR := True;
      if Abs(Lines[I][0].X) + Abs(Lines[I][0].Y - 1) < 0.2 then
        FoundT := True;
      if Abs(Lines[I][0].X) + Abs(Lines[I][0].Y + 1) < 0.2 then
        FoundB := True;
    end;
    Check(FoundR and FoundT and FoundB, 'implicit passes near (1,0),(0,1),(0,-1)');
    N.Free;
  finally
    Ctx.Free;
  end;
  if Fails > 0 then
  begin
    WriteLn(Fails, ' FAILURES');
    Halt(1);
  end;
  WriteLn('All graph tests passed.');
end.
