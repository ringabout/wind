import lists
import strutils
import types
import lexer

proc factor(cur: var SinglyLinkedNode[Token]): Node
proc term(cur: var SinglyLinkedNode[Token]): Node
proc expression*(cur: var SinglyLinkedNode[Token]): Node



proc consume(cur: var SinglyLinkedNode[Token], given: TokenKind): bool = 
  let token = cur.value
  if token.kind == TkError:
    raise newException(ValueError, "TKError")
  elif token.kind != given:
    false
  else:
    cur = cur.next
    true


proc expression*(cur: var SinglyLinkedNode[Token]): Node= 
  let t1 = cur.term

  while not cur.isNil:
    if cur.consume(TKAdd):
      return Node(kind: AddNode, left: t1, right: cur.term)
    elif cur.consume(TkMinus):
      return Node(kind: MinusNode, left: t1, right: cur.term)
    else:
      return t1
  return t1

  
proc term(cur: var SinglyLinkedNode[Token]): Node = 
  let f1 = cur.factor

  while not cur.isNil:
    if cur.consume(TkMul):
      return Node(kind: MulNode, left: f1, right: cur.factor)
    elif cur.consume(TkDiv):
      return Node(kind: DivNode, left: f1, right: cur.factor)
    else:
      return f1
  return f1
 

proc factor(cur: var SinglyLinkedNode[Token]): Node= 
  let text = cur.value.text
  if cur.consume(TkLparen):
    result = cur.expression
    doAssert cur.consume(TkRparen)
  elif cur.consume(TkInt):
    result = Node(kind: IntNode, intVar: text.parseInt)
  elif cur.consume(TkFloat):
    result = Node(kind: FloatNode, floatVar: text.parseFloat)
  elif cur.consume(TkBool):
    result = Node(kind: BoolNode, boolVar: text.parseBool)
  elif cur.consume(TkString):
    result = Node(kind: StringNode, stringVar: text)