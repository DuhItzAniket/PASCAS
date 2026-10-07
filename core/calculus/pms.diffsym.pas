{ Symbolic differentiation (Phase 20): constants, variables, powers,
  sums, products, quotients, elementary functions with chain rule.
  Pure (input untouched); results pass through the simplifier so
  d/dx(x^2) reads 2*x, not 2*x^1*1. Golden cases in test_cas. }
unit PMS.DiffSym;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, PMS.Types, PMS.AST, PMS.Simplify;

function HasVar(Node: TASTNode; const VarName: string): Boolean;
function Differentiate(Node: TASTNode; const VarName: string;
  Ctx: TEvalContext; out Err: TCalcError): TASTNode;

implementation

function HasVar(Node: TASTNode; const VarName: string): Boolean;
var
  I: Integer;
begin
  if Node is TVarNode then
    Exit(TVarNode(Node).Name = VarName);
  if Node is TFuncNode then
  begin
    for I := 0 to High(TFuncNode(Node).Args) do
      if HasVar(TFuncNode(Node).Args[I], VarName) then
        Exit(True);
    Exit(False);
  end;
  if Node is TBinaryNode then
    Exit(HasVar(TBinaryNode(Node).Left, VarName) or
      HasVar(TBinaryNode(Node).Right, VarName));
  if Node is TUnaryNode then
    Exit(HasVar(TUnaryNode(Node).Child, VarName));
  Result := False;
end;

function DRaw(Node: TASTNode; const VarName: string;
  out Err: TCalcError): TASTNode;
var
  U, V, Du, Dv: TASTNode;
  F: TFuncNode;
  E1, N1: TASTNode;
  L: string;
  I: Integer;
