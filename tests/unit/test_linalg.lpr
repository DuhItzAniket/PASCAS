{ Assert-runner for PMS.LinAlg (Phase 27). }
program test_linalg;

{$mode objfpc}{$H+}

uses
  SysUtils, PMS.Types, PMS.Matrix, PMS.LinAlg;

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

function ApplyPerm(const Piv: TIntArray; const A: TMatrix): TMatrix;
var
  E: TCalcError;
  I, J: Integer;
begin
  Result := MMake(A.Rows, A.Cols, E);
  for I := 0 to A.Rows - 1 do
    for J := 0 to A.Cols - 1 do
      MSet(Result, I, J, MGet(A, Piv[I], J));
end;

var
  E: TCalcError;
  A, L, U, Q, R, Vv, Vt, Uu, Rec: TMatrix;
  Piv: TIntArray;
  Vals, S: TDoubleArray;
  Vec: TDoubleArray;
  Val: Double;
begin
  // LU: P*A = L*U
  A := MFrom([2, 1, 1, 4, 3, 3, 8, 7, 9], 3, 3, E);
  LUDecomp(A, 1e-12, L, U, Piv, E);
  Check(E = ceNone, 'lu factors');
  Rec := MMul(L, U, E);
  Check(MApprox(Rec, ApplyPerm(Piv, A), 1e-9), 'lu reconstructs P*A');
  // QR: A = Q*R, Q'Q = I
  QRDecomp(A, 1e-12, Q, R, E);
  Check(E = ceNone, 'qr factors');
  Rec := MMul(Q, R, E);
  Check(MApprox(Rec, A, 1e-9), 'qr reconstructs A');
  Rec := MMul(MTranspose(Q), Q, E);
  Check(MApprox(Rec, MIdent(3, E), 1e-9), 'Q orthogonal');
  // symmetric eigen: diag(3,1) permuted
  A := MFrom([2, 1, 1, 2], 2, 2, E);
  EigenSym(A, 1e-12, Vals, Vv, E);
  Check((E = ceNone) and (Abs(Vals[0] + Vals[1] - 4) < 1e-9) and
    (Abs(Vals[0] * Vals[1] - 3) < 1e-9), 'eigvals 3,1 in some order');
  // A = V*diag*V'
  Rec := MMul(Vv, MFrom([Vals[0], 0, 0, Vals[1]], 2, 2, E), E);
  Rec := MMul(Rec, MTranspose(Vv), E);
  Check(MApprox(Rec, A, 1e-8), 'eigendecomposition reconstructs');
  // nonsymmetric refused honestly
  A := MFrom([0, -1, 1, 0], 2, 2, E);
  EigenSym(A, 1e-12, Vals, Vv, E);
  Check(E = ceUnsupported, 'nonsymmetric spectrum refused');
  // power iteration: dominant of diag-ish
  A := MFrom([4, 1, 2, 3], 2, 2, E);
  Check(EigenPower(A, 1e-10, Val, Vec, E) and (Abs(Val - 5) < 1e-6),
    'dominant eigenval 5, got ' + FloatToStr(Val));
  // SVD roundtrip on full-rank 2x2
  A := MFrom([3, 2, 2, 3], 2, 2, E);
  MSVD(A, 1e-12, Uu, S, Vt, E);
  Check((E = ceNone) and (Abs(S[0] - 5) < 1e-8) and (Abs(S[1] - 1) < 1e-8),
    'singular values 5,1');
  Rec := MMul(Uu, MFrom([S[0], 0, 0, S[1]], 2, 2, E), E);
  Rec := MMul(Rec, Vt, E);
  Check(MApprox(Rec, A, 1e-8), 'svd reconstructs: ' + MFormat(Rec));
  if Fails > 0 then
  begin
    WriteLn(Fails, ' FAILURES');
    Halt(1);
  end;
  WriteLn('All linalg tests passed.');
end.
