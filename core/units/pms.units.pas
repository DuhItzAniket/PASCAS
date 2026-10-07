{ Units and dimensional analysis (Phase 30): SI-based quantities with
  dimension vectors, compound-unit parsing (kg*m/s^2), temperature
  offsets, and alias display (N, J, W, Pa...). Incompatible dimensions
  are ceDomain, unknown units ceSyntax. Case-SENSITIVE names: 'F' is the
  farad (fahrenheit is degF), 'C' the coulomb (celsius is degC),
  'S' the siemens (second is s). }
unit PMS.Units;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Math, PMS.Types;

type
  TDim = array[0..6] of Integer; // m kg s K A mol cd

  TQty = record
    V: Double; // always SI
    D: TDim;
  end;

function QMake(V: Double; const U: string; out Q: TQty;
  out Err: TCalcError): Boolean;
function QParseUnit(const U: string; out D: TDim; out Scale: Double;
  out Err: TCalcError): Boolean;
function QAdd(const A, B: TQty; out Err: TCalcError): TQty;
function QSub(const A, B: TQty; out Err: TCalcError): TQty;
function QMul(const A, B: TQty): TQty;
function QDiv(const A, B: TQty; out Err: TCalcError): TQty;
function QPow(const A: TQty; N: Integer): TQty;
function QConvert(const Q: TQty; const U: string; out V: Double;
  out Err: TCalcError): Boolean;
function QFormat(const Q: TQty): string;
function SameDim(const A, B: TDim): Boolean;

implementation

type
  TUnitDef = record
    Name: string;
    D: array[0..6] of Integer;
    Scale: Double; // SI = v * Scale + Off
    Off: Double;
  end;

const
  Units: array[0..44] of TUnitDef = (
    (Name: 'mm'; D: (1,0,0,0,0,0,0); Scale: 1e-3; Off: 0),
    (Name: 'cm'; D: (1,0,0,0,0,0,0); Scale: 1e-2; Off: 0),
    (Name: 'm'; D: (1,0,0,0,0,0,0); Scale: 1; Off: 0),
    (Name: 'km'; D: (1,0,0,0,0,0,0); Scale: 1e3; Off: 0),
    (Name: 'in'; D: (1,0,0,0,0,0,0); Scale: 0.0254; Off: 0),
    (Name: 'ft'; D: (1,0,0,0,0,0,0); Scale: 0.3048; Off: 0),
    (Name: 'yd'; D: (1,0,0,0,0,0,0); Scale: 0.9144; Off: 0),
    (Name: 'mile'; D: (1,0,0,0,0,0,0); Scale: 1609.344; Off: 0),
    (Name: 'mg'; D: (0,1,0,0,0,0,0); Scale: 1e-6; Off: 0),
    (Name: 'g'; D: (0,1,0,0,0,0,0); Scale: 1e-3; Off: 0),
    (Name: 'kg'; D: (0,1,0,0,0,0,0); Scale: 1; Off: 0),
    (Name: 'lb'; D: (0,1,0,0,0,0,0); Scale: 0.45359237; Off: 0),
    (Name: 'ms'; D: (0,0,1,0,0,0,0); Scale: 1e-3; Off: 0),
    (Name: 's'; D: (0,0,1,0,0,0,0); Scale: 1; Off: 0),
    (Name: 'min'; D: (0,0,1,0,0,0,0); Scale: 60; Off: 0),
    (Name: 'h'; D: (0,0,1,0,0,0,0); Scale: 3600; Off: 0),
    (Name: 'day'; D: (0,0,1,0,0,0,0); Scale: 86400; Off: 0),
    (Name: 'K'; D: (0,0,0,1,0,0,0); Scale: 1; Off: 0),
    (Name: 'degC'; D: (0,0,0,1,0,0,0); Scale: 1; Off: 273.15),
    (Name: 'degF'; D: (0,0,0,1,0,0,0); Scale: 0.5555555555555556; Off: 255.3722222222222),
    (Name: 'J'; D: (2,1,-2,0,0,0,0); Scale: 1; Off: 0),
    (Name: 'kJ'; D: (2,1,-2,0,0,0,0); Scale: 1e3; Off: 0),
    (Name: 'cal'; D: (2,1,-2,0,0,0,0); Scale: 4.184; Off: 0),
    (Name: 'kWh'; D: (2,1,-2,0,0,0,0); Scale: 3.6e6; Off: 0),
    (Name: 'W'; D: (2,1,-3,0,0,0,0); Scale: 1; Off: 0),
    (Name: 'kW'; D: (2,1,-3,0,0,0,0); Scale: 1e3; Off: 0),
    (Name: 'MW'; D: (2,1,-3,0,0,0,0); Scale: 1e6; Off: 0),
    (Name: 'Pa'; D: (-1,1,-2,0,0,0,0); Scale: 1; Off: 0),
    (Name: 'kPa'; D: (-1,1,-2,0,0,0,0); Scale: 1e3; Off: 0),
    (Name: 'bar'; D: (-1,1,-2,0,0,0,0); Scale: 1e5; Off: 0),
    (Name: 'atm'; D: (-1,1,-2,0,0,0,0); Scale: 101325; Off: 0),
    (Name: 'psi'; D: (-1,1,-2,0,0,0,0); Scale: 6894.757293168; Off: 0),
    (Name: 'V'; D: (2,1,-3,0,-1,0,0); Scale: 1; Off: 0),
    (Name: 'A'; D: (0,0,0,0,1,0,0); Scale: 1; Off: 0),
    (Name: 'ohm'; D: (2,1,-3,0,-2,0,0); Scale: 1; Off: 0),
    (Name: 'F'; D: (-2,-1,4,0,2,0,0); Scale: 1; Off: 0),
    (Name: 'H'; D: (2,1,-2,0,-2,0,0); Scale: 1; Off: 0),
    (Name: 'N'; D: (1,1,-2,0,0,0,0); Scale: 1; Off: 0),
    (Name: 'Hz'; D: (0,0,-1,0,0,0,0); Scale: 1; Off: 0),
    (Name: 'C'; D: (0,0,1,0,1,0,0); Scale: 1; Off: 0),
    (Name: 'T'; D: (0,1,-2,0,-1,0,0); Scale: 1; Off: 0),
    (Name: 'S'; D: (-2,-1,3,0,2,0,0); Scale: 1; Off: 0),
    (Name: 'mol'; D: (0,0,0,0,0,1,0); Scale: 1; Off: 0),
    (Name: 'cd'; D: (0,0,0,0,0,0,1); Scale: 1; Off: 0),
    (Name: ''; D: (0,0,0,0,0,0,0); Scale: 1; Off: 0)
  );

