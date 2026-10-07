{ Assert-runner for PMS.Matrix (Phase 26). }
program test_matrix;

{$mode objfpc}{$H+}

uses
  SysUtils, PMS.Types, PMS.Matrix;

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
  A, B, C, I2: TMatrix;
  D: Double;
begin
  A := MFrom([1, 2, 3, 4], 2, 2, E);
  Check(E = ceNone, 'make 2x2');
  // golden: det([[1,2],[3,4]]) = -2
  D := MDet(A, 1e-12, E);
  Check((E = ceNone) and (Abs(D + 2) < 1e-12), 'det = -2');
  I2 := MIdent(2, E);
  B := MMul(A, I2, E);
  Check((E = ceNone) and MApprox(A, B, 1e-12), 'A*I = A');
  C := MInv(A, 1e-12, E);
  Check(E = ceNone, 'inverse exists');
  B := MMul(A, C, E);
  Check((E = ceNone) and MApprox(B, I2, 1e-9), 'A*inv = I, got ' + MFormat(B));
  Check(Abs(MTrace(A, E) - 5) < 1e-12, 'trace = 5');
  B := MTranspose(A);
  Check(Abs(MGet(B, 0, 1) - 3) < 1e-12, 'transpose');
  B := MFrom([5, 6], 2, 1, E);
  C := MSolve(A, B, 1e-12, E);
  Check((E = ceNone) and (Abs(MGet(C, 0, 0) + 4) < 1e-9) and
    (Abs(MGet(C, 1, 0) - 4.5) < 1e-9), 'solve Ax=b');
  Check(MRank(A, 1e-12) = 2, 'rank 2');
  B := MFrom([2, 4, 1, 2], 2, 2, E);
  Check(MRank(B, 1e-12) = 1, 'rank-deficient rank 1');
  C := MInv(B, 1e-12, E);
  Check(E = ceNoConvergence, 'singular inverse refused');
  B := MFrom([1, 2, 3], 1, 3, E);
  C := MAdd(A, B, E);
  Check(E = ceInvalidMatrixDim, 'dim mismatch refused');
  C := MScalar(A, 2);
  Check(Abs(MGet(C, 1, 1) - 8) < 1e-12, 'scalar mul');
  Check(MFormat(I2) = '[[1,0];[0,1]]', 'format: ' + MFormat(I2));
  if Fails > 0 then
  begin
    WriteLn(Fails, ' FAILURES');
    Halt(1);
  end;
  WriteLn('All matrix tests passed.');
end.
