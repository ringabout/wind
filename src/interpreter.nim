import lexer
import types
import parser
import ast


proc repl() = 
  while true:
    try:
      stdout.write(">>> ")
      stdout.flushFile()
      var input = stdin.readLine()
      var lex = newLexer(input)
      var source = lex.tkSource.head
      let node = program(source)
      discard eval(node)
    except EOFError:
      raise
    except Exception:
      discard

when isMainModule:
  repl()