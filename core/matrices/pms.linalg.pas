{ Advanced linear algebra (Phase 27): LU/QR factorizations, symmetric
  eigenpairs via cyclic Jacobi, dominant eigenpair via power iteration,
  and SVD through the symmetric Gram matrix. Tolerances documented;
  nonsymmetric full spectra are honestly out of scope for v1. }
unit PMS.LinAlg;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Math, PMS.Types, PMS.Matrix;

procedure LUDecomp(const A: TMatrix; Tol: Double; out L, U: TMatrix;
  out Piv: TIntArray; out Err: TCalcError);
procedure QRDecomp(const A: TMatrix; Tol: Double; out Q, R: TMatrix;
  out Err: TCalcError);
procedure EigenSym(const A: TMatrix; Tol: Double; out Vals: TDoubleArray;
  out Vecs: TMatrix; out Err: TCalcError);
function EigenPower(const A: TMatrix; Tol: Double; out Val: Double;
  out Vec: TDoubleArray; out Err: TCalcError): Boolean;
procedure MSVD(const A: TMatrix; Tol: Double; out U: TMatrix;
  out S: TDoubleArray; out Vt: TMatrix; out Err: TCalcError);

implementation

procedure LUDecomp(const A: TMatrix; Tol: Double; out L, U: TMatrix;
  out Piv: TIntArray; out Err: TCalcError);
var
  N, I, J, K, P: Integer;
  Mx, T: Double;
begin
  Err := ceNone;
  if (A.Rows <> A.Cols) or (A.Rows < 1) then
  begin
    Err := ceInvalidMatrixDim;
    Exit;
  end;
  N := A.Rows;
  U := A;
  U.D := Copy(A.D);
  L := MIdent(N, Err);
  if Err <> ceNone then
    Exit;
  SetLength(Piv, N);
  for I := 0 to N - 1 do
    Piv[I] := I;
  for K := 0 to N - 1 do
  begin
    P := K;
    Mx := Abs(MGet(U, K, K));
    for I := K + 1 to N - 1 do
      if Abs(MGet(U, I, K)) > Mx then
      begin
        Mx := Abs(MGet(U, I, K));
        P := I;
      end;
    if Mx <= Tol then
    begin
      Err := ceNoConvergence;
      Exit;
    end;
    if P <> K then
    begin
      for J := 0 to N - 1 do
      begin
        T := MGet(U, K, J);
        MSet(U, K, J, MGet(U, P, J));
        MSet(U, P, J, T);
      end;
      for J := 0 to K - 1 do
      begin
        T := MGet(L, K, J);
        MSet(L, K, J, MGet(L, P, J));
        MSet(L, P, J, T);
      end;
      I := Piv[K];
      Piv[K] := Piv[P];
      Piv[P] := I;
    end;
    for I := K + 1 to N - 1 do
    begin
      T := MGet(U, I, K) / MGet(U, K, K);
      MSet(L, I, K, T);
      for J := K to N - 1 do
        MSet(U, I, J, MGet(U, I, J) - T * MGet(U, K, J));
    end;
  end;
  for I := 0 to N - 1 do
    for J := 0 to I - 1 do
      if Abs(MGet(U, I, J)) < Tol then
        MSet(U, I, J, 0);
end;

procedure QRDecomp(const A: TMatrix; Tol: Double; out Q, R: TMatrix;
  out Err: TCalcError);
var
  M, N, I, J, K: Integer;
  S, Nrm: Double;
