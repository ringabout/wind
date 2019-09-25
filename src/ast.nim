import parser
import strformat
import types
import tables


proc `$`*(root: Node): string



# 直接执行
proc eval*(root: Node): Value =
  var
    tempBool: Value
    tempInt: Value
    tempStr: Value
  case root.kind
  of IndentNode:
    result = eval(envs[root.identName])
  of IntNode:
    result = root.intVar
  of GtNode:
    tempBool = eval(root.left) > eval(root.right)
    result = tempBool
  of LetNode:
    envs[root.letName] = root.letValue
  of VarNode:
    envs[root.varName] = root.varValue
  of AddNode:
    tempInt = eval(root.left) + eval(root.right)
    result = tempInt
  of MulNode:
    tempInt = eval(root.left) * eval(root.right)
    result = tempInt
  of ProgramNode:
    for r in root.code:
      tempStr = eval(r)
      if tempStr == "":
        echo envs
      else:
        echo tempStr
  else:
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