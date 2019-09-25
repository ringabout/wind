import lists
import strutils
import types
import lexer

import tables


proc program*(cur: var SinglyLinkedNode[Token]): Node 
proc statement*(cur: var SinglyLinkedNode[Token]): Node
proc letExpr*(cur: var SinglyLinkedNode[Token]): Node
proc varExpr*(cur: var SinglyLinkedNode[Token]): Node
proc bodyExpr*(cur: var SinglyLinkedNode[Token]): Node
proc ifExpr*(cur: var SinglyLinkedNode[Token]): Node
proc forExpr*(cur: var SinglyLinkedNode[Token]): Node
proc whileExpr*(cur: var SinglyLinkedNode[Token]): Node
proc funcExpr*(cur: var SinglyLinkedNode[Token]): Node 
proc argExpr*(cur: var SinglyLinkedNode[Token]): Node
proc retExpr*(cur: var SinglyLinkedNode[Token]): Node
proc expression*(cur: var SinglyLinkedNode[Token]): Node
proc equal*(cur: var SinglyLinkedNode[Token]): Node
proc relational*(cur: var SinglyLinkedNode[Token]): Node
proc add*(cur: var SinglyLinkedNode[Token]): Node
proc mul*(cur: var SinglyLinkedNode[Token]): Node
proc unary*(cur: var SinglyLinkedNode[Token]): Node
proc primary*(cur: var SinglyLinkedNode[Token]): Node


var envs*: Table[string, Node] 


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
      if cur.eat(TkEof):
        break
      ndContainer.add(cur.statement)
  Node(kind: ProgramNode, code: ndContainer)

proc statement*(cur: var SinglyLinkedNode[Token]): Node = 
  if not cur.isNil:
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
    elif cur.consume(TkSymbol, "return"):
      result = cur.retExpr
    else:
      result = cur.expression
  
proc letExpr*(cur: var SinglyLinkedNode[Token]): Node =
  var 
    text, letName, letType: string
    node: Node
  if not cur.isNil:
    text = cur.value.text
    if cur.eat(TkIndent):
      letName = text
      if cur.eat(TkColon):
        letType = cur.value.text
        doAssert cur.eat(TkType)
      if cur.eat(TkAssign):
        node = Node(kind: LetNode, letName: letName, 
              letValue: cur.expression, letType: letType)
        envs[letName] = node.letValue
      else:
        node = Node(kind: LetNode, letName: letName, 
              letValue: Node(kind: NilNode), letType: letType)
        envs[letName] = Node(kind: NilNode)
      return node
    return Node(kind: ErrorNode)

proc varExpr*(cur: var SinglyLinkedNode[Token]): Node = 
  var
    text, varName, varType: string
    node: Node
  if not cur.isNil:
    text = cur.value.text
    if cur.eat(TkIndent):
      varName = text
      if cur.eat(TkColon):
        varType = cur.value.text
        doAssert cur.eat(TkType)
      if cur.eat(TkAssign):
        node = Node(kind: VarNode, varName: varName, 
              varValue: cur.expression, varType: varType)
        envs[varName] = node.varValue
      else:
        node = Node(kind: VarNode, varName: varName, 
              varValue: Node(kind: NilNode), varType: varType)
        envs[varName] = Node(kind: NilNode)
      return node
    return Node(kind: ErrorNode)

proc bodyExpr*(cur: var SinglyLinkedNode[Token]): Node = 
  discard cur.eat(TkNewLine)
  result = cur.statement
  discard cur.eat(TkNewLine)
  doAssert cur.eat(TkRBrace)

proc ifExpr*(cur: var SinglyLinkedNode[Token]): Node =  
  var 
    condPart: Node 
    ifPart: Node
    elifCond: seq[Node]
    elifPart: seq[Node] = @[]
    elsePart: Node = Node(kind: NilNode)
  if not cur.isNil:
    condPart = cur.expression
    doAssert cur.eat(TkLBrace)
    ifPart = cur.bodyExpr
    while not cur.isNil and cur.consume(TkSymbol, "elif"):
      elifCond.add(cur.expression)
      elifPart.add(cur.bodyExpr)
    if not cur.isNil and cur.consume(TkSymbol, "else"):
      doAssert cur.eat(TkLBrace)
      elsePart = cur.bodyExpr

  return Node(kind: IfNode, condPart: condPart, ifPart: ifPart, 
                elifPart: elifPart, elsePart: elsePart)
             