begin
  Err := ceNone;
  if (A.Rows < 1) or (A.Cols < 1) then
  begin
    Err := ceInvalidMatrixDim;
    Exit;
  end;
  M := A.Rows;
  N := A.Cols;
  Q := MMake(M, N, Err);
  if Err <> ceNone then
    Exit;
  R := MMake(N, N, Err);
  if Err <> ceNone then
    Exit;
  for K := 0 to N - 1 do
  begin
    for I := 0 to M - 1 do
      MSet(Q, I, K, MGet(A, I, K));
    for J := 0 to K - 1 do
    begin
      S := 0;
      for I := 0 to M - 1 do
        S := S + MGet(Q, I, J) * MGet(Q, I, K);
      MSet(R, J, K, S);
      for I := 0 to M - 1 do
        MSet(Q, I, K, MGet(Q, I, K) - S * MGet(Q, I, J));
    end;
    Nrm := 0;
    for I := 0 to M - 1 do
      Nrm := Nrm + Sqr(MGet(Q, I, K));
    Nrm := Sqrt(Nrm);
    if Nrm <= Tol then
    begin
      Err := ceNoConvergence; // rank-deficient
      Exit;
    end;
    MSet(R, K, K, Nrm);
    for I := 0 to M - 1 do
      MSet(Q, I, K, MGet(Q, I, K) / Nrm);
  end;
end;

procedure EigenSym(const A: TMatrix; Tol: Double; out Vals: TDoubleArray;
  out Vecs: TMatrix; out Err: TCalcError);
var
  W: TMatrix;
  N, P, Qc, I, Sweep: Integer;
  Off, App, Aqq, Apq, Phi, C, S, Aip, Aiq, Vip, Viq: Double;
begin
  Err := ceNone;
  if (A.Rows <> A.Cols) or (A.Rows < 1) then
  begin
    Err := ceInvalidMatrixDim;
    Exit;
  end;
  N := A.Rows;
  for I := 0 to N - 1 do
    for Qc := 0 to N - 1 do
      if Abs(MGet(A, I, Qc) - MGet(A, Qc, I)) > Tol then
      begin
        Err := ceUnsupported; // nonsymmetric full spectra: out of v1 scope
        Exit;
      end;
  W := A;
  W.D := Copy(A.D);
  Vecs := MIdent(N, Err);
  if Err <> ceNone then
    Exit;
  for Sweep := 1 to 100 do
  begin
    Off := 0;
    for P := 0 to N - 2 do
      for Qc := P + 1 to N - 1 do
      begin
        Apq := MGet(W, P, Qc);
        Off := Off + Apq * Apq;
        if Abs(Apq) <= Tol then
          Continue;
        App := MGet(W, P, P);
        Aqq := MGet(W, Qc, Qc);
        Phi := (Aqq - App) / (2 * Apq);
        if Phi >= 0 then
          S := 1 / (Phi + Sqrt(1 + Phi * Phi))
        else
          S := -1 / (-Phi + Sqrt(1 + Phi * Phi));
        C := 1 / Sqrt(1 + S * S);
        S := S * C;
        // rotate W
        for I := 0 to N - 1 do
        begin
          if (I = P) or (I = Qc) then
            Continue;
          Aip := MGet(W, I, P);
          Aiq := MGet(W, I, Qc);
          MSet(W, I, P, C * Aip - S * Aiq);
          MSet(W, P, I, C * Aip - S * Aiq);
          MSet(W, I, Qc, S * Aip + C * Aiq);
          MSet(W, Qc, I, S * Aip + C * Aiq);
        end;
        MSet(W, P, P, C * C * App - 2 * S * C * Apq + S * S * Aqq);
        MSet(W, Qc, Qc, S * S * App + 2 * S * C * Apq + C * C * Aqq);
        MSet(W, P, Qc, 0);
        MSet(W, Qc, P, 0);
        // accumulate vectors
        for I := 0 to N - 1 do
        begin
          Vip := MGet(Vecs, I, P);
          Viq := MGet(Vecs, I, Qc);
          MSet(Vecs, I, P, C * Vip - S * Viq);
          MSet(Vecs, I, Qc, S * Vip + C * Viq);
        end;
      end;
    if Sqrt(Off) <= Tol then
      Break;
  end;
  SetLength(Vals, N);
  for I := 0 to N - 1 do
    Vals[I] := MGet(W, I, I);
end;

function EigenPower(const A: TMatrix; Tol: Double; out Val: Double;
  out Vec: TDoubleArray; out Err: TCalcError): Boolean;
var
  N, I, J, It: Integer;
  W, Nw: TDoubleArray;
  Lambda, Prev, Nrm: Double;
begin
  Result := False;
  Val := 0;
  SetLength(Vec, 0);
  if (A.Rows <> A.Cols) or (A.Rows < 1) then
  begin
    Err := ceInvalidMatrixDim;
    Exit;
  end;
  N := A.Rows;
  SetLength(W, N);
  SetLength(Nw, N);
  for I := 0 to N - 1 do
    W[I] := 1;
  Prev := 0;
  for It := 1 to PMSMaxIterations * 5 do
  begin
    for I := 0 to N - 1 do
    begin
      Nw[I] := 0;
      for J := 0 to N - 1 do
        Nw[I] := Nw[I] + MGet(A, I, J) * W[J];
    end;
    Nrm := 0;
    for I := 0 to N - 1 do
      Nrm := Nrm + Nw[I] * Nw[I];
    Nrm := Sqrt(Nrm);
    if Nrm = 0 then
    begin
      Err := ceNoConvergence;
      Exit;
    end;
    Lambda := 0;
    for I := 0 to N - 1 do
    begin
      W[I] := Nw[I] / Nrm;
      Lambda := Lambda + W[I] * Nw[I];
    end;
    if Abs(Lambda - Prev) <= Tol * (1 + Abs(Lambda)) then
    begin
      Val := Lambda;
      Vec := Copy(W);
      Err := ceNone;
      Exit(True);
    end;
    Prev := Lambda;
  end;
  Err := ceNoConvergence;
end;

procedure MSVD(const A: TMatrix; Tol: Double; out U: TMatrix;
  out S: TDoubleArray; out Vt: TMatrix; out Err: TCalcError);
var
  M, N, I, J, K, R: Integer;
  G, V: TMatrix;
  Vals: TDoubleArray;
  Col: TMatrix;
  Nrm: Double;
begin
  Err := ceNone;
  if (A.Rows < 1) or (A.Cols < 1) then
  begin
    Err := ceInvalidMatrixDim;
    Exit;
  end;
  M := A.Rows;
  N := A.Cols;
  // Gram matrix G = A'A (symmetric, N x N)
  G := MMul(MTranspose(A), A, Err);
  if Err <> ceNone then
    Exit;
  EigenSym(G, Tol, Vals, V, Err);
  if Err <> ceNone then
    Exit;
  // singular values, clamped at 0, sorted descending (standard SVD order)
  SetLength(S, N);
  for I := 0 to N - 1 do
  begin
    if Vals[I] < 0 then
      Vals[I] := 0;
    S[I] := Sqrt(Vals[I]);
  end;
  for I := 0 to N - 2 do
    for J := I + 1 to N - 1 do
      if S[J] > S[I] then
      begin
        Nrm := S[I];
        S[I] := S[J];
        S[J] := Nrm;
        for K := 0 to N - 1 do // swap eigenvector columns to match
        begin
          Nrm := MGet(V, K, I);
          MSet(V, K, I, MGet(V, K, J));
          MSet(V, K, J, Nrm);
        end;
      end;
  R := 0;
  for I := 0 to N - 1 do
    if S[I] > Tol then
      Inc(R);
  // Vt = V' ; U columns = A*v_i / s_i
  Vt := MTranspose(V);
  U := MMake(M, R, Err);
  if Err <> ceNone then
    Exit;
  K := 0;
  for I := 0 to N - 1 do
  begin
    if S[I] <= Tol then
      Continue;
    Col := MMake(N, 1, Err);
    if Err <> ceNone then
      Exit;
    for J := 0 to N - 1 do
      MSet(Col, J, 0, MGet(V, J, I));
    Col := MMul(A, Col, Err);
    if Err <> ceNone then
      Exit;
    Nrm := 0;
    for J := 0 to M - 1 do
      Nrm := Nrm + Sqr(MGet(Col, J, 0));
    Nrm := Sqrt(Nrm);
    for J := 0 to M - 1 do
      if Nrm > 0 then
        MSet(U, J, K, MGet(Col, J, 0) / Nrm)
      else
        MSet(U, J, K, 0);
    Inc(K);
  end;
end;

end.
