{ Desktop console front-end (Phase 10): evaluates expressions via the
  shared core. The LCL graphical shell arrives in Phase 13; this proves
  parse -> eval -> print end-to-end on desktop. }
program PMSCalc;

{$mode objfpc}{$H+}

uses
  SysUtils, PMS.AppName, PMS.Types, PMS.Eval;

var
  Ctx: TEvalContext;

procedure RunLine(const Src: string);
var
  V: Double;
  E: TCalcError;
  P: Integer;
begin
  if Trim(Src) = '' then
    Exit;
  if EvalText(Src, Ctx, V, E, P) then
    WriteLn(Format('%.10g', [V]))
  else if P > 0 then
    WriteLn('Error (pos ', P, '): ', CalcErrorMessage(E))
  else
    WriteLn('Error: ', CalcErrorMessage(E));
end;

var
  I: Integer;
  Line: string;
begin
  DefaultFormatSettings.DecimalSeparator := '.'; // expression syntax is locale-independent
  Ctx := TEvalContext.Create;
  try
    if ParamCount > 0 then
    begin
      for I := 1 to ParamCount do
        RunLine(ParamStr(I));
    end
    else
    begin
      WriteLn(PMSProductName, ' v', PMSVersion, ' — type an expression, empty line quits.');
      while True do
      begin
        Write('> ');
        ReadLn(Line);
        if Trim(Line) = '' then
          Break;
        RunLine(Line);
      end;
    end;
  finally
    Ctx.Free;
  end;
end.
