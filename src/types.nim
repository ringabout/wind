type 
  InterpretError* = Exception


  NodeKind* = enum
    ProgramNode, StmtNode, ExprNode AssignNode, EqualNode, RelationalNode,
    IntNode, FloatNode, BoolNode, StringNode, IndentNode, LeafNode
    AddNode, MulNode, MinusNode, DivNode,
    LtNode, GtNode, LeNode, GeNode,
    EqNode, NeqNode, 
    IfNode, WhileNode, ForNode, 
    LetNode, VarNode,
    ProcNode, ReturnNode,
    ErrorNode


  Node* = ref object
    case kind*: NodeKind
    of ProgramNode: code*: seq[Node]
    of LeafNode: value*: Node
    of LetNode: 
      letName*: string
      letValue*: Node
    of VarNode:
      varName*: string
      varValue*: Node
    of IndentNode: name*: string
    of IntNode: intVar*: int  
    of FloatNode: floatVar*: float
    of BoolNode: boolvar*: bool 
    of StringNode: stringVar*: string
    of IfNode: condition*, thenPart*, elsePart*: Node 
    of ErrorNode: discard
    else: left*, right*: Node


  TokenKind* = enum 
    TkAdd, TkMinus, TkMul, TkDiv, TkMod, TkColon, Tkcomma, TkAssign
    TkEq, TkNeq, TkSymbol, TkLt, TkGt, TkLe, TkGe
    TkComment, TkNewLine
    TkIndent, TkInt, TkFloat, TkBool, TkString
    # { } ( ) [ ]
    TkLBrace, TkRBrace, TkLParen, TkRParen, TkLBracket, TkRBracket
    TkIf, TkWhile, TkFor
    TkEOL, TkError

  TokenObj = ref object of RootObj
    kind*: TokenKind
    text*: string
  Token* = TokenObj


const
  chars: set[char] = {'a'..'z', 'A'..'Z', '_'}

  nums: set[char] = {'0'..'9'}

proc isLetter*(ch: char): bool = ch in chars
proc isDigit*(num: char): bool = num in nums
