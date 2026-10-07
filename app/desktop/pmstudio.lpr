program PMStudio;

{$mode objfpc}{$H+}

uses
  Interfaces,
  Forms,
  MainForm,
  PMS.AppName;

{$R *.res}

begin
  Application.Title := PMSProductName;
  Application.Scaled := True;
  Application.Initialize;
  Application.CreateForm(TStudioForm, StudioForm);
  Application.Run;
end.
