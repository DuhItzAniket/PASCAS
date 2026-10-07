{ Desktop console front-end skeleton (Phase 04).
  The LCL graphical shell arrives in Phase 13; this proves the desktop
  toolchain end-to-end: FPC -> exe -> runs. }
program PMSCalc;

{$mode objfpc}{$H+}

uses
  SysUtils, PMS.AppName;

begin
  WriteLn(PMSProductName, ' v', PMSVersion, ' (console skeleton)');
end.
