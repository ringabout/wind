import types
import tables
import sets
import lists


type
  Lexer* = ref object
    source*: string
    token*: SinglyLinkedList[Token]
    #col* ==> 改成扫描式的
    start*: int
    current*: int

    # keywords = (
    #     'BREAK', 'DO', 'INSTANCEOF', 'TYPEOF', 'ELSE',
    #     'NEW', 'VAR', 'RETURN', 'VOID', 'CONTINUE', 'WHILE',
    #     'FUNCTION', 'THIS', 'IF', 'DELETE', 'IN', 'DEBUGGER')

const 
  keywords = ["break", "case", "catch", "continue", "default", "delete",
              "do", "else", "finally", "for", "function", "if", "in",
              "in", "instanceof", "new", "return", "switch", "this",
              "throw", "try", "typeof", "var", "void", "while", "with"
            ].toHashSet
  # keywords = ["min", "max", "const", "let", "var", "proc", "return", 
  #             "type", "mod", "div", "for", "in", "assert", "doAssert",
  #             "break", "continue", "object","if", "else", 
  #             "while", "echo"].toHashSet
  charOperators*: set[char] = {'+', '-', '*', '/', '%', 
                            '{', '}', '(', ')','[', ']', 
                              ':', ',', ';',
                              '\n'}
  charToken*: Table[char, TokenKind] = {'+': TkAdd, '-': TkMinus, 
                  '*': TkMul, '/': TkDiv, '%': TkMod, 
                  '{': TkLBrace, '}': TkRBrace, '(': TkLParen, ')': TkRParen,
                  '[': TkLBracket, ']': TkRBracket, ':': TkColon, ',': TkComma, 
                  '<': TkLt, '>': TkGt, '#': TkComment, ';': TkSemi,
                  '\n': TkNewLine}.toTable
  typewords* = ["int", "float", "bool", "string"].toHashSet

proc append*(lex: var Lexer, tk: Token) = 
  lex.token.append(tk)


proc pickToken*(lex: var Lexer): string = 
  lex.source[lex.start .. lex.current]


proc addToken(lex: var Lexer, kind: TokenKind): Token =
  Token(kind: kind, text: lex.source[lex.start .. lex.current])

proc newLexer*(source: string): Lexer = 
  Lexer(source: source, start: 0, current: 0)

proc atEOF(lex: var Lexer): bool =
  lex.source.len <= lex.current

proc next(lex: var Lexer) =
  if not lex.atEOF:
    lex.current += 1

proc advance(lex: var Lexer): char = 
  lex.next()
  lex.source[lex.current-1]

proc peek(lex: var Lexer): char =
  if lex.atEOF: 
    return '\0'
  return lex.source[lex.current]

proc peekNext(lex: var Lexer): char =
  if lex.source.len <= lex.current + 1:
    return '\0'
  return lex.source[lex.current+1]

proc move(lex: var Lexer) = 
  if not lex.atEOF:
    lex.start = lex.current + 1

proc tkNum(lex: var Lexer): Token = 
  while isDigit(lex.peek):
    if not lex.atEOf:
      lex.next()
    if lex.peek == '.':
      lex.next()
      while isDigit(lex.peek):
        lex.next()

      lex.current -= 1
      result = lex.addToken(TkFloat)
      lex.current += 1
  

  lex.current -= 1
  result = lex.addToken(TkInt)


proc tkIndent(lex: var Lexer): Token = 
  if isLetter(lex.peek):
    lex.next()
  while isLetter(lex.peek) or isDigit(lex.peek):
    lex.next()

  lex.current -= 1
  if lex.pickToken in keywords:
    lex.addToken(TkSymbol)
  elif lex.pickToken in typewords:
    lex.addToken(TkType)
  else:
    lex.addToken(TkIndent)


proc tkSource*(lex: var Lexer): SinglyLinkedList[Token] = 
  while not lex.atEOF: 
    # echo lex.start, " -> ", lex.current, " -> ", lex.peek
    # 抽空改成哈希表
    let value = lex.peek
    case value
    of 'a' .. 'z', 'A' .. 'Z': 
      lex.append(lex.tkIndent)
      lex.move()
    of '0' .. '9':
      lex.append(lex.tkNum)
      lex.move()
    of charOperators:
      lex.append(lex.addToken(charToken[value]))
      lex.move()
    of '!':
      doAssert lex.peekNext == '='
      lex.next()
      lex.append(lex.addToken(TkNeq))
      lex.move()
    of '=':
      if lex.peekNext == '=':
        lex.next()
        lex.append(lex.addToken(TkEq))
        lex.move()
      else:
        lex.append(lex.addToken(TkAssign))
        lex.move()
    of '<': 
      if lex.peekNext == '=':
        lex.next()
        lex.append(lex.addToken(TkLe))
        lex.move()
      else:
        lex.append(lex.addToken(TkLt))
        lex.move()    
    of '#': 
      while lex.peek != '\n':
        lex.next()
      lex.next()
      lex.move()
    of '"':
      while lex.peekNext != '"':
        lex.next()
      lex.next()
      lex.append(lex.addToken(TkString))
      lex.move()
    of '>': 
      if lex.peekNext == '=':
        lex.next()
        lex.append(lex.addToken(TkGe))
        lex.move()
      else:
        lex.append(lex.addToken(TkGt))
        lex.move()     
    else:
      lex.start += 1
    lex.next()
  lex.append(Token(kind: TkEof, text: "nil"))
    # echo lex.start, " -> ", lex.current, "->", lex.source.len
  lex.token 