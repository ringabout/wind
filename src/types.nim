type 
  InterpretError* = Exception


  NodeKind* = enum
    IntNode, FloatNode, BoolNode, StringNode, IndentNode,
    AddNode, MulNode, MinusNode, DivNode,
    LtNode, GtNode, LeNode, GeNode,
    EqNode, NeNode, IfNode


  Node* = ref object
    case kind*: NodeKind
    of IntNode: intVar*: int  
    of FloatNode: floatVar*: float
    of BoolNode: boolvar*: bool 
    of StringNode: stringVar*: string
    of IfNode: condition*, thenPart*, elsePart*: Node 
    else: left*, right*: Node


  TokenKind* = enum 
    TkAdd, TkMinus, TkMul, TkDiv
    TkEq, TkNeq, TkSymbol
    TkIndent, TkInt, TkFloat, TkBool, TkString
    TkLparen, TkRparen
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