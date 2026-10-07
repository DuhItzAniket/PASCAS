{ Constant registry: math + SI physics. Single source of truth — no
  constant literals scattered through the engine. Identifiers are matched
  case-insensitively by the evaluator. }
unit PMS.Consts;

{$mode objfpc}{$H+}

interface

function GetConstant(const Name: string; out Value: Double): Boolean;
function ConstantCount: Integer;
function ConstantName(Index: Integer): string;

implementation

uses
  SysUtils;

type
  TConstEntry = record
    Name: string;
    Value: Double;
  end;

const
  Entries: array[0..16] of TConstEntry = (
    (Name: 'pi'; Value: 3.14159265358979323846),
    (Name: 'e'; Value: 2.71828182845904523536),
    (Name: 'phi'; Value: 1.61803398874989484820),
    (Name: 'tau'; Value: 6.28318530717958647692),
    (Name: 'sqrt2'; Value: 1.41421356237309504880),
    (Name: 'sqrt3'; Value: 1.73205080756887729352),
    (Name: 'c'; Value: 299792458.0),
    (Name: 'g'; Value: 6.67430e-11),
    (Name: 'h'; Value: 6.62607015e-34),
    (Name: 'hbar'; Value: 1.054571817e-34),
    (Name: 'kb'; Value: 1.380649e-23),
    (Name: 'na'; Value: 6.02214076e23),
    (Name: 'r'; Value: 8.314462618),
    (Name: 'me'; Value: 9.1093837015e-31),
    (Name: 'mp'; Value: 1.67262192369e-27),
    (Name: 'qe'; Value: 1.602176634e-19),
    (Name: 'avogadro'; Value: 6.02214076e23)
  );

function GetConstant(const Name: string; out Value: Double): Boolean;
var
  I: Integer;
  L: string;
begin
  L := LowerCase(Name);
  for I := Low(Entries) to High(Entries) do
    if Entries[I].Name = L then
    begin
      Value := Entries[I].Value;
      Exit(True);
    end;
  Value := 0;
  Result := False;
end;

function ConstantCount: Integer;
begin
  Result := Length(Entries);
end;

function ConstantName(Index: Integer): string;
begin
  if (Index >= Low(Entries)) and (Index <= High(Entries)) then
    Result := Entries[Index].Name
  else
    Result := '';
end;

end.
