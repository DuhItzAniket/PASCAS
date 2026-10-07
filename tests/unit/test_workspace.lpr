{ Assert-runner: Workspace + Analysis + Graph3D (Phases 35, 36, 38, 39). }
program test_workspace;

{$mode objfpc}{$H+}

uses
  SysUtils, Math, PMS.Types, PMS.AST, PMS.Matrix, PMS.Viewport, PMS.Sampler,
  PMS.Workspace, PMS.Analysis, PMS.Graph3D, PMS.Parser, PMS.Eval;

var
  Fails: Integer = 0;

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

var
  W: TWorkspace;
  V: TViewport;
  E: TCalcError;
  P: Integer;
  Lines: TSampleLines;
  Roots: TDoubleArray;
  XMinPt, XMaxPt, Y, Slope, Area: Double;
  HasMin, HasMax: Boolean;
  N: TASTNode;
  Exp: TASTNode;
  Ctx: TEvalContext;
  VW3: TView3D;
  HF: THeightField;
  SX, SY: Double;
begin
  W := TWorkspace.Create;
  try
    V := VDefault(800, 600);
    Check(W.AddExpr('x^2', wkFuncY, E, P) = 0, 'add parabola');
    Check(W.AddExpr('sin(x)', wkFuncY, E, P) = 1, 'add sine');
    Check(W.EntryCount = 2, 'two entries');
    Lines := W.SampleEntry(0, V, E);
    Check((E = ceNone) and (Length(Lines) = 1) and (Length(Lines[0]) > 700),
      'sample entry');
    W.SetVisible(1, False);
    Lines := W.SampleEntry(1, V, E);
    Check((E = ceNone) and (Length(Lines) = 0), 'hidden entry samples empty');
    W.SetVisible(1, True);
    // reactivity: a=2, entry uses a
    Check(W.DefineVar('a = 2', E, P), 'define a');
    Check(W.AddExpr('a*x', wkFuncY, E, P) = 2, 'add a*x');
    Lines := W.SampleEntry(2, V, E);
    Check((E = ceNone) and (Length(Lines[0]) > 700), 'sample with var');
    Check(W.SetVar('a', 5), 'slide a');
    Check(W.BindParam('a', -5, 5, 0.1), 'bind slider');
    Check(W.ParamCount = 1, 'one param');
    Lines := W.SampleEntry(2, V, E);
    Check(E = ceNone, 'resample after slide');
    Check(W.AddExpr('t*t-2;t', wkParam, E, P) = 3, 'add parametric');
    Check(W.AddExpr('x^2+y^2-1', wkImplicit, E, P) = 4, 'add implicit');
    Lines := W.SampleEntry(4, V, E);
    Check((E = ceNone) and (Length(Lines) > 20), 'sample implicit entry');
    W.DeleteEntry(4);
    Check(W.EntryCount = 4, 'delete entry');
  finally
    W.Free;
  end;

  // analysis over plain expressions
  Ctx := TEvalContext.Create;
  try
    ParseExpression('x^2-4', N, E, P);
    Exp := N; // already expanded (no user funcs)
    Check(ANRoots(Exp, Ctx, 'x', -5, 5, Roots, E) and (Length(Roots) = 2),
      'roots of x^2-4');
    Check((Abs(Roots[0] + 2) < 1e-6) and (Abs(Roots[1] - 2) < 1e-6),
      'roots are -2, 2');
    Check(ANExtrema(Exp, Ctx, 'x', -5, 5, XMinPt, XMaxPt, HasMin, HasMax, E) and
      HasMin and (Abs(XMinPt) < 1e-4), 'min at 0');
    Check(ANTangent(Exp, Ctx, 'x', 2, Y, Slope, E) and (Abs(Y - 0) < 1e-9) and
      (Abs(Slope - 4) < 1e-4), 'tangent at 2: y=0 slope=4');
    Check(ANArea(Exp, Ctx, 'x', 0, 2, Area, E) and
      (Abs(Area + 16 / 3) < 1e-6), 'area 0..2 = -16/3');
    N.Free;
    ParseExpression('sin(x)', N, E, P);
    Exp := N;
    ParseExpression('cos(x)', N, E, P);
    Check(ANIntersect(Exp, N, Ctx, 'x', 0, 3, Roots, E) and
      (Length(Roots) = 1) and (Abs(Roots[0] - Pi / 4) < 1e-6),
      'sin=cos at pi/4');
    Exp.Free;
    N.Free;
  finally
    Ctx.Free;
  end;

  // 3D: projection sanity + heightfield
  VW3 := P3Default;
  P3Project(0, 0, 0, VW3, 800, 600, 20, SX, SY);
  Check((Abs(SX - 400) < 1e-9) and (Abs(SY - 300) < 1e-9), 'origin projects center');
  Ctx := TEvalContext.Create;
  try
    ParseExpression('x^2+y^2', N, E, P);
    Check(P3Sample(N, 'x', 'y', -2, 2, -2, 2, 20, 20, Ctx, HF, E) and
      (P3GoodCount(HF) = 441), 'heightfield 21x21 all good');
    Check(Abs(HF.H[10][10]) < 1e-12, 'center height 0');
    N.Free;
  finally
    Ctx.Free;
  end;
  if Fails > 0 then
  begin
    WriteLn(Fails, ' FAILURES');
    Halt(1);
  end;
  WriteLn('All workspace tests passed.');
end.