function FindUnit(const Name: string): Integer;
var
  I: Integer;
begin
  for I := Low(Units) to High(Units) - 1 do
    if Units[I].Name = Name then
      Exit(I);
  Result := -1;
end;

function SameDim(const A, B: TDim): Boolean;
var
  I: Integer;
begin
  for I := 0 to 6 do
    if A[I] <> B[I] then
      Exit(False);
  Result := True;
end;

function ZeroDim(out D: TDim): Boolean;
var
  I: Integer;
begin
  for I := 0 to 6 do
    D[I] := 0;
  Result := True;
end;

function QParseUnit(const U: string; out D: TDim; out Scale: Double;
  out Err: TCalcError): Boolean;
var
  S, Part, Name, ExpS: string;
  I, Caret, Ui, E, J: Integer;
  Num: Boolean;
begin
  Result := False;
  ZeroDim(D);
  Scale := 1;
  Err := ceNone;
  S := Trim(U);
  if S = '' then
  begin
    Err := ceSyntax;
    Exit;
  end;
  Num := True; // numerator until '/'
  I := 1;
  while I <= Length(S) do
  begin
    if S[I] = '*' then
    begin
      Inc(I);
      Continue;
    end;
    if S[I] = '/' then
    begin
      Num := False;
      Inc(I);
      Continue;
    end;
    if S[I] = ' ' then
    begin
      Inc(I);
      Continue;
    end;
    // read one factor
    Part := '';
    while (I <= Length(S)) and (S[I] <> '*') and (S[I] <> '/') and (S[I] <> ' ') do
    begin
      Part := Part + S[I];
      Inc(I);
    end;
    Caret := Pos('^', Part);
    if Caret > 0 then
    begin
      Name := Copy(Part, 1, Caret - 1);
      ExpS := Copy(Part, Caret + 1, Length(Part));
      if not TryStrToInt(ExpS, E) then
      begin
        Err := ceSyntax;
        Exit;
      end;
    end
    else
    begin
      Name := Part;
      E := 1;
    end;
    if not Num then
      E := -E;
    Ui := FindUnit(Name);
    if Ui < 0 then
    begin
      Err := ceSyntax; // unknown unit
      Exit;
    end;
    if Units[Ui].Off <> 0 then
    begin
      Err := ceSyntax; // offset units (degC/degF) only absolute, not compound
      Exit;
    end;
    for J := 0 to 6 do
      D[J] := D[J] + Units[Ui].D[J] * E;
    Scale := Scale * Power(Units[Ui].Scale, E);
  end;
  Result := True;