proc whileExpr*(cur: var SinglyLinkedNode[Token]): Node =
  var
    whilePart: Node
    bodyPart: Node
  if not cur.isNil:
    whilePart = cur.expression
    doAssert cur.eat(TkLBrace)
    bodyPart = cur.bodyExpr
  return Node(kind: WhileNode, whilePart: whilePart, bodyPart: bodyPart)
        
proc forExpr*(cur: var SinglyLinkedNode[Token]): Node =
  if not cur.isNil:
    if cur.eat(TkIndent):
      discard

proc funcExpr*(cur: var SinglyLinkedNode[Token]): Node =
  var
    procName: string
    argsPart: seq[Node]
    returnType: string
    returnNode: Node
  if not cur.isNil:
    procName = cur.value.text
    doAssert cur.eat(TkLParen)
    while not cur.isNil and not cur.eat(TkRParen):
      argsPart.add(cur.argExpr)
      # if not cur.isNil:
      #   doAssert cur.eat(TkColon)
      #   returnType = cur.value.text
      #   doAssert cur.eat(TkLBrace):
      #   # bodyPar = cur.bodyExpr

  
proc argExpr*(cur: var SinglyLinkedNode[Token]): Node = 
  var 
    argName: string
    argType: string
  argName = cur.value.text
  doAssert cur.eat(TkIndent)
  doAssert cur.eat(TkColon)
  argType = cur.value.text
  result = Node(kind: ArgNode, argName: argName, argType: argType)
  if cur.next.value.kind != TkRParen:
    doAssert cur.eat(TkComma)
  
proc retExpr*(cur: var SinglyLinkedNode[Token]): Node = 
  cur.expression

  

proc expression*(cur: var SinglyLinkedNode[Token]): Node = 
  var 
    leftValue = cur.equal
    rightValue : seq[Node]
  if not cur.isNil:
    while not cur.isNil and cur.eat(TkAssign):
      rightValue.add(cur.equal)  
    return Node(kind: AssignNode, leftValue: leftValue, rightValue: rightValue)

  return leftValue

proc equal*(cur: var SinglyLinkedNode[Token]): Node = 
  let r1 = cur.relational
  if not cur.isNil:
    if cur.eat(TkEq):
      return Node(kind: EqNode, left: r1, right: cur.relational)
    elif cur.eat(TkNeq):
      return Node(kind: NeqNode, left: r1, right: cur.relational)
  return r1
  
proc relational*(cur: var SinglyLinkedNode[Token]): Node =
  var a1 = cur.add
  if not cur.isNil:
    if cur.eat(TkLt):
      return Node(kind: LtNode, left: a1, right: cur.add)
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
      return cur.primary
    elif cur.eat(TkMinus):
      var primary = cur.primary
      case primary.kind:
        of FloatNode:
          primary.floatVar = 0 - primary.floatVar
        of IntNode:
          primary.intVar = 0 - primary.intVar
        else:
          return Node(kind: ErrorNode)
      return primary
  return cur.primary


proc primary*(cur: var SinglyLinkedNode[Token]): Node = 
  let text = cur.value.text
  if cur.eat(TkLBrace):
    result = cur.expression
    doAssert cur.eat(TkRBrace)
  elif cur.eat(TkIndent):
    result = Node(kind: IndentNode, identName: text)
  elif cur.eat(TkInt):
    result = Node(kind: IntNode, intVar: text.parseInt)
  elif cur.eat(TkFloat):
    result = Node(kind: FloatNode, floatVar: text.parseFloat)
  elif cur.eat(TkBool):
    result = Node(kind: BoolNode, boolVar: text.parseBool)
  elif cur.eat(TkString):
    result = Node(kind: StringNode, stringVar: text)