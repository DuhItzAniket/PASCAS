{ First graphical milestone: expression in, result out, history kept.
  Thin shell over PMS.Eval — no math lives here. Buttons are generated
  from a table (the .lfm holds only layout); persistence lands in Phase 14. }
unit MainForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, ExtCtrls, LCLType, Clipbrd,
  PMS.Types, PMS.Eval;

type
  TStudioForm = class(TForm)
    ExprEdit: TEdit;
    ResultLabel: TLabel;
    HistoryBox: TListBox;
    BtnPanel: TPanel;
    TopPanel: TPanel;
    AngleButton: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ExprKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure HistoryRecall(Sender: TObject);
    procedure AngleToggle(Sender: TObject);
  private
    FCtx: TEvalContext;
    FMem: Double;       // memory register (volatile, per session)
    FLastResult: Double;
    FLastOK: Boolean;
    FHistNav: Integer;  // -1 = typing, else history index
    FNavLock: Boolean;  // True while recalling (suppresses OnChange reset)
    FHistFile: string;
    procedure Evaluate;
    procedure InsertText(const S: string);
    procedure ButtonClicked(Sender: TObject);
    procedure MakeButtons;
    procedure LoadHistory;
    procedure SaveHistory;
    procedure ExprChanged(Sender: TObject);
    procedure HistoryNav(Delta: Integer);
  end;

var
  StudioForm: TStudioForm;

implementation

{$R *.lfm}

const
  // caption, inserted text ('=' 'C' '<' 'A' are actions)
  BtnDefs: array[0..34] of array[0..1] of string = (
    ('7', '7'), ('8', '8'), ('9', '9'), ('/', '/'), ('C', 'C'),
    ('4', '4'), ('5', '5'), ('6', '6'), ('*', '*'), ('Bksp', '<'),
    ('1', '1'), ('2', '2'), ('3', '3'), ('-', '-'), ('Ans', 'A'),
    ('0', '0'), ('.', '.'), ('=', '='), ('+', '+'), ('^', '^'),
    ('sin(', 'sin('), ('cos(', 'cos('), ('tan(', 'tan('), ('ln(', 'ln('), ('log(', 'log('),
    ('sqrt(', 'sqrt('), ('(', '('), (')', ')'), ('pi', 'pi'), ('mod', ' mod '),
    ('M+', 'M+'), ('M-', 'M-'), ('MR', 'MR'), ('MC', 'MC'), ('+/-', 'N')
  );

procedure TStudioForm.FormCreate(Sender: TObject);
begin
  FCtx := TEvalContext.Create;
  FMem := 0;
  FLastOK := False;
  FHistNav := -1;
  Caption := 'PascalMath Studio';
  FHistFile := GetAppConfigDir(False) + 'history.txt';
  LoadHistory;
  ExprEdit.OnChange := @ExprChanged;
  MakeButtons;
end;

procedure TStudioForm.FormDestroy(Sender: TObject);
begin
  SaveHistory;
  FCtx.Free;
end;

procedure TStudioForm.LoadHistory;
begin
  try
    if FileExists(FHistFile) then
      HistoryBox.Items.LoadFromFile(FHistFile);
    while HistoryBox.Items.Count > 200 do
      HistoryBox.Items.Delete(HistoryBox.Items.Count - 1);
  except
    // history is a convenience; never break startup over it
  end;
end;

procedure TStudioForm.SaveHistory;
begin
  try
    ForceDirectories(ExtractFileDir(FHistFile));
    HistoryBox.Items.SaveToFile(FHistFile);
  except
  end;
end;

procedure TStudioForm.ExprChanged(Sender: TObject);
begin
  if not FNavLock then
    FHistNav := -1;
end;

procedure TStudioForm.HistoryNav(Delta: Integer);
var
  Idx: Integer;
begin
  if HistoryBox.Items.Count = 0 then
    Exit;
  if FHistNav < 0 then
    Idx := 0
  else
    Idx := FHistNav + Delta;
  if Idx < 0 then
    Idx := 0;
  if Idx >= HistoryBox.Items.Count then
    Idx := HistoryBox.Items.Count - 1;
  FHistNav := Idx;
  FNavLock := True;
  try
    ExprEdit.Text := Copy(HistoryBox.Items[Idx], 1, Pos(' = ', HistoryBox.Items[Idx]) - 1);
  finally
    FNavLock := False;
  end;
  ExprEdit.SelStart := Length(ExprEdit.Text);
end;

procedure TStudioForm.MakeButtons;
var
  I, R, C: Integer;
  B: TButton;
  W, H: Integer;
