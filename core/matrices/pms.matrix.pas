{ Matrix and vector engine (Phase 26): creation, arithmetic, transpose,
  trace, determinant (LU partial pivot), inverse (Gauss-Jordan),
  rank, and Ax=b solving. Row-major, 0-based. All dimension problems
  are ceInvalidMatrixDim; singular systems are ceNoConvergence.
  (Matrix *literal* syntax [[..]] arrives with the UI phases; the
  golden det case is covered at API level here.) }
unit PMS.Matrix;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Math, PMS.Types;

type
  TDoubleArray = array of Double;
  TIntArray = array of Integer;

  TMatrix = record
    Rows, Cols: Integer;
    D: array of Double; // row-major, Rows*Cols
  end;

function MIdx(const M: TMatrix; R, C: Integer): Integer;
function MGet(const M: TMatrix; R, C: Integer): Double;
procedure MSet(var M: TMatrix; R, C: Integer; V: Double);
function MMake(Rows, Cols: Integer; out Err: TCalcError): TMatrix;
function MFrom(const V: array of Double; Rows, Cols: Integer;
  out Err: TCalcError): TMatrix;
function MIdent(N: Integer; out Err: TCalcError): TMatrix;
function MAdd(const A, B: TMatrix; out Err: TCalcError): TMatrix;
function MSub(const A, B: TMatrix; out Err: TCalcError): TMatrix;
function MMul(const A, B: TMatrix; out Err: TCalcError): TMatrix;
function MScalar(const A: TMatrix; S: Double): TMatrix;
function MTranspose(const A: TMatrix): TMatrix;
function MTrace(const A: TMatrix; out Err: TCalcError): Double;
function MDet(const A: TMatrix; Tol: Double; out Err: TCalcError): Double;
function MInv(const A: TMatrix; Tol: Double; out Err: TCalcError): TMatrix;
function MRank(const A: TMatrix; Tol: Double): Integer;
function MSolve(const A, B: TMatrix; Tol: Double; out Err: TCalcError): TMatrix;
function MApprox(const A, B: TMatrix; Tol: Double): Boolean;
function MFormat(const A: TMatrix): string;

implementation

function MIdx(const M: TMatrix; R, C: Integer): Integer;
begin
  Result := R * M.Cols + C;
end;

function MGet(const M: TMatrix; R, C: Integer): Double;
begin
  Result := M.D[MIdx(M, R, C)];
end;

procedure MSet(var M: TMatrix; R, C: Integer; V: Double);
begin
  M.D[MIdx(M, R, C)] := V;
end;

function MMake(Rows, Cols: Integer; out Err: TCalcError): TMatrix;
var
  I: Integer;
begin
  Err := ceNone;
  Result.Rows := 0;
  Result.Cols := 0;
  SetLength(Result.D, 0);
  if (Rows < 1) or (Cols < 1) or (Rows > PMSMaxMatrixDim) or
    (Cols > PMSMaxMatrixDim) then
  begin
    Err := ceInvalidMatrixDim;
    Exit;
  end;
  Result.Rows := Rows;
  Result.Cols := Cols;
  SetLength(Result.D, Rows * Cols);
  for I := 0 to High(Result.D) do
    Result.D[I] := 0;
end;

function MFrom(const V: array of Double; Rows, Cols: Integer;
  out Err: TCalcError): TMatrix;
var
  I: Integer;
begin
  Result := MMake(Rows, Cols, Err);
  if Err <> ceNone then
    Exit;
  if Length(V) <> Rows * Cols then
  begin
    Err := ceInvalidMatrixDim;
    Exit;
  end;
  for I := 0 to High(V) do
    Result.D[I] := V[I];
end;

function MIdent(N: Integer; out Err: TCalcError): TMatrix;
var
  I: Integer;
begin
  Result := MMake(N, N, Err);
  if Err <> ceNone then
    Exit;
  for I := 0 to N - 1 do
    MSet(Result, I, I, 1);
end;

function SameDim(const A, B: TMatrix): Boolean;
begin
  Result := (A.Rows = B.Rows) and (A.Cols = B.Cols) and (A.Rows > 0);
end;

function MAdd(const A, B: TMatrix; out Err: TCalcError): TMatrix;
var
  I: Integer;
begin
  Err := ceNone;
  if not SameDim(A, B) then
  begin
    Err := ceInvalidMatrixDim;
    Result := A;
    Exit;
  end;
  Result := A;
  for I := 0 to High(Result.D) do
    Result.D[I] := A.D[I] + B.D[I];
end;

function MSub(const A, B: TMatrix; out Err: TCalcError): TMatrix;
var
  I: Integer;
begin
  Err := ceNone;
  if not SameDim(A, B) then
  begin
    Err := ceInvalidMatrixDim;
    Result := A;
    Exit;
  end;
  Result := A;
  for I := 0 to High(Result.D) do
    Result.D[I] := A.D[I] - B.D[I];
end;

function MMul(const A, B: TMatrix; out Err: TCalcError): TMatrix;
var
  I, J, K: Integer;
  S: Double;