end;

function QMake(V: Double; const U: string; out Q: TQty;
  out Err: TCalcError): Boolean;
var
  D: TDim;
  Scale, V2: Double;
  Ui: Integer;
  S: string;
begin
  Result := False;
  S := Trim(U);
  Ui := FindUnit(S);
  if Ui >= 0 then
  begin
    // plain unit, offsets allowed
    Q.V := V * Units[Ui].Scale + Units[Ui].Off;
    Q.D := Units[Ui].D;
    Err := ceNone;
    Exit(True);
  end;
  if not QParseUnit(S, D, Scale, Err) then
    Exit;
  V2 := V * Scale;
  Q.V := V2;
  Q.D := D;
  Result := True;
end;

function QAdd(const A, B: TQty; out Err: TCalcError): TQty;
begin
  Err := ceNone;
  if not SameDim(A.D, B.D) then
  begin
    Err := ceDomain; // incompatible dimensions
    Result := A;
    Exit;
  end;
  Result := A;
  Result.V := A.V + B.V;
end;

function QSub(const A, B: TQty; out Err: TCalcError): TQty;
begin
  Err := ceNone;
  if not SameDim(A.D, B.D) then
  begin
    Err := ceDomain;
    Result := A;
    Exit;
  end;
  Result := A;
  Result.V := A.V - B.V;
end;

function QMul(const A, B: TQty): TQty;
var
  I: Integer;
begin
  Result.V := A.V * B.V;
  for I := 0 to 6 do
    Result.D[I] := A.D[I] + B.D[I];
end;

function QDiv(const A, B: TQty; out Err: TCalcError): TQty;
var
  I: Integer;
begin
  Err := ceNone;
  if B.V = 0 then
  begin
    Err := ceDivisionByZero;
    Result := A;
    Exit;
  end;
  Result.V := A.V / B.V;
  for I := 0 to 6 do
    Result.D[I] := A.D[I] - B.D[I];
end;

function QPow(const A: TQty; N: Integer): TQty;
var
  I: Integer;
begin
  Result.V := Power(A.V, N);
  for I := 0 to 6 do
    Result.D[I] := A.D[I] * N;
end;

function QConvert(const Q: TQty; const U: string; out V: Double;
  out Err: TCalcError): Boolean;
var
  D: TDim;
  Scale: Double;
  Ui: Integer;
  S: string;
begin
  Result := False;
  V := 0;
  S := Trim(U);
  Ui := FindUnit(S);
  if Ui >= 0 then
  begin
    if not SameDim(Q.D, Units[Ui].D) then
    begin
      Err := ceDomain;
      Exit;
    end;
    V := (Q.V - Units[Ui].Off) / Units[Ui].Scale;
    Err := ceNone;
    Exit(True);
  end;
  if not QParseUnit(S, D, Scale, Err) then
    Exit;
  if not SameDim(Q.D, D) then
  begin
    Err := ceDomain;
    Exit;
  end;
  V := Q.V / Scale;
  Result := True;
end;

function AliasFor(const D: TDim): string;
var
  I: Integer;
begin
  // exact SI-coherent aliases (scale 1, no offset)
  for I := Low(Units) to High(Units) do
  begin
    if (Units[I].Name = '') or (Units[I].Off <> 0) or (Units[I].Scale <> 1) then
      Continue;
    if SameDim(D, Units[I].D) then
      Exit(Units[I].Name);
  end;
  Result := '';
end;

function QFormat(const Q: TQty): string;
const
  Base: array[0..6] of string = ('m', 'kg', 's', 'K', 'A', 'mol', 'cd');
var
  A: string;
  I: Integer;
  First: Boolean;
begin
  A := AliasFor(Q.D);
  if A <> '' then
    Exit(Format('%.10g %s', [Q.V, A]));
  A := '';
  First := True;
  for I := 0 to 6 do
  begin
    if Q.D[I] = 0 then
      Continue;
    if not First then
      A := A + '*';
    A := A + Base[I];
    if Q.D[I] <> 1 then
      A := A + '^' + IntToStr(Q.D[I]);
    First := False;
  end;
  if A = '' then
    Exit(Format('%.10g', [Q.V]));
  Result := Format('%.10g %s', [Q.V, A]);
end;

end.
