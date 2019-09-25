import lexer
import types
import parser
import ast


var  lex = newLexer(source="let a: int = 12\n")
var source = lex.tkSource.head

let node = program(source)
# discard eval(node)


echo $node

# while not source.isNil:
#   echo source.value.kind, " -> ", source.value.text.repr, " <- "
#   if source.value.kind == TkNewLine:
#     echo "newline -> ", source.value.text == "\n" 
#   source = source.next