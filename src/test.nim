import lexer
import parser





var  lex = newLexer(source="let flag = 4 > 5")
var source = lex.tkSource.head
# let node = expression(source)
# echo node.left.repr, " ==> ", node.kind, " ==> ", node.right.repr

while not source.isNil:
  echo source.value.kind, " -> ", source.value.text.repr
  source = source.next