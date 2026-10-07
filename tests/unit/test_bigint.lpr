{ Assert-runner for PMS.BigInt (Phase 17). }
program test_bigint;

{$mode objfpc}{$H+}

uses
  SysUtils, PMS.Types, PMS.BigInt;

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
  E: TCalcError;
  A, B, C: TBigInt;
begin
  A := BFromInt(40);
  B := BFromInt(2);
  C := BAdd(A, B, E);
  Check((E = ceNone) and (BToStr(C) = '42'), 'add');
  C := BMul(A, B, E);
  Check((E = ceNone) and (BToStr(C) = '80'), 'mul');
  C := BSub(A, B, E);
  Check((E = ceNone) and (BToStr(C) = '38'), 'sub');
  C := BFact(20, E);
  Check((E = ceNone) and (BToStr(C) = '2432902008176640000'), '20! exact: ' + BToStr(C));
  C := BFact(21, E);
  Check(E = ceOverflow, '21! overflows Int64 honestly');
  C := BFact(-1, E);
  Check(E = ceDomain, 'negative factorial domain');
  C := BPow(BFromInt(2), 62, E);
  Check((E = ceNone) and (BToStr(C) = '4611686018427387904'), '2^62');
  C := BPow(BFromInt(2), 63, E);
  Check(E = ceOverflow, '2^63 overflows');
  C := BPow(BFromInt(10), 0, E);
  Check((E = ceNone) and (BToStr(C) = '1'), 'x^0 = 1');
  C := BPow(BFromInt(2), -1, E);
  Check(E = ceDomain, 'negative exponent domain');
  A := BFromInt(High(Int64));
  C := BAdd(A, BFromInt(1), E);
  Check(E = ceOverflow, 'MaxInt64+1 overflow');
  C := BSub(BFromInt(-5), BFromInt(Low(Int64)), E);
  Check((E = ceNone) and (BToStr(C) = '9223372036854775803'), 'sub Low edge');
  C := BFromStr('123456789012345678', E);
  Check((E = ceNone) and (BToStr(C) = '123456789012345678'), 'from string');
  C := BFromStr('99999999999999999999', E);
  Check(E = ceOverflow, 'oversize string overflow');
  C := BFromStr('abc', E);
  Check(E = ceSyntax, 'junk string syntax error');
  Check(BCmp(BFromInt(3), BFromInt(5)) < 0, 'cmp');
  Check(BGCD(BFromInt(12), BFromInt(18)).V = 6, 'gcd');
  if Fails > 0 then
  begin
    WriteLn(Fails, ' FAILURES');
    Halt(1);
  end;
  WriteLn('All bigint tests passed.');
end.
