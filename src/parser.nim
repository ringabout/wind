import lists
import strutils
import types
import lexer


proc program*(cur: var SinglyLinkedNode[Token]): Node 
proc statement*(cur: var SinglyLinkedNode[Token]): Node
proc letExpr*(cur: var SinglyLinkedNode[Token]): Node
proc varExpr*(cur: var SinglyLinkedNode[Token]): Node
proc ifExpr*(cur: var SinglyLinkedNode[Token]): Node
proc forExpr*(cur: var SinglyLinkedNode[Token]): Node
proc whileExpr*(cur: var SinglyLinkedNode[Token]): Node
proc funcExpr*(cur: var SinglyLinkedNode[Token]): Node
proc expression*(cur: var SinglyLinkedNode[Token]): Node
proc equal*(cur: var SinglyLinkedNode[Token]): Node
proc relational*(cur: var SinglyLinkedNode[Token]): Node
proc add*(cur: var SinglyLinkedNode[Token]): Node
proc mul*(cur: var SinglyLinkedNode[Token]): Node
proc unary*(cur: var SinglyLinkedNode[Token]): Node
proc primary*(cur: var SinglyLinkedNode[Token]): Node




proc eat(cur: var SinglyLinkedNode[Token], given: TokenKind): bool = 
  let token = cur.value
  if token.kind == TkError:
    raise newException(ValueError, "TKError")
  elif token.kind != given:
    false
  else:
    cur = cur.next
    true

proc consume*(cur: var SinglyLinkedNode[Token], 
                  given: TokenKind, name: string): bool =
  let token = cur.value
  if token.kind == TkError:
    raise newException(ValueError, "TKError")
  elif token.kind != given or token.text != name:
    false
  else:
    cur = cur.next
    true

proc program*(cur: var SinglyLinkedNode[Token]): Node =
  let statement = cur.statement
  var ndContainer = @[statement] 
  while not cur.isNil:
    if cur.eat(TkNewLine):
      ndContainer.add(cur.statement)
  Node(kind: ProgramNode, code: ndContainer)



proc statement*(cur: var SinglyLinkedNode[Token]): Node = 

  if cur.consume(TkSymbol, "let"):
    result = cur.letExpr
  elif cur.consume(TkSymbol, "var"):
    result = cur.varExpr
  elif cur.consume(TkSymbol, "if"):
    result = cur.ifExpr
  elif cur.consume(TkSymbol, "while"):
    result = cur.whileExpr
  elif cur.consume(TkSymbol, "for"):
    result = cur.forExpr
  elif cur.consume(TkSymbol, "proc"):
    result = cur.funcExpr
  else:
    result = cur.expression
  



proc letExpr*(cur: var SinglyLinkedNode[Token]): Node =
  discard

proc varExpr*(cur: var SinglyLinkedNode[Token]): Node = 
  discard

proc ifExpr*(cur: var SinglyLinkedNode[Token]): Node =  
  discard

proc whileExpr*(cur: var SinglyLinkedNode[Token]): Node =
  discard

proc forExpr*(cur: var SinglyLinkedNode[Token]): Node =
  discard

proc funcExpr*(cur: var SinglyLinkedNode[Token]): Node =
  discard

proc expression*(cur: var SinglyLinkedNode[Token]): Node = 
  var assign = cur.equal
  if not cur.isNil:
    if cur.eat(TkAssign):
      return Node(kind: AssignNode, left: assign, right: cur.equal)
    else:
      return Node(kind: LeafNode, value: assign)
  return Node(kind: LeafNode, value: assign)


proc equal*(cur: var SinglyLinkedNode[Token]): Node = 
  let r1 = cur.relational
  if not cur.isNil:
    if cur.eat(TkEq):
      return Node(kind: EqNode, left: r1, right: cur.relational)
    elif cur.eat(TkNeq):
      return Node(kind: NeqNode, left: r1, right: cur.relational)
  return Node(kind: LeafNode, value: r1)
  


proc relational*(cur: var SinglyLinkedNode[Token]): Node =
  var a1 = cur.add
  if not cur.isNil:
    if cur.eat(TkLt):
      return Node(kind: LeNode, left: a1, right: cur.add)
    elif cur.eat(TkGt):
      return Node(kind: GtNode, left: a1, right: cur.add)
    elif cur.eat(TkLe):
      return Node(kind: LeNode, left: a1, right: cur.add)
    elif cur.eat(TkGe):
      return Node(kind: GeNode, left: a1, right: cur.add)
  return a1

proc add*(cur: var SinglyLinkedNode[Token]): Node = 
  var t1 = cur.mul
  while not cur.isNil:
    if cur.eat(TKAdd):
      t1 = Node(kind: AddNode, left: t1, right: cur.mul)
    elif cur.eat(TkMinus):
      t1 = Node(kind: MinusNode, left: t1, right: cur.mul)
    else:
      break
  return t1
 
proc mul*(cur: var SinglyLinkedNode[Token]): Node = 
  var f1 = cur.unary
  while not cur.isNil:
    if cur.eat(TkMul):
      f1 = Node(kind: MulNode, left: f1, right: cur.unary)
    elif cur.eat(TkDiv):
      f1 = Node(kind: DivNode, left: f1, right: cur.unary)
    else:
      break
  return f1
 
proc unary*(cur: var SinglyLinkedNode[Token]): Node =
  if not cur.isNil:
    if cur.eat(TkAdd):
      return Node(kind: LeafNode, value: cur.primary)
    elif cur.eat(TkMinus):
      var primary = cur.primary
      case primary.kind:
        of FloatNode:
          primary.floatVar = 0 - primary.floatVar
        of IntNode:
          primary.intVar = 0 - primary.intVar
        else:
          return Node(kind: ErrorNode)
      return Node(kind: LeafNode, value: primary)
  return Node(kind: LeafNode, value: cur.primary)


proc primary*(cur: var SinglyLinkedNode[Token]): Node = 
  let text = cur.value.text
  if cur.eat(TkLBrace):
    result = cur.expression
    doAssert cur.eat(TkRBrace)
  elif cur.eat(TkIndent):
    result = Node(kind: IndentNode, name: text)
  elif cur.eat(TkInt):
    result = Node(kind: IntNode, intVar: text.parseInt)
  elif cur.eat(TkFloat):
    result = Node(kind: FloatNode, floatVar: text.parseFloat)
  elif cur.eat(TkBool):
    result = Node(kind: BoolNode, boolVar: text.parseBool)
  elif cur.eat(TkString):
    result = Node(kind: StringNode, stringVar: text)
