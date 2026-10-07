{ AST utilities: precedence-aware pretty printer, s-expression serializer,
  node counter, depth, preorder walk. Used by the UI, tests, and session
  save/load (Phase 40). }
unit PMS.ASTUtils;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, PMS.AST;

type
  TVisitProc = procedure(N: TASTNode);

function Pretty(Node: TASTNode): string;
function Serialize(Node: TASTNode): string;
function NodeCount(Node: TASTNode): Integer;
function TreeDepth(Node: TASTNode): Integer;
procedure Walk(Node: TASTNode; Proc: TVisitProc);

implementation

function PrecOf(Op: Char): Integer;
begin
  case Op of
    '+', '-': Result := 1;
    '*', '/', 'm': Result := 2;
    '!': Result := 5;
  else
    Result := 4; // '^', unary, '%'
  end;
end;

function NumStr(V: Double): string;
begin
  Result := FloatToStr(V);
end;

function PrettyBin(Op: Char; L, R: TASTNode): string;
var
  LS, RS: string;
begin
  LS := Pretty(L);
  RS := Pretty(R);
  if (L is TBinaryNode) and (PrecOf(TBinaryNode(L).Op) < PrecOf(Op)) then
    LS := '(' + LS + ')';
  if (R is TBinaryNode) and ((PrecOf(TBinaryNode(R).Op) < PrecOf(Op)) or
    ((TBinaryNode(R).Op = Op) and ((Op = '-') or (Op = '/') or (Op = '^')))) then
    RS := '(' + RS + ')';
  if (R is TUnaryNode) and (Op = '^') then
    RS := '(' + RS + ')';
  if Op = 'm' then
    Result := LS + ' mod ' + RS
  else
    Result := LS + Op + RS;
end;

function Pretty(Node: TASTNode): string;
var
  I: Integer;
  U: TUnaryNode;
begin
  if Node is TNumberNode then
    Result := NumStr(TNumberNode(Node).Value)
  else if Node is TVarNode then
    Result := TVarNode(Node).Name
  else if Node is TUnaryNode then
  begin
    U := TUnaryNode(Node);
    case U.Op of
      '-':
        if (U.Child is TBinaryNode) or (U.Child is TUnaryNode) then
          Result := '-(' + Pretty(U.Child) + ')'
        else
          Result := '-' + Pretty(U.Child);
      '!': Result := Pretty(U.Child) + '!';
      '%': Result := Pretty(U.Child) + '%';
    else
      Result := Pretty(U.Child);
    end;
  end
  else if Node is TBinaryNode then
    Result := PrettyBin(TBinaryNode(Node).Op, TBinaryNode(Node).Left,
      TBinaryNode(Node).Right)
  else if Node is TFuncNode then
  begin
    Result := TFuncNode(Node).Name + '(';
    for I := 0 to High(TFuncNode(Node).Args) do
    begin
      if I > 0 then
        Result := Result + ',';
      Result := Result + Pretty(TFuncNode(Node).Args[I]);
    end;
    Result := Result + ')';
  end
  else if Node is TAssignNode then
    Result := TAssignNode(Node).Name + '=' + Pretty(TAssignNode(Node).Expr)
  else if Node is TFuncDefNode then
  begin
    Result := TFuncDefNode(Node).Name + '(';
    for I := 0 to High(TFuncDefNode(Node).Params) do
    begin
      if I > 0 then
        Result := Result + ',';
      Result := Result + TFuncDefNode(Node).Params[I];
    end;
    Result := Result + ')=' + Pretty(TFuncDefNode(Node).Body);
  end
  else
    Result := '?';
end;

function Serialize(Node: TASTNode): string;
var
  I: Integer;
begin
  if Node is TNumberNode then
    Result := NumStr(TNumberNode(Node).Value)
  else if Node is TVarNode then
    Result := TVarNode(Node).Name
  else if Node is TUnaryNode then
    Result := '(' + TUnaryNode(Node).Op + ' ' + Serialize(TUnaryNode(Node).Child) + ')'
  else if Node is TBinaryNode then
    Result := '(' + TBinaryNode(Node).Op + ' ' + Serialize(TBinaryNode(Node).Left) +
      ' ' + Serialize(TBinaryNode(Node).Right) + ')'
  else if Node is TFuncNode then
  begin
    Result := '(' + TFuncNode(Node).Name;
    for I := 0 to High(TFuncNode(Node).Args) do
      Result := Result + ' ' + Serialize(TFuncNode(Node).Args[I]);
    Result := Result + ')';
  end
  else if Node is TAssignNode then
    Result := '(= ' + TAssignNode(Node).Name + ' ' + Serialize(TAssignNode(Node).Expr) + ')'
  else if Node is TFuncDefNode then
  begin
    Result := '(def ' + TFuncDefNode(Node).Name;
    for I := 0 to High(TFuncDefNode(Node).Params) do
      Result := Result + ' ' + TFuncDefNode(Node).Params[I];
    Result := Result + ' ' + Serialize(TFuncDefNode(Node).Body) + ')';
  end
  else
    Result := '?';
end;

function NodeCount(Node: TASTNode): Integer;
var
  I: Integer;
begin
  if Node is TFuncNode then
  begin
    Result := 1;
    for I := 0 to High(TFuncNode(Node).Args) do
      Result := Result + NodeCount(TFuncNode(Node).Args[I]);
  end
  else if Node is TBinaryNode then
    Result := 1 + NodeCount(TBinaryNode(Node).Left) +
      NodeCount(TBinaryNode(Node).Right)
  else if Node is TUnaryNode then
    Result := 1 + NodeCount(TUnaryNode(Node).Child)
  else if Node is TAssignNode then
    Result := 1 + NodeCount(TAssignNode(Node).Expr)
  else if Node is TFuncDefNode then
    Result := 1 + NodeCount(TFuncDefNode(Node).Body)
  else
    Result := 1;
end;

function TreeDepth(Node: TASTNode): Integer;
var
  I, D: Integer;
begin
  Result := 1;
  if Node is TFuncNode then
  begin
    for I := 0 to High(TFuncNode(Node).Args) do
    begin
      D := TreeDepth(TFuncNode(Node).Args[I]);
      if D + 1 > Result then
        Result := D + 1;
    end;
  end
  else if Node is TBinaryNode then
  begin
    D := TreeDepth(TBinaryNode(Node).Left);
    if D + 1 > Result then
      Result := D + 1;
    D := TreeDepth(TBinaryNode(Node).Right);
    if D + 1 > Result then
      Result := D + 1;
  end
  else if Node is TUnaryNode then
    Result := 1 + TreeDepth(TUnaryNode(Node).Child)
  else if Node is TAssignNode then
    Result := 1 + TreeDepth(TAssignNode(Node).Expr)
  else if Node is TFuncDefNode then
    Result := 1 + TreeDepth(TFuncDefNode(Node).Body);
end;

procedure Walk(Node: TASTNode; Proc: TVisitProc);
var
  I: Integer;
begin
  Proc(Node);
  if Node is TFuncNode then
    for I := 0 to High(TFuncNode(Node).Args) do
      Walk(TFuncNode(Node).Args[I], Proc)
  else if Node is TBinaryNode then
  begin
    Walk(TBinaryNode(Node).Left, Proc);
    Walk(TBinaryNode(Node).Right, Proc);
  end
  else if Node is TUnaryNode then
    Walk(TUnaryNode(Node).Child, Proc)
  else if Node is TAssignNode then
    Walk(TAssignNode(Node).Expr, Proc)
  else if Node is TFuncDefNode then
    Walk(TFuncDefNode(Node).Body, Proc);
end;

end.
