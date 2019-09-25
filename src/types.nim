type 
  InterpretError* = Exception


  NodeKind* = enum
    ProgramNode, StmtNode, ExprNode AssignNode, EqualNode, RelationalNode,
    IntNode, FloatNode, BoolNode, StringNode, IndentNode, ArgNode
    AddNode, MulNode, MinusNode, DivNode,
    LtNode, GtNode, LeNode, GeNode,
    EqNode, NeqNode, 
    IfNode, WhileNode, ForNode, 
    LetNode, VarNode,
    ProcNode, ReturnNode,
    ErrorNode, NilNode


  Node* = ref object
    case kind*: NodeKind
    of ProgramNode: code*: seq[Node]
    of LetNode: 
      letName*: string
      letValue*: Node
      letType*: string
    of VarNode:
      varName*: string
      varValue*: Node
      varType*: string
    of AssignNode:
      leftValue*: Node
      rightValue*: seq[Node]
    of IndentNode: 
      identName*: string
    of ArgNode: 
      argName*: string
      argType*: string
    of IntNode: intVar*: int  
    of FloatNode: floatVar*: float
    of BoolNode: boolvar*: bool 
    of StringNode: stringVar*: string
    of IfNode: 
      condPart*: Node
      ifPart*: Node 
      elifPart*: seq[Node]
      elsePart*: Node
    of WhileNode:
      whilePart*: Node
      bodyPart*: Node
    of ProcNode:
      procName*: string
      argsPart*: seq[Node]
      returnType*: string
      returnPart*: Node
    of NilNode: discard
    of ErrorNode: discard
    else: left*, right*: Node


  TokenKind* = enum 
    TkAdd, TkMinus, TkMul, TkDiv, TkMod, TkColon, Tkcomma, TkAssign
    TkEq, TkNeq, TkSymbol, TkLt, TkGt, TkLe, TkGe
    TkComment, TkNewLine, TkEof
    TkIndent, TkInt, TkFloat, TkBool, TkString, TkType
    # { } ( ) [ ]
    TkLBrace, TkRBrace, TkLParen, TkRParen, TkLBracket, TkRBracket
    TkWhile, TkFor
    TkError

  TokenObj = ref object of RootObj
    kind*: TokenKind
    text*: string
  Token* = TokenObj


const
  chars: set[char] = {'a'..'z', 'A'..'Z', '_'}

  nums: set[char] = {'0'..'9'}

proc isLetter*(ch: char): bool = ch in chars
proc isDigit*(num: char): bool = num in nums