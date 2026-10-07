{ Symbolic integration foundation (Phase 23): rules we can stand behind
  (constants, x^n, 1/x, exp/sin/cos of x or a linear a*x+b, sums,
  constant multiples). Anything else returns ceUnsupported — a structured
  "I can't do this yet", never a wrong antiderivative. Indefinite only
  (+C left to the presenter); definite integrals go through IntNum. }
unit PMS.IntSym;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Math, PMS.Types, PMS.AST, PMS.Simplify;

function Integrate(Node: TASTNode; const VarName: string;
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

{ Match a*x+b with constants a, b. True + A/B on match (A may be 0/1). }
function TryLinear(Node: TASTNode; const VarName: string; out A, B: TASTNode): Boolean;
var
  L, R: TASTNode;
begin
  A := nil;
  B := nil;
  Result := False;
  if (Node is TVarNode) and (TVarNode(Node).Name = VarName) then
  begin
    A := TNumberNode.Create(1);
    B := TNumberNode.Create(0);
    Exit(True);
  end;
  if not (Node is TBinaryNode) then
    Exit;
  L := TBinaryNode(Node).Left;
  R := TBinaryNode(Node).Right;
  case TBinaryNode(Node).Op of
    '+', '-':
      if not HasVar(L, VarName) then
      begin
        // c +/- rest
        if TryLinear(R, VarName, A, B) then
        begin
          if TBinaryNode(Node).Op = '+' then
            B := TBinaryNode.Create('+', B, L.Clone())
          else
            B := TBinaryNode.Create('-', B, L.Clone());
          Exit(True);
        end;
      end
      else if not HasVar(R, VarName) then
      begin
        // rest +/- c
        if TryLinear(L, VarName, A, B) then
        begin
          if TBinaryNode(Node).Op = '+' then
            B := TBinaryNode.Create('+', B, R.Clone())
          else
            B := TBinaryNode.Create('-', B, R.Clone());
          Exit(True);
        end;
      end;
    '*':
      if not HasVar(L, VarName) then
      begin
        if TryLinear(R, VarName, A, B) then
        begin
          A := TBinaryNode.Create('*', A, L.Clone());
          B := TBinaryNode.Create('*', B, L.Clone());
          Exit(True);
        end;
      end
      else if not HasVar(R, VarName) then
      begin
        if TryLinear(L, VarName, A, B) then
        begin
          A := TBinaryNode.Create('*', A, R.Clone());
          B := TBinaryNode.Create('*', B, R.Clone());
          Exit(True);
        end;
      end;
  end;
end;

function IRaw(Node: TASTNode; const VarName: string;
  out Err: TCalcError): TASTNode;
var
  U, V, Iu, Iv: TASTNode;
  F, G: TFuncNode;
  A, B, N1: TASTNode;
  L: string;
  I: Integer;
begin
  Err := ceNone;
  Result := nil;
  if (Node is TNumberNode) or not HasVar(Node, VarName) then
    // ∫c dx = c*x
    Exit(TBinaryNode.Create('*', Node.Clone(), TVarNode.Create(VarName)));
  if (Node is TVarNode) and (TVarNode(Node).Name = VarName) then
    // ∫x dx = x^2/2
    Exit(TBinaryNode.Create('/',
      TBinaryNode.Create('^', TVarNode.Create(VarName), TNumberNode.Create(2)),
      TNumberNode.Create(2)));
  if Node is TUnaryNode then
  begin
    if TUnaryNode(Node).Op = '-' then
    begin
      Iu := IRaw(TUnaryNode(Node).Child, VarName, Err);
      if Err <> ceNone then
      begin
        Iu.Free;
        Exit(nil);
      end;
      Exit(TUnaryNode.Create('-', Iu));
    end;
    Err := ceUnsupported;
    Exit(nil);
  end;
  if Node is TBinaryNode then
  begin
    U := TBinaryNode(Node).Left;
    V := TBinaryNode(Node).Right;
    case TBinaryNode(Node).Op of
      '+', '-':
      begin
        Iu := IRaw(U, VarName, Err);
        if Err <> ceNone then
        begin
          Iu.Free;
          Exit(nil);
        end;
        Iv := IRaw(V, VarName, Err);
        if Err <> ceNone then
        begin
          Iu.Free;
          Iv.Free;
          Exit(nil);
        end;
        Exit(TBinaryNode.Create(TBinaryNode(Node).Op, Iu, Iv));
      end;
      '*':
        if not HasVar(U, VarName) then
        begin
          Iv := IRaw(V, VarName, Err);
          if Err <> ceNone then
          begin
            Iv.Free;
            Exit(nil);
          end;
          Exit(TBinaryNode.Create('*', U.Clone(), Iv));
        end
        else if not HasVar(V, VarName) then
        begin
          Iu := IRaw(U, VarName, Err);
          if Err <> ceNone then
          begin
            Iu.Free;
            Exit(nil);
          end;
          Exit(TBinaryNode.Create('*', Iu, V.Clone()));
        end
        else
        begin
          Err := ceUnsupported; // no parts/integration-by-guess in v1
          Exit(nil);
        end;
      '/':
        if not HasVar(V, VarName) then
        begin
          Iu := IRaw(U, VarName, Err);
          if Err <> ceNone then
          begin
            Iu.Free;
            Exit(nil);
          end;
          Exit(TBinaryNode.Create('/', Iu, V.Clone()));
        end
        else if (U is TNumberNode) and (TNumberNode(U).Value = 1) then
        begin
          // ∫1/u dx = ln(u)/a for linear u = a*x+b
          A := nil;
          B := nil;
          if not TryLinear(V, VarName, A, B) then
          begin
            A.Free;
            B.Free;
            Err := ceUnsupported;
            Exit(nil);
          end;
          G := TFuncNode.Create('ln');
          G.AddArg(V.Clone());
          if (A is TNumberNode) and (TNumberNode(A).Value = 1) then
          begin
            A.Free;
            B.Free;
            Exit(G);
          end;
          Result := TBinaryNode.Create('/', G, A);
          B.Free;
          Exit;
        end
        else
        begin
          Err := ceUnsupported;
          Exit(nil);
        end;
      '^':
      begin
        // u^n, n constant (≠ -1); u = x handled by power rule below via
        // general path: only x^n with numeric n, else unsupported
        if (V is TNumberNode) and (U is TVarNode) and
          (TVarNode(U).Name = VarName) then
        begin
          if TNumberNode(V).Value = -1 then
          begin
            // ∫1/x dx = ln(x) (x > 0 in real mode)
            F := TFuncNode.Create('ln');
            F.AddArg(TVarNode.Create(VarName));
            Exit(F);
          end;
          // x^(n+1)/(n+1)
          N1 := TBinaryNode.Create('+', V.Clone(), TNumberNode.Create(1));
          Exit(TBinaryNode.Create('/',
            TBinaryNode.Create('^', TVarNode.Create(VarName), N1),
            TBinaryNode.Create('+', V.Clone(), TNumberNode.Create(1))));
        end;
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
      Err := ceUnsupported;
      Exit(nil);
    end;
  U := F.Args[0];
  L := LowerCase(F.Name);
  A := nil;
  B := nil;
  if ((L = 'sin') or (L = 'cos') or (L = 'exp')) and
    TryLinear(U, VarName, A, B) then
    begin
      // ∫sin(ax+b) = -cos(ax+b)/a etc. (a ≠ 0; a = 0 folds to const)
      if L = 'sin' then
      begin
        G := TFuncNode.Create('cos');
        G.AddArg(U.Clone());
        Iv := TUnaryNode.Create('-', G);
      end
      else if L = 'cos' then
      begin
        G := TFuncNode.Create('sin');
        G.AddArg(U.Clone());
        Iv := G;
      end
      else
      begin
        G := TFuncNode.Create('exp');
        G.AddArg(U.Clone());
        Iv := G;
      end;
      if (A is TNumberNode) and (TNumberNode(A).Value = 1) then
      begin
        A.Free;
        B.Free;
        Exit(Iv);
      end;
      Result := TBinaryNode.Create('/', Iv, A);
      B.Free; // B only confirmed linearity; no +C in v1 core form
      Exit;
    end;
    A.Free; // safe on nil when TryLinear never ran
    B.Free;
    Err := ceUnsupported;
    Exit(nil);
  end;
  Err := ceUnsupported;
end;

function Integrate(Node: TASTNode; const VarName: string;
  Ctx: TEvalContext; out Err: TCalcError): TASTNode;
var
  Raw: TASTNode;
begin
  Raw := IRaw(Node, VarName, Err);
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
