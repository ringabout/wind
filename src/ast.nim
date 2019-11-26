import strformat
import types
import scope


proc `$`*(root: Node): string


type
  Obj* = ref object of RootObj
    case tag*: Value
    of ObjInt: intVar: int
    of ObjFloat: floatVar: float
    of ObjBool: boolVar: bool
    of ObjString: stringVar: string

var 
  envs: Scope

proc getUpper(res: Obj): Obj = 
  case res.tag:
  of ObjInt:  
    return Obj(tag: ObjFloat, floatVar: float(res.intVar))
  else: 
    return res


#直接执行
proc eval*(root: Node): Obj =
  var temp: Obj
  case root.kind
  of IndentNode:
    result = eval(envs[root.identName])
  of IntNode:
    result.tag = ObjInt
    result.intVar = root.intVar
  of FloatNode:
    result.tag = ObjFloat
    result.floatVar = root.floatVar
  of BoolNode:
    result.tag = ObjBool
    result.boolVar = root.boolVar
  of GtNode:
    result.tag = ObjBool
    result.boolVar = eval(root.left).intVar > eval(root.right).intVar
  of LtNode:
    result.tag = ObjBool
    result.boolVar = eval(root.left).intVar < eval(root.right).intVar
  of GeNode:
    result.tag = ObjBool
    result.boolVar = eval(root.left).intVar >= eval(root.right).intVar
  of LeNode:
    result.tag = ObjBool
    result.boolVar = eval(root.left).intVar <= eval(root.right).intVar
  of LetNode:
    doAssert root.letType == $(eval(root.letValue).tag)
    envs[root.letName] = root.letValue
  of VarNode:
    doAssert root.varType == $(eval(root.varValue).tag)
    envs[root.varName] = root.varValue
  of IfNode:
    if eval(root.condPart).boolVar:
      discard
    for cond in root.elifCond:
      discard
  of WhileNode:
    while eval(root.whilePart).boolVar:
      for code in root.bodyPart.blockPart:
        discard eval(code)
  of AddNode:
    result.tag = ObjInt
    result.intVar = eval(root.left).intVar + eval(root.right).intVar
  of MinusNode:
    result.tag = ObjInt
    result.intVar = eval(root.left).intVar - eval(root.right).intVar
  of MulNode:
    result.tag = ObjInt
    result.intVar = eval(root.left).intVar * eval(root.right).intVar
  of DivNode:
    result.tag = ObjInt
    result.intVar = eval(root.left).intVar div eval(root.right).intVar
  of ProgramNode:
    for r in root.code:
      temp = eval(r)
      if temp == nil:
        echo envs.repr
      else:
        echo temp.repr
  else:
    discard

proc `$`*(root: BlockStatement): string = 
  discard

proc `$`*(root: Node): string = 
  case root.kind 
  of IndentNode:
    result &= root.identName
  of IntNode:
    result &= $root.intVar
  of FloatNode:
    result &= $root.floatVar
  of BoolNode:
    result &= $root.boolVar
  of AssignNode:
    result &= fmt"{$root.left} = {$root.right})"
  of LetNode:
    result &= fmt"let {root.letName}: {root.letType} = {$root.letValue}"
  of VarNode:
    result &= fmt"var {root.varName}: {root.varType} = {root.varValue}"
  of NilNode:  
    result &= ""
  of IfNode:
    result &= fmt"if {root.condPart} " & "{" & fmt"{root.ifPart}" & "}" & 
          "\nelse {" & fmt"{root.elsePart}" & "}"
  of WhileNode:
    result &= fmt"while {root.whilePart}" & "{" & fmt"{root.bodyPart}" & "}"
  of ForNode:
    result &= fmt"for({root.startPart}; {root.forCond}; {root.forPart})" &
     "\n{" & fmt"{root.bodyPart}" & "}\n"
  of AddNode:
    result &= fmt"{root.left} + {root.right}"
  of MinusNode:
    result &= fmt"{root.left} - {root.right}"
  of MulNode:
    result &= fmt"{root.left} * {root.right}"
  of DivNode:
    result &= fmt"{root.left} / {root.right}"
  of LeNode:
    result &= fmt"{$root.left} <= {$root.right}"
  of GeNode:
    result &= fmt"{$root.left} >= {$root.right}"
  of LtNode:
    result &= fmt"{$root.left} < {$root.right}"
  of GtNode:
    result &= fmt"{$root.left} > {$root.right}"
  of EqNode:
    result &= fmt"{$root.left} == {$root.right}"
  of ProgramNode:
    for r in root.code:
      result &= $r
      result &= "\n"
  else:
    result &= root.repr