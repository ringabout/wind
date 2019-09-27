import types
import tables


type
  Stack* = seq[Scope]
  Scope* = ref object of RootObj
    scope*: Table[string, Node]
    parent*: Scope
  GlobalScope* = ref object of Scope
  # BlockScope* = ref object of Scope
  # FuncScope* = ref object of Scope
  # ClassScope* = ref object of Scope

proc top*(s: Stack): Scope =
  if s.len != 0:
    s[s.len - 1]
  else:
    nil

proc `[]`*(s: Scope, name: string): Node =
  s.scope[name] 

proc `[]=`*(s: Scope, name: string, value: Node) =
  s.scope[name] = value 

proc contains*(s: Scope, name: string): bool =
  name in s.scope

proc push*(s: var Stack, frame: Scope) = 
  frame.parent = s.top
  s.add(frame)

proc pop*(s: var Stack) = 
  s.pop

proc getSymbol*(s: Stack, name: string): Node = 
  var t: Scope = s.top
  while name notin t and t.parent != nil:
    t = t.parent


proc setSymbol*(s: Stack, name: string, value: Node) = 
  var t = s.top
  t[name] = value
