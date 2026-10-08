{ Browser application (Phases 42-43): the SAME Pascal core (evaluator,
  workspace, sampler, session) compiled with Pas2JS, driven by a thin
  DOM/Canvas shell. All math runs locally — no server, no per-keystroke
  requests. JS exists only as the compiler's output, never as authored
  math code. Multi-expression workspace, sliders, localStorage
  persistence, pointer-event (mouse+touch) pan/zoom. }
program PMSWeb;

{$mode objfpc}{$H+}

uses
  SysUtils, JS, Web, PMS.AppName, PMS.Types, PMS.Eval, PMS.Workspace,
  PMS.Viewport, PMS.Sampler, PMS.Session, PMS.Matrix, PMS.Deps;

var
  Ctx: TEvalContext;
  WS: TWorkspace;
  V: TViewport;
  Dragging: Boolean = False;
  LastPX, LastPY: Integer;
  E2: TCalcError;
  P2: Integer;

const
  Palette: array[0..7] of string = ('#c00000', '#0000cc', '#008000',
    '#800080', '#008080', '#ff8000', '#800000', '#000080');

function El(const Id: string): TJSHTMLElement;
begin
  Result := TJSHTMLElement(document.getElementById(Id));
end;

function CanvasEl: TJSHTMLCanvasElement;
begin
  Result := TJSHTMLCanvasElement(document.getElementById('graph'));
end;

function Ctx2D: TJSCanvasRenderingContext2D;
begin
  Result := TJSCanvasRenderingContext2D(CanvasEl.getContext('2d'));
end;

function Fmt(X: Double): string;
begin
  Result := Format('%.10g', [X]);
end;

procedure Persist; forward;
procedure Replot; forward;
procedure RefreshEntries; forward;
procedure RebuildSliders; forward;
procedure DetectSliders; forward;
function EntryBtn(Event: TJSEvent): Boolean; forward;
function SliderMoved(Event: TJSEvent): Boolean; forward;
function DetectBtn(Event: TJSEvent): Boolean; forward;

function Evaluate(Event: TJSEvent): Boolean;
var
  Src: string;
  Val: Double;
  E: TCalcError;
  P: Integer;
begin
  Src := TJSHTMLInputElement(El('expr')).value;
  if Trim(Src) = '' then
    Exit(True);
  if EvalText(Src, Ctx, Val, E, P) then
    El('out').innerHTML := Fmt(Val)
  else if P > 0 then
    El('out').innerHTML := 'Error (pos ' + IntToStr(P) + '): ' +
      CalcErrorMessage(E)
  else
    El('out').innerHTML := 'Error: ' + CalcErrorMessage(E);
  Result := True;
end;

procedure StrokeLines(C: TJSCanvasRenderingContext2D;
  const Lines: TSampleLines; const Color: string; Width: Double);
var
  I, J: Integer;
begin
  C.strokeStyle := Color;
  C.lineWidth := Width;
  for J := 0 to High(Lines) do
  begin
    C.beginPath;
    for I := 0 to High(Lines[J]) do
    begin
      if (I = 0) or not Lines[J][I].Pen then
        C.moveTo(Lines[J][I].SX, Lines[J][I].SY)
      else
        C.lineTo(Lines[J][I].SX, Lines[J][I].SY);
    end;
    C.stroke;
  end;
end;

procedure Replot;
var
  C: TJSCanvasRenderingContext2D;
  W, H: Integer;
  TX, TY: TDoubleArray;
  I, K: Integer;
  SX, SY: Double;
  Lines: TSampleLines;
  E: TCalcError;
begin
  W := CanvasEl.width;
  H := CanvasEl.height;
  V.W := W;
  V.H := H;
  C := Ctx2D;
  C.clearRect(0, 0, W, H);
  C.strokeStyle := '#e0e0e0';
  C.lineWidth := 1;
  VNiceTicks(V.XMin, V.XMax, 10, TX);
  C.beginPath;
  for I := 0 to High(TX) do
  begin
    VWorldToScreen(V, TX[I], 0, SX, SY);
    C.moveTo(SX, 0);
    C.lineTo(SX, H);
  end;
  C.stroke;
  VNiceTicks(V.YMin, V.YMax, 10, TY);
  C.beginPath;
  for I := 0 to High(TY) do
  begin
    VWorldToScreen(V, 0, TY[I], SX, SY);
    C.moveTo(0, SY);
    C.lineTo(W, SY);
  end;
  C.stroke;
  C.strokeStyle := '#000000';
  if (V.YMin <= 0) and (V.YMax >= 0) then
  begin
    VWorldToScreen(V, 0, 0, SX, SY);
    C.beginPath;
    C.moveTo(0, SY);
    C.lineTo(W, SY);
    C.stroke;
  end;
  if (V.XMin <= 0) and (V.XMax >= 0) then
  begin
    VWorldToScreen(V, 0, 0, SX, SY);
    C.beginPath;
    C.moveTo(SX, 0);
    C.lineTo(SX, H);
    C.stroke;
  end;
  for K := 0 to WS.EntryCount - 1 do
  begin
    if not WS.EntryVisible(K) then
      Continue;
    Lines := WS.SampleEntry(K, V, E);
    if E = ceNone then
      StrokeLines(C, Lines, Palette[WS.EntryColor(K) mod 8], 2);
  end;
end;

procedure Persist;
var
  J: string;
begin
  // localStorage session snapshot; failures (private mode) are silent
  try
    if SessionSave(WS, V, Ord(Ctx.AngleMode), J) then
      window.localStorage.setItem('pmsession', J);
  except
  end;
end;

function LSGet(const Key: string): string;
var
  I: Integer;
begin
  // getItem on a missing key returns JS null, which the string bridge
  // cannot swallow — scan keys first so getItem always hits.
  Result := '';
  try
    for I := 0 to window.localStorage.length - 1 do
      if window.localStorage.key(I) = Key then
      begin
        Result := window.localStorage.getItem(Key);
        Break;
      end;
  except
  end;
end;

procedure Restore;
var
  J: string;
  E: TCalcError;
  A: Integer;
begin
  J := LSGet('pmsession');
  if J = '' then
    Exit;
  if SessionLoad(J, WS, V, A, E) then
  begin
    Ctx.AngleMode := TAngleMode(A);
    RefreshEntries;
    RebuildSliders;
  end;
end;

procedure RefreshEntries;
var
  Box, Row, Dot, Txt, Hide, Del: TJSHTMLElement;
  Inp: TJSHTMLInputElement;
  I: Integer;
begin
  Box := El('entries');
  Box.innerHTML := '';
  for I := 0 to WS.EntryCount - 1 do
  begin
    Row := TJSHTMLElement(document.createElement('div'));
    Row.className := 'entry';
    Dot := TJSHTMLElement(document.createElement('span'));
    Dot.className := 'dot';
    Dot.setAttribute('style', 'background:' + Palette[WS.EntryColor(I) mod 8]);
    Txt := TJSHTMLElement(document.createElement('span'));
    Txt.className := 'etext';
    Txt.innerHTML := WS.EntryText(I);
    Hide := TJSHTMLElement(document.createElement('button'));
    Hide.setAttribute('data-i', IntToStr(I));
    Hide.setAttribute('data-a', 't');
    if WS.EntryVisible(I) then
      Hide.innerHTML := 'hide'
    else
      Hide.innerHTML := 'show';
    Hide.addEventListener('click', @EntryBtn);
    Del := TJSHTMLElement(document.createElement('button'));
    Del.setAttribute('data-i', IntToStr(I));
    Del.setAttribute('data-a', 'd');
    Del.innerHTML := 'x';
    Del.addEventListener('click', @EntryBtn);
    Inp := TJSHTMLInputElement(document.createElement('input'));
    Row.appendChild(Dot);
    Row.appendChild(Txt);
    Row.appendChild(Hide);
    Row.appendChild(Del);
    Box.appendChild(Row);
  end;
end;

function EntryBtn(Event: TJSEvent): Boolean;
var
  B: TJSHTMLElement;
  I: Integer;
begin
  B := TJSHTMLElement(Event.target);
  I := StrToIntDef(B.getAttribute('data-i'), -1);
  if (I < 0) or (I >= WS.EntryCount) then
    Exit(True);
  if B.getAttribute('data-a') = 't' then
    WS.SetVisible(I, not WS.EntryVisible(I))
  else
    WS.DeleteEntry(I);
  RefreshEntries;
  Replot;
  Persist;
  Result := True;
end;

procedure RebuildSliders;
var
  Box, Row, Lab: TJSHTMLElement;
  Inp: TJSHTMLInputElement;
  I: Integer;
  Pb: TParamBinding;
  Val: Double;
begin
  Box := El('sliders');
  Box.innerHTML := '';
  for I := 0 to WS.ParamCount - 1 do
  begin
    Pb := WS.ParamInfo(I);
    Row := TJSHTMLElement(document.createElement('div'));
    Row.className := 'slider';
    Lab := TJSHTMLElement(document.createElement('span'));
    Lab.innerHTML := Pb.Name;
    Inp := TJSHTMLInputElement(document.createElement('input'));
    Inp.setAttribute('type', 'range');
    Inp.setAttribute('min', FloatToStr(Pb.Lo));
    Inp.setAttribute('max', FloatToStr(Pb.Hi));
    Inp.setAttribute('step', FloatToStr(Pb.Step));
    if WS.GetVar(Pb.Name, Val) then
      Inp.setAttribute('value', FloatToStr(Val))
    else
      Inp.setAttribute('value', FloatToStr((Pb.Lo + Pb.Hi) / 2));
    Inp.setAttribute('data-i', IntToStr(I));
    Inp.addEventListener('input', @SliderMoved);
    Row.appendChild(Lab);
    Row.appendChild(Inp);
    Box.appendChild(Row);
  end;
end;

function SliderMoved(Event: TJSEvent): Boolean;
var
  Inp: TJSHTMLInputElement;
  Pb: TParamBinding;
begin
  Inp := TJSHTMLInputElement(Event.target);
  Pb := WS.ParamInfo(StrToIntDef(Inp.getAttribute('data-i'), 0));
  WS.SetVar(Pb.Name, StrToFloatDef(Inp.value, Pb.Lo));
  Replot;
  Persist;
  Result := True;
end;

procedure DetectSliders;
var
  I: Integer;
begin
  for I := 0 to WS.Store.EntryCount - 1 do
  begin
    if WS.Store.EntryKind(I) <> dkVar then
      Continue;
    WS.BindParam(WS.Store.EntryName(I), -5, 5, 0.1);
  end;
  RebuildSliders;
end;

function DetectBtn(Event: TJSEvent): Boolean;
begin
  DetectSliders;
  Result := True;
end;

function DoPlot(Event: TJSEvent): Boolean;
var
  E: TCalcError;
  P: Integer;
  Idx: Integer;
begin
  Idx := WS.AddExpr(TJSHTMLInputElement(El('plotexpr')).value, wkFuncY, E, P);
  if Idx < 0 then
  begin
    El('out').innerHTML := 'Plot error (pos ' + IntToStr(P) + '): ' +
      CalcErrorMessage(E);
    Exit(True);
  end;
  TJSHTMLInputElement(El('plotexpr')).value := '';
  RefreshEntries;
  Replot;
  Persist;
  Result := True;
end;

function DoShare(Event: TJSEvent): Boolean;
var
  J: string;
begin
  if not SessionSave(WS, V, Ord(Ctx.AngleMode), J) then
    Exit(True);
  window.location.hash := SessionToHash(J);
  TJSHTMLInputElement(El('link')).value := window.location.href;
  Result := True;
end;

function OnPointerDown(Event: TJSEvent): Boolean;
var
  M: TJSPointerEvent;
begin
  M := TJSPointerEvent(Event);
  Dragging := True;
  LastPX := Round(M.offsetX);
  LastPY := Round(M.offsetY);
  Result := True;
end;

function OnPointerMove(Event: TJSEvent): Boolean;
var
  M: TJSPointerEvent;
begin
  if not Dragging then
    Exit(True);
  M := TJSPointerEvent(Event);
  VPanPixels(V, Round(M.offsetX) - LastPX, Round(M.offsetY) - LastPY);
  LastPX := Round(M.offsetX);
  LastPY := Round(M.offsetY);
  Replot;
  Result := True;
end;

function OnPointerUp(Event: TJSEvent): Boolean;
begin
  Dragging := False;
  Persist;
  Result := True;
end;

function OnWheel(Event: TJSEvent): Boolean;
var
  W: TJSWheelEvent;
  WX, WY: Double;
begin
  W := TJSWheelEvent(Event);
  W.preventDefault;
  VScreenToWorld(V, W.offsetX, W.offsetY, WX, WY);
  if W.deltaY > 0 then
    VZoom(V, 1.25, WX, WY)
  else
    VZoom(V, 0.8, WX, WY);
  Replot;
  Persist;
  Result := True;
end;

procedure FitCanvas;
var
  W: Integer;
begin
  W := El('graph').clientWidth;
  if W < 100 then
    W := 800;
  CanvasEl.width := W;
  CanvasEl.height := Round(W * 9 / 16);
end;

function OnResize(Event: TJSEvent): Boolean;
begin
  FitCanvas;
  Replot;
  Result := True;
end;

procedure Wire(const Id, Evt: string; H: TJSEventHandler);
begin
  El(Id).addEventListener(Evt, H);
end;

procedure ImportHash;
var
  H, J: string;
  E: TCalcError;
  A: Integer;
begin
  H := window.location.hash;
  if H = '' then
    Exit;
  if SessionFromHash(H, J, E) and SessionLoad(J, WS, V, A, E) then
  begin
    Ctx.AngleMode := TAngleMode(A);
    RefreshEntries;
    RebuildSliders;
  end;
end;

begin
  Ctx := TEvalContext.Create;
  WS := TWorkspace.Create;
  V := VDefault(800, 450);
  El('ver').innerHTML := PMSVersion;
  Wire('eval', 'click', @Evaluate);
  Wire('expr', 'change', @Evaluate);
  Wire('plot', 'click', @DoPlot);
  Wire('plotexpr', 'change', @DoPlot);
  Wire('share', 'click', @DoShare);
  Wire('slidersbtn', 'click', @DetectBtn);
  Wire('graph', 'pointerdown', @OnPointerDown);
  Wire('graph', 'pointermove', @OnPointerMove);
  Wire('graph', 'pointerup', @OnPointerUp);
  Wire('graph', 'wheel', @OnWheel);
  window.addEventListener('resize', @OnResize);
  FitCanvas;
  Restore;
  ImportHash;
  if WS.EntryCount = 0 then
  begin
    WS.AddExpr('sin(x)', wkFuncY, E2, P2);
    RefreshEntries;
  end;
  Evaluate(nil);
  Replot;
end.