begin
  Err := ceNone;
  if (A.Cols <> B.Rows) or (A.Rows < 1) or (B.Cols < 1) then
  begin
    Err := ceInvalidMatrixDim;
    Result.Rows := 0;
    Result.Cols := 0;
    Exit;
  end;
  Result := MMake(A.Rows, B.Cols, Err);
  if Err <> ceNone then
    Exit;
  for I := 0 to A.Rows - 1 do
    for J := 0 to B.Cols - 1 do
    begin
      S := 0;
      for K := 0 to A.Cols - 1 do
        S := S + MGet(A, I, K) * MGet(B, K, J);
      MSet(Result, I, J, S);
    end;
end;

function MScalar(const A: TMatrix; S: Double): TMatrix;
var
  I: Integer;
begin
  Result := A;
  for I := 0 to High(Result.D) do
    Result.D[I] := Result.D[I] * S;
end;

function MTranspose(const A: TMatrix): TMatrix;
var
  E: TCalcError;
  I, J: Integer;
begin
  Result := MMake(A.Cols, A.Rows, E);
  if E <> ceNone then
  begin
    Result.Rows := 0;
    Result.Cols := 0;
    Exit;
  end;
  for I := 0 to A.Rows - 1 do
    for J := 0 to A.Cols - 1 do
      MSet(Result, J, I, MGet(A, I, J));
end;

function MTrace(const A: TMatrix; out Err: TCalcError): Double;
var
  I: Integer;
begin
  Err := ceNone;
  Result := 0;
  if (A.Rows <> A.Cols) or (A.Rows < 1) then
  begin
    Err := ceInvalidMatrixDim;
    Exit;
  end;
  for I := 0 to A.Rows - 1 do
    Result := Result + MGet(A, I, I);
end;

{ In-place LU with partial pivot on a copy. Returns swap parity in NSwaps. }
function LUFactor(W: TMatrix; Tol: Double; out Piv: TIntArray;
  out NSwaps: Integer; out Err: TCalcError): TMatrix;
var
  N, I, J, K, P: Integer;
  Mx, T: Double;
begin
  Err := ceNone;
  N := W.Rows;
  SetLength(Piv, N);
  for I := 0 to N - 1 do
    Piv[I] := I;
  NSwaps := 0;
  for K := 0 to N - 1 do
  begin
    P := K;
    Mx := Abs(MGet(W, K, K));
    for I := K + 1 to N - 1 do
      if Abs(MGet(W, I, K)) > Mx then
      begin
        Mx := Abs(MGet(W, I, K));
        P := I;
      end;
    if Mx <= Tol then
    begin
      Err := ceNoConvergence; // singular
      Result := W;
      Exit;
    end;
    if P <> K then
    begin
      for J := 0 to N - 1 do
      begin
        T := MGet(W, K, J);
        MSet(W, K, J, MGet(W, P, J));
        MSet(W, P, J, T);
      end;
      I := Piv[K];
      Piv[K] := Piv[P];
      Piv[P] := I;
      Inc(NSwaps);
    end;
    for I := K + 1 to N - 1 do
    begin
      MSet(W, I, K, MGet(W, I, K) / MGet(W, K, K));
      for J := K + 1 to N - 1 do
        MSet(W, I, J, MGet(W, I, J) - MGet(W, I, K) * MGet(W, K, J));
    end;
  end;
  Result := W;
end;

function MDet(const A: TMatrix; Tol: Double; out Err: TCalcError): Double;
var
  W: TMatrix;
  Piv: TIntArray;
  NS, I: Integer;
begin
  Err := ceNone;
  Result := 0;
  if (A.Rows <> A.Cols) or (A.Rows < 1) then
  begin
    Err := ceInvalidMatrixDim;
    Exit;
  end;
  W := A;
  W.D := Copy(A.D); // detach: record assignment shares the array
  W := LUFactor(W, Tol, Piv, NS, Err);
  if Err <> ceNone then
  begin
    Result := 0; // singular: determinant is exactly 0, not an error
    Err := ceNone;
    Exit;
  end;
  Result := 1;
  for I := 0 to A.Rows - 1 do
    Result := Result * MGet(W, I, I);
  if Odd(NS) then
    Result := -Result;
end;

function MInv(const A: TMatrix; Tol: Double; out Err: TCalcError): TMatrix;
var
  N, I, J, K: Integer;
  W, Inv: TMatrix;
  Piv: TIntArray;
  NS: Integer;
  S: Double;
