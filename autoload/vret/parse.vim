unlet! s:indent_level s:capture_level s:bol_stack
" TODO: nr2char() for number representations.
command! -nargs=+ -count VRET echo vret#parse#match(<q-args>, <count>).value
" Remove all our functions {{{1
"let s:more = &more
"set nomore
"redir => s:func
"silent function
"redir END
"let &more = s:more
"for f in map(filter(split(s:func, '\n'), 'v:val =~# "vret#parse"'), 'matchstr(v:val, "vret#parse#\\k*")')
  ""echo f
  "exec "delfunc " . f
"endfor
"unlet f
function! vret#parse#match(re, ...) "{{{1
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
  try
    if s:magic ==# '\m'
      let result = g:vret#parser_magic#now.match(a:re)
    elseif s:magic ==# '\M'
      let result = g:vret#parser_non_magic#now.match(a:re)
    elseif s:magic ==# '\v'
      let result = g:vret#parser_very_magic#now.match(a:re)
    elseif s:magic ==# '\V'
      let result = g:vret#parser_very_non_magic#now.match(a:re)
    endif
  catch /^VRET/
    let result = {'value': {'elem': 'error', 'o': substitute(v:exception, '\C^VRET: E\(\d\+\).*', '\1', ''), 'v': [v:exception] }}
  endtry
  if empty(result.value)
    let result.value = {'o': 'error', 'v': [] }
  endif
  let result.value.magic = s:magic
  let result.value.case  = s:ignore_case
  let result.value.comp  = s:ignore_composing
  let &maxfuncdepth = save_mfd
  return result
endfunction "Parse

function! vret#parse#walk(ast, visitor, ...) "{{{1
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
function! vret#parse#regexp(elems) abort
  " regexp ::= legal_flag * err13A ? pattern ? ( escape ? eore | err2 ) -> #regexp
  call s:Debug(a:elems, 2)
  let result = {'elem': 're', 'v': []}
  if !empty(a:elems[0]) && !empty(a:elems[0][0])
    call extend(result.v, a:elems[0])
  endif
  if !empty(a:elems[2])
    if type(a:elems[2][0]) == type([]) && len(a:elems[2]) == 1
      call extend(result.v, a:elems[2][0])
    else
      call add(result.v, a:elems[2][0])
    endif
  endif
  if !empty(a:elems[3]) && !empty(a:elems[3][0])
    call add(result.v, a:elems[3][0][0])
  endif
  call s:Debug(result)
  return result
endfunction "vret#parser#regexp

"pattern() {{{1
function! vret#parse#pattern(elems) abort
  " pattern ::= branch ( or branch ? ) *  | ( or branch ?) + -> #pattern
  call s:Debug(a:elems, 2)
  let empty_or = !type(get(a:elems[0], 0, '')) == type('') && get(a:elems[0], 0, '') =~ '\\\?|'
  if !empty_or && empty(a:elems[1])
    " Only one element.
    let result = a:elems[0]
    call s:Debug(result)
    return result
  endif
  if empty_or
    let elems = a:elems
    let list = ['']
  else
    let elems = a:elems[1]
    let list = type(a:elems[0]) == type([]) && len(a:elems[0]) == 1
          \ ? a:elems[0] : [a:elems[0]]
  endif
  for i in elems
    let item = get(i[1], 0, '')
    if type(item) == type([]) && len(item) == 1
      " A list with a single item.
      call extend(list, item)
    else
      call add(list, item)
    endif
  endfor
  let result = {'elem': 'and', 'o': '\|', 'v': list}
  call s:Debug(result)
  return result
endfunction "vret#parser#pattern

"or() {{{1
function! vret#parse#or(elems) abort
  " or ::= '\\|' -> #or
  call s:ChLvl('-')
  let result = '\'.a:elems[1]
  call s:ChLvl('+')
  let s:bol_stack[-1] = get(s:bol_stack, -2, 0)
  call s:Debug(result . ' -> ' . string(s:bol_stack))
  return result
endfunction "vret#parser#or

