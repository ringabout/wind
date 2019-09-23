import lexer
import types
import parser
import ast


var  lex = newLexer(source=" let age = 12\nvar name = 12 > 3\nage +10 *2\nname")
var source = lex.tkSource.head

let node = program(source)
discard eval(node)
# echo $node

# while not source.isNil:
#   echo source.value.kind, " -> ", source.value.text.repr, " <- "
#   if source.value.kind == TkNewLine:
#     echo "newline -> ", source.value.text == "\n" 
#   source = source.next