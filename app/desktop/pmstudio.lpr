program PMStudio;

{$mode objfpc}{$H+}

uses
  Interfaces,
  Forms,
  SysUtils,
  MainForm,
  GraphUI,
  Graph3DUI,
  PMS.AppName;

{$R *.res}

begin
  DefaultFormatSettings.DecimalSeparator := '.'; // expression syntax is locale-independent
  Application.Title := PMSProductName;
  Application.Scaled := True;
  Application.Initialize;
  Application.CreateForm(TStudioForm, StudioForm);
  Application.CreateForm(TGraphForm, GraphForm);
  Application.CreateForm(TGraph3DForm, Graph3DForm);
  Application.Run;
end.
