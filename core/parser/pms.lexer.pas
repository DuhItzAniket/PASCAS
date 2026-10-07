{ Lexical analysis: numbers, identifiers, operators. No regex, no locale
  dependence (decimal point is always '.'). }
unit PMS.Lexer;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, PMS.Types;

type
  TTokenKind = (tkEOF, tkNumber, tkIdent, tkPlus, tkMinus, tkStar, tkSlash,
    tkCaret, tkLParen, tkRParen, tkComma, tkEquals, tkBang, tkPercent);

  TToken = record
    Kind: TTokenKind;
    NumValue: Double;
    Text: string;
    Pos: Integer;
  end;

  TTokenArray = array of TToken;

{ False + Err on invalid input. ErrPos = 1-based char index. }
function Tokenize(const Src: string; out Tokens: TTokenArray;
  out Err: TCalcError; out ErrPos: Integer): Boolean;

implementation

function IsDigit(C: Char): Boolean; inline;
begin
  Result := (C >= '0') and (C <= '9');
end;

function IsIdentStart(C: Char): Boolean; inline;
begin
  Result := ((C >= 'a') and (C <= 'z')) or ((C >= 'A') and (C <= 'Z')) or (C = '_');
end;

function IsIdentChar(C: Char): Boolean; inline;
begin
  Result := IsIdentStart(C) or IsDigit(C);
end;

procedure Push(var Tokens: TTokenArray; Kind: TTokenKind; Pos: Integer);
begin
  SetLength(Tokens, Length(Tokens) + 1);
  Tokens[High(Tokens)].Kind := Kind;
  Tokens[High(Tokens)].NumValue := 0;
  Tokens[High(Tokens)].Text := '';
  Tokens[High(Tokens)].Pos := Pos;
end;

function Tokenize(const Src: string; out Tokens: TTokenArray;
  out Err: TCalcError; out ErrPos: Integer): Boolean;
var
  I, Start: Integer;
  NumStr: string;

  procedure ScanNumber;
  var
    HasExp: Boolean;
  begin
    Start := I;
    while (I <= Length(Src)) and IsDigit(Src[I]) do
      Inc(I);
    if (I <= Length(Src)) and (Src[I] = '.') then
    begin
      Inc(I);
      while (I <= Length(Src)) and IsDigit(Src[I]) do
        Inc(I);
    end;
    HasExp := (I <= Length(Src)) and ((Src[I] = 'e') or (Src[I] = 'E'));
    if HasExp then
    begin
      Inc(I);
      if (I <= Length(Src)) and ((Src[I] = '+') or (Src[I] = '-')) then
        Inc(I);
      if (I > Length(Src)) or not IsDigit(Src[I]) then
      begin
        Err := ceSyntax;
        ErrPos := Start;
        Tokens := nil;
        Exit;
      end;
      while (I <= Length(Src)) and IsDigit(Src[I]) do
        Inc(I);
    end;
    NumStr := Copy(Src, Start, I - Start);
    if not TryStrToFloat(NumStr, Tokens[High(Tokens)].NumValue) then
    begin
      Err := ceSyntax;
      ErrPos := Start;
      Tokens := nil;
      Exit;
    end;
    Tokens[High(Tokens)].Text := NumStr;
  end;

begin
  Tokens := nil;
  Err := ceNone;
  ErrPos := 0;
  Result := True;
  if Length(Src) > PMSMaxInputLen then
  begin
    Err := ceTooComplex;
    ErrPos := PMSMaxInputLen + 1;
    Exit(False);
  end;
  I := 1;
  while I <= Length(Src) do
  begin
    if (Src[I] = ' ') or (Src[I] = #9) then
    begin
      Inc(I);
      Continue;
    end;
    if IsDigit(Src[I]) or ((Src[I] = '.') and (I < Length(Src)) and IsDigit(Src[I + 1])) then
    begin
      Push(Tokens, tkNumber, I);
      ScanNumber;
      if Err <> ceNone then
        Exit(False);
      Continue;
    end;
    if IsIdentStart(Src[I]) then
    begin
      Start := I;
      while (I <= Length(Src)) and IsIdentChar(Src[I]) do
        Inc(I);
      Push(Tokens, tkIdent, Start);
      Tokens[High(Tokens)].Text := Copy(Src, Start, I - Start);
      Continue;
    end;
    case Src[I] of
      '+': Push(Tokens, tkPlus, I);
      '-': Push(Tokens, tkMinus, I);
      '*': Push(Tokens, tkStar, I);
      '/': Push(Tokens, tkSlash, I);
      '^': Push(Tokens, tkCaret, I);
      '(': Push(Tokens, tkLParen, I);
      ')': Push(Tokens, tkRParen, I);
      ',': Push(Tokens, tkComma, I);
      '=': Push(Tokens, tkEquals, I);
      '!': Push(Tokens, tkBang, I);
      '%': Push(Tokens, tkPercent, I);
    else
      Err := ceSyntax;
      ErrPos := I;
      Tokens := nil;
      Exit(False);
    end;
    Inc(I);
  end;
  Push(Tokens, tkEOF, Length(Src) + 1);
end;

end.