begin
  Err := ceNone;
  Result := nil;
  if Node is TNumberNode then
    Exit(TNumberNode.Create(0));
  if Node is TVarNode then
  begin
    if TVarNode(Node).Name = VarName then
      Exit(TNumberNode.Create(1));
    Exit(TNumberNode.Create(0));
  end;
  if Node is TUnaryNode then
  begin
    Du := DRaw(TUnaryNode(Node).Child, VarName, Err);
    if Err <> ceNone then
    begin
      Du.Free;
      Exit(nil);
    end;
    if TUnaryNode(Node).Op = '-' then
      Exit(TUnaryNode.Create('-', Du));
    if TUnaryNode(Node).Op = '%' then
      Exit(TBinaryNode.Create('/', Du, TNumberNode.Create(100)));
    Result := Du; // unary plus: (+u)' = u'
    Exit;
  end;
  if Node is TBinaryNode then
  begin
    U := TBinaryNode(Node).Left;
    V := TBinaryNode(Node).Right;
    case TBinaryNode(Node).Op of
      '+', '-':
      begin
        Du := DRaw(U, VarName, Err);
        if Err <> ceNone then
        begin
          Du.Free;
          Exit(nil);
        end;
        Dv := DRaw(V, VarName, Err);
        if Err <> ceNone then
        begin
          Du.Free;
          Dv.Free;
          Exit(nil);
        end;
        Exit(TBinaryNode.Create(TBinaryNode(Node).Op, Du, Dv));
      end;
      '*':
      begin
        Du := DRaw(U, VarName, Err);
        if Err <> ceNone then
        begin
          Du.Free;
          Exit(nil);
        end;
        Dv := DRaw(V, VarName, Err);
        if Err <> ceNone then
        begin
          Du.Free;
          Dv.Free;
          Exit(nil);
        end;
        // u'v + uv'
        Exit(TBinaryNode.Create('+',
          TBinaryNode.Create('*', Du, V.Clone()),
          TBinaryNode.Create('*', U.Clone(), Dv)));
      end;
      '/':
      begin
        Du := DRaw(U, VarName, Err);
        if Err <> ceNone then
        begin
          Du.Free;
          Exit(nil);
        end;
        Dv := DRaw(V, VarName, Err);
        if Err <> ceNone then
        begin
          Du.Free;
          Dv.Free;
          Exit(nil);
        end;
        // (u'v - uv') / v^2
        Exit(TBinaryNode.Create('/',
          TBinaryNode.Create('-',
            TBinaryNode.Create('*', Du, V.Clone()),
            TBinaryNode.Create('*', U.Clone(), Dv)),
          TBinaryNode.Create('^', V.Clone(), TNumberNode.Create(2))));
      end;
      '^':
      begin
        if not HasVar(V, VarName) then
        begin
          // power rule: n*u^(n-1)*u'
          Du := DRaw(U, VarName, Err);
          if Err <> ceNone then
          begin
            Du.Free;
            Exit(nil);
          end;
          Exit(TBinaryNode.Create('*',
            TBinaryNode.Create('*', V.Clone(),
              TBinaryNode.Create('^', U.Clone(),
                TBinaryNode.Create('-', V.Clone(), TNumberNode.Create(1)))),
            Du));
        end;
        if not HasVar(U, VarName) then
        begin
          // a^v: a^v * ln(a) * v'
          Dv := DRaw(V, VarName, Err);
          if Err <> ceNone then
          begin
            Dv.Free;
            Exit(nil);
          end;
          F := TFuncNode.Create('ln');
          F.AddArg(U.Clone());
          Exit(TBinaryNode.Create('*',
            TBinaryNode.Create('*', Node.Clone(), F), Dv));
        end;
        // general u^v: u^v * (v'*ln(u) + v*u'/u)
        Du := DRaw(U, VarName, Err);
        if Err <> ceNone then
        begin
          Du.Free;
          Exit(nil);
        end;
        Dv := DRaw(V, VarName, Err);
        if Err <> ceNone then
        begin
          Du.Free;
          Dv.Free;
          Exit(nil);
        end;
        F := TFuncNode.Create('ln');
        F.AddArg(U.Clone());
        Exit(TBinaryNode.Create('*', Node.Clone(),
          TBinaryNode.Create('+',
            TBinaryNode.Create('*', Dv, F),
            TBinaryNode.Create('/', TBinaryNode.Create('*', V.Clone(), Du),
              U.Clone()))));
      end;
      'm':
      begin
        Err := ceUnsupported;
        Exit(nil);
      end;
    end;
    Err := ceUnsupported;
    Exit(nil);
  end;
  if Node is TFuncNode then
  begin
    F := TFuncNode(Node);
    if Length(F.Args) <> 1 then
    begin
      Err := ceUnsupported; // only single-arg rules in v1
      Exit(nil);
    end;
    U := F.Args[0];
    Du := DRaw(U, VarName, Err);
    if Err <> ceNone then
    begin
      Du.Free;
      Exit(nil);
    end;
    L := LowerCase(F.Name);
    E1 := nil;
    if L = 'sin' then
    begin
      E1 := TFuncNode.Create('cos');
      TFuncNode(E1).AddArg(U.Clone());
    end
    else if L = 'cos' then
    begin
      E1 := TFuncNode.Create('sin');
      TFuncNode(E1).AddArg(U.Clone());
      E1 := TUnaryNode.Create('-', E1);
    end
    else if L = 'tan' then
    begin
      // sec^2 = 1 + tan^2
      N1 := TFuncNode.Create('tan');
      TFuncNode(N1).AddArg(U.Clone());
      E1 := TBinaryNode.Create('+', TNumberNode.Create(1),
        TBinaryNode.Create('^', N1, TNumberNode.Create(2)));
    end
    else if L = 'exp' then
      E1 := Node.Clone()
    else if L = 'ln' then
      E1 := TBinaryNode.Create('/', TNumberNode.Create(1), U.Clone())
    else if L = 'log' then
    begin
      F := TFuncNode.Create('ln');
      F.AddArg(TNumberNode.Create(10));
      E1 := TBinaryNode.Create('/', TNumberNode.Create(1),
        TBinaryNode.Create('*', U.Clone(), F));
    end
    else if L = 'sqrt' then
    begin
      E1 := TFuncNode.Create('sqrt');
      TFuncNode(E1).AddArg(U.Clone());
      E1 := TBinaryNode.Create('/', TNumberNode.Create(1),
        TBinaryNode.Create('*', TNumberNode.Create(2), E1));
    end
    else if L = 'asin' then
    begin
      E1 := TBinaryNode.Create('-', TNumberNode.Create(1),
        TBinaryNode.Create('^', U.Clone(), TNumberNode.Create(2)));
      F := TFuncNode.Create('sqrt');
      F.AddArg(E1);
      E1 := TBinaryNode.Create('/', TNumberNode.Create(1), F);
    end
    else if L = 'acos' then
    begin
      E1 := TBinaryNode.Create('-', TNumberNode.Create(1),
        TBinaryNode.Create('^', U.Clone(), TNumberNode.Create(2)));
      F := TFuncNode.Create('sqrt');
      F.AddArg(E1);
      E1 := TBinaryNode.Create('/', TNumberNode.Create(1), F);
      E1 := TUnaryNode.Create('-', E1);
    end
    else if L = 'atan' then
    begin
      E1 := TBinaryNode.Create('+', TNumberNode.Create(1),
        TBinaryNode.Create('^', U.Clone(), TNumberNode.Create(2)));
      E1 := TBinaryNode.Create('/', TNumberNode.Create(1), E1);
    end
    else if L = 'sinh' then
    begin
      E1 := TFuncNode.Create('cosh');
      TFuncNode(E1).AddArg(U.Clone());
    end
    else if L = 'cosh' then
    begin
      E1 := TFuncNode.Create('sinh');
      TFuncNode(E1).AddArg(U.Clone());
    end
    else if L = 'tanh' then
    begin
      N1 := TFuncNode.Create('tanh');
      TFuncNode(N1).AddArg(U.Clone());
      E1 := TBinaryNode.Create('-', TNumberNode.Create(1),
        TBinaryNode.Create('^', N1, TNumberNode.Create(2)));
    end
    else if (L = 'abs') or (L = 'floor') or (L = 'ceil') or (L = 'round') then
    begin
      Err := ceUnsupported; // non-smooth: no symbolic derivative
      Du.Free;
      Exit(nil);
    end
    else
    begin
      Err := ceUnknownFunction;
      Du.Free;
      Exit(nil);
    end;
    // chain rule: outer'(u) * u'
    Result := TBinaryNode.Create('*', E1, Du);
    Exit;
  end;
  Err := ceUnsupported; // assignments and definitions
end;

function Differentiate(Node: TASTNode; const VarName: string;
  Ctx: TEvalContext; out Err: TCalcError): TASTNode;
var
  Raw: TASTNode;
begin
  Raw := DRaw(Node, VarName, Err);
  if Err <> ceNone then
  begin
    Raw.Free;
    Result := nil;
    Exit;
  end;
  Result := Simplify(Raw, Ctx);
  Raw.Free;
end;

end.
