import lexer
import types
import parser
import ast


var lex = newLexer(source="let a: string = \"my name is xzs\"\n let b: int = 6")
var source = lex.tkSource.head

# let node = program(source)
# discard eval(node)


# echo $node

while not source.isNil:
  echo source.value.kind, " -> ", source.value.text.repr, " <- "
  if source.value.kind == TkNewLine:
    echo "newline -> ", source.value.text == "\n" 
  source = source.next