import types
import tables


type
  Stack* = seq[Scope]
  Scope* = ref object
    scope*: Table[string, Node]

proc top*(s: Stack): Scope =
  s[s.len - 1]

proc `[]`*(s: Scope, name: string): Node =
  s.scope[name] 

proc `[]=`*(s: Scope, name: string, value: Node) =
  s.scope[name] = value 

proc contains*(s: Scope, name: string): bool =
  name in s.scope

proc push*(s: var Stack, frame: Scope) = 
  s.add(frame)

proc pop*(s: var Stack) = 
  s.pop

proc getSymbol*(s: Stack, name: string): Node = 
  var t: Scope
  for i in countdown(s.len - 1, 0):
    t = s[i]
    if name in t:
      return t[name]

proc setSymbol*(s: Stack, name: string, value: Node) = 
  var t = s.top
  t[name] = value
