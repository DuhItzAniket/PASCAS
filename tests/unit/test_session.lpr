{ Assert-runner for PMS.Session (Phase 40): JSON engine + save/load +
  URL-hash sharing. }
program test_session;

{$mode objfpc}{$H+}

uses
  SysUtils, PMS.Types, PMS.Viewport, PMS.Workspace, PMS.Session;

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
  W, W2: TWorkspace;
  V, V2: TViewport;
  E: TCalcError;
  P, A: Integer;
  J, H, Back: string;
  VV: Double;
  JV: TJsonVal;
  EP: Integer;
begin
  // JSON engine basics
  Check(JsonParse('{"a":1,"b":[true,null],"c":"x\"y"}', JV, EP), 'parse object');
  Check(JsonStringify(JV) = '{"a":1,"b":[true,null],"c":"x\"y"}', 'roundtrip');
  Check(not JsonParse('{"a":}', JV, EP), 'trailing content refused');
  Check(not JsonParse('[1,2', JV, EP), 'truncated refused');
  Check(JsonParse('  42  ', JV, EP) and (JV.Kind = jkNum), 'surrounding ws');

  W := TWorkspace.Create;
  try
    V := VDefault(800, 600);
    V.XMin := -5;
    V.XMax := 5;
    Check(W.DefineVar('a = 2', E, P), 'session var');
    Check(W.AddExpr('a*sin(x)', wkFuncY, E, P) = 0, 'session expr');
    Check(W.AddExpr('t*t;t+1', wkParam, E, P) = 1, 'session param');
    W.SetVisible(1, False);
    Check(SessionSave(W, V, 1, J), 'save');
    Check(Pos('"schemaVersion":1', J) > 0, 'schema marker present');
    H := SessionToHash(J);
    Check((H <> '') and (H[1] = '#'), 'hash prefix');
    Check(SessionFromHash(H, Back, E) and (Back = J), 'hash roundtrip');

    W2 := TWorkspace.Create;
    try
      V2 := VDefault(1, 1);
      Check(SessionLoad(J, W2, V2, A, E), 'load');
      Check((W2.EntryCount = 2) and (W2.EntryKind(1) = wkParam) and
        (not W2.EntryVisible(1)), 'entries restored');
      Check((Abs(V2.XMin + 5) < 1e-9) and (Abs(V2.XMax - 5) < 1e-9),
        'viewport restored');
      Check(A = 1, 'angle restored');
      Check(W2.GetVar('a', VV) and (Abs(VV - 2) < 1e-12), 'var restored');
      Check(not SessionLoad('{"nope":1}', W2, V2, A, E) and
        (E = ceUnsupported), 'schema-less refused');
      Check(not SessionLoad('{{{', W2, V2, A, E) and (E = ceSyntax),
        'garbage refused');
    finally
      W2.Free;
    end;
  finally
    W.Free;
  end;
  if Fails > 0 then
  begin
    WriteLn(Fails, ' FAILURES');
    Halt(1);
  end;
  WriteLn('All session tests passed.');
end.
