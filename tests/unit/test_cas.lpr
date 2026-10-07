{ Assert-runner: PMS.Simplify + PMS.DiffSym + PMS.IntSym (Phases 18, 20, 23). }
program test_cas;

{$mode objfpc}{$H+}

uses
  SysUtils, PMS.Types, PMS.AST, PMS.Parser, PMS.ASTUtils, PMS.Simplify,
  PMS.DiffSym, PMS.IntSym;

var
  Fails: Integer = 0;
  Ctx: TEvalContext;

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

function TreeOf(const Src: string): TASTNode;
var
  E: TCalcError;
  P: Integer;
begin
  if not ParseExpression(Src, Result, E, P) then
  begin
    WriteLn('  (parse failed: ', Src, ')');
    Result := nil;
  end;
end;

procedure CheckSimp(const Src, Want: string);
var
  N, S: TASTNode;
begin
  N := TreeOf(Src);
  if N = nil then
  begin
    Check(False, 'parse ' + Src);
    Exit;
  end;
  S := Simplify(N, Ctx);
  Check(Pretty(S) = Want, 'simp ' + Src + ' -> ' + Pretty(S) + ' (want ' + Want + ')');
  S.Free;
  N.Free;
end;

procedure CheckDiff(const Src, V, Want: string);
var
  N, D: TASTNode;
  E: TCalcError;
begin
  N := TreeOf(Src);
  if N = nil then
  begin
    Check(False, 'parse ' + Src);
    Exit;
  end;
  D := Differentiate(N, V, Ctx, E);
  if E <> ceNone then
  begin
    Check(False, 'diff ' + Src + ' err=' + IntToStr(Ord(E)));
    N.Free;
    Exit;
  end;
  Check(Pretty(D) = Want, 'd/d' + V + ' ' + Src + ' = ' + Pretty(D) + ' (want ' + Want + ')');
  D.Free;
  N.Free;
end;

procedure CheckInt(const Src, V, Want: string);
var
  N, D: TASTNode;
  E: TCalcError;
begin
  N := TreeOf(Src);
  if N = nil then
  begin
    Check(False, 'parse ' + Src);
    Exit;
  end;
  D := Integrate(N, V, Ctx, E);
  if E <> ceNone then
  begin
    Check(False, 'int ' + Src + ' err=' + IntToStr(Ord(E)));
    N.Free;
    Exit;
  end;
  Check(Pretty(D) = Want, 'int ' + Src + ' = ' + Pretty(D) + ' (want ' + Want + ')');
  D.Free;
  N.Free;
end;

procedure CheckUnsimp(const Src: string);
var
  N, D: TASTNode;
  E: TCalcError;
begin
  N := TreeOf(Src);
  D := Integrate(N, 'x', Ctx, E);
  Check((E = ceUnsupported) and (D = nil), 'int ' + Src + ' honestly unsupported');
  D.Free;
  N.Free;
end;

begin
  Ctx := TEvalContext.Create;
  try
    CheckSimp('x + 0', 'x');
    CheckSimp('0 + x', 'x');
    CheckSimp('x - 0', 'x');
    CheckSimp('x - x', '0');
    CheckSimp('x * 1', 'x');
    CheckSimp('1 * x', 'x');
    CheckSimp('x * 0', '0');
    CheckSimp('0 * y', '0');
    CheckSimp('x / 1', 'x');
    CheckSimp('x / x', '1');
    CheckSimp('x^1', 'x');
    CheckSimp('x^0', '1');
    CheckSimp('2*3+4', '10');
    CheckSimp('sin(0)', '0');
    CheckSimp('cos(0)', '1');
    CheckSimp('ln(1)', '0');
    CheckSimp('--x', 'x');

    CheckDiff('x^2', 'x', '2*x');
    CheckDiff('x^3', 'x', '3*x^2');
    CheckDiff('sin(x)', 'x', 'cos(x)');
    CheckDiff('cos(x)', 'x', '-sin(x)');
    CheckDiff('exp(x)', 'x', 'exp(x)');
    CheckDiff('ln(x)', 'x', '1/x');
    CheckDiff('x*sin(x)', 'x', 'sin(x)+x*cos(x)');
    CheckDiff('5', 'x', '0');
    CheckDiff('y', 'x', '0');

    CheckInt('x^2', 'x', 'x^3/3');
    CheckInt('x', 'x', 'x^2/2');
    CheckInt('5', 'x', '5*x');
    CheckInt('sin(x)', 'x', '-cos(x)');
    CheckInt('cos(x)', 'x', 'sin(x)');
    CheckInt('exp(x)', 'x', 'exp(x)');
    CheckInt('2*x+3', 'x', '2*x^2/2+3*x');
    CheckInt('1/x', 'x', 'ln(x)');
    CheckUnsimp('sin(x^2)');
    CheckUnsimp('x*sin(x)');
  finally
    Ctx.Free;
  end;
  if Fails > 0 then
  begin
    WriteLn(Fails, ' FAILURES');
    Halt(1);
  end;
  WriteLn('All CAS tests passed.');
end.
