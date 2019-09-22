import parser
import strformat
import types


proc `$`*(root: Node): string = 
  case root.kind 
  of LeafNode:
    result &= $root.value
  of IndentNode:
    result &= root.name
  of IntNode:
    result &= $root.intVar
  of AssignNode:
    result &= fmt"Assign({$root.left}, {$root.right})"
  of ProgramNode:
    for r in root.code:
      result &= $r
  else:
    result &= root.repr