begin
  Err := ceNone;
  if (A.Rows <> A.Cols) or (A.Rows < 1) then
  begin
    Err := ceInvalidMatrixDim;
    Result := A;
    Exit;
  end;
  N := A.Rows;
  W := A;
  W.D := Copy(A.D); // detach
  W := LUFactor(W, Tol, Piv, NS, Err);
  if Err <> ceNone then
    Exit;
  Inv := MIdent(N, Err);
  if Err <> ceNone then
    Exit;
  // solve L*Y = P*I then U*X = Y, column by column
  for K := 0 to N - 1 do
  begin
    // forward: permuted RHS
    for I := 0 to N - 1 do
    begin
      S := 0;
      if Piv[I] = K then
        S := 1;
      for J := 0 to I - 1 do
        S := S - MGet(W, I, J) * MGet(Inv, J, K);
      MSet(Inv, I, K, S);
    end;
    // backward
    for I := N - 1 downto 0 do
    begin
      S := MGet(Inv, I, K);
      for J := I + 1 to N - 1 do
        S := S - MGet(W, I, J) * MGet(Inv, J, K);
      MSet(Inv, I, K, S / MGet(W, I, I));
    end;
  end;
  Result := Inv;
end;

function MRank(const A: TMatrix; Tol: Double): Integer;
var
  W: TMatrix;
  R, C, P, I, J: Integer;
  Mx, T: Double;
begin
  Result := 0;
  if (A.Rows < 1) or (A.Cols < 1) then
    Exit;
  W := A;
  W.D := Copy(A.D); // detach
  R := 0;
  for C := 0 to A.Cols - 1 do
  begin
    if R >= A.Rows then
      Break;
    P := R;
    Mx := Abs(MGet(W, R, C));
    for I := R + 1 to A.Rows - 1 do
      if Abs(MGet(W, I, C)) > Mx then
      begin
        Mx := Abs(MGet(W, I, C));
        P := I;
      end;
    if Mx <= Tol then
      Continue;
    if P <> R then
      for J := C to A.Cols - 1 do
      begin
        T := MGet(W, R, J);
        MSet(W, R, J, MGet(W, P, J));
        MSet(W, P, J, T);
      end;
    for I := R + 1 to A.Rows - 1 do
    begin
      T := MGet(W, I, C) / MGet(W, R, C);
      for J := C to A.Cols - 1 do
        MSet(W, I, J, MGet(W, I, J) - T * MGet(W, R, J));
    end;
    Inc(R);
  end;
  Result := R;
end;

function MSolve(const A, B: TMatrix; Tol: Double; out Err: TCalcError): TMatrix;
var
  N, M, I, J, K, P: Integer;
  W: TMatrix;
  Mx, T: Double;
begin
  Err := ceNone;
  if (A.Rows <> A.Cols) or (A.Rows < 1) or (B.Rows <> A.Rows) or (B.Cols < 1) then
  begin
    Err := ceInvalidMatrixDim;
    Result.Rows := 0;
    Result.Cols := 0;
    Exit;
  end;
  N := A.Rows;
  M := B.Cols;
  W := A;
  W.D := Copy(A.D); // detach
  Result := B;
  Result.D := Copy(B.D); // detach
  for K := 0 to N - 1 do
  begin
    P := K;
    Mx := Abs(MGet(W, K, K));
    for I := K + 1 to N - 1 do
      if Abs(MGet(W, I, K)) > Mx then
      begin
        Mx := Abs(MGet(W, I, K));
        P := I;
      end;
    if Mx <= Tol then
    begin
      Err := ceNoConvergence;
      Exit;
    end;
    if P <> K then
    begin
      for J := K to N - 1 do
      begin
        T := MGet(W, K, J);
        MSet(W, K, J, MGet(W, P, J));
        MSet(W, P, J, T);
      end;
      for J := 0 to M - 1 do
      begin
        T := MGet(Result, K, J);
        MSet(Result, K, J, MGet(Result, P, J));
        MSet(Result, P, J, T);
      end;
    end;
    for I := K + 1 to N - 1 do
    begin
      T := MGet(W, I, K) / MGet(W, K, K);
      MSet(W, I, K, T);
      for J := K + 1 to N - 1 do
        MSet(W, I, J, MGet(W, I, J) - T * MGet(W, K, J));
      for J := 0 to M - 1 do
        MSet(Result, I, J, MGet(Result, I, J) - T * MGet(Result, K, J));
    end;
  end;
  for J := 0 to M - 1 do
    for I := N - 1 downto 0 do
    begin
      T := MGet(Result, I, J);
      for K := I + 1 to N - 1 do
        T := T - MGet(W, I, K) * MGet(Result, K, J);
      MSet(Result, I, J, T / MGet(W, I, I));
    end;
end;

function MApprox(const A, B: TMatrix; Tol: Double): Boolean;
var
  I: Integer;
begin
  if not SameDim(A, B) then
    Exit(False);
  for I := 0 to High(A.D) do
    if Abs(A.D[I] - B.D[I]) > Tol then
      Exit(False);
  Result := True;
end;

function MFormat(const A: TMatrix): string;
var
  I, J: Integer;
begin
  Result := '[';
  for I := 0 to A.Rows - 1 do
  begin
    if I > 0 then
      Result := Result + ';';
    Result := Result + '[';
    for J := 0 to A.Cols - 1 do
    begin
      if J > 0 then
        Result := Result + ',';
      Result := Result + Format('%.10g', [MGet(A, I, J)]);
    end;
    Result := Result + ']';
  end;
  Result := Result + ']';
end;

end.
