{ Rule-based algebraic simplification (Phase 18). Pure: input untouched,
  new tree out. Two passes bottom-up: fold closed subtrees via the
  evaluator (sin(0), ln(1), 2*3 all vanish here), then ~12 symbolic rules
  (x+0, x*1, x^0, x-x, ...). Domain assumptions documented below.
  Fixpoint loop capped at 16 rounds; each round is linear in tree size. }
unit PMS.Simplify;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, PMS.Types, PMS.AST, PMS.ASTUtils, PMS.Eval, PMS.Consts;

{ Domain assumptions (also the spec's own examples): reals, finite, and
  x/x-style rules assume x <> 0. Variables are case-SENSITIVE (matches
  the evaluator); function/constant names are case-insensitive. }
function Simplify(Node: TASTNode; Ctx: TEvalContext): TASTNode;
function HasFreeVar(Node: TASTNode): Boolean;
function SameTree(A, B: TASTNode): Boolean;

implementation

function HasFreeVar(Node: TASTNode): Boolean;
var
  I: Integer;
  Dummy: Double;
begin
  if Node is TVarNode then
  begin
    // known constants fold; everything else (incl. Ans) is free
    Result := not GetConstant(TVarNode(Node).Name, Dummy);
    Exit;
  end;
  if Node is TFuncNode then
  begin
    for I := 0 to High(TFuncNode(Node).Args) do
      if HasFreeVar(TFuncNode(Node).Args[I]) then
        Exit(True);
    Exit(False);
  end;
  if Node is TBinaryNode then
    Exit(HasFreeVar(TBinaryNode(Node).Left) or HasFreeVar(TBinaryNode(Node).Right));
  if Node is TUnaryNode then
    Exit(HasFreeVar(TUnaryNode(Node).Child));
  if Node is TAssignNode then
    Exit(HasFreeVar(TAssignNode(Node).Expr));
  if Node is TFuncDefNode then
    Exit(HasFreeVar(TFuncDefNode(Node).Body));
  Result := False;
end;

function SameTree(A, B: TASTNode): Boolean;
var
  I: Integer;
begin
  if A.ClassType <> B.ClassType then
    Exit(False);
  if A is TNumberNode then
    Exit(TNumberNode(A).Value = TNumberNode(B).Value);
  if A is TVarNode then
    Exit(TVarNode(A).Name = TVarNode(B).Name);
  if A is TUnaryNode then
    Exit((TUnaryNode(A).Op = TUnaryNode(B).Op) and
      SameTree(TUnaryNode(A).Child, TUnaryNode(B).Child));
  if A is TBinaryNode then
    Exit((TBinaryNode(A).Op = TBinaryNode(B).Op) and
      SameTree(TBinaryNode(A).Left, TBinaryNode(B).Left) and
      SameTree(TBinaryNode(A).Right, TBinaryNode(B).Right));
  if A is TFuncNode then
  begin
    if (TFuncNode(A).Name <> TFuncNode(B).Name) or
      (Length(TFuncNode(A).Args) <> Length(TFuncNode(B).Args)) then
      Exit(False);
    for I := 0 to High(TFuncNode(A).Args) do
      if not SameTree(TFuncNode(A).Args[I], TFuncNode(B).Args[I]) then
        Exit(False);
    Exit(True);
  end;
  if A is TAssignNode then
    Exit((TAssignNode(A).Name = TAssignNode(B).Name) and
      SameTree(TAssignNode(A).Expr, TAssignNode(B).Expr));
  if A is TFuncDefNode then
    Exit(False); // never merge definitions
  Result := False;
end;

function IsNum(Node: TASTNode; V: Double): Boolean;
begin
  Result := (Node is TNumberNode) and (TNumberNode(Node).Value = V);
end;

function Num(V: Double): TASTNode;
begin
  Result := TNumberNode.Create(V);
end;

function SimpOnce(Node: TASTNode; Ctx: TEvalContext): TASTNode;
var
  L, R, C: TASTNode;
  F: TFuncNode;
  I: Integer;
  E: TCalcError;
  V: Double;
begin
  if Node is TNumberNode then
    Exit(TNumberNode.Create(TNumberNode(Node).Value));
  if Node is TVarNode then
    Exit(TVarNode.Create(TVarNode(Node).Name));
  if not HasFreeVar(Node) then
  begin
    // closed subtree: fold via the evaluator (constants, sin(0), 2*3...)
    V := EvalNode(Node, Ctx, E);
    if E = ceNone then
      Exit(Num(V));
  end;
  if Node is TUnaryNode then
  begin
    C := SimpOnce(TUnaryNode(Node).Child, Ctx);
    case TUnaryNode(Node).Op of
      '-':
        if C is TUnaryNode then
        begin
          if TUnaryNode(C).Op = '-' then
          begin
            Result := TUnaryNode(C).Child.Clone();
            C.Free;
            Exit;
          end;
        end;
    end;
    Result := TUnaryNode.Create(TUnaryNode(Node).Op, C);
    Exit;
  end;
  if Node is TBinaryNode then
  begin
    L := SimpOnce(TBinaryNode(Node).Left, Ctx);
    R := SimpOnce(TBinaryNode(Node).Right, Ctx);
    case TBinaryNode(Node).Op of
      '+':
      begin
        if IsNum(L, 0) then
        begin
          L.Free;
          Exit(R);
        end;
        if IsNum(R, 0) then
        begin
          R.Free;
          Exit(L);
        end;
      end;
      '-':
      begin
        if IsNum(R, 0) then
        begin
          R.Free;
          Exit(L);
        end;
        if SameTree(L, R) then
        begin
          L.Free;
          R.Free;
          Exit(Num(0));
        end;
      end;
      '*':
      begin
        if IsNum(L, 0) or IsNum(R, 0) then
        begin
          L.Free;
          R.Free;
          Exit(Num(0));
        end;
        if IsNum(L, 1) then
        begin
          L.Free;
          Exit(R);
        end;
        if IsNum(R, 1) then
        begin
          R.Free;
          Exit(L);
        end;
      end;
      '/':
      begin
        if IsNum(L, 0) and (R is TNumberNode) and (TNumberNode(R).Value <> 0) then
        begin
          L.Free;
          R.Free;
          Exit(Num(0));
        end;
        if IsNum(R, 1) then
        begin
          R.Free;
          Exit(L);
        end;
        if SameTree(L, R) then // valid for x <> 0 (documented)
        begin
          L.Free;
          R.Free;
          Exit(Num(1));
        end;
      end;
      '^':
      begin
        if IsNum(R, 0) then // x^0 = 1 (matches evaluator's 0^0 convention)
        begin
          L.Free;
          R.Free;
          Exit(Num(1));
        end;
        if IsNum(R, 1) then
        begin
          R.Free;
          Exit(L);
        end;
        if IsNum(L, 0) and (R is TNumberNode) and (TNumberNode(R).Value > 0) then
        begin
          L.Free;
          R.Free;
          Exit(Num(0));
        end;
        if IsNum(L, 1) then
        begin
          L.Free;
          R.Free;
          Exit(Num(1));
        end;
      end;
    end;
    Result := TBinaryNode.Create(TBinaryNode(Node).Op, L, R);
    Exit;
  end;
  if Node is TFuncNode then
  begin
    F := TFuncNode.Create(TFuncNode(Node).Name);
    for I := 0 to High(TFuncNode(Node).Args) do
      F.AddArg(SimpOnce(TFuncNode(Node).Args[I], Ctx));
    Exit(F);
  end;
  if Node is TAssignNode then
    Exit(TAssignNode.Create(TAssignNode(Node).Name,
      SimpOnce(TAssignNode(Node).Expr, Ctx)));
  if Node is TFuncDefNode then
  begin
    Result := TFuncDefNode.Create(TFuncDefNode(Node).Name,
      SimpOnce(TFuncDefNode(Node).Body, Ctx));
    for I := 0 to High(TFuncDefNode(Node).Params) do
      TFuncDefNode(Result).AddParam(TFuncDefNode(Node).Params[I]);
    Exit;
  end;
  Result := Node.Clone();
end;

function SerializeKey(Node: TASTNode): string;
begin
  // structural fingerprint for the fixpoint check (cheap: pretty print)
  Result := Pretty(Node);
end;

function Simplify(Node: TASTNode; Ctx: TEvalContext): TASTNode;
var
  Cur, Next: TASTNode;
  I: Integer;
begin
  Cur := SimpOnce(Node, Ctx);
  for I := 1 to 16 do
  begin
    Next := SimpOnce(Cur, Ctx);
    if SerializeKey(Next) = SerializeKey(Cur) then
    begin
      Next.Free;
      Break;
    end;
    Cur.Free;
    Cur := Next;
  end;
  Result := Cur;
end;

end.
