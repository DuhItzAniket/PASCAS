{ Assert-runner for PMS.Types. Fails (nonzero exit) on first broken invariant. }
program test_types;

{$mode objfpc}{$H+}

uses
  SysUtils, PMS.Types;

var
  Ctx: TEvalContext;
  V: Double;
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

begin
  Check(CalcErrorMessage(ceNone) = 'ok', 'ceNone message');
  Check(Pos('zero', CalcErrorMessage(ceDivisionByZero)) > 0, 'div-by-zero message');
  Ctx := TEvalContext.Create;
  try
    Check(Ctx.AngleMode = amRadian, 'default radian mode');
    Check(not Ctx.GetVar('x', V), 'unknown var -> false');
    Ctx.SetVar('x', 2.5);
    Check(Ctx.GetVar('x', V) and (V = 2.5), 'set/get var');
    Ctx.SetVar('x', 3.0);
    Check(Ctx.GetVar('x', V) and (V = 3.0), 'overwrite var');
    Check(Ctx.CheckOps and (Ctx.OpCount = 1), 'op budget counts');
    Ctx.OpCount := PMSMaxOps;
    Check(not Ctx.CheckOps, 'op budget exhausts');
  finally
    Ctx.Free;
  end;
  if Fails > 0 then
  begin
    WriteLn(Fails, ' FAILURES');
    Halt(1);
  end;
  WriteLn('All type tests passed.');
end.
