import lexer
import types
import parser
import ast


var  lex = newLexer(source="if name == 12{let age:" &
                  "int = 10}else{let age:int = 10}\n # qhuwderfvcj76325\n")
var source = lex.tkSource.head

let node = program(source)
# discard eval(node)


echo $node

# while not source.isNil:
#   echo source.value.kind, " -> ", source.value.text.repr, " <- "
#   if source.value.kind == TkNewLine:
#     echo "newline -> ", source.value.text == "\n" 
#   source = source.next