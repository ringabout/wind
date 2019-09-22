import lists
import strutils
import types
import lexer


proc program*(cur: var SinglyLinkedNode[Token]): Node 
proc statement*(cur: var SinglyLinkedNode[Token]): Node
proc expression*(cur: var SinglyLinkedNode[Token]): Node
proc equal*(cur: var SinglyLinkedNode[Token]): Node
proc relational*(cur: var SinglyLinkedNode[Token]): Node
proc add*(cur: var SinglyLinkedNode[Token]): Node
proc mul*(cur: var SinglyLinkedNode[Token]): Node
proc unary*(cur: var SinglyLinkedNode[Token]): Node
proc primary*(cur: var SinglyLinkedNode[Token]): Node




proc consume(cur: var SinglyLinkedNode[Token], given: TokenKind): bool = 
  let token = cur.value
  if token.kind == TkError:
    raise newException(ValueError, "TKError")
  elif token.kind != given:
    false
  else:
    cur = cur.next
    true


proc program*(cur: var SinglyLinkedNode[Token]): Node =
  let statement = cur.statement
  var ndContainer = @[statement] 
  while not cur.isNil:
    if cur.consume(TkNewLine):
      ndContainer.add(cur.statement)
  Node(kind: ProgramNode, code: ndContainer)



proc statement*(cur: var SinglyLinkedNode[Token]): Node = 
  let expression = cur.expression
  return Node(kind: LeafNode, value: expression)


proc expression*(cur: var SinglyLinkedNode[Token]): Node = 
  let assign = cur.equal
  if not cur.isNil:
    if cur.consume(TkAssign):
      return Node(kind: AssignNode, left: assign, right: cur.equal)
    else:
      return Node(kind: LeafNode, value: assign)
  return Node(kind: LeafNode, value: assign)


proc equal*(cur: var SinglyLinkedNode[Token]): Node = 
  let r1 = cur.relational
  if not cur.isNil:
    if cur.consume(TkEq):
      return Node(kind: EqNode, left: r1, right: cur.relational)
    elif cur.consume(TkNeq):
      return Node(kind: NeqNode, left: r1, right: cur.relational)
  return Node(kind: LeafNode, value: r1)
  


proc relational*(cur: var SinglyLinkedNode[Token]): Node =
  let a1 = cur.add
  if not cur.isNil:
    if cur.consume(TkLt):
      return Node(kind: LeNode, left: a1, right: cur.add)
    elif cur.consume(TkGt):
      return Node(kind: GtNode, left: a1, right: cur.add)
    elif cur.consume(TkLe):
      return Node(kind: LeNode, left: a1, right: cur.add)
    elif cur.consume(TkGe):
      return Node(kind: GeNode, left: a1, right: cur.add)
  return Node(kind: LeafNode, value: a1)

proc add*(cur: var SinglyLinkedNode[Token]): Node = 
  let t1 = cur.mul
  if not cur.isNil:
    if cur.consume(TKAdd):
      return Node(kind: AddNode, left: t1, right: cur.mul)
    elif cur.consume(TkMinus):
      return Node(kind: MinusNode, left: t1, right: cur.mul)

  return Node(kind: LeafNode, value: t1)
 
proc mul*(cur: var SinglyLinkedNode[Token]): Node = 
  let f1 = cur.unary
  if not cur.isNil:
    if cur.consume(TkMul):
      return Node(kind: MulNode, left: f1, right: cur.unary)
    elif cur.consume(TkDiv):
      return Node(kind: DivNode, left: f1, right: cur.unary)
  return Node(kind: LeafNode, value: f1)
 
proc unary*(cur: var SinglyLinkedNode[Token]): Node =
  if not cur.isNil:
    if cur.consume(TkAdd):
      return Node(kind: LeafNode, value: cur.primary)
    elif cur.consume(TkMinus):
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
  if cur.consume(TkLBrace):
    result = cur.expression
    doAssert cur.consume(TkRBrace)
  elif cur.consume(TkIndent):
    result = Node(kind: IndentNode, name: text)
  elif cur.consume(TkInt):
    result = Node(kind: IntNode, intVar: text.parseInt)
  elif cur.consume(TkFloat):
    result = Node(kind: FloatNode, floatVar: text.parseFloat)
  elif cur.consume(TkBool):
    result = Node(kind: BoolNode, boolVar: text.parseBool)
  elif cur.consume(TkString):
    result = Node(kind: StringNode, stringVar: text)