"branch() {{{1
function! vret#parse#branch(elems) abort
  " branch  ::= concat ( and concat ? ) * | ( and concat ? ) + -> #branch
  call s:Debug(a:elems, 2)
  let empty_and = !type(get(a:elems[0], 0, '')) == type('') && get(a:elems[0], 0, '') =~ '\\\?&'
  if !empty_and && empty(a:elems[1])
    " Only one element.
    let result = a:elems[0]
    call s:Debug(result)
    return result
  endif
  if empty_and
    let elems = a:elems
    let list = ['']
  else
    let elems = a:elems[1]
    let list = type(a:elems[0]) == type([]) && len(a:elems[0]) == 1
          \ ? a:elems[0] : [a:elems[0]]
  endif
  for i in elems
    let item = get(i[1], 0, '')
    if type(item) == type([]) && len(item) == 1
      " A list with a single item.
      call extend(list, item)
    else
      call add(list, item)
    endif
  endfor
  let result = {'elem': 'and', 'o': '\&', 'v': list}
  call s:Debug(result)
  return result
endfunction "vret#parser#branch

"and() {{{1
function! vret#parse#and(elems) abort
  " and ::= '\\&' -> #and
  call s:ChLvl('-')
  let result = '\'.a:elems[1]
  call s:ChLvl('+')
  let s:bol_stack[-1] = get(s:bol_stack, -2, 0)
  call s:Debug(result . ' -> ' . string(s:bol_stack))
  return result
endfunction "vret#parser#and

"concat() {{{1
function! vret#parse#concat(elems) abort
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
endfunction "vret#parser#concat

"piece() {{{1
function! vret#parse#piece(elems) abort
  " piece ::= atom ( err3 | multi ) ? flag * -> #piece
  call s:Debug(a:elems, 2)
  if empty(a:elems[1])
    " Just the atom.
    let mediator = type(a:elems[0]) == type([]) ? a:elems[0] : [a:elems[0]]
  elseif type(a:elems[1][0]) == type({})
    " Atom plus curly.
    let mediator = extend(a:elems[1][0], {'v':[a:elems[0]]})
  else
    " Atom plus other multi.
    let mediator = {'elem': 'multi', 'o': a:elems[1][0], 'v': [a:elems[0]]}
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
endfunction "vret#parser#piece

"atom() {{{1
function! vret#parse#atom(elems) abort
  " atom ::= flag * ( non_capture_group | capture_group | ordinary_atom )
  call s:Debug(a:elems, 2)
  if empty(a:elems[0])
    let result = a:elems[1]
  else
    let result = add(a:elems[0], a:elems[1])
  endif
  call s:Debug(result)
  return result
endfunction "vret#parser#atom

"legal_flag() {{{1
function! vret#parse#legal_flag(elems) abort
  " legal_flag    ::= case_flag | magic_flag | ignore_comb_chars -> #legal_flag
  call s:Debug(a:elems, 2)
  " Flags at the beginning only.
  if a:elems ==# '\C'
    let s:ignore_case = 0
  elseif a:elems ==# '\c'
    let s:ignore_case = 1
  elseif a:elems ==# '\Z'
    let s:ignore_composing = 1
  else
    let s:magic = a:elems
  endif
  let result = {'elem': 'flag', 'o': a:elems, 'v': []}
  call s:Debug(result)
  return result
endfunction "vret#parser#legal_flag

"flag() {{{1
function! vret#parse#flag(elems) abort
  " flag    ::= case_flag | magic_flag | ignore_comb_chars -> #flag
  call s:Debug(a:elems, 2)
  " Flags at the beginning only.
  call s:error(12, 'flags must be at the begining.')
  if a:elems ==# '\C'
    let s:ignore_case = 0
  elseif a:elems ==# '\c'
    let s:ignore_case = 1
  elseif a:elems ==# '\Z'
    let s:ignore_composing = 1
  else
    "let result = a:elems
  endif
  let result = {'elem': 'flag', 'o': a:elems, 'v': []}
  call s:Debug(result)
  return result
endfunction "vret#parser#flag

"capture_group() {{{1
function! vret#parse#capture_group(elems) abort
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
endfunction "vret#parser#capture_group

"non_capture_group() {{{1
function! vret#parse#non_capture_group(elems) abort
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
endfunction "vret#parser#non_capture_group

"open_capture_group() {{{1
function! vret#parse#open_capture_group(elems) abort
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
endfunction "vret#parser#open_capture_group

"open_non_capture_group() {{{1
function! vret#parse#open_non_capture_group(elems) abort
  " open_non_capture_group ::= '\\%(' -> #open_non_capture_group
  let result = '\'.a:elems[1]
  call s:ChLvl('+')
  call add(s:bol_stack, get(s:bol_stack, -1, 0))
  call s:Debug(string(result) . ' -> ' . string(s:bol_stack))
  return result
endfunction "vret#parser#open_non_capture_group

"close_non_capture_group() {{{1
function! vret#parse#close_non_capture_group(elems) abort
  " close_non_capture_group ::= '\\)' -> #close_non_capture_group
  call s:ChLvl('-')
  let result = a:elems
  call remove(s:bol_stack, -1)
  call s:Debug(string(result) . ' -> ' . string(s:bol_stack))
  return result
endfunction "vret#parser#close_non_capture_group

"close_capture_group() {{{1
function! vret#parse#close_capture_group(elems) abort
  " close_capture_group ::= '\\)' -> #close_group
  call s:ChLvl('-')
  let result = a:elems
  call remove(s:bol_stack, -1)
  let s:capture_level -= 1
  call s:Debug(string(result) . ' -> ' . string(s:bol_stack))
  return result
endfunction "vret#parser#close_capture_group

"multi() {{{1
function! vret#parse#multi(elems) abort
  " multi ::= quant_star | quant_plus | quant_equal | quant_question | curly | look_around -> #multi
  call s:Debug(a:elems, 2)
  if type(a:elems) == type([])
    let result = (a:elems[1] =~ '[*]' ? '' : '\') . a:elems[1]
  else
    let result = a:elems
  endif
  call s:Debug(result)
  return result
endfunction "vret#parser#multi

"curly() {{{1
function! vret#parse#curly(elems) abort
  " curly ::= start_curly '-' ? lower ? ( ',' upper ? ) ? end_curly -> #curly
  call s:Debug(a:elems, 2)
  let result = {'elem': 'multi', 'o': [get(a:elems[0], 0, '').a:elems[0][1], get(a:elems[-1][0], 0, '').a:elems[-1][1]]}
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
endfunction "vret#parser#curly

"number() {{{1
function! vret#parse#number(elems) abort
  " number ::= '\d\+' -> #number
  let result = str2nr(a:elems)
  call s:Debug(result)
  return result
endfunction "vret#parser#number

"ordinary_atom() {{{1
function! vret#parse#ordinary_atom(elems) abort
  " ordinary_atom ::= any | nl_or_any | anchor | char_class | collection | sequence | back_reference | last_substitution | char -> #ordinary_atom
  call s:Debug(a:elems, 2)
  if type(a:elems) == type([])
    echoerr 'Hello there!'
    let result = (a:elems[1] =~ '^[$^]$' ? '\_' : a:elems[1] =~ '^[.]$' ? '' : '\') . a:elems[1]
  elseif type(a:elems) == type('') && a:elems == '\_$'
    let result = {'elem': 'eol_any', 'o': a:elems, 'v': []}
  elseif type(a:elems) == type('') && a:elems == '\_^'
    let result = {'elem': 'bol_any', 'o': a:elems, 'v': []}
  else
    let result = a:elems
  endif
  call s:Debug(result)
  let s:bol_stack[-1] = 1
  return result
endfunction "vret#parser#ordinary_atom

"any() {{{1
function! vret#parse#any(elems) abort
  " any ::= '\.' -> #any
  let result = {'elem': 'any', 'o': join(a:elems, ''), 'v': []}
  call s:Debug(result)
  return result
endfunction "vret#parser#any

"nl_or_any() {{{1
function! vret#parse#nl_or_any(elems) abort
  " nl_or_any ::= '\\_\.' -> #nl_or_any
  let result = {'elem': 'nl_or_any', 'o': '\_.', 'v': []}
  call s:Debug(result)
  return result
endfunction "vret#parser#nl_or_any

"bol() {{{1
function! vret#parse#bol(elems) abort
  " bol ::= '\^' -> #bol
  call s:Debug(a:elems, 2)
  let result = {'elem': 'bol_or_^', 'o': join(a:elems, ''), 'v':[]}
  let result.bol = !get(s:bol_stack, -1, 0)
  call s:Debug(result)
  return result
endfunction "vret#parser#bol

"eol() {{{1
function! vret#parse#eol(elems) abort
  " bol ::= & '\$\%(\\)\)*\%(\\&\|\\|\|$\)' '\$' -> #eol
  call s:Debug(a:elems, 2)
  let result = {'elem': 'eol_or_$', 'o': join(a:elems[1:], ''), 'v': [], 'eol': 1}
  let s:eol_level = s:indent_level
  call s:Debug(result)
  return result
endfunction "vret#parser#eol

"mark() {{{1
function! vret#parse#mark(elems) abort
  " mark ::= '\\%''' '[[:alnum:]<>[\]''"^.(){}]' -> #mark
  call s:Debug(a:elems, 2)
  let result = {'elem': 'mark', 'o': join(a:elems, ''), 'v': [a:elems[2]]}
  call s:Debug(result)
  return result
endfunction "vret#parser#mark

"char_code() {{{1
function! vret#parse#char_code(elems) abort
  "char_code    ::= decimal_char | octal_char | hex_char_low | hex_char_medium | hex_char_high | err11 -> #char_code
  call s:Debug(a:elems, 2)
  let result = {'elem': 'char_code', 'o': join(a:elems[0:1], ''), 'v': [a:elems[2]]}
  call s:Debug(result)
  return result
endfunction "vret#parser#char_code

"char_class() {{{1
function! vret#parse#char_class(elems) abort
  " char_class ::= identifier | identifier_no_digits | keyword | non_keyword | file_name | file_name_no_digits | printable | printable_no_digits | whitespace | non_whitespace | digit | non_digit | hex_digit | non_hex_digit | octal_digit | non_octal_digit | word | non_word | head | non_head | alpha | non_alpha | lowercase | non_lowercase | uppercase | non_uppercase | nl_or_identifier | nl_or_identifier_no_digits | nl_or_keyword | nl_or_non_keyword | nl_or_file_name | nl_or_file_name_no_digits | nl_or_printable | nl_or_printable_no_digits | nl_or_whitespace | nl_or_non_whitespace | nl_or_digit | nl_or_non_digit | nl_or_hex_digit | nl_or_non_hex_digit | nl_or_octal_digit | nl_or_non_octal_digit | nl_or_word | nl_or_non_word | nl_or_head | nl_or_non_head | nl_or_alpha | nl_or_non_alpha | nl_or_lowercase | nl_or_non_lowercase | nl_or_uppercase | nl_or_non_uppercase -> #char_class
  call s:Debug(a:elems, 2)
  let result = {'elem': 'char_class', 'o': a:elems, 'v': [a:elems[-1:]]}
  let result.nl = a:elems[1] == '_'
  call s:Debug(result)
  return result
endfunction "vret#parser#char_class

"collection() {{{1
function! vret#parse#collection(elems) abort
  " collection ::= start_collection caret ? coll_inner end_collection -> #collection
  call s:Debug(a:elems, 2)
  let result = {'elem': 'collection', 'o': a:elems[0], 'v': a:elems[2]}
  if a:elems[0] == '\_['
    call add(result.v, '\n')
  endif
  let result.negate = !empty(a:elems[1])
  call s:Debug(result)
  return result
endfunction "vret#parser#collection

"coll_inner() {{{1
function! vret#parse#coll_inner(elems) abort
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
endfunction "vret#parser#coll_inner

"start_collection() {{{1
function! vret#parse#start_collection(elems) abort
  " start_collection ::= coll_nl_or_start | coll_start -> #start_collection
  let result = a:elems
  call s:Debug(result)
  return result
endfunction "vret#parser#start_collection

"end_collection() {{{1
function! vret#parse#end_collection(elems) abort
  " end_collection ::= '\]' -> #end_collection
  call s:ChLvl('-')
  let result = a:elems
  call s:Debug(result)
  return result
endfunction "vret#parser#end_collection

"coll_start() {{{1
function! vret#parse#coll_start(elems) abort
  " coll_start ::= '\\_' -> #coll_start
  let result = join(a:elems, '')
  call s:ChLvl('+')
  call s:Debug(result)
  return result
endfunction "vret#parser#coll_start

"coll_nl_or_start() {{{1
function! vret#parse#coll_nl_or_start(elems) abort
  " coll_nl_or_start ::= '\\_' -> #coll_nl_or_start
  let result = a:elems
  call s:ChLvl('+')
  call s:Debug(result)
  return result
endfunction "vret#parser#coll_nl_or_start

"range() {{{1
function! vret#parse#range(elems) abort
  " range ::= char '-' char -> #range
  call s:Debug(a:elems, 2)
  let result = {'elem': 'coll_range', 'o': a:elems[1], 'v': [a:elems[0], a:elems[2]]}
  call s:Debug(result)
  return result
endfunction "vret#parser#range

"coll_decimal_char() {{{1
function! vret#parse#coll_decimal_char(elems) abort
  " range ::= char '-' char -> #coll_decimal_char
  call s:Debug(a:elems, 2)
  let result = {'elem': 'coll_numeric_char', 'o': '['.a:elems[0], 'v': [a:elems[1]]}
  call s:Debug(result)
  return result
endfunction "vret#parser#coll_decimal_char

"bracket_class() {{{1
function! vret#parse#bracket_class(elems) abort
  " bracket_class ::= '[:' ( bc_alpha | bc_alnum | bc_blank | bc_cntrl | bc_digit | bc_graph | bc_lower | bc_print | bc_punct | bc_space | bc_upper | bc_xdigit | bc_return | bc_tab | bc_escape | bc_backspace ) ':]' -> #bracket_class
  call s:Debug(a:elems, 2)
  let result = {'elem': 'bracket_class', 'o': a:elems[0], 'v': [a:elems[1]]}
  call s:Debug(result)
  return result
endfunction "vret#parser#bracket_class

"coll_char() {{{1
function! vret#parse#coll_char(elems) abort
  " coll_char ::= esc | tab | cr | bs | lb | !'\]' ( '\\]' | '.' ) -> #coll_char
  call s:Debug(a:elems, 2)
  let result = type(a:elems) == type([]) ? a:elems[1] : a:elems
  call s:Debug(result)
  return result
endfunction "vret#parser#coll_char

"sequence() {{{1
function! vret#parse#sequence(elems) abort
  " sequence ::= start_sequence ( err10 | collection | seq_char ) + end_sequence | err8 | err9 -> #sequence
  call s:Debug(a:elems, 2)
  let list = a:elems[1]
  call map(list, 'type(v:val) == type([]) ? v:val[1] : v:val')
  let result = {'elem': 'sequence', 'o': join(a:elems[0], ''), 'v': list}
  call s:Debug(result)
  return result
endfunction "vret#parser#sequence

"equivalence() {{{1
function! vret#parse#equivalence(elems) abort
  " equivalence ::= '\[=' char '=\]' -> #equivalence
  call s:Debug(a:elems, 2)
  let result = {'elem': 'equivalence', 'o': a:elems[0], 'v': [a:elems[1]]}
  call s:Debug(result)
  return result
endfunction "vret#parser#equivalence

"char() {{{1
function! vret#parse#char(elems) abort
  " char ::= escaped_char | '[^\\[.]' -> #char
  call s:Debug(a:elems, 2)
  " Use only the second char of non special escaped sequences.
  if type(a:elems) == type([])
    "let result = (a:elems[1] =~ '[@%\[\]()<>+=?]' ? '' : '\') . a:elems[1]
    "let result = (a:elems[1] =~ '[*.~]' ? '\' : '') . a:elems[1]
    let result = join(a:elems, '')
  elseif type(a:elems) == type('') && a:elems == '$'
    let result = {'elem': 'eol_or_$', 'o': '$', 'v': [], 'eol': 0}
  else
    let result = a:elems
  endif
  call s:Debug(result)
  return result
endfunction "vret#parser#char

"err1() {{{1
function! vret#parse#err1(elems) abort
  " atom ::= flag * ( non_capture_group | capture_group | ordinary_atom )
  call s:Debug(a:elems, 2)
  let result = a:elems
  call s:Debug(result)
  call s:error(1, 'unmatched (')
  return result
endfunction "vret#parser#err1

"err2() {{{1
function! vret#parse#err2(elems) abort
  " atom ::= flag * ( non_capture_group | capture_group | ordinary_atom )
  call s:Debug(a:elems, 2)
  let result = a:elems
  call s:Debug(result)
  call s:error(2, 'unmatched )')
  return result
endfunction "vret#parser#err2

"err3() {{{1
function! vret#parse#err3(elems) abort
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
endfunction "vret#parser#err3

"err4() {{{1
function! vret#parse#err4(elems) abort
  " atom ::= flag * ( non_capture_group | capture_group | ordinary_atom )
  call s:Debug(a:elems, 2)
  let result = a:elems
  call s:Debug(result)
  call s:error(4, 'invalid character after @')
  return result
endfunction "vret#parser#err4

"err5() {{{1
function! vret#parse#err5(elems) abort
  " atom ::= flag * ( non_capture_group | capture_group | ordinary_atom )
  call s:Debug(a:elems, 2)
  let result = a:elems
  call s:Debug(result)
  call s:error(5, 'invalid character after %')
  return result
endfunction "vret#parser#err5

"err6() {{{1
function! vret#parse#err6(elems) abort
  " atom ::= flag * ( non_capture_group | capture_group | ordinary_atom )
  call s:Debug(a:elems, 2)
  let result = a:elems
  call s:Debug(result)
  call s:error(6, 'syntax error in {...}')
  return result
endfunction "vret#parser#err6

"err7() {{{1
function! vret#parse#err7(elems) abort
  " atom ::= flag * ( non_capture_group | capture_group | ordinary_atom )
  call s:Debug(a:elems, 2)
  let result = a:elems
  call s:Debug(result)
  call s:error(7, 'invalid use of \_')
  return result
endfunction "vret#parser#err7

"err8() {{{1
function! vret#parse#err8(elems) abort
  " atom ::= flag * ( non_capture_group | capture_group | ordinary_atom )
  call s:Debug(a:elems, 2)
  let result = a:elems
  call s:Debug(result)
  call s:error(8, 'missing ] after %[')
  return result
endfunction "vret#parser#err8

"err9() {{{1
function! vret#parse#err9(elems) abort
  " atom ::= flag * ( non_capture_group | capture_group | ordinary_atom )
  call s:Debug(a:elems, 2)
  let result = a:elems
  call s:Debug(result)
  call s:error(9, 'empty %[]')
  return result
endfunction "vret#parser#err9

"err10() {{{1
function! vret#parse#err10(elems) abort
  " atom ::= flag * ( non_capture_group | capture_group | ordinary_atom )
  call s:Debug(a:elems, 2)
  let result = a:elems
  call s:Debug(result)
  call s:error(10, 'invalid item in %[]')
  return result
endfunction "vret#parser#err10

"err11() {{{1
function! vret#parse#err11(elems) abort
  " atom ::= flag * ( non_capture_group | capture_group | ordinary_atom )
  call s:Debug(a:elems, 2)
  let result = a:elems
  call s:Debug(result)
  call s:error(11, 'invalid character after %[dxouU]')
  return result
endfunction "vret#parser#err11

"err12() {{{1
function! vret#parse#err12(elems) abort
  " atom ::= flag * ( non_capture_group | capture_group | ordinary_atom )
  call s:Debug(a:elems, 2)
  let result = a:elems
  call s:Debug(result)
  call s:error(12, 'invalid mark')
  return result
endfunction "vret#parser#err12

"err13() {{{1
function! vret#parse#err13(elems) abort
  " atom ::= flag * ( non_capture_group | capture_group | ordinary_atom )
  call s:Debug(a:elems, 2)
  let result = a:elems
  call s:Debug(result)
  call s:error(13, 'multi follows nothing')
  return result
endfunction "vret#parser#err13

" Playground {{{
"2RE a\|b
