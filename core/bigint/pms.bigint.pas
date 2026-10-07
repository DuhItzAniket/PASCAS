{ Arbitrary-integer / precision abstraction (Phase 17). Method-style API
  over an Int64 backend with checked arithmetic: overflow is a structured
  error, never a wrap. Callers never touch V directly, so the backend can
  later become a digit array without changing call sites. }
// ponytail: Int64 backend caps exact integers at ±9.2e18; swap TBigInt
// internals for a digit array if exact big-integer demand appears.
unit PMS.BigInt;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, PMS.Types;

type
  TBigInt = record
    V: Int64; // opaque: use the B-functions, not this field
  end;

function BFromInt(X: Int64): TBigInt;
function BFromStr(const S: string; out Err: TCalcError): TBigInt;
function BAdd(const A, B: TBigInt; out Err: TCalcError): TBigInt;
function BSub(const A, B: TBigInt; out Err: TCalcError): TBigInt;
function BMul(const A, B: TBigInt; out Err: TCalcError): TBigInt;
function BNeg(const A: TBigInt): TBigInt;
function BPow(Base: TBigInt; Exp: Integer; out Err: TCalcError): TBigInt;
function BFact(N: Integer; out Err: TCalcError): TBigInt;
function BGCD(const A, B: TBigInt): TBigInt;
function BToStr(const A: TBigInt): string;
function BToFloat(const A: TBigInt): Double;
function BCmp(const A, B: TBigInt): Integer;

implementation

function BFromInt(X: Int64): TBigInt;
begin
  Result.V := X;
end;

function BFromStr(const S: string; out Err: TCalcError): TBigInt;
var
  T: string;
  Neg: Boolean;
  U: QWord;
  I: Integer;
begin
  Err := ceNone;
  T := Trim(S);
  Neg := (T <> '') and (T[1] = '-');
  if Neg or ((T <> '') and (T[1] = '+')) then
    Delete(T, 1, 1);
  for I := 1 to Length(T) do
    if not (T[I] in ['0'..'9']) then
    begin
      Err := ceSyntax; // non-digit junk (empty string lands here too)
      Result.V := 0;
      Exit;
    end;
  if T = '' then
  begin
    Err := ceSyntax;
    Result.V := 0;
    Exit;
  end;
  if not TryStrToQWord(T, U) then
  begin
    Err := ceOverflow; // all digits but beyond QWord
    Result.V := 0;
    Exit;
  end;
  if Neg then
  begin
    if U > QWord(High(Int64)) + 1 then
    begin
      Err := ceOverflow;
      Result.V := 0;
      Exit;
    end;
    if U = QWord(High(Int64)) + 1 then
      Result.V := Low(Int64)
    else
      Result.V := -Int64(U);
  end
  else
  begin
    if U > QWord(High(Int64)) then
    begin
      Err := ceOverflow;
      Result.V := 0;
      Exit;
    end;
    Result.V := Int64(U);
  end;
end;

function BAdd(const A, B: TBigInt; out Err: TCalcError): TBigInt;
begin
  Err := ceNone;
  if B.V > 0 then
  begin
    if A.V > High(Int64) - B.V then
    begin
      Err := ceOverflow;
      Result.V := 0;
      Exit;
    end;
  end
  else if B.V < 0 then
  begin
    if A.V < Low(Int64) - B.V then
    begin
      Err := ceOverflow;
      Result.V := 0;
      Exit;
    end;
  end;
  Result.V := A.V + B.V;
end;

function BSub(const A, B: TBigInt; out Err: TCalcError): TBigInt;
var
  N: TBigInt;
begin
  if B.V = Low(Int64) then
  begin
    // A - Low = A + 2^63: overflows iff A >= 0; exact mod-2^64 otherwise
    if A.V >= 0 then
    begin
      Err := ceOverflow;
      Result.V := 0;
    end
    else
    begin
      Err := ceNone;
      Result.V := A.V - B.V;
    end;
    Exit;
  end;
  N.V := -B.V;
  Result := BAdd(A, N, Err);
end;

function BMul(const A, B: TBigInt; out Err: TCalcError): TBigInt;
var
  X, Y: Int64;
begin
  Err := ceNone;
  X := A.V;
  Y := B.V;
  if (X = 0) or (Y = 0) then
  begin
    Result.V := 0;
    Exit;
  end;
  if X > 0 then
  begin
    if Y > 0 then
    begin
      if X > High(Int64) div Y then
      begin
        Err := ceOverflow;
        Result.V := 0;
        Exit;
      end;
    end
    else
    begin
      if Y < Low(Int64) div X then
      begin
        Err := ceOverflow;
        Result.V := 0;
        Exit;
      end;
    end;
  end
  else
  begin
    if Y > 0 then
    begin
      if X < Low(Int64) div Y then
      begin
        Err := ceOverflow;
        Result.V := 0;
        Exit;
      end;
    end
    else
    begin
      if (X <> 0) and (Y < High(Int64) div X) then
      begin
        Err := ceOverflow;
        Result.V := 0;
        Exit;
      end;
    end;
  end;
  Result.V := X * Y;
end;

function BNeg(const A: TBigInt): TBigInt;
begin
  Result.V := -A.V; // Low(Int64) negation wraps; BCmp callers avoid it
end;

function BPow(Base: TBigInt; Exp: Integer; out Err: TCalcError): TBigInt;
var
  R: TBigInt;
begin
  Err := ceNone;
  if Exp < 0 then
  begin
    Err := ceDomain;
    Result.V := 0;
    Exit;
  end;
  R := BFromInt(1);
  while Exp > 0 do
  begin
    if Odd(Exp) then
    begin
      R := BMul(R, Base, Err);
      if Err <> ceNone then
      begin
        Result.V := 0;
        Exit;
      end;
    end;
    Exp := Exp shr 1;
    if Exp > 0 then
    begin
      Base := BMul(Base, Base, Err);
      if Err <> ceNone then
      begin
        Result.V := 0;
        Exit;
      end;
    end;
  end;
  Result := R;
end;

function BFact(N: Integer; out Err: TCalcError): TBigInt;
var
  I: Integer;
begin
  Err := ceNone;
  if N < 0 then
  begin
    Err := ceDomain;
    Result.V := 0;
    Exit;
  end;
  Result := BFromInt(1);
  for I := 2 to N do
  begin
    Result := BMul(Result, BFromInt(I), Err);
    if Err <> ceNone then
    begin
      Result.V := 0;
      Exit;
    end;
  end;
end;

function BGCD(const A, B: TBigInt): TBigInt;
var
  X, Y, T: Int64;
begin
  X := Abs(A.V);
  Y := Abs(B.V);
  if (A.V = Low(Int64)) or (B.V = Low(Int64)) then
  begin
    // Abs(Low) is out of range; saturate honestly
    Result.V := High(Int64);
    Exit;
  end;
  while Y <> 0 do
  begin
    T := X mod Y;
    X := Y;
    Y := T;
  end;
  Result.V := X;
end;

function BToStr(const A: TBigInt): string;
begin
  Result := IntToStr(A.V);
end;

function BToFloat(const A: TBigInt): Double;
begin
  Result := A.V;
end;

function BCmp(const A, B: TBigInt): Integer;
begin
  if A.V < B.V then
    Result := -1
  else if A.V > B.V then
    Result := 1
  else
    Result := 0;
end;

end.
