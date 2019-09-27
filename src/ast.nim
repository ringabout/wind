import parser
import strformat
import types
import tables


proc `$`*(root: Node): string


type
  Stack* = seq[Scope]
  Scope* = ref object
    scope*: Table[string, Node]
  Obj* = ref object of RootObj
    case tag*: Value
    of ObjInt: intVar: int
    of ObjFloat: floatVar: float
    of ObjBool: boolVar: bool
    of ObjString: stringVar: string




#直接执行
proc eval*(root: Node): Obj =
  var temp: Obj
  case root.kind
  of IndentNode:
    result = eval(envs[root.identName])
  of IntNode:
    result.tag = ObjInt
    result.intVar = root.intVar
  of GtNode:
    result.tag = ObjBool
    result.boolVar = eval(root.left).intVar > eval(root.right).intVar
  of LetNode:
    envs[root.letName] = root.letValue
  of VarNode:
    envs[root.varName] = root.varValue
  of AddNode:
    result.tag = ObjInt
    result.intVar = eval(root.left).intVar + eval(root.right).intVar
  of MulNode:
    result.tag = ObjInt
    result.intVar = eval(root.left).intVar * eval(root.right).intVar
  of ProgramNode:
    for r in root.code:
      temp = eval(r)
      if temp == nil:
        echo envs
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