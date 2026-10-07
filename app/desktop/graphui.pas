{ Desmos-style graph window (Phases 32-38): plots the workspace with
  pan/zoom, expression list, parameter sliders, click-to-inspect and
  analysis (roots, extrema, intersections, tangent, area). Thin view:
  all math lives in PMS.Viewport/Sampler/Workspace/Analysis. }
unit GraphUI;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, ExtCtrls, CheckLst, ComCtrls,
  Graphics, LCLType, PMS.Types, PMS.AST, PMS.Matrix, PMS.Viewport, PMS.Sampler,
  PMS.Workspace, PMS.Analysis, PMS.Deps;

type
  TGraphForm = class(TForm)
    ExprEdit: TEdit;
    KindCombo: TComboBox;
    AddButton: TButton;
    DelButton: TButton;
    Btn3D: TButton;
    ExprList: TCheckListBox;
    DetectButton: TButton;
    SliderBox: TScrollBox;
    Memo: TMemo;
    RootsButton: TButton;
    ExtremaButton: TButton;
    InterButton: TButton;
    AreaButton: TButton;
    TangentButton: TButton;
    StatusLabel: TLabel;
    PaintBox: TPaintBox;
    TopPanel: TPanel;
    RightPanel: TPanel;
    AnalysisPanel: TPanel;
    BtnRow1: TPanel;
    BtnRow2: TPanel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure AddClicked(Sender: TObject);
    procedure DelClicked(Sender: TObject);
    procedure ExprKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ExprChecked(Sender: TObject);
    procedure DetectSliders(Sender: TObject);
    procedure SliderChanged(Sender: TObject);
    procedure RootsClicked(Sender: TObject);
    procedure ExtremaClicked(Sender: TObject);
    procedure InterClicked(Sender: TObject);
    procedure AreaClicked(Sender: TObject);
    procedure TangentClicked(Sender: TObject);
    procedure Open3D(Sender: TObject);
    procedure PaintBoxPaint(Sender: TObject);
    procedure PaintMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaintMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure PaintMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaintMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
  private
    FWS: TWorkspace;
    FV: TViewport;
    FInit: Boolean;
    FDrag: Boolean;
    FDragDist: Integer;
    FLastX, FLastY: Integer;
    FInspectX: Double;
    FHasInspect: Boolean;
    procedure EnsureInit;
    procedure RefreshList;
    procedure RebuildSliders;
    function SelectedEntry: Integer;
    function AnalyzedNode(out Node: TASTNode; out Err: TCalcError): Boolean;
  end;

var
  GraphForm: TGraphForm;

const
  Palette: array[0..7] of TColor = (clRed, clBlue, $008000, $800080,
    $008080, $FF8000, $800000, $000080);

implementation

uses
  Graph3DUI;

{$R *.lfm}

procedure TGraphForm.FormCreate(Sender: TObject);
begin
  FWS := TWorkspace.Create;
  FInit := False;
  FDrag := False;
  FHasInspect := False;
  Caption := 'PascalMath Studio — Graph';
end;

procedure TGraphForm.FormDestroy(Sender: TObject);
begin
  FWS.Free;
end;

function TGraphForm.SelectedEntry: Integer;
begin
  Result := ExprList.ItemIndex;
end;

procedure TGraphForm.EnsureInit;
begin
  if FInit then
    Exit;
  if (PaintBox.Width >= 8) and (PaintBox.Height >= 8) then
    FV := VDefault(PaintBox.Width, PaintBox.Height)
  else
    FV := VDefault(640, 480);
  FV.W := PaintBox.Width;
  FV.H := PaintBox.Height;
  FInit := True;
end;

procedure TGraphForm.RefreshList;
var
  I: Integer;
begin
  ExprList.Items.BeginUpdate;
  try
    ExprList.Items.Clear;
    for I := 0 to FWS.EntryCount - 1 do
    begin
      ExprList.Items.Add(FWS.EntryText(I));
      ExprList.Checked[I] := FWS.EntryVisible(I);
    end;
  finally
    ExprList.Items.EndUpdate;
  end;
end;

procedure TGraphForm.AddClicked(Sender: TObject);
var
  E: TCalcError;
  P: Integer;
  K: TWSKind;
  Idx: Integer;
begin
  case KindCombo.ItemIndex of
    1: K := wkParam;
    2: K := wkPolar;
    3: K := wkImplicit;
  else
    K := wkFuncY;
  end;
  Idx := FWS.AddExpr(Trim(ExprEdit.Text), K, E, P);
  if Idx < 0 then
    StatusLabel.Caption := 'Error (pos ' + IntToStr(P) + '): ' +
      CalcErrorMessage(E)
  else
  begin
    StatusLabel.Caption := 'Added: ' + FWS.EntryText(Idx);
    ExprList.ItemIndex := Idx;
  end;
  RefreshList;
  PaintBox.Invalidate;
end;

procedure TGraphForm.DelClicked(Sender: TObject);
begin
  if SelectedEntry < 0 then
    Exit;
  FWS.DeleteEntry(SelectedEntry);
  RefreshList;
  PaintBox.Invalidate;
end;

procedure TGraphForm.ExprKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
  begin
    AddClicked(Sender);
    Key := 0;
  end;
end;

procedure TGraphForm.ExprChecked(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to ExprList.Items.Count - 1 do
    FWS.SetVisible(I, ExprList.Checked[I]);
  PaintBox.Invalidate;
end;

procedure TGraphForm.DetectSliders(Sender: TObject);
var
  I: Integer;
  Nm: string;
begin
  for I := 0 to FWS.Store.EntryCount - 1 do
  begin
    if FWS.Store.EntryKind(I) <> dkVar then
      Continue;
    Nm := FWS.Store.EntryName(I);
    FWS.BindParam(Nm, -5, 5, 0.1);
  end;
  RebuildSliders;
end;

procedure TGraphForm.RebuildSliders;
var
  I, Y: Integer;
  Lab: TLabel;
  Trk: TTrackBar;
  Pb: TParamBinding;
  V: Double;
begin
  while SliderBox.ControlCount > 0 do
    SliderBox.Controls[0].Free;
  Y := 0;
  for I := 0 to FWS.ParamCount - 1 do
  begin
    Pb := FWS.ParamInfo(I);
    Lab := TLabel.Create(SliderBox);
    Lab.Parent := SliderBox;
    Lab.Caption := Pb.Name;
    Lab.SetBounds(4, Y, SliderBox.ClientWidth - 8, 16);
    Y := Y + 18;
    Trk := TTrackBar.Create(SliderBox);
    Trk.Parent := SliderBox;
    Trk.Tag := I;
    Trk.Min := 0;
    Trk.Max := 1000;
    if FWS.GetVar(Pb.Name, V) then
      Trk.Position := Round((V - Pb.Lo) / (Pb.Hi - Pb.Lo) * 1000)
    else
      Trk.Position := 500;
    Trk.OnChange := @SliderChanged;
    Trk.SetBounds(4, Y, SliderBox.ClientWidth - 8, 30);
    Y := Y + 32;
  end;
end;

procedure TGraphForm.SliderChanged(Sender: TObject);
var
  Pb: TParamBinding;
  V: Double;
begin
  Pb := FWS.ParamInfo(TTrackBar(Sender).Tag);
  V := Pb.Lo + TTrackBar(Sender).Position / 1000 * (Pb.Hi - Pb.Lo);
  FWS.SetVar(Pb.Name, V);
  TTrackBar(Sender).Hint := Pb.Name + ' = ' + Format('%.4g', [V]);
  PaintBox.Invalidate;
end;

function TGraphForm.AnalyzedNode(out Node: TASTNode;
  out Err: TCalcError): Boolean;
var
  Idx: Integer;
begin
  Result := False;
  Node := nil;
  Idx := SelectedEntry;
  if (Idx < 0) or (FWS.EntryKind(Idx) <> wkFuncY) then
  begin
    Memo.Lines.Add('Select a y=f(x) expression first.');
    Exit;
  end;
  if not FWS.RefreshEntry(Idx, Err) then
  begin
    Memo.Lines.Add('Error: ' + CalcErrorMessage(Err));
    Exit;
  end;
  Node := FWS.ExpandEntry(Idx, 1, Err);
  if Err <> ceNone then
  begin
    Node.Free;
    Node := nil;
    Memo.Lines.Add('Error: ' + CalcErrorMessage(Err));
    Exit;
  end;
  Result := True;
end;

procedure TGraphForm.RootsClicked(Sender: TObject);
var
  N: TASTNode;
  E: TCalcError;
  R: TDoubleArray;
  I: Integer;
begin
  if not AnalyzedNode(N, E) then
    Exit;
  try
    if ANRoots(N, FWS.Store.Ctx, 'x', FV.XMin, FV.XMax, R, E) then
    begin
      Memo.Lines.Add('Roots in view: ' + IntToStr(Length(R)));
      for I := 0 to High(R) do
        Memo.Lines.Add('  x = ' + Format('%.10g', [R[I]]));
    end
    else
      Memo.Lines.Add('Roots error: ' + CalcErrorMessage(E));
  finally
    N.Free;
  end;
end;

procedure TGraphForm.ExtremaClicked(Sender: TObject);
var
  N: TASTNode;
  E: TCalcError;
  XMn, XMx: Double;
  HasMn, HasMx: Boolean;
begin
  if not AnalyzedNode(N, E) then
    Exit;
  try
    if ANExtrema(N, FWS.Store.Ctx, 'x', FV.XMin, FV.XMax, XMn, XMx,
      HasMn, HasMx, E) then
    begin
      if HasMn then
        Memo.Lines.Add('Min near x = ' + Format('%.10g', [XMn]));
      if HasMx then
        Memo.Lines.Add('Max near x = ' + Format('%.10g', [XMx]));
      if not (HasMn or HasMx) then
        Memo.Lines.Add('No interior extrema in view.');
    end
    else
      Memo.Lines.Add('Extrema error: ' + CalcErrorMessage(E));
  finally
    N.Free;
  end;
end;

procedure TGraphForm.InterClicked(Sender: TObject);
var
  A, B: TASTNode;
  E: TCalcError;
  R: TDoubleArray;
  I, J: Integer;
begin
  I := SelectedEntry;
  if I < 0 then
  begin
    Memo.Lines.Add('Select the first expression.');
    Exit;
  end;
  J := I + 1;
  while (J < FWS.EntryCount) and
    ((not FWS.EntryVisible(J)) or (FWS.EntryKind(J) <> wkFuncY)) do
    Inc(J);
  if (FWS.EntryKind(I) <> wkFuncY) or (J >= FWS.EntryCount) then
  begin
    Memo.Lines.Add('Need two visible y=f(x) expressions.');
    Exit;
  end;
  if not FWS.RefreshEntry(I, E) or not FWS.RefreshEntry(J, E) then
  begin
    Memo.Lines.Add('Error: ' + CalcErrorMessage(E));
    Exit;
  end;
  A := FWS.ExpandEntry(I, 1, E);
  if E <> ceNone then
  begin
    A.Free;
    Memo.Lines.Add('Error: ' + CalcErrorMessage(E));
    Exit;
  end;
  B := FWS.ExpandEntry(J, 1, E);
  if E <> ceNone then
  begin
    A.Free;
    B.Free;
    Memo.Lines.Add('Error: ' + CalcErrorMessage(E));
    Exit;
  end;
  try
    if ANIntersect(A, B, FWS.Store.Ctx, 'x', FV.XMin, FV.XMax, R, E) then
    begin
      Memo.Lines.Add('Intersections: ' + IntToStr(Length(R)));
      for I := 0 to High(R) do
        Memo.Lines.Add('  x = ' + Format('%.10g', [R[I]]));
    end
    else
      Memo.Lines.Add('Intersect error: ' + CalcErrorMessage(E));
  finally
    A.Free;
    B.Free;
  end;
end;

procedure TGraphForm.AreaClicked(Sender: TObject);
var
  N: TASTNode;
  E: TCalcError;
  A: Double;
begin
  if not AnalyzedNode(N, E) then
    Exit;
  try
    if ANArea(N, FWS.Store.Ctx, 'x', FV.XMin, FV.XMax, A, E) then
      Memo.Lines.Add('Area in view = ' + Format('%.10g', [A]))
    else
      Memo.Lines.Add('Area error: ' + CalcErrorMessage(E));
  finally
    N.Free;
  end;
end;

procedure TGraphForm.TangentClicked(Sender: TObject);
var
  N: TASTNode;
  E: TCalcError;
  Y, S: Double;
begin
  if not FHasInspect then
  begin
    Memo.Lines.Add('Click the graph to pick a point first.');
    Exit;
  end;
  if not AnalyzedNode(N, E) then
    Exit;
  try
    if ANTangent(N, FWS.Store.Ctx, 'x', FInspectX, Y, S, E) then
      Memo.Lines.Add('f(' + Format('%.6g', [FInspectX]) + ') = ' +
        Format('%.10g', [Y]) + ', slope = ' + Format('%.10g', [S]))
    else
      Memo.Lines.Add('Tangent error: ' + CalcErrorMessage(E));
  finally
    N.Free;
  end;
end;

procedure TGraphForm.Open3D(Sender: TObject);
begin
  Graph3DForm.Show;
end;

procedure TGraphForm.PaintBoxPaint(Sender: TObject);
var
  V: TViewport;
  TX, TY: TDoubleArray;
  I, K, J: Integer;
  Lines: TSampleLines;
  E: TCalcError;
  SX, SY, ZX, ZY: Double;
  First: Boolean;
begin
  if (PaintBox.Width < 8) or (PaintBox.Height < 8) then
    Exit;
  EnsureInit;
  FV.W := PaintBox.Width;
  FV.H := PaintBox.Height;
  V := FV;
  with PaintBox.Canvas do
  begin
    Brush.Color := clWhite;
    FillRect(0, 0, PaintBox.Width, PaintBox.Height);
    // grid
    Pen.Color := $E0E0E0;
    Pen.Style := psDot;
    Pen.Width := 1;
    VNiceTicks(V.XMin, V.XMax, 10, TX);
    for I := 0 to High(TX) do
    begin
      VWorldToScreen(V, TX[I], 0, SX, SY);
      MoveTo(Round(SX), 0);
      LineTo(Round(SX), V.H);
    end;
    VNiceTicks(V.YMin, V.YMax, 10, TY);
    for I := 0 to High(TY) do
    begin
      VWorldToScreen(V, 0, TY[I], SX, SY);
      MoveTo(0, Round(SY));
      LineTo(V.W, Round(SY));
    end;
    // axes
    Pen.Color := clBlack;
    Pen.Style := psSolid;
    if (V.YMin <= 0) and (V.YMax >= 0) then
    begin
      VWorldToScreen(V, 0, 0, ZX, ZY);
      MoveTo(0, Round(ZY));
      LineTo(V.W, Round(ZY));
    end;
    if (V.XMin <= 0) and (V.XMax >= 0) then
    begin
      VWorldToScreen(V, 0, 0, ZX, ZY);
      MoveTo(Round(ZX), 0);
      LineTo(Round(ZX), V.H);
    end;
    // curves
    for K := 0 to FWS.EntryCount - 1 do
    begin
      if not FWS.EntryVisible(K) then
        Continue;
      Lines := FWS.SampleEntry(K, V, E);
      if E <> ceNone then
        Continue;
      Pen.Color := Palette[FWS.EntryColor(K) mod 8];
      if K = SelectedEntry then
        Pen.Width := 2
      else
        Pen.Width := 1;
      for J := 0 to High(Lines) do
      begin
        First := True;
        for I := 0 to High(Lines[J]) do
        begin
          SX := Lines[J][I].SX;
          SY := Lines[J][I].SY;
          if First or not Lines[J][I].Pen then
            MoveTo(Round(SX), Round(SY))
          else
            LineTo(Round(SX), Round(SY));
          First := False;
        end;
      end;
    end;
    // crosshair
    if FHasInspect then
    begin
      Pen.Color := clRed;
      Pen.Style := psDot;
      Pen.Width := 1;
      VWorldToScreen(V, FInspectX, V.YMin, SX, SY);
      MoveTo(Round(SX), 0);
      LineTo(Round(SX), V.H);
    end;
    Pen.Style := psSolid;
  end;
end;

procedure TGraphForm.PaintMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
  begin
    FDrag := True;
    FDragDist := 0;
    FLastX := X;
    FLastY := Y;
  end;
end;

procedure TGraphForm.PaintMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var
  WX, WY: Double;
begin
  if (PaintBox.Width < 8) or (PaintBox.Height < 8) then
    Exit;
  EnsureInit;
  FV.W := PaintBox.Width;
  FV.H := PaintBox.Height;
  if FDrag then
  begin
    VPanPixels(FV, X - FLastX, Y - FLastY);
    FDragDist := FDragDist + Abs(X - FLastX) + Abs(Y - FLastY);
    FLastX := X;
    FLastY := Y;
    PaintBox.Invalidate;
  end
  else
  begin
    VScreenToWorld(FV, X, Y, WX, WY);
    StatusLabel.Caption := 'x = ' + Format('%.6g', [WX]) + '   y = ' +
      Format('%.6g', [WY]);
  end;
end;

procedure TGraphForm.PaintMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  WX, WY: Double;
begin
  if not FDrag then
    Exit;
  FDrag := False;
  if FDragDist < 4 then
  begin
    // treated as click: inspect here
    VScreenToWorld(FV, X, Y, WX, WY);
    FInspectX := WX;
    FHasInspect := True;
    PaintBox.Invalidate;
  end;
end;

procedure TGraphForm.PaintMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
var
  WX, WY: Double;
begin
  EnsureInit;
  VScreenToWorld(FV, MousePos.X, MousePos.Y, WX, WY);
  if WheelDelta > 0 then
    VZoom(FV, 0.8, WX, WY)
  else
    VZoom(FV, 1.25, WX, WY);
  PaintBox.Invalidate;
  Handled := True;
end;

end.
