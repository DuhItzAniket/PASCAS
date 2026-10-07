{ Assert-runner for PMS.Lexer. }
program test_lexer;

{$mode objfpc}{$H+}

uses
  SysUtils, PMS.Types, PMS.Lexer;

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

procedure ShowTokens(const Src: string);
var
  T: TTokenArray;
  E: TCalcError;
  P, I: Integer;
begin
  Check(Tokenize(Src, T, E, P), 'lex ok: ' + Src);
  if E <> ceNone then
    Exit;
  for I := 0 to High(T) do
    WriteLn('  tok kind=', Ord(T[I].Kind), ' text="', T[I].Text, '" pos=', T[I].Pos);
end;

var
  T: TTokenArray;
  E: TCalcError;
  P: Integer;
begin
  Check(Tokenize('2 + 3 * 4', T, E, P) and (Length(T) = 6), '2+3*4 is 5 toks + EOF');
  Check((T[0].Kind = tkNumber) and (T[0].NumValue = 2), 'first tok number 2');
  Check(Tokenize('1.5e-3', T, E, P) and (Abs(T[0].NumValue - 0.0015) < 1e-15), 'scientific notation');
  Check(Tokenize('.5', T, E, P) and (T[0].NumValue = 0.5), 'leading-dot float');
  Check(Tokenize('sin(x)+pi', T, E, P) and (T[0].Kind = tkIdent) and (T[0].Text = 'sin'), 'identifier');
  Check(Tokenize('a=b,c!% ^/-*()', T, E, P), 'all operator tokens');
  Check((not Tokenize('2 @ 3', T, E, P)) and (E = ceSyntax) and (P = 3), 'invalid char @ at pos 3');
  Check((not Tokenize('1e', T, E, P)) and (E = ceSyntax), 'dangling exponent');
  Check((not Tokenize(StringOfChar('1', PMSMaxInputLen + 1), T, E, P)) and (E = ceTooComplex),
    'input length limit');
  ShowTokens('f(x) = a*x^2 + 1');
  if Fails > 0 then
  begin
    WriteLn(Fails, ' FAILURES');
    Halt(1);
  end;
  WriteLn('All lexer tests passed.');
end.
