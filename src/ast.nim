import parser
import strformat
import types


proc `$`*(root: Node): string = 
  case root.kind 
  of IndentNode:
    result &= root.name
  of IntNode:
    result &= $root.intVar
  of AssignNode:
    result &= fmt"{$root.left} = {$root.right})"
  of LetNode:
    result &= fmt"let {root.letName} = {$root.letValue}"
  of VarNode:
    result &= fmt"var {root.varName} = {root.varValue}"
  of LeNode:
    result &= fmt"{$root.left} <= {$root.right}"
  of GeNode:
    result &= fmt"{$root.left} >= {$root.right}"
  of LtNode:
    result &= fmt"{$root.left} < {$root.right}"
  of GtNode:
    result &= fmt"{$root.left} > {$root.right}"
  of ProgramNode:
    for r in root.code:
      result &= $r
      result &= "\n"
  else:
    result &= root.repr
