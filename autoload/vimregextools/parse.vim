unlet! s:indent_level s:capture_level s:bol_stack
" TODO: nr2char() for number representations.
command! -nargs=+ -count RE echo vimregextools#parse#match(<q-args>, <count>).value
" Remove all our functions {{{1
"let s:more = &more
"set nomore
"redir => s:func
"silent function
"redir END
"let &more = s:more
"for f in map(filter(split(s:func, '\n'), 'v:val =~# "vimregextools#parse"'), 'matchstr(v:val, "vimregextools#parse#\\k*")')
  ""echo f
  "exec "delfunc " . f
"endfor
"unlet f
function! vimregextools#parse#match(re, ...) "{{{1
  let s:debug = a:0 ? a:1 : 0
  " Case matching
  let s:ignore_case = 0
  " Ignore composing chars
  let s:ignore_composing = 0
  " Output indentation.
  let s:indent_level = 0
  let s:capture_level = 0
  let s:bol_stack = [0]
  let s:eol_level = 0
  call s:Debug('/' . escape(a:re, '/') . '/')
  let s:magic = matchstr(matchstr(a:re, '\C\m^\%(\\[vVmMZcC]\)*'), '\C\m\\[vVmM]')
  let s:magic = empty(s:magic) ? '\m' : s:magic
  let save_mfd = &maxfuncdepth
  set maxfuncdepth=1000
  "redir => g:log
  if empty(s:magic) || s:magic ==# '\m'
    let result = g:vimregextools#parser_magic#now.match(a:re)
  elseif s:magic ==# '\M'
    let result = g:vimregextools#parser_non_magic#now.match(a:re)
  elseif s:magic ==# '\v'
    let result = g:vimregextools#parser_very_magic#now.match(a:re)
  elseif s:magic ==# '\V'
    let result = g:vimregextools#parser_very_non_magic#now.match(a:re)
  endif
  let result.magic = s:magic
  let result.case = s:ignore_case
  let result.comp = s:ignore_composing
  "redir END
  let &maxfuncdepth = save_mfd
  let g:output = 1
  return result
endfunction "Parse

function! vimregextools#parse#walk(ast, visitor, ...) "{{{1
  return a:0 ? s:walk(a:ast, a:visitor, a:1) : s:walk(a:ast, a:visitor)
endfunction

function! s:walk(ast, visitor, ...) " {{{1
  return type(a:ast) != type({}) && type(a:ast) != type([]) ? a:ast
        \ : ( a:0 ? call(a:visitor, [a:ast], a:1) : call(a:visitor, [a:ast]) )
endfunction

function! s:fix_eol(ast) "{{{1
  let a = copy(a:ast)
  let map = 'type(v:val) == type("") && v:val == "\\_$"'
          \ . '? "\\$" : s:walk(v:val, "s:fix_eol")'
  if type(a) == type({})
    call map(a.v, map)
  else
    call map(a, map)
  endif
  return a
endfunction

function! s:ChLvl(sign) "{{{1
  let s:indent_level = a:sign == '+' ? 1 : -1
endfunction "s:ChLvl

function! s:IndentLvl(...) "{{{1
  return repeat(' ', s:indent_level * 2)
endfunction "s:IndentLvl

function! s:SID() "{{{1
  return matchstr(expand('<sfile>'), '<SNR>\d\+_\zeSID$')
endfun

function! s:Debug(msg, ...) "{{{1
  let level = a:0 ? a:1 : 1
  let chain = expand('<sfile>')
  let prefix = matchstr(chain, '^function\s\+\%(\k\+\..\)*\%(\k\+\)\?\zs\%(#\|s:\)\k\+\ze\.\.' . s:SID() . 'Debug$')
  let msg = string(a:msg)
  if exists('s:debug') && s:debug >= level
    echom '|' . prefix . '|' . msg
  endif
endfunction "s:Debug

function! s:error(errnum, msg) "{{{1
  throw 'VRET: E' . a:errnum . ': ' . a:msg
endfunction

"regexp() {{{1
function! vimregextools#parse#regexp(elems) abort
  " regexp ::= legal_flag ? pattern ? escape ? eore -> #regexp
  call s:Debug(a:elems, 2)
  let result = {'o': 're', 'v': []}
  if !empty(a:elems[0]) && !empty(a:elems[0][0])
    call extend(result.v, a:elems[0])
  endif
  if !empty(a:elems[1])
    if type(a:elems[1][0]) == type([]) && len(a:elems[1]) == 1
      call extend(result.v, a:elems[1][0])
    else
      call add(result.v, a:elems[1][0])
    endif
  endif
  if !empty(a:elems[2])
    call add(result.v, a:elems[2][0])
  endif
  call s:Debug(result)
  return result
endfunction "vimregextools#parser#regexp

"pattern() {{{1
function! vimregextools#parse#pattern(elems) abort
  " pattern ::= branch ( or branch ) * -> #pattern
  call s:Debug(a:elems, 2)
  if empty(a:elems[1])
    " Only one element.
    let result = a:elems[0]
  else
    let list = type(a:elems[0]) == type([]) && len(a:elems[0]) == 1
          \ ? a:elems[0] : [a:elems[0]]
    for i in a:elems[1]
      if type(i[1]) == type([]) && len(i[1]) == 1
        " A list with a single item.
        call extend(list, i[1])
      else
        call add(list, i[1])
      endif
    endfor
    let result = {'o': '\|', 'v': list}
  endif
  call s:Debug(result)
  return result
endfunction "vimregextools#parser#pattern

"or() {{{1
function! vimregextools#parse#or(elems) abort
  " or ::= '\\|' -> #or
  call s:ChLvl('-')
  let result = '\'.a:elems[1]
  call s:ChLvl('+')
  let s:bol_stack[-1] = get(s:bol_stack, -2, 0)
  call s:Debug(result . ' -> ' . string(s:bol_stack))
  return result
endfunction "vimregextools#parser#or

"branch() {{{1
function! vimregextools#parse#branch(elems) abort
  " branch ::= concat ( and concat ) * -> #branch
  "['a', []]
  "['a', [['|', 'b']]]
  "['a', [['|', 'b'], ['|', 'c']]]
  "['a', [['|', 'b'], ['|', 'c'], ['|', 'd']]]
  call s:Debug(a:elems, 2)
  call s:Debug(a:elems, 2)
  if empty(a:elems[1])
    "['a', []]
    let result = a:elems[0]
  else
    "'[^|]' ( '|' '[^|]' ) *
    "['a', [['|', 'b']]]
    "['a', [['|', 'b'], ['|', 'c']]]
    "['a', [['|', 'b'], ['|', 'c'], ['|', 'd']]]
    let list = a:elems[0]
    for i in a:elems[1]
      if type(i[1]) == type([]) && len(i[1]) == 1
        call extend(list, i[1])
      else
        call add(list, i[1])
      endif
    endfor
    let result = {'o': '\&', 'v': list}
  endif
  call s:Debug(result)
  return result
endfunction "vimregextools#parser#branch

"and() {{{1
function! vimregextools#parse#and(elems) abort
  " and ::= '\\&' -> #and
  call s:ChLvl('-')
  let result = '\'.a:elems[1]
  call s:ChLvl('+')
  let s:bol_stack[-1] = get(s:bol_stack, -2, 0)
  call s:Debug(result . ' -> ' . string(s:bol_stack))
  return result
endfunction "vimregextools#parser#and

"concat() {{{1
function! vimregextools#parse#concat(elems) abort
  " concat ::= piece + -> #concat
  call s:Debug(a:elems, 2)
  let result = []
  let elems = len(a:elems) == 1 && type(a:elems[0]) == type([]) ? a:elems[0] : a:elems
  for i in elems
    if len(i) == 1 && type(i) == type([])
      call extend(result, i)
    else
      call add(result, i)
    endif
    unlet i
  endfor
  if index(result, '\_$') != -1
    let s:maxfuncdepth = &mfd
    set mfd=10000
    call map(result, 's:walk(v:val, "s:fix_eol")')
    let &mfd = s:maxfuncdepth
  endif
  call s:Debug(result)
  return result
endfunction "vimregextools#parser#concat

"piece() {{{1
function! vimregextools#parse#piece(elems) abort
  " piece ::= atom multi ? flag * -> #piece
  call s:Debug(a:elems, 2)
  if empty(a:elems[1])
    " Just the atom.
    let mediator = type(a:elems[0]) == type([]) ? a:elems[0] : [a:elems[0]]
  elseif type(a:elems[1][0]) == type({})
    " Atom plus curly.
    let mediator = extend(a:elems[1][0], {'v':[a:elems[0]]})
  else
    " Atom plus other multi.
    let mediator = {'o': a:elems[1][0], 'v': [a:elems[0]]}
  endif
  " Add flags, if any.
  if !empty(a:elems[2]) && !empty(a:elems[2][0]) && type(mediator) == type({})
    let result = [mediator, a:elems[2]]
  elseif !empty(a:elems[2]) && !empty(a:elems[2][0])
    let result = extend(mediator, a:elems[2])
  else
    let result = mediator
  endif
  call s:Debug(result)
  return result
endfunction "vimregextools#parser#piece

"atom() {{{1
function! vimregextools#parse#atom(elems) abort
  " atom ::= flag * ( non_capture_group | capture_group | ordinary_atom )
  call s:Debug(a:elems, 2)
  if empty(a:elems[0])
    let result = a:elems[1]
  else
    let result = add(a:elems[0], a:elems[1])
  endif
  call s:Debug(result)
  return result
endfunction "vimregextools#parser#atom

"err1() {{{1
function! vimregextools#parse#err1(elems) abort
  " atom ::= flag * ( non_capture_group | capture_group | ordinary_atom )
  call s:Debug(a:elems, 2)
  let result = a:elems
  call s:Debug(result)
  call s:error(1, 'unmatched (')
  return result
endfunction "vimregextools#parser#err1

"err2() {{{1
function! vimregextools#parse#err2(elems) abort
  " atom ::= flag * ( non_capture_group | capture_group | ordinary_atom )
  call s:Debug(a:elems, 2)
  let result = a:elems
  call s:Debug(result)
  call s:error(2, 'unmatched )')
  return result
endfunction "vimregextools#parser#err2

"err3() {{{1
function! vimregextools#parse#err3(elems) abort
  " atom ::= flag * ( non_capture_group | capture_group | ordinary_atom )
  call s:Debug(a:elems, 2)
  let result = a:elems
  call s:Debug(result)
  if type(a:elems[0]) != type({})
    let s = a:elems[0]
  else
    let s = a:elems[0].o . '}'
  endif
  let s .= join(map(a:elems[1], 'type(v:val) == type({}) ? v:val.o . "}" : v:val'), '')
  call s:error(3, 'nested quantifiers: ' . s)
  return result
endfunction "vimregextools#parser#err3

"err4() {{{1
function! vimregextools#parse#err4(elems) abort
  " atom ::= flag * ( non_capture_group | capture_group | ordinary_atom )
  call s:Debug(a:elems, 2)
  let result = a:elems
  call s:Debug(result)
  call s:error(4, 'invalid character after @')
  return result
endfunction "vimregextools#parser#err4

"err5() {{{1
function! vimregextools#parse#err5(elems) abort
  " atom ::= flag * ( non_capture_group | capture_group | ordinary_atom )
  call s:Debug(a:elems, 2)
  let result = a:elems
  call s:Debug(result)
  call s:error(5, 'invalid character after %')
  return result
endfunction "vimregextools#parser#err5

"err6() {{{1
function! vimregextools#parse#err6(elems) abort
  " atom ::= flag * ( non_capture_group | capture_group | ordinary_atom )
  call s:Debug(a:elems, 2)
  let result = a:elems
  call s:Debug(result)
  call s:error(6, 'syntax error in {...}')
  return result
endfunction "vimregextools#parser#err6

"err7() {{{1
function! vimregextools#parse#err7(elems) abort
  " atom ::= flag * ( non_capture_group | capture_group | ordinary_atom )
  call s:Debug(a:elems, 2)
  let result = a:elems
  call s:Debug(result)
  call s:error(7, 'invalid use of \_')
  return result
endfunction "vimregextools#parser#err7

"err8() {{{1
function! vimregextools#parse#err8(elems) abort
  " atom ::= flag * ( non_capture_group | capture_group | ordinary_atom )
  call s:Debug(a:elems, 2)
  let result = a:elems
  call s:Debug(result)
  call s:error(8, 'missing ] after %[')
  return result
endfunction "vimregextools#parser#err8

"err9() {{{1
function! vimregextools#parse#err9(elems) abort
  " atom ::= flag * ( non_capture_group | capture_group | ordinary_atom )
  call s:Debug(a:elems, 2)
  let result = a:elems
  call s:Debug(result)
  call s:error(9, 'empty %[]')
  return result
endfunction "vimregextools#parser#err9

"err10() {{{1
function! vimregextools#parse#err10(elems) abort
  " atom ::= flag * ( non_capture_group | capture_group | ordinary_atom )
  call s:Debug(a:elems, 2)
  let result = a:elems
  call s:Debug(result)
  call s:error(10, 'invalid item in %[]')
  return result
endfunction "vimregextools#parser#err10

"err11() {{{1
function! vimregextools#parse#err11(elems) abort
  " atom ::= flag * ( non_capture_group | capture_group | ordinary_atom )
  call s:Debug(a:elems, 2)
  let result = a:elems
  call s:Debug(result)
  call s:error(11, 'invalid character after %[dxouU]')
  return result
endfunction "vimregextools#parser#err11

"flag() {{{1
function! vimregextools#parse#flag(elems) abort
  " flag    ::= case_flag | magic_flag | ignore_comb_chars -> #flag
  call s:Debug(a:elems, 2)
  if a:elems ==# '\C'
    let s:ignore_case = 0
    let result = []
  elseif a:elems ==# '\c'
    let s:ignore_case = 1
    let result = []
  elseif a:elems ==# '\Z'
    let s:ignore_composing = 1
    let result = []
  else
    let result = a:elems
  endif
  call s:Debug(result)
  return result
endfunction "vimregextools#parser#flag

"capture_group() {{{1
function! vimregextools#parse#capture_group(elems) abort
  " capture_group ::= open_capture_group pattern close_group -> #capture_group
  call s:Debug(a:elems, 2)
  "let result = {'o': a:elems[0], 'v': [get(get(a:elems, 1, []), 0, [])]}
  let result = {'o': a:elems[0]}
  if empty(a:elems[1])
        \ || (len(a:elems[1]) == 1 && type(a:elems[1][0]) == type([])
        \     && empty(a:elems[1][0]))
    let result.v = []
  else
    let result.v = type(a:elems[1][0]) == type([])
          \ ? a:elems[1][0] : [a:elems[1][0]]
  endif
  call s:Debug(result)
  return result
endfunction "vimregextools#parser#capture_group

"non_capture_group() {{{1
function! vimregextools#parse#non_capture_group(elems) abort
  " non_capture_group ::= open_non_capture_group pattern close_group -> #non_capture_group
  call s:Debug(a:elems, 2)
  "let result = {'o': a:elems[0], 'v': [get(get(a:elems, 1, []), 0, [])]}
  let result = {'o': a:elems[0]}
  if empty(a:elems[1])
        \ || (len(a:elems[1]) == 1 && type(a:elems[1][0]) == type([])
        \     && empty(a:elems[1][0]))
    let result.v = []
  else
    let result.v = type(a:elems[1][0]) == type([])
          \ ? a:elems[1][0] : [a:elems[1][0]]
  endif
  call s:Debug(result)
  return result
endfunction "vimregextools#parser#non_capture_group

"open_capture_group() {{{1
function! vimregextools#parse#open_capture_group(elems) abort
  " open_capture_group ::= '\\(' -> #open_capture_group
  let result = '\'.a:elems[1]
  call s:ChLvl('+')
  call add(s:bol_stack, get(s:bol_stack, -1, 0))
  let s:capture_level += 1
  if s:capture_level > 9
    call s:error(8, 'too many (')
  endif
  call s:Debug(string(result) . ' -> ' . string(s:bol_stack))
  return result
endfunction "vimregextools#parser#open_capture_group

"open_non_capture_group() {{{1
function! vimregextools#parse#open_non_capture_group(elems) abort
  " open_non_capture_group ::= '\\%(' -> #open_non_capture_group
  let result = '\'.a:elems[1]
  call s:ChLvl('+')
  call add(s:bol_stack, get(s:bol_stack, -1, 0))
  call s:Debug(string(result) . ' -> ' . string(s:bol_stack))
  return result
endfunction "vimregextools#parser#open_non_capture_group

"close_non_capture_group() {{{1
function! vimregextools#parse#close_non_capture_group(elems) abort
  " close_non_capture_group ::= '\\)' -> #close_non_capture_group
  call s:ChLvl('-')
  let result = a:elems
  call remove(s:bol_stack, -1)
  call s:Debug(string(result) . ' -> ' . string(s:bol_stack))
  return result
endfunction "vimregextools#parser#close_non_capture_group

"close_capture_group() {{{1
function! vimregextools#parse#close_capture_group(elems) abort
  " close_capture_group ::= '\\)' -> #close_group
  call s:ChLvl('-')
  let result = a:elems
  call remove(s:bol_stack, -1)
  let s:capture_level -= 1
  call s:Debug(string(result) . ' -> ' . string(s:bol_stack))
  return result
endfunction "vimregextools#parser#close_capture_group

"multi() {{{1
function! vimregextools#parse#multi(elems) abort
  " multi ::= quant_star | quant_plus | quant_equal | quant_question | curly | look_around -> #multi
  call s:Debug(a:elems)
  if type(a:elems) == type([])
    let result = (a:elems[1] =~ '[*]' ? '' : '\') . a:elems[1]
  else
    let result = a:elems
  endif
  call s:Debug(result)
  return result
endfunction "vimregextools#parser#multi

"curly() {{{1
function! vimregextools#parse#curly(elems) abort
  " curly ::= start_curly '-' ? lower ? ( ',' upper ? ) ? end_curly -> #curly
  call s:Debug(a:elems)
  let result = {'o': '\'.a:elems[0][1]}
  let list = a:elems[1:-2]
  if empty(list[2])
    call insert(list, '', 3)
  elseif empty(list[2][0][1])
    call extend(list, [remove(list, 2)[0][0], ''], 2)
  else
    call extend(list, [list[2][0][0], remove(list, 2)[0][1]], 2)
  endif
  call map(list, 'type(v:val) == type([]) ? get(v:val, 0, "") : v:val')
  let result.greedy = empty(list[0])
  let result.lower = list[1][0]
  let result.range = !empty(list[2])
  let result.upper = list[3][0]
  call s:Debug(result)
  return result
endfunction "vimregextools#parser#curly

"number() {{{1
function! vimregextools#parse#number(elems) abort
  " number ::= '\d\+' -> #number
  let result = str2nr(a:elems)
  call s:Debug(result)
  return result
endfunction "vimregextools#parser#number

"ordinary_atom() {{{1
function! vimregextools#parse#ordinary_atom(elems) abort
  " ordinary_atom ::= any | nl_or_any | anchor | char_class | collection | sequence | back_reference | last_substitution | char -> #ordinary_atom
  call s:Debug(a:elems, 2)
  if type(a:elems) == type([])
    let result = (a:elems[1] =~ '^[$^]$' ? '\_' : a:elems[1] =~ '^[.]$' ? '' : '\') . a:elems[1]
  else
    let result = a:elems
  endif
  call s:Debug(result)
  let s:bol_stack[-1] = 1
  return result
endfunction "vimregextools#parser#ordinary_atom

"any() {{{1
function! vimregextools#parse#any(elems) abort
  " any ::= '\.' -> #any
  let result = '.'
  call s:Debug(result)
  return result
endfunction "vimregextools#parser#any

"nl_or_any() {{{1
function! vimregextools#parse#nl_or_any(elems) abort
  " nl_or_any ::= '\\_\.' -> #nl_or_any
  let result = {'o': '\|', 'v': ['.', '\n']}
  call s:Debug(result)
  return result
endfunction "vimregextools#parser#nl_or_any

"bol() {{{1
function! vimregextools#parse#bol(elems) abort
  " bol ::= '\^' -> #bol
  if get(s:bol_stack, -1, 0)
    let result = '\^'
  else
    let result = '\_^'
  endif
  call s:Debug(result)
  return result
endfunction "vimregextools#parser#bol

"eol() {{{1
function! vimregextools#parse#eol(elems) abort
  " bol ::= & '\$\%(\\)\)*\%(\\&\|\\|\|$\)' '\$' -> #eol
  let result = '\_$'
  let s:eol_level = s:indent_level
  call s:Debug(result)
  return result
endfunction "vimregextools#parser#eol

"mark() {{{1
function! vimregextools#parse#mark(elems) abort
  " mark ::= '\\%''' '[[:alnum:]<>[\]''"^.(){}]' -> #mark
  call s:Debug(a:elems, 2)
  let result = {'o': '\'.a:elems[1] . get(a:elems, 3, ''), 'v': [a:elems[2]]}
  call s:Debug(result)
  return result
endfunction "vimregextools#parser#mark

"decimal_char() {{{1
function! vimregextools#parse#decimal_char(elems) abort
  " range ::= char '-' char -> #decimal_char
  call s:Debug(a:elems, 2)
  let result = {'o': '['.a:elems[0], 'v': [a:elems[1]]}
  call s:Debug(result)
  return result
endfunction "vimregextools#parser#decimal_char

"char_class() {{{1
function! vimregextools#parse#char_class(elems) abort
  " char_class ::= identifier | identifier_no_digits | keyword | non_keyword | file_name | file_name_no_digits | printable | printable_no_digits | whitespace | non_whitespace | digit | non_digit | hex_digit | non_hex_digit | octal_digit | non_octal_digit | word | non_word | head | non_head | alpha | non_alpha | lowercase | non_lowercase | uppercase | non_uppercase | nl_or_identifier | nl_or_identifier_no_digits | nl_or_keyword | nl_or_non_keyword | nl_or_file_name | nl_or_file_name_no_digits | nl_or_printable | nl_or_printable_no_digits | nl_or_whitespace | nl_or_non_whitespace | nl_or_digit | nl_or_non_digit | nl_or_hex_digit | nl_or_non_hex_digit | nl_or_octal_digit | nl_or_non_octal_digit | nl_or_word | nl_or_non_word | nl_or_head | nl_or_non_head | nl_or_alpha | nl_or_non_alpha | nl_or_lowercase | nl_or_non_lowercase | nl_or_uppercase | nl_or_non_uppercase -> #char_class
  call s:Debug(a:elems)
  if match(a:elems, '_') == -1
    let result = a:elems
  else
    let result = {'o': '\|', 'v': [substitute(a:elems, '_', '', ''), '\n']}
  endif
  call s:Debug(result)
  return result
endfunction "vimregextools#parser#char_class

"collection() {{{1
function! vimregextools#parse#collection(elems) abort
  " collection ::= start_collection caret ? coll_inner end_collection -> #collection
  call s:Debug(a:elems, 2)
  let operator = substitute(a:elems[0], '^\\_', '', '')
  let result = {'o': operator, 'v': a:elems[2]}
  if a:elems[0] == '\_['
    call add(result.v, '\n')
  endif
  let result.negate = !empty(a:elems[1])
  call s:Debug(result)
  return result
endfunction "vimregextools#parser#collection

"coll_inner() {{{1
function! vimregextools#parse#coll_inner(elems) abort
  " start_collection ::=  ']' ( range | decimal_char | octal_char | hex_char_low | hex_char_medium | hex_char_high | bracket_class | equivalence | collation | !']' coll_char ) * | ( range | decimal_char | octal_char | hex_char_low | hex_char_medium | hex_char_high | bracket_class | equivalence | collation | !']' coll_char ) + -> #coll_inner
  call s:Debug(a:elems, 2)
  let elems = a:elems
  if type(elems[0]) == type('') && elems[0] == ']'
    let result = ['\'.remove(elems, 0)]
    if !empty(elems)
      call extend(result, elems[0])
    endif
  else
    let result = []
    for i in elems
      if type(i) == type([])
        call add(result, i[1])
      else
        call add(result, i)
      endif
      unlet i
    endfor
  endif
  call s:Debug(result)
  return result
endfunction "vimregextools#parser#coll_inner

"start_collection() {{{1
function! vimregextools#parse#start_collection(elems) abort
  " start_collection ::= coll_nl_or_start | coll_start -> #start_collection
  let result = a:elems
  call s:Debug(result)
  return result
endfunction "vimregextools#parser#start_collection

"end_collection() {{{1
function! vimregextools#parse#end_collection(elems) abort
  " end_collection ::= '\]' -> #end_collection
  call s:ChLvl('-')
  let result = a:elems
  call s:Debug(result)
  return result
endfunction "vimregextools#parser#end_collection

"coll_start() {{{1
function! vimregextools#parse#coll_start(elems) abort
  " coll_start ::= '\\_' -> #coll_start
  let result = a:elems[1]
  call s:ChLvl('+')
  call s:Debug(result)
  return result
endfunction "vimregextools#parser#coll_start

"coll_nl_or_start() {{{1
function! vimregextools#parse#coll_nl_or_start(elems) abort
  " coll_nl_or_start ::= '\\_' -> #coll_nl_or_start
  let result = a:elems
  call s:ChLvl('+')
  call s:Debug(result)
  return result
endfunction "vimregextools#parser#coll_nl_or_start

"caret() {{{1
function! vimregextools#parse#caret(elems) abort
  " caret ::= '\^' -> #caret
  let result = '\'.a:elems
  call s:Debug(result)
  return result
endfunction "vimregextools#parser#caret

"range() {{{1
function! vimregextools#parse#range(elems) abort
  " range ::= char '-' char -> #range
  call s:Debug(a:elems, 2)
  let result = {'o': a:elems[1], 'v': [a:elems[0], a:elems[2]]}
  call s:Debug(result)
  return result
endfunction "vimregextools#parser#range

"coll_decimal_char() {{{1
function! vimregextools#parse#coll_decimal_char(elems) abort
  " range ::= char '-' char -> #coll_decimal_char
  call s:Debug(a:elems, 2)
  let result = {'o': '['.a:elems[0], 'v': [a:elems[1]]}
  call s:Debug(result)
  return result
endfunction "vimregextools#parser#coll_decimal_char

"bracket_class() {{{1
function! vimregextools#parse#bracket_class(elems) abort
  " bracket_class ::= '[:' ( bc_alpha | bc_alnum | bc_blank | bc_cntrl | bc_digit | bc_graph | bc_lower | bc_print | bc_punct | bc_space | bc_upper | bc_xdigit | bc_return | bc_tab | bc_escape | bc_backspace ) ':]' -> #bracket_class
  call s:Debug(a:elems, 2)
  let result = {'o': a:elems[0], 'v': [a:elems[1]]}
  call s:Debug(result)
  return result
endfunction "vimregextools#parser#bracket_class

"coll_char() {{{1
function! vimregextools#parse#coll_char(elems) abort
  " coll_char ::= esc | tab | cr | bs | lb | !'\]' ( '\\]' | '.' ) -> #coll_char
  call s:Debug(a:elems, 2)
  let result = type(a:elems) == type([]) ? a:elems[1] : a:elems
  call s:Debug(result)
  return result
endfunction "vimregextools#parser#coll_char

"sequence() {{{1
function! vimregextools#parse#sequence(elems) abort
  " sequence ::= start_sequence ( collection | seq_char ) + end_sequence -> #sequence
  call s:Debug(a:elems, 2)
  let list = a:elems[1]
  call map(list, 'type(v:val) == type([]) ? v:val[1] : v:val')
  let result = {'o': '\'.a:elems[0][1], 'v': list}
  call s:Debug(result)
  return result
endfunction "vimregextools#parser#sequence

"equivalence() {{{1
function! vimregextools#parse#equivalence(elems) abort
  " equivalence ::= '\[=' char '=\]' -> #equivalence
  call s:Debug(a:elems, 2)
  let result = {'o': a:elems[0], 'v': [a:elems[1]]}
  call s:Debug(result)
  return result
endfunction "vimregextools#parser#equivalence

"char() {{{1
function! vimregextools#parse#char(elems) abort
  " char ::= escaped_char | '[^\\[.]' -> #char
  call s:Debug(a:elems, 2)
  " Use only the second char of non special escaped sequences.
  if type(a:elems) == type([])
    "let result = (a:elems[1] =~ '[@%\[\]()<>+=?]' ? '' : '\') . a:elems[1]
    let result = (a:elems[1] =~ '[*.~]' ? '\' : '') . a:elems[1]
  elseif type(a:elems) == type('') && a:elems == '$'
    let result = '\' . a:elems
  else
    let result = a:elems
  endif
  call s:Debug(result)
  return result
endfunction "vimregextools#parser#char

" Playground {{{1
"2RE a\|b
