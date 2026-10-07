{ Software wireframe 3D view (Phase 39): z = f(x,y) sampled by
  PMS.Graph3D, projected and stroked on a Canvas. Azimuth/elevation
  sliders rotate live. }
unit Graph3DUI;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, ExtCtrls, ComCtrls, Graphics,
  PMS.Types, PMS.AST, PMS.Parser, PMS.Eval, PMS.Deps, PMS.Graph3D;

type
  TGraph3DForm = class(TForm)
    ExprEdit: TEdit;
    PlotButton: TButton;
    AzimTrack: TTrackBar;
    ElevTrack: TTrackBar;
    StatusLabel: TLabel;
    PaintBox: TPaintBox;
    TopPanel: TPanel;
    SidePanel: TPanel;
    AzimLabel: TLabel;
    ElevLabel: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure PlotClicked(Sender: TObject);
    procedure ExprKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ViewChanged(Sender: TObject);
    procedure PaintBoxPaint(Sender: TObject);
  private
    FStore: TDepStore;
    FRoot: TASTNode;
    procedure EnsureExpr(out Err: TCalcError; out ErrPos: Integer);
  end;

var
  Graph3DForm: TGraph3DForm;

implementation

{$R *.lfm}

procedure TGraph3DForm.FormCreate(Sender: TObject);
begin
  FStore := TDepStore.Create;
  FRoot := nil;
  Caption := 'PascalMath Studio — 3D';
end;

procedure TGraph3DForm.FormDestroy(Sender: TObject);
begin
  FRoot.Free;
  FStore.Free;
end;

procedure TGraph3DForm.EnsureExpr(out Err: TCalcError; out ErrPos: Integer);
var
  N: TASTNode;
begin
  if FRoot <> nil then
  begin
    Err := ceNone;
    ErrPos := 0;
    Exit;
  end;
  if not ParseExpression(Trim(ExprEdit.Text), N, Err, ErrPos) then
    Exit;
  FRoot := N;
end;

procedure TGraph3DForm.PlotClicked(Sender: TObject);
var
  E: TCalcError;
  P: Integer;
begin
  FRoot.Free;
  FRoot := nil;
  EnsureExpr(E, P);
  if E <> ceNone then
    StatusLabel.Caption := 'Error (pos ' + IntToStr(P) + '): ' +
      CalcErrorMessage(E)
  else
    StatusLabel.Caption := 'z = ' + Trim(ExprEdit.Text);
  PaintBox.Invalidate;
end;

procedure TGraph3DForm.ExprKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = 13 then
  begin
    PlotClicked(Sender);
    Key := 0;
  end;
end;

procedure TGraph3DForm.ViewChanged(Sender: TObject);
begin
  PaintBox.Invalidate;
end;

procedure TGraph3DForm.PaintBoxPaint(Sender: TObject);
var
  E: TCalcError;
  P: Integer;
  VW: TView3D;
  HF: THeightField;
  I, J: Integer;
  SX, SY, Span: Double;
  First: Boolean;
begin
  if (PaintBox.Width < 8) or (PaintBox.Height < 8) then
    Exit;
  EnsureExpr(E, P);
  if E <> ceNone then
    Exit;
  VW.AzimDeg := AzimTrack.Position - 180;
  VW.ElevDeg := ElevTrack.Position;
  if not P3Sample(FRoot, 'x', 'y', -5, 5, -5, 5, 60, 60, FStore.Ctx, HF, E) then
    Exit;
  Span := 8;
  with PaintBox.Canvas do
  begin
    Brush.Color := clWhite;
    FillRect(0, 0, PaintBox.Width, PaintBox.Height);
    Pen.Color := clNavy;
    Pen.Width := 1;
    // rows along X
    for J := 0 to HF.NY do
    begin
      First := True;
      for I := 0 to HF.NX do
      begin
        if not HF.OK[J][I] then
        begin
          First := True;
          Continue;
        end;
        P3Project(HF.X0 + (HF.X1 - HF.X0) * I / HF.NX,
          HF.Y0 + (HF.Y1 - HF.Y0) * J / HF.NY, HF.H[J][I],
          VW, PaintBox.Width, PaintBox.Height, Span, SX, SY);
        if First then
          MoveTo(Round(SX), Round(SY))
        else
          LineTo(Round(SX), Round(SY));
        First := False;
      end;
    end;
    // columns along Y
    for I := 0 to HF.NX do
    begin
      First := True;
      for J := 0 to HF.NY do
      begin
        if not HF.OK[J][I] then
        begin
          First := True;
          Continue;
        end;
        P3Project(HF.X0 + (HF.X1 - HF.X0) * I / HF.NX,
          HF.Y0 + (HF.Y1 - HF.Y0) * J / HF.NY, HF.H[J][I],
          VW, PaintBox.Width, PaintBox.Height, Span, SX, SY);
        if First then
          MoveTo(Round(SX), Round(SY))
        else
          LineTo(Round(SX), Round(SY));
        First := False;
      end;
    end;
  end;
end;

end.