begin
  W := BtnPanel.ClientWidth div 5;
  H := BtnPanel.ClientHeight div 7;
  for I := 0 to High(BtnDefs) do
  begin
    R := I div 5;
    C := I mod 5;
    B := TButton.Create(BtnPanel);
    B.Parent := BtnPanel;
    B.Caption := BtnDefs[I][0];
    B.Hint := BtnDefs[I][1];
    B.Tag := I;
    B.TabStop := False;
    B.SetBounds(C * W, R * H, W, H);
    B.Anchors := [];
    B.OnClick := @ButtonClicked;
  end;
end;

procedure TStudioForm.ButtonClicked(Sender: TObject);
var
  Act: string;
begin
  Act := BtnDefs[TButton(Sender).Tag][1];
  if Act = '=' then
    Evaluate
  else if Act = 'C' then
  begin
    ExprEdit.Text := '';
    ResultLabel.Caption := '0';
  end
  else if Act = '<' then
    InsertText('')
  else if Act = 'A' then
    InsertText('Ans')
  else if Act = 'M+' then
  begin
    if FLastOK then
      FMem := FMem + FLastResult;
  end
  else if Act = 'M-' then
  begin
    if FLastOK then
      FMem := FMem - FLastResult;
  end
  else if Act = 'MR' then
    InsertText(Format('%.10g', [FMem]))
  else if Act = 'MC' then
    FMem := 0
  else if Act = 'N' then
  begin
    if Trim(ExprEdit.Text) <> '' then
      ExprEdit.Text := '-(' + ExprEdit.Text + ')';
  end
  else
    InsertText(Act);
  ExprEdit.SetFocus;
end;

procedure TStudioForm.InsertText(const S: string);
begin
  // '<' action deletes one char behind the caret
  if S = '' then
  begin
    if ExprEdit.SelStart > 0 then
    begin
      ExprEdit.SelStart := ExprEdit.SelStart - 1;
      ExprEdit.SelLength := 1;
      ExprEdit.SelText := '';
    end;
    Exit;
  end;
  ExprEdit.SelText := S;
end;

procedure TStudioForm.Evaluate;
var
  V: Double;
  E: TCalcError;
  P: Integer;
  Expr: string;
begin
  Expr := Trim(ExprEdit.Text);
  if Expr = '' then
    Exit;
  if EvalText(Expr, FCtx, V, E, P) then
  begin
    FLastResult := V;
    FLastOK := True;
    ResultLabel.Caption := Format('%.10g', [V]);
    HistoryBox.Items.Insert(0, Expr + ' = ' + ResultLabel.Caption);
    while HistoryBox.Items.Count > 200 do
      HistoryBox.Items.Delete(HistoryBox.Items.Count - 1);
  end
  else if P > 0 then
  begin
    FLastOK := False;
    ResultLabel.Caption := 'Error (pos ' + IntToStr(P) + '): ' + CalcErrorMessage(E);
  end
  else
  begin
    FLastOK := False;
    ResultLabel.Caption := 'Error: ' + CalcErrorMessage(E);
  end;
  ExprEdit.SetFocus;
  ExprEdit.SelectAll;
end;

procedure TStudioForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (ssCtrl in Shift) and (Key = Ord('C')) and not ExprEdit.Focused then
  begin
    // copy result (or history line) when the edit box isn't handling it
    if HistoryBox.Focused and (HistoryBox.ItemIndex >= 0) then
      Clipboard.AsText := HistoryBox.Items[HistoryBox.ItemIndex]
    else
      Clipboard.AsText := ResultLabel.Caption;
    Key := 0;
  end
  else if Key = VK_RETURN then
  begin
    Evaluate;
    Key := 0;
  end
  else if Key = VK_ESCAPE then
  begin
    ExprEdit.Text := '';
    ResultLabel.Caption := '0';
    Key := 0;
  end;
end;

procedure TStudioForm.ExprKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
  begin
    Evaluate;
    Key := 0;
  end
  else if Key = VK_UP then
  begin
    HistoryNav(+1);
    Key := 0;
  end
  else if Key = VK_DOWN then
  begin
    HistoryNav(-1);
    Key := 0;
  end;
end;

procedure TStudioForm.HistoryRecall(Sender: TObject);
var
  S: string;
  Eq: Integer;
begin
  if HistoryBox.ItemIndex < 0 then
    Exit;
  S := HistoryBox.Items[HistoryBox.ItemIndex];
  Eq := Pos(' = ', S);
  if Eq > 0 then
    S := Copy(S, 1, Eq - 1);
  ExprEdit.Text := S;
  ExprEdit.SetFocus;
end;

procedure TStudioForm.AngleToggle(Sender: TObject);
begin
  if FCtx.AngleMode = amRadian then
  begin
    FCtx.AngleMode := amDegree;
    AngleButton.Caption := 'DEG';
  end
  else if FCtx.AngleMode = amDegree then
  begin
    FCtx.AngleMode := amGrad;
    AngleButton.Caption := 'GRAD';
  end
  else
  begin
    FCtx.AngleMode := amRadian;
    AngleButton.Caption := 'RAD';
  end;
end;

end.
