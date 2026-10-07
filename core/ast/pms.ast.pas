{ Single AST for evaluator, simplifier, differentiator, plotter, printer.
  Root owns all children: freeing the root frees the tree. }
unit PMS.AST;

{$mode objfpc}{$H+}

interface

type
  TASTNode = class
  public
    function Clone: TASTNode; virtual; abstract;
  end;

  TNumberNode = class(TASTNode)
  public
    Value: Double;
    constructor Create(AValue: Double);
    function Clone: TASTNode; override;
  end;

  TVarNode = class(TASTNode)
  public
    Name: string;
    constructor Create(const AName: string);
    function Clone: TASTNode; override;
  end;

  { Op: '+' unary plus / '-' negate / '!' factorial / '%' percent. }
  TUnaryNode = class(TASTNode)
  public
    Op: Char;
    Child: TASTNode;
    constructor Create(AOp: Char; AChild: TASTNode);
    destructor Destroy; override;
    function Clone: TASTNode; override;
  end;

  { Op: '+','-','*','/','^','m' (modulo). }
  TBinaryNode = class(TASTNode)
  public
    Op: Char;
    Left, Right: TASTNode;
    constructor Create(AOp: Char; ALeft, ARight: TASTNode);
    destructor Destroy; override;
    function Clone: TASTNode; override;
  end;

  TFuncNode = class(TASTNode)
  public
    Name: string;
    Args: array of TASTNode;
    constructor Create(const AName: string);
    destructor Destroy; override;
    procedure AddArg(A: TASTNode);
    function Clone: TASTNode; override;
  end;

  TAssignNode = class(TASTNode)
  public
    Name: string;
    Expr: TASTNode;
    constructor Create(const AName: string; AExpr: TASTNode);
    destructor Destroy; override;
    function Clone: TASTNode; override;
  end;

  { Parsed in Phase 08; evaluated in Phase 31. }
  TFuncDefNode = class(TASTNode)
  public
    Name: string;
    Params: array of string;
    Body: TASTNode;
    constructor Create(const AName: string; ABody: TASTNode);
    destructor Destroy; override;
    procedure AddParam(const P: string);
    function Clone: TASTNode; override;
  end;

implementation

constructor TNumberNode.Create(AValue: Double);
begin
  inherited Create;
  Value := AValue;
end;

function TNumberNode.Clone: TASTNode;
begin
  Result := TNumberNode.Create(Value);
end;

constructor TVarNode.Create(const AName: string);
begin
  inherited Create;
  Name := AName;
end;

function TVarNode.Clone: TASTNode;
begin
  Result := TVarNode.Create(Name);
end;

constructor TUnaryNode.Create(AOp: Char; AChild: TASTNode);
begin
  inherited Create;
  Op := AOp;
  Child := AChild;
end;

destructor TUnaryNode.Destroy;
begin
  Child.Free;
  inherited Destroy;
end;

function TUnaryNode.Clone: TASTNode;
begin
  Result := TUnaryNode.Create(Op, Child.Clone);
end;

constructor TBinaryNode.Create(AOp: Char; ALeft, ARight: TASTNode);
begin
  inherited Create;
  Op := AOp;
  Left := ALeft;
  Right := ARight;
end;

destructor TBinaryNode.Destroy;
begin
  Left.Free;
  Right.Free;
  inherited Destroy;
end;

function TBinaryNode.Clone: TASTNode;
begin
  Result := TBinaryNode.Create(Op, Left.Clone, Right.Clone);
end;

constructor TFuncNode.Create(const AName: string);
begin
  inherited Create;
  Name := AName;
  SetLength(Args, 0);
end;

destructor TFuncNode.Destroy;
var
  I: Integer;
begin
  for I := 0 to High(Args) do
    Args[I].Free;
  inherited Destroy;
end;

procedure TFuncNode.AddArg(A: TASTNode);
begin
  SetLength(Args, Length(Args) + 1);
  Args[High(Args)] := A;
end;

function TFuncNode.Clone: TASTNode;
var
  I: Integer;
begin
  Result := TFuncNode.Create(Name);
  for I := 0 to High(Args) do
    TFuncNode(Result).AddArg(Args[I].Clone);
end;

constructor TAssignNode.Create(const AName: string; AExpr: TASTNode);
begin
  inherited Create;
  Name := AName;
  Expr := AExpr;
end;

destructor TAssignNode.Destroy;
begin
  Expr.Free;
  inherited Destroy;
end;

function TAssignNode.Clone: TASTNode;
begin
  Result := TAssignNode.Create(Name, Expr.Clone);
end;

constructor TFuncDefNode.Create(const AName: string; ABody: TASTNode);
begin
  inherited Create;
  Name := AName;
  Body := ABody;
  SetLength(Params, 0);
end;

destructor TFuncDefNode.Destroy;
begin
  Body.Free;
  inherited Destroy;
end;

procedure TFuncDefNode.AddParam(const P: string);
begin
  SetLength(Params, Length(Params) + 1);
  Params[High(Params)] := P;
end;

function TFuncDefNode.Clone: TASTNode;
var
  I: Integer;
begin
  Result := TFuncDefNode.Create(Name, Body.Clone);
  for I := 0 to High(Params) do
    TFuncDefNode(Result).AddParam(Params[I]);
end;

end.
