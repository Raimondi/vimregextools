let s:indent_level = 0
let s:capture_level = 0
let s:debug = 0
" TODO: nr2char() for number representations.
function! ChLvl(sign) "{{{1
  let s:indent_level = a:sign == '+' ? 1 : -1
endfunction "ChLvl

function! IndentLvl() "{{{1
  return repeat(' ', s:indent_level * 2)
endfunction "IndentLvl

function! vimregextools#parse#match(re) "{{{1
  let s:indent_level = 0
  let s:capture_level = 0
  call Debug(string(a:re))
  redir => g:log
  let result = g:vimregextools#parser#now.match(a:re)
  redir END
  let g:output = 1
  return result
endfunction "Parse
function! Debug(msg) "{{{1
  "echom s:debug
  if exists('s:debug') && s:debug > 0
    echom a:msg
  endif
endfunction "Debug
function! SetTest(...) "{{{1
  if a:0
    call setline('.', substitute(getline('.'),
          \ "^\\(.\\{-} \\)'\\%(''\\|[^']\\)*' \\([01]\\)$", '\1\2', ''))
  endif
  let line = getline('.')
  let result = vimregextools#parse#match(line[:-3]).value
  let str = string(string(result))
  call setline('.', line[:-3].' '.str. line[-2:])
endfunction "SetTest
function! L2s(l) "{{{1
  let result = ''
  if type(a:l) == type([])
    for i in a:l
      let result .= L2s(i)
      unlet i
    endfor
    return result
  else
    return a:l
  endif
endfunction "s:l2s

function! NoEmpty(arg) "{{{
  if type(a:arg) != type([])
    return a:arg
  endif
  let result = []
  for item in a:arg
    if type(item) != type([])
      call add(result, item)
      unlet item
      continue
    endif
    if !empty(item)
      call add(result, NoEmpty(item))
    endif
    unlet item
  endfor
  if len(result) == 1
    return result[0]
  endif
  return result
endfunction "NoEmpty }}}

function! Flatten(arg) "{{{
  if type(a:arg) != type([])
    return a:arg
  endif
  if len(a:arg) == 0
    return a:arg
  endif
  if len(filter(copy(a:arg), 'type(v:val) == type([])')) > 0
    let list = []
    let index = -1
    for i in a:arg
      let index += 1
      if type(i) == type([]) && len(i) > 0
        call extend(list, Flatten(i))
      else
        call add(list, i)
      endif
      unlet! i
    endfor
    return list
  else
    return a:arg
  endif
endfunction "Flatten }}}

"regexp() {{{1
function! vimregextools#parse#regexp(elems) abort
  " regexp ::= legal_flag ? pattern eor -> #regexp
  let name = 'regexp'
  "let result = type(a:elems) == type([]) ? NoEmpty(a:elems[:-2]) : [a:elems]
  let result = NoEmpty(a:elems[:-2])
  call Debug('regexp: ' . string(result))
  return result
endfunction "vimregextools#parser#regexp

"pattern() {{{1
function! vimregextools#parse#pattern(elems) abort
  " pattern ::= branch ( or branch ) * -> #pattern
  let name = 'pattern'
  let result = Flatten(NoEmpty(a:elems))
  call Debug('pattern: ' . string(result))
  return result
endfunction "vimregextools#parser#pattern

"or() {{{1
function! vimregextools#parse#or(elems) abort
  " or ::= '\\|' -> #or
  let name = '\|'
  "let result = NoEmpty(a:elems)
  call ChLvl('-')
  let result = IndentLvl() . name . " => previous atom and next atom are alternate choices ('or')."
  call ChLvl('+')
  call Debug('or: ' . string(result))
  return result
endfunction "vimregextools#parser#or

"branch() {{{1
function! vimregextools#parse#branch(elems) abort
  " branch ::= concat ( and concat ) * -> #branch
  let name = 'branch'
  let result = Flatten(NoEmpty(a:elems))
  call Debug('branch: ' . string(result))
  return result
endfunction "vimregextools#parser#branch

"and() {{{1
function! vimregextools#parse#and(elems) abort
  " and ::= '\\&' -> #and
  let name = '\&'
  "let result = NoEmpty(a:elems)
  call ChLvl('-')
  let result = IndentLvl() . name . " => previous atom and next atom are required together ('and')."
  call ChLvl('+')
  call Debug('and: ' . string(result))
  return result
endfunction "vimregextools#parser#and

"concat() {{{1
function! vimregextools#parse#concat(elems) abort
  " concat ::= piece + -> #concat
  let name = 'concat'
  let result = Flatten(NoEmpty(a:elems))
  call Debug('concat: ' . string(result))
  return result
endfunction "vimregextools#parser#concat

"piece() {{{1
function! vimregextools#parse#piece(elems) abort
  " piece ::= atom multi ? flag * -> #piece
  let name = 'piece'
  let result = Flatten(NoEmpty(a:elems))
  call Debug('piece: ' . string(result))
  return result
endfunction "vimregextools#parser#piece

"atom() {{{1
function! vimregextools#parse#atom(elems) abort
  " atom ::= flag * ( non_capture_group | capture_group | ordinary_atom )
  let name = 'atom'
  let result = NoEmpty(a:elems)
  call Debug('atom: ' . string(result))
  return result
endfunction "vimregextools#parser#atom

"flag() {{{1
function! vimregextools#parse#flag(elems) abort
  " flag ::= case_flag | magic_flag | ignore_comb_chars -> #flag
  let name = 'flag'
  let result = a:elems[2] "NoEmpty(a:elems)
  call Debug('flag: ' . string(result))
  return result
endfunction "vimregextools#parser#flag

"legal_flag() {{{1
function! vimregextools#parse#legal_flag(elems) abort
  " legal_flag ::= case_flag | ignore_comb_chars -> #legal_flag
  call Debug(string(a:elems))
  let result = a:elems[2] "NoEmpty(a:elems)
  call Debug('legal_flag: ' . string(result))
  return result
endfunction "vimregextools#parser#legal_flag

"ignore_comb_chars() {{{1
function! vimregextools#parse#ignore_comb_chars(elems) abort
  " ignore_comb_chars ::= '\\Z' -> #ignore_comb_chars
  let name = '\Z'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => ignore differences in Unicode \"combining characters\"."
  call Debug('ignore_comb_chars: ' . string(result))
  return result
endfunction "vimregextools#parser#ignore_comb_chars

"case_flag() {{{1
function! vimregextools#parse#case_flag(elems) abort
  " case_flag ::= ignore_case | match_case -> #case_flag
  let name = 'case_flag'
  let result = NoEmpty(a:elems)
  call Debug('case_flag: ' . string(result))
  return result
endfunction "vimregextools#parser#case_flag

"ignore_case() {{{1
function! vimregextools#parse#ignore_case(elems) abort
  " ignore_case ::= '\\c' -> #ignore_case
  let name = '\c'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => ignore case."
  call Debug('ignore_case: ' . string(result))
  return result
endfunction "vimregextools#parser#ignore_case

"match_case() {{{1
function! vimregextools#parse#match_case(elems) abort
  " match_case ::= '\\C' -> #match_case
  let name = '\C'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => match case."
  call Debug('match_case: ' . string(result))
  return result
endfunction "vimregextools#parser#match_case

"magic_flag() {{{1
function! vimregextools#parse#magic_flag(elems) abort
  " magic_flag ::= magic | no_magic | very_magic | very_no_magic -> #magic_flag
  let name = 'magic_flag'
  let result = NoEmpty(a:elems)
  call Debug('magic_flag: ' . string(result))
  return result
endfunction "vimregextools#parser#magic_flag

"magic() {{{1
function! vimregextools#parse#magic(elems) abort
  " magic ::= '\\m' -> #magic
  let name = '\m'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => magic."
  call Debug('magic: ' . string(result))
  return result
endfunction "vimregextools#parser#magic

"no_magic() {{{1
function! vimregextools#parse#no_magic(elems) abort
  " no_magic ::= '\\M' -> #no_magic
  let name = '\M'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => non-magic."
  call Debug('no_magic: ' . string(result))
  return result
endfunction "vimregextools#parser#no_magic

"very_magic() {{{1
function! vimregextools#parse#very_magic(elems) abort
  " very_magic ::= '\\v' -> #very_magic
  let name = '\v'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => very magic."
  call Debug('very_magic: ' . string(result))
  return result
endfunction "vimregextools#parser#very_magic

"very_no_magic() {{{1
function! vimregextools#parse#very_no_magic(elems) abort
  " very_no_magic ::= '\\V' -> #very_no_magic
  let name = '\V'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => very non-magic."
  call Debug('very_no_magic: ' . string(result))
  return result
endfunction "vimregextools#parser#very_no_magic

"capture_group() {{{1
function! vimregextools#parse#capture_group(elems) abort
  " capture_group ::= open_capture_group pattern close_group -> #capture_group
  let name = 'capture_group'
  let result = Flatten(a:elems) "NoEmpty(a:elems)
  call Debug('capture_group: ' . string(result))
  return result
endfunction "vimregextools#parser#capture_group

"non_capture_group() {{{1
function! vimregextools#parse#non_capture_group(elems) abort
  " non_capture_group ::= open_non_capture_group pattern close_group -> #non_capture_group
  let name = 'non_capture_group'
  let result = Flatten(a:elems) "NoEmpty(a:elems)
  call Debug('non_capture_group: ' . string(result))
  return result
endfunction "vimregextools#parser#non_capture_group

"open_capture_group() {{{1
function! vimregextools#parse#open_capture_group(elems) abort
  " open_capture_group ::= '\\(' -> #open_capture_group
  let name = '\('
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => start capture group."
  call ChLvl('+')
  call Debug('open_capture_group: ' . string(result))
  return result
endfunction "vimregextools#parser#open_capture_group

"open_non_capture_group() {{{1
function! vimregextools#parse#open_non_capture_group(elems) abort
  " open_non_capture_group ::= '\\%(' -> #open_non_capture_group
  let name = '\%('
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => start non-capture group."
  call ChLvl('+')
  call Debug('open_non_capture_group: ' . string(result))
  return result
endfunction "vimregextools#parser#open_non_capture_group

"close_group() {{{1
function! vimregextools#parse#close_non_capture_group(elems) abort
  " close_non_capture_group ::= '\\)' -> #close_non_capture_group
  let name = '\)'
  "let result = NoEmpty(a:elems)
  call ChLvl('-')
  let result = IndentLvl() . name . " => end non-capture group."
  call Debug('close_non_capture_group: ' . string(result))
  return result
endfunction "vimregextools#parser#close_non_capture_group

"close_group() {{{1
function! vimregextools#parse#close_capture_group(elems) abort
  " close_capture_group ::= '\\)' -> #close_group
  let name = '\)'
  "let result = NoEmpty(a:elems)
  call ChLvl('-')
  let result = IndentLvl() . name . " => end capture group."
  call Debug('close_capture_group: ' . string(result))
  return result
endfunction "vimregextools#parser#close_capture_group

"multi() {{{1
function! vimregextools#parse#multi(elems) abort
  " multi ::= star | plus | equal | question | curly | look_around -> #multi
  let name = 'multi'
  "let result = NoEmpty(a:elems)
  let result = type(a:elems) == type([]) ? a:elems[2] : a:elems
  call Debug('multi: ' . string(result))
  return result . " of the previous atom."
endfunction "vimregextools#parser#multi

"star() {{{1
function! vimregextools#parse#star(elems) abort
  " star ::= '*' -> #star
  let name = '*'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => zero or more"
  call Debug('star: ' . string(result))
  return result
endfunction "vimregextools#parser#star

"plus() {{{1
function! vimregextools#parse#plus(elems) abort
  " plus ::= '\\+' -> #plus
  let name = '\+'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => one or more"
  call Debug('plus: ' . string(result))
  return result
endfunction "vimregextools#parser#plus

"equal() {{{1
function! vimregextools#parse#equal(elems) abort
  " equal ::= '\\=' -> #equal
  let name = '\='
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => zero or one"
  call Debug('equal: ' . string(result))
  return result
endfunction "vimregextools#parser#equal

"question() {{{1
function! vimregextools#parse#question(elems) abort
  " question ::= '\\?' -> #question
  let name = '\?'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => zero or one"
  call Debug('question: ' . string(result))
  return result
endfunction "vimregextools#parser#question

"curly() {{{1
function! vimregextools#parse#curly(elems) abort
  " curly ::= start_curly '-' ? lower ? ( ',' upper ? ) ? end_curly -> #curly
  let elems = Flatten(a:elems)
  let lazy = type(elems[1]) != type([]) ? elems[1] : ''
  let lower = type(elems[2]) != type([]) ? elems[2] : ''
  let comma =  type(elems[3]) != type([]) ? elems[3] : ''
  let upper =  type(elems[4]) != type([]) ? elems[4] : ''
  let description = ''
  if !empty(lazy)
    let description .= 'few as possible "lazy" match'
  else
    let description .= 'many as possible "greedy" match'
  endif
  if !empty(lower) && !empty(upper)
    ".\{x,y}
    let description .= ', at least ' . lower . ' but '. upper . ' at most'
  elseif !empty(lower) && empty(upper) && !empty(comma)
    ".\{x,}
    let description .= ', at least ' . lower
  elseif !empty(lower) && empty(upper)
    "\{x}
    let description .= ', exactly ' . lower
  elseif empty(lower) && !empty(upper)
    "\{,y}
    let description .= ' up to ' . upper
  else
  "elseif !empty(comma) || (empty(comma) && empty(lazy))
    "\{,} or \{}
    let description = 'zero'
  endif
  let name = '{'.lazy.lower.comma.upper.'}'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => ".description
  call Debug('curly: ' . string(result))
  return result
endfunction "vimregextools#parser#curly

"start_curly() {{{1
function! vimregextools#parse#start_curly(elems) abort
  " start_curly ::= '\\{' -> #start_curly
  let name = 'start_curly'
  let result = a:elems "NoEmpty(a:elems)
  call Debug('start_curly: ' . string(result))
  return result
endfunction "vimregextools#parser#start_curly

"end_curly() {{{1
function! vimregextools#parse#end_curly(elems) abort
  " end_curly ::= escape ? '}' -> #end_curly
  let name = 'end_curly'
  let result = a:elems "NoEmpty(a:elems)
  call Debug('end_curly: ' . string(result))
  return result
endfunction "vimregextools#parser#end_curly

"non_greedy() {{{1
function! vimregextools#parse#non_greedy(elems) abort
  " non_greedy ::= '-' greedy ? -> #non_greedy
  let name = 'non_greedy'
  let result = a:elems "NoEmpty(a:elems)
  call Debug('non_greedy: ' . string(result))
  return result
endfunction "vimregextools#parser#non_greedy

"greedy() {{{1
function! vimregextools#parse#greedy(elems) abort
  " greedy ::= lower ( ',' upper ) ? | ',' upper -> #greedy
  let name = 'greedy'
  let result = a:elems "NoEmpty(a:elems)
  call Debug('greedy: ' . string(result))
  return result
endfunction "vimregextools#parser#greedy

"lower() {{{1
function! vimregextools#parse#lower(elems) abort
  " lower ::= number -> #lower
  let name = 'lower'
  let result = a:elems[0] "NoEmpty(a:elems)
  call Debug('lower: ' . string(result))
  return result
endfunction "vimregextools#parser#lower

"upper() {{{1
function! vimregextools#parse#upper(elems) abort
  " upper ::= number -> #upper
  let name = 'upper'
  let result = a:elems[0] "NoEmpty(a:elems)
  call Debug('upper: ' . string(result))
  return result
endfunction "vimregextools#parser#upper

"number() {{{1
function! vimregextools#parse#number(elems) abort
  " number ::= '\d\+' -> #number
  let name = 'number'
  let result = NoEmpty(a:elems)
  call Debug('number: ' . string(result))
  return result
endfunction "vimregextools#parser#number

"look_around() {{{1
function! vimregextools#parse#look_around(elems) abort
  " look_around ::= at_ahead | at_no_ahead | at_behind | at_no_behind | at_whole -> #at
  let name = 'look_around'
  let result = NoEmpty(a:elems)
  call Debug('look_around: ' . string(result))
  return result
endfunction "vimregextools#parser#look_around

"at_ahead() {{{1
function! vimregextools#parse#at_ahead(elems) abort
  " at_ahead ::= '\\@=' -> #at_ahead
  let name = '\@='
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => positive lookahead: previous atom present ? match : no match."
  call Debug('at_ahead: ' . string(result))
  return result
endfunction "vimregextools#parser#at_ahead

"at_no_ahead() {{{1
function! vimregextools#parse#at_no_ahead(elems) abort
  " at_no_ahead ::= '\\@!' -> #at_no_ahead
  let name = '\@!'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => negative lookahead: previous atom present ? no match : match."
  call Debug('at_no_ahead: ' . string(result))
  return result
endfunction "vimregextools#parser#at_no_ahead

"at_behind() {{{1
function! vimregextools#parse#at_behind(elems) abort
  " at_behind ::= '\\@<=' -> #at_behind
  let name = '\@<='
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => positive lookbehind: previous atom present ? match : no match."
  call Debug('at_behind: ' . string(result))
  return result
endfunction "vimregextools#parser#at_behind

"at_no_behind() {{{1
function! vimregextools#parse#at_no_behind(elems) abort
  " at_no_behind ::= '\\@<!' -> #at_no_behind
  let name = '\@<!'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => negative lookbehind: previous atom present ? no match : match."
  call Debug('at_no_behind: ' . string(result))
  return result
endfunction "vimregextools#parser#at_no_behind

"at_whole() {{{1
function! vimregextools#parse#at_whole(elems) abort
  " at_whole ::= '\\@>' -> #at_whole
  let name = '\@>'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => match the preceding atom like matching a whole pattern."
  call Debug('at_whole: ' . string(result))
  return result
endfunction "vimregextools#parser#at_whole

"ordinary_atom() {{{1
function! vimregextools#parse#ordinary_atom(elems) abort
  " ordinary_atom ::= dot | nl_or_dot | anchor | char_class | collection | sequence | back_reference | last_substitution | char -> #ordinary_atom
  let name = 'ordinary_atom'
  let result = NoEmpty(a:elems)
  call Debug('ordinary_atom: ' . string(result))
  return result
endfunction "vimregextools#parser#ordinary_atom

"dot() {{{1
function! vimregextools#parse#dot(elems) abort
  " dot ::= '\.' -> #dot
  let name = '.'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => any single character."
  call Debug('dot: ' . string(result))
  return result
endfunction "vimregextools#parser#dot

"nl_or_dot() {{{1
function! vimregextools#parse#nl_or_dot(elems) abort
  " nl_or_dot ::= '\\_\.' -> #nl_or_dot
  let name = '\_.'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => any single character or end of line."
  call Debug('nl_or_dot: ' . string(result))
  return result
endfunction "vimregextools#parser#nl_or_dot

"anchor() {{{1
function! vimregextools#parse#anchor(elems) abort
  " anchor ::= bol | bol_any | eol | eol_any | bow | eow | zs | ze | bof | eof | visual | cursor | mark | line | column | virtual_column -> #anchor
  let name = 'anchor'
  let result = NoEmpty(a:elems)[1:]
  call Debug('anchor: ' . string(result))
  return result
endfunction "vimregextools#parser#anchor

"bol() {{{1
function! vimregextools#parse#bol(elems) abort
  " bol ::= '\^' -> #bol
  let name = '^'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => start of line."
  call Debug('bol: ' . string(result))
  return result
endfunction "vimregextools#parser#bol

"bol_any() {{{1
function! vimregextools#parse#bol_any(elems) abort
  " bol_any ::= '\\_\^' -> #bol_any
  let name = '\_^'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => start of line, anywhere in the pattern."
  call Debug('bol_any: ' . string(result))
  return result
endfunction "vimregextools#parser#bol_any

"eol() {{{1
function! vimregextools#parse#eol(elems) abort
  " eol ::= '\$' -> #eol
  let name = '$'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => end of line."
  call Debug('eol: ' . string(result))
  return result
endfunction "vimregextools#parser#eol

"eol_any() {{{1
function! vimregextools#parse#eol_any(elems) abort
  " eol_any ::= '\\_\$' -> #eol_any
  let name = '\_$'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => end of line, anywhere in the pattern."
  call Debug('eol_any: ' . string(result))
  return result
endfunction "vimregextools#parser#eol_any

"bow() {{{1
function! vimregextools#parse#bow(elems) abort
  " bow ::= '\\<' -> #bow
  let name = '\<'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => start of a word."
  call Debug('bow: ' . string(result))
  return result
endfunction "vimregextools#parser#bow

"eow() {{{1
function! vimregextools#parse#eow(elems) abort
  " eow ::= '\\>' -> #eow
  let name = '\>'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => end of a word."
  call Debug('eow: ' . string(result))
  return result
endfunction "vimregextools#parser#eow

"zs() {{{1
function! vimregextools#parse#zs(elems) abort
  " zs ::= '\\zs' -> #zs
  let name = '\zs'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => start of match."
  call Debug('zs: ' . string(result))
  return result
endfunction "vimregextools#parser#zs

"ze() {{{1
function! vimregextools#parse#ze(elems) abort
  " ze ::= '\\ze' -> #ze
  let name = '\ze'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => end of match."
  call Debug('ze: ' . string(result))
  return result
endfunction "vimregextools#parser#ze

"bof() {{{1
function! vimregextools#parse#bof(elems) abort
  " bof ::= '\\%\$' -> #bof
  let name = '\%^'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => start of file."
  call Debug('bof: ' . string(result))
  return result
endfunction "vimregextools#parser#bof

"eof() {{{1
function! vimregextools#parse#eof(elems) abort
  " eof ::= '\\%\^' -> #eof
  let name = '\%$'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => end of filen"
  call Debug('eof: ' . string(result))
  return result
endfunction "vimregextools#parser#eof

"visual() {{{1
function! vimregextools#parse#visual(elems) abort
  " visual ::= '\\%V' -> #visual
  let name = '\%V'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => inside the Visual area."
  call Debug('visual: ' . string(result))
  return result
endfunction "vimregextools#parser#visual

"cursor() {{{1
function! vimregextools#parse#cursor(elems) abort
  " cursor ::= '\\%#' -> #cursor
  let name = '\%#'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => current cursor position."
  call Debug('cursor: ' . string(result))
  return result
endfunction "vimregextools#parser#cursor

"mark() {{{1
function! vimregextools#parse#mark(elems) abort
  " mark ::= '\\%''[[:alnum:]<>[\]''"^.(){}]' -> #mark
  let mark = a:elems[2]
  let name = '\%'''.mark
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => mark ".mark."."
  call Debug('mark: ' . string(result))
  return result
endfunction "vimregextools#parser#mark

"line() {{{1
function! vimregextools#parse#line(elems) abort
  " line ::= '\\%\d\+l' -> #line
  let line = a:elems[1:-2]
  let name = '\%'.line.'l'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => line ".line."."
  call Debug('line: ' . string(result))
  return result
endfunction "vimregextools#parser#line

"column() {{{1
function! vimregextools#parse#column(elems) abort
  " column ::= '\\%\d\+c' -> #column
  let col = a:elems[1:-2]
  let name = '\%'.col.'c'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => column ".col."."
  call Debug('column: ' . string(result))
  return result
endfunction "vimregextools#parser#column

"virtual_column() {{{1
function! vimregextools#parse#virtual_column(elems) abort
  " virtual_column ::= '\\%\d\+v' -> #virtual_column
  let col = a:elems[1:-2]
  let name = '\%'.col.'v'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => virtual column ".col."."
  call Debug('virtual_column: ' . string(result))
  return result
endfunction "vimregextools#parser#virtual_column

"char_class() {{{1
function! vimregextools#parse#char_class(elems) abort
  " char_class ::= identifier | identifier_no_digits | keyword | non_keyword | file_name | file_name_no_digits | printable | printable_no_digits | whitespace | non_whitespace | digit | non_digit | hex_digit | non_hex_digit | octal_digit | non_octal_digit | word | non_word | head | non_head | alpha | non_alpha | lowercase | non_lowercase | uppercase | non_uppercase | nl_or_identifier | nl_or_identifier_no_digits | nl_or_keyword | nl_or_non_keyword | nl_or_file_name | nl_or_file_name_no_digits | nl_or_printable | nl_or_printable_no_digits | nl_or_whitespace | nl_or_non_whitespace | nl_or_digit | nl_or_non_digit | nl_or_hex_digit | nl_or_non_hex_digit | nl_or_octal_digit | nl_or_non_octal_digit | nl_or_word | nl_or_non_word | nl_or_head | nl_or_non_head | nl_or_alpha | nl_or_non_alpha | nl_or_lowercase | nl_or_non_lowercase | nl_or_uppercase | nl_or_non_uppercase -> #char_class
  let name = 'char_class'
  call Debug(string(a:elems))
  let result = a:elems[1][2]
  call Debug('char_class: ' . string(result))
  return result
endfunction "vimregextools#parser#char_class

"collection() {{{1
function! vimregextools#parse#collection(elems) abort
  " collection ::= start_collection caret ? ']' ? ( range | decimal_char | octal_char | hex_char_low | hex_char_medium | hex_char_high | bracket_class | equivalence | collation | coll_esc_char | !']' char ) * end_collection -> #collection
  let name = 'collection'
  let result = Flatten(NoEmpty(a:elems))
  call Debug('collection: ' . string(result))
  return result
endfunction "vimregextools#parser#collection

"start_collection() {{{1
function! vimregextools#parse#start_collection(elems) abort
  " start_collection ::= nl_or ? '\[' -> #start_collection
  let name = 'start_collection'
  let result = Flatten(NoEmpty(a:elems))
  call Debug('start_collection: ' . string(result))
  return result
endfunction "vimregextools#parser#start_collection

"end_collection() {{{1
function! vimregextools#parse#end_collection(elems) abort
  " end_collection ::= '\]' -> #end_collection
  let name = ']'
  "let result = NoEmpty(a:elems)
  call ChLvl('-')
  let result = IndentLvl() . name . " => end collection."
  call Debug('end_collection: ' . string(result))
  return result
endfunction "vimregextools#parser#end_collection

"coll_start() {{{1
function! vimregextools#parse#coll_start(elems) abort
  " coll_start ::= '\\_' -> #coll_start
  let name = '['
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => start collection."
  call ChLvl('+')
  call Debug('coll_start: ' . string(result))
  return result
endfunction "vimregextools#parser#coll_start

"coll_nl_or_start() {{{1
function! vimregextools#parse#coll_nl_or_start(elems) abort
  " coll_nl_or_start ::= '\\_' -> #coll_nl_or_start
  let name = '\_['
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => start collection that also matches newline."
  call ChLvl('+')
  call Debug('coll_nl_or_start: ' . string(result))
  return result
endfunction "vimregextools#parser#coll_nl_or_start

"caret() {{{1
function! vimregextools#parse#caret(elems) abort
  " caret ::= '\^' -> #caret
  let name = '^'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => caret."
  call Debug('caret: ' . string(result))
  return result
endfunction "vimregextools#parser#caret

"range() {{{1
function! vimregextools#parse#range(elems) abort
  " range ::= char '-' char -> #range
  let name =join(a:elems, '')
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => range of chars from ".name[0]." to ".name[2]."."
  call Debug('range: ' . string(result))
  return result
endfunction "vimregextools#parser#range

"decimal_char() {{{1
function! vimregextools#parse#decimal_char(elems) abort
  " decimal_char ::= '\\d\d\+' -> #decimal_char
  let name = '\d'.a:elems[2:]
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => decimal number of character."
  call Debug('decimal_char: ' . string(result))
  return result
endfunction "vimregextools#parser#decimal_char

"octal_char() {{{1
function! vimregextools#parse#octal_char(elems) abort
  " octal_char ::= '\\o[0-7]\{,4}' -> #octal_char
  let name = '\o'.a:elems[2:]
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => octal number of character up to 0377."
  call Debug('octal_char: ' . string(result))
  return result
endfunction "vimregextools#parser#octal_char

"hex_char_low() {{{1
function! vimregextools#parse#hex_char_low(elems) abort
  " hex_char_low ::= '\\x[0-9a-f]\{,2}' -> #hex_char_low
  let name = '\x'.a:elems[2:]
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => hexadecimal number of multibyte character up to 0xff."
  call Debug('hex_char_low: ' . string(result))
  return result
endfunction "vimregextools#parser#hex_char_low

"hex_char_medium() {{{1
function! vimregextools#parse#hex_char_medium(elems) abort
  " hex_char_medium ::= '\\u[0-9a-f]\{,4}' -> #hex_char_medium
  let name = '\u'.a:elems[2:]
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => hexadecimal number of multibyte character up to 0xffff."
  call Debug('hex_char_medium: ' . string(result))
  return result
endfunction "vimregextools#parser#hex_char_medium

"hex_char_high() {{{1
function! vimregextools#parse#hex_char_high(elems) abort
  " hex_char_high ::= '\\U[0-9a-f]\{,8}' -> #hex_char_high
  let name = '\U'.a:elems[2:]
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => hexadecimal number of multibyte character up to 0xffffffff."
  call Debug('hex_char_high: ' . string(result))
  return result
endfunction "vimregextools#parser#hex_char_high

"bracket_class() {{{1
function! vimregextools#parse#bracket_class(elems) abort
  " bracket_class ::= '[:' ( bc_alpha | bc_alnum | bc_blank | bc_cntrl | bc_digit | bc_graph | bc_lower | bc_print | bc_punct | bc_space | bc_upper | bc_xdigit | bc_return | bc_tab | bc_escape | bc_backspace ) ':]' -> #bracket_class
  let name = 'bracket_class'
  let result = NoEmpty(a:elems)[1]
  call Debug('bracket_class: ' . string(result))
  return result
endfunction "vimregextools#parser#bracket_class

"bc_alpha() {{{1
function! vimregextools#parse#bc_alpha(elems) abort
  " bc_alpha ::= 'alpha' -> #bc_alpha
  let name = '[:alpha:]'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => letters."
  call Debug('bc_alpha: ' . string(result))
  return result
endfunction "vimregextools#parser#bc_alpha

"bc_alnum() {{{1
function! vimregextools#parse#bc_alnum(elems) abort
  " bc_alnum ::= 'alnum' -> #bc_alnum
  let name = '[:alnum:]'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => letters and digits."
  call Debug('bc_alnum: ' . string(result))
  return result
endfunction "vimregextools#parser#bc_alnum

"bc_blank() {{{1
function! vimregextools#parse#bc_blank(elems) abort
  " bc_blank ::= 'blank' -> #bc_blank
  let name = '[:blank:]'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => space and tab characters."
  call Debug('bc_blank: ' . string(result))
  return result
endfunction "vimregextools#parser#bc_blank

"bc_cntrl() {{{1
function! vimregextools#parse#bc_cntrl(elems) abort
  " bc_cntrl ::= 'cntrl' -> #bc_cntrl
  let name = '[:cntrl:]'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => control character."
  call Debug('bc_cntrl: ' . string(result))
  return result
endfunction "vimregextools#parser#bc_cntrl

"bc_digit() {{{1
function! vimregextools#parse#bc_digit(elems) abort
  " bc_digit ::= 'digit' -> #bc_digit
  let name = '[:digit:]'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => decimal digit."
  call Debug('bc_digit: ' . string(result))
  return result
endfunction "vimregextools#parser#bc_digit

"bc_graph() {{{1
function! vimregextools#parse#bc_graph(elems) abort
  " bc_graph ::= 'graph' -> #bc_graph
  let name = '[:graph:]'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => printable character including space."
  call Debug('bc_graph: ' . string(result))
  return result
endfunction "vimregextools#parser#bc_graph

"bc_lower() {{{1
function! vimregextools#parse#bc_lower(elems) abort
  " bc_lower ::= 'lower' -> #bc_lower
  let name = '[:lower:]'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => loercase letters (all letters when 'ignorecase' is used)."
  call Debug('bc_lower: ' . string(result))
  return result
endfunction "vimregextools#parser#bc_lower

"bc_print() {{{1
function! vimregextools#parse#bc_print(elems) abort
  " bc_print ::= 'print' -> #bc_print
  let name = '[:print:]'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => printable character including space."
  call Debug('bc_print: ' . string(result))
  return result
endfunction "vimregextools#parser#bc_print

"bc_punct() {{{1
function! vimregextools#parse#bc_punct(elems) abort
  " bc_punct ::= 'punct' -> #bc_punct
  let name = '[:punct:]'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => punctuation."
  call Debug('bc_punct: ' . string(result))
  return result
endfunction "vimregextools#parser#bc_punct

"bc_space() {{{1
function! vimregextools#parse#bc_space(elems) abort
  " bc_space ::= 'space' -> #bc_space
  let name = '[:space:]'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => space."
  call Debug('bc_space: ' . string(result))
  return result
endfunction "vimregextools#parser#bc_space

"bc_upper() {{{1
function! vimregextools#parse#bc_upper(elems) abort
  " bc_upper ::= 'upper' -> #bc_upper
  let name = '[:upper:]'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => uppercase letters (all letters when 'ignorecase' is used)."
  call Debug('bc_upper: ' . string(result))
  return result
endfunction "vimregextools#parser#bc_upper

"bc_xdigit() {{{1
function! vimregextools#parse#bc_xdigit(elems) abort
  " bc_xdigit ::= 'xdigit' -> #bc_xdigit
  let name = '[:xdigit:]'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => hexadecimal digits."
  call Debug('bc_xdigit: ' . string(result))
  return result
endfunction "vimregextools#parser#bc_xdigit

"bc_return() {{{1
function! vimregextools#parse#bc_return(elems) abort
  " bc_return ::= 'return' -> #bc_return
  let name = '[:return:]'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => return character."
  call Debug('bc_return: ' . string(result))
  return result
endfunction "vimregextools#parser#bc_return

"bc_tab() {{{1
function! vimregextools#parse#bc_tab(elems) abort
  " bc_tab ::= 'tab' -> #bc_tab
  let name = '[:tab:]'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => tab character."
  call Debug('bc_tab: ' . string(result))
  return result
endfunction "vimregextools#parser#bc_tab

"bc_escape() {{{1
function! vimregextools#parse#bc_escape(elems) abort
  " bc_escape ::= 'escape' -> #bc_escape
  let name = '[:escape:]'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => escape character."
  call Debug('bc_escape: ' . string(result))
  return result
endfunction "vimregextools#parser#bc_escape

"bc_backspace() {{{1
function! vimregextools#parse#bc_backspace(elems) abort
  " bc_backspace ::= 'backspace' -> #bc_backspace
  let name = '[:backspace:]'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => backspace character."
  call Debug('bc_backspace: ' . string(result))
  return result
endfunction "vimregextools#parser#bc_backspace

"coll_chars() {{{1
function! vimregextools#parse#coll_chars(elems) abort
  " coll_char ::= '\\[^\]^\bdertnoUux-]' -> #coll_char
  if type(a:elems) == type([])
    let name = join(a:elems, '')
  else
    let name = a:elems
  endif
  let name = substitute(name, ' ', '<Space>', 'g')
  let result = IndentLvl() . name . " => literal character(s)."
  call Debug('coll_chars: ' . string(result))
  return result
endfunction "vimregextools#parser#coll_chars

"coll_char() {{{1
function! vimregextools#parse#coll_char(elems) abort
  " coll_char ::= '\\[^\]^\bdertnoUux-]' -> #coll_char
  let name = 'coll_char'
  let result = type(a:elems) == type([]) ? a:elems[1] : a:elems
  call Debug('coll_char: ' . string(result))
  return result
endfunction "vimregextools#parser#coll_char

"sequence() {{{1
function! vimregextools#parse#sequence(elems) abort
  " sequence ::= start_sequence ']' ? ( collection | seq_char ) * end_sequence -> #sequence
  let name = 'sequence'
  let result = Flatten(NoEmpty(a:elems))
  call Debug('sequence: ' . string(result))
  return result
endfunction "vimregextools#parser#sequence

"seq_char() {{{1
function! vimregextools#parse#seq_char(elems) abort
  " seq_char ::= seq_escaped_char | !']' '.' -> #seq_char
  let name = 'seq_char'
  let result = NoEmpty(a:elems)
  call Debug('seq_char: ' . string(result))
  return result
endfunction "vimregextools#parser#seq_char

"seq_escaped_char() {{{1
function! vimregextools#parse#seq_escaped_char(elems) abort
  " seq_escaped_char ::= escape ( esc | tab | cr | bs | lb | '.' ) -> #seq_escaped_char
  let name = a:elems
  let result = NoEmpty(a:elems)[1]
  call Debug('seq_escaped_char: ' . string(result))
  return result
endfunction "vimregextools#parser#seq_escaped_char

"start_sequence() {{{1
function! vimregextools#parse#start_sequence(elems) abort
  " start_sequence ::= '\\%[' -> #start_sequence
  let name = '\%['
  "let result = NoEmpty(a:elems)
  call ChLvl('+')
  let result = IndentLvl() . name . " => start of optional sequence."
  call Debug('start_sequence: ' . string(result))
  return result
endfunction "vimregextools#parser#start_sequence

"end_sequence() {{{1
function! vimregextools#parse#end_sequence(elems) abort
  " end_sequence ::= '\]' -> #end_sequence
  let name = ']'
  call ChLvl('-')
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => end of optional sequence."
  call Debug('end_sequence: ' . string(result))
  return result
endfunction "vimregextools#parser#end_sequence

"equivalence() {{{1
function! vimregextools#parse#equivalence(elems) abort
  " equivalence ::= '\[=' char '=\]' -> #equivalence
  let name = join(NoEmpty(a:elems), '')
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => equivalence class."
  call Debug('equivalence: ' . string(result))
  return result
endfunction "vimregextools#parser#equivalence

"collation() {{{1
function! vimregextools#parse#collation(elems) abort
  " collation ::= '\[\.' char '\.\]' -> #collation
  let name = join(NoEmpty(a:elems), '')
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => collation element."
  call Debug('collation: ' . string(result))
  return result
endfunction "vimregextools#parser#collation

"back_reference() {{{1
function! vimregextools#parse#back_reference(elems) abort
  " back_reference ::= '\\[1-9]' -> #back_reference
  let name = '\'.a:elems[1]
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => back-reference to captured group ".a:elems[1]."."
  call Debug('back_reference: ' . string(result))
  "return 'Back-reference number '.result[-1:]
  return result
endfunction "vimregextools#parser#back_reference

"last_substitution() {{{1
function! vimregextools#parse#last_substitution(elems) abort
  " last_substitution ::= '\~' -> #last_substitution
  let name = '~'
  "let result = NoEmpty(a:elems)
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => last substitution."
  call Debug('last_substitution: ' . string(result))
  return result
endfunction "vimregextools#parser#last_substitution

"identifier() {{{1
function! vimregextools#parse#identifier(elems) abort
  " identifier ::= '\\i' -> #identifier
  let name = '\i'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => identifier (:help 'isident')."
  call Debug('identifier: ' . string(result))
  return result
endfunction "vimregextools#parser#identifier

"nl_or_identifier() {{{1
function! vimregextools#parse#nl_or_identifier(elems) abort
  " nl_or_identifier ::= '\\_i' -> #nl_or_identifier
  let name = '\_i'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => identifier (:help 'isident') or newline."
  call Debug('nl_or_identifier: ' . string(result))
  return result
endfunction "vimregextools#parser#nl_or_identifier

"identifier_no_digits() {{{1
function! vimregextools#parse#identifier_no_digits(elems) abort
  " identifier_no_digits ::= '\\I' -> #identifier_no_digits
  let name = '\I'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => identifier non-digit (:help 'isident')."
  call Debug('identifier_no_digits: ' . string(result))
  return result
endfunction "vimregextools#parser#identifier_no_digits

"nl_or_identifier_no_digits() {{{1
function! vimregextools#parse#nl_or_identifier_no_digits(elems) abort
  " nl_or_identifier_no_digits ::= '\\_I' -> #nl_or_identifier_no_digits
  let name = '\_I'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => identifier non-digit (:help 'isident') or newline."
  call Debug('nl_or_identifier_no_digits: ' . string(result))
  return result
endfunction "vimregextools#parser#nl_or_identifier_no_digits

"keyword() {{{1
function! vimregextools#parse#keyword(elems) abort
  " keyword ::= '\\k' -> #keyword
  let name = '\k'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => keyword (:help 'iskeyword')."
  call Debug('keyword: ' . string(result))
  return result
endfunction "vimregextools#parser#keyword

"nl_or_keyword() {{{1
function! vimregextools#parse#nl_or_keyword(elems) abort
  " nl_or_keyword ::= '\\_k' -> #nl_or_keyword
  let name = '\_k'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => keyword (:help 'iskeyword') or newline."
  call Debug('nl_or_keyword: ' . string(result))
  return result
endfunction "vimregextools#parser#nl_or_keyword

"non_keyword() {{{1
function! vimregextools#parse#non_keyword(elems) abort
  " non_keyword ::= '\\K' -> #non_keyword
  let name = '\K'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => non-keyword (:help 'iskeyword')."
  call Debug('non_keyword: ' . string(result))
  return result
endfunction "vimregextools#parser#non_keyword

"nl_or_non_keyword() {{{1
function! vimregextools#parse#nl_or_non_keyword(elems) abort
  " nl_or_non_keyword ::= '\\_K' -> #nl_or_non_keyword
  let name = '\_K'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => non-keyword (:help 'iskeyword') or newline."
  call Debug('nl_or_non_keyword: ' . string(result))
  return result
endfunction "vimregextools#parser#nl_or_non_keyword

"file_name() {{{1
function! vimregextools#parse#file_name(elems) abort
  " file_name ::= '\\f' -> #file_name
  let name = '\f'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => file-name (:help 'isfname')."
  call Debug('file_name: ' . string(result))
  return result
endfunction "vimregextools#parser#file_name

"nl_or_file_name() {{{1
function! vimregextools#parse#nl_or_file_name(elems) abort
  " nl_or_file_name ::= '\\_f' -> #nl_or_file_name
  let name = '\_f'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => file-name (:help 'isfname') or newline."
  call Debug('nl_or_file_name: ' . string(result))
  return result
endfunction "vimregextools#parser#nl_or_file_name

"file_name_no_digits() {{{1
function! vimregextools#parse#file_name_no_digits(elems) abort
  " file_name_no_digits ::= '\\F' -> #file_name_no_digits
  let name = '\F'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => file-name non-digit."
  call Debug('file_name_no_digits: ' . string(result))
  return result
endfunction "vimregextools#parser#file_name_no_digits

"nl_or_file_name_no_digits() {{{1
function! vimregextools#parse#nl_or_file_name_no_digits(elems) abort
  " nl_or_file_name_no_digits ::= '\\_F' -> #nl_or_file_name_no_digits
  let name = '\_F'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => file-name no-digit (:help 'isfname') or newline."
  call Debug('nl_or_file_name_no_digits: ' . string(result))
  return result
endfunction "vimregextools#parser#nl_or_file_name_no_digits

"printable() {{{1
function! vimregextools#parse#printable(elems) abort
  " printable ::= '\\p' -> #printable
  let name = '\p'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => printable (:help 'isprint')."
  call Debug('printable: ' . string(result))
  return result
endfunction "vimregextools#parser#printable

"nl_or_printable() {{{1
function! vimregextools#parse#nl_or_printable(elems) abort
  " nl_or_printable ::= '\\_p' -> #nl_or_printable
  let name = '\_p'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => printable (:help 'isprint') or newline."
  call Debug('nl_or_printable: ' . string(result))
  return result
endfunction "vimregextools#parser#nl_or_printable

"printable_no_digits() {{{1
function! vimregextools#parse#printable_no_digits(elems) abort
  " printable_no_digits ::= '\\P' -> #printable_no_digits
  let name = '\P'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => printable non-digit (:help 'isprint')."
  call Debug('printable_no_digits: ' . string(result))
  return result
endfunction "vimregextools#parser#printable_no_digits

"nl_or_printable_no_digits() {{{1
function! vimregextools#parse#nl_or_printable_no_digits(elems) abort
  " nl_or_printable_no_digits ::= '\\_P' -> #nl_or_printable_no_digits
  let name = '\_P'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => printable non-digit (:help 'isprint') or newline."
  call Debug('nl_or_printable_no_digits: ' . string(result))
  return result
endfunction "vimregextools#parser#nl_or_printable_no_digits

"whitespace() {{{1
function! vimregextools#parse#whitespace(elems) abort
  " whitespace ::= '\\s' -> #whitespace
  let name = '\s'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => whitespace."
  call Debug('whitespace: ' . string(result))
  return result
endfunction "vimregextools#parser#whitespace

"nl_or_whitespace() {{{1
function! vimregextools#parse#nl_or_whitespace(elems) abort
  " nl_or_whitespace ::= '\\_s' -> #nl_or_whitespace
  let name = '\_s'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => whitespace or newline."
  call Debug('nl_or_whitespace: ' . string(result))
  return result
endfunction "vimregextools#parser#nl_or_whitespace

"non_whitespace() {{{1
function! vimregextools#parse#non_whitespace(elems) abort
  " non_whitespace ::= '\\S' -> #non_whitespace
  let name = '\S'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => non-whitespace."
  call Debug('non_whitespace: ' . string(result))
  return result
endfunction "vimregextools#parser#non_whitespace

"nl_or_non_whitespace() {{{1
function! vimregextools#parse#nl_or_non_whitespace(elems) abort
  " nl_or_non_whitespace ::= '\\_S' -> #nl_or_non_whitespace
  let name = '\_S'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => non-whitespace or newline."
  call Debug('nl_or_non_whitespace: ' . string(result))
  return result
endfunction "vimregextools#parser#nl_or_non_whitespace

"digit() {{{1
function! vimregextools#parse#digit(elems) abort
  " digit ::= '\\d' -> #digit
  let name = '\d'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => digit [0-9]."
  call Debug('digit: ' . string(result))
  return result
endfunction "vimregextools#parser#digit

"nl_or_digit() {{{1
function! vimregextools#parse#nl_or_digit(elems) abort
  " nl_or_digit ::= '\\_d' -> #nl_or_digit
  let name = '\_d'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => digit [0-9] or newline."
  call Debug('nl_or_digit: ' . string(result))
  return result
endfunction "vimregextools#parser#nl_or_digit

"non_digit() {{{1
function! vimregextools#parse#non_digit(elems) abort
  " non_digit ::= '\\D' -> #non_digit
  let name = '\D'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => non-digit [^0-9]."
  call Debug('non_digit: ' . string(result))
  return result
endfunction "vimregextools#parser#non_digit

"nl_or_non_digit() {{{1
function! vimregextools#parse#nl_or_non_digit(elems) abort
  " nl_or_non_digit ::= '\\_D' -> #nl_or_non_digit
  let name = '\_D'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => non-digit [0-9] or newline."
  call Debug('nl_or_non_digit: ' . string(result))
  return result
endfunction "vimregextools#parser#nl_or_non_digit

"hex_digit() {{{1
function! vimregextools#parse#hex_digit(elems) abort
  " hex_digit ::= '\\x' -> #hex_digit
  let name = '\x'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => hex-digit [0-9a-f]."
  call Debug('hex_digit: ' . string(result))
  return result
endfunction "vimregextools#parser#hex_digit

"nl_or_hex_digit() {{{1
function! vimregextools#parse#nl_or_hex_digit(elems) abort
  " nl_or_hex_digit ::= '\\_x' -> #nl_or_hex_digit
  let name = '\_x'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => hex-digit [0-9a-f] or newline."
  call Debug('nl_or_hex_digit: ' . string(result))
  return result
endfunction "vimregextools#parser#nl_or_hex_digit

"non_hex_digit() {{{1
function! vimregextools#parse#non_hex_digit(elems) abort
  " non_hex_digit ::= '\\X' -> #non_hex_digit
  let name = '\X'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => non-hex-digit [^0-9a-f]."
  call Debug('non_hex_digit: ' . string(result))
  return result
endfunction "vimregextools#parser#non_hex_digit

"nl_or_non_hex_digit() {{{1
function! vimregextools#parse#nl_or_non_hex_digit(elems) abort
  " nl_or_non_hex_digit ::= '\\_X' -> #nl_or_non_hex_digit
  let name = '\_X'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => non-hex-digit [0-9a-f] or newline."
  call Debug('nl_or_non_hex_digit: ' . string(result))
  return result
endfunction "vimregextools#parser#nl_or_non_hex_digit

"octal_digit() {{{1
function! vimregextools#parse#octal_digit(elems) abort
  " octal_digit ::= '\\o' -> #octal_digit
  let name = '\o'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => octal-digit [0-7]."
  call Debug('octal_digit: ' . string(result))
  return result
endfunction "vimregextools#parser#octal_digit

"nl_or_octal_digit() {{{1
function! vimregextools#parse#nl_or_octal_digit(elems) abort
  " nl_or_octal_digit ::= '\\_o' -> #nl_or_octal_digit
  let name = '\_o'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => octal-digit ([0-7]) or newline."
  call Debug('nl_or_octal_digit: ' . string(result))
  return result
endfunction "vimregextools#parser#nl_or_octal_digit

"non_octal_digit() {{{1
function! vimregextools#parse#non_octal_digit(elems) abort
  " non_octal_digit ::= '\\O' -> #non_octal_digit
  let name = '\O'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => non-octal-digit ([^0-7])."
  call Debug('non_octal_digit: ' . string(result))
  return result
endfunction "vimregextools#parser#non_octal_digit

"nl_or_non_octal_digit() {{{1
function! vimregextools#parse#nl_or_non_octal_digit(elems) abort
  " nl_or_non_octal_digit ::= '\\_O' -> #nl_or_non_octal_digit
  let name = '\_O'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => non-octal-number ([0-7]) or newline."
  call Debug('nl_or_non_octal_digit: ' . string(result))
  return result
endfunction "vimregextools#parser#nl_or_non_octal_digit

"word() {{{1
function! vimregextools#parse#word(elems) abort
  " word ::= '\\w' -> #word
  let name = '\w'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => word ([a-zA-Z0-9_])."
  call Debug('word: ' . string(result))
  return result
endfunction "vimregextools#parser#word

"nl_or_word() {{{1
function! vimregextools#parse#nl_or_word(elems) abort
  " nl_or_word ::= '\\_w' -> #nl_or_word
  let name = '\_w'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => word ([a-zA-Z0-9_] or newline."
  call Debug('nl_or_word: ' . string(result))
  return result
endfunction "vimregextools#parser#nl_or_word

"non_word() {{{1
function! vimregextools#parse#non_word(elems) abort
  " non_word ::= '\\W' -> #non_word
  let name = '\W'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => non-word ([a-zA-Z0-9_])."
  call Debug('non_word: ' . string(result))
  return result
endfunction "vimregextools#parser#non_word

"nl_or_non_word() {{{1
function! vimregextools#parse#nl_or_non_word(elems) abort
  " nl_or_non_word ::= '\\_W' -> #nl_or_non_word
  let name = '\_W'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => non-word ([^a-zA-Z0-9_]) or newline."
  call Debug('nl_or_non_word: ' . string(result))
  return result
endfunction "vimregextools#parser#nl_or_non_word

"head() {{{1
function! vimregextools#parse#head(elems) abort
  " head ::= '\\h' -> #head
  let name = '\h'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => head ([a-zA-Z_])."
  call Debug('head: ' . string(result))
  return result
endfunction "vimregextools#parser#head

"nl_or_head() {{{1
function! vimregextools#parse#nl_or_head(elems) abort
  " nl_or_head ::= '\\_h' -> #nl_or_head
  let name = '\_h'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => head ([a-zA-Z_]) or newline."
  call Debug('nl_or_head: ' . string(result))
  return result
endfunction "vimregextools#parser#nl_or_head

"non_head() {{{1
function! vimregextools#parse#non_head(elems) abort
  " non_head ::= '\\H' -> #non_head
  let name = '\H'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => non-head ([^a-zA-Z_])."
  call Debug('non_head: ' . string(result))
  return result
endfunction "vimregextools#parser#non_head

"nl_or_non_head() {{{1
function! vimregextools#parse#nl_or_non_head(elems) abort
  " nl_or_non_head ::= '\\_H' -> #nl_or_non_head
  let name = '\_H'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => non-head (alpha or _) or newline."
  call Debug('nl_or_non_head: ' . string(result))
  return result
endfunction "vimregextools#parser#nl_or_non_head

"alpha() {{{1
function! vimregextools#parse#alpha(elems) abort
  " alpha ::= '\\a' -> #alpha
  let name = '\a'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => alphabetic."
  call Debug('alpha: ' . string(result))
  return result
endfunction "vimregextools#parser#alpha

"nl_or_alpha() {{{1
function! vimregextools#parse#nl_or_alpha(elems) abort
  " nl_or_alpha ::= '\\_a' -> #nl_or_alpha
  let name = '\_a'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => alphabetic or newline."
  call Debug('nl_or_alpha: ' . string(result))
  return result
endfunction "vimregextools#parser#nl_or_alpha

"non_alpha() {{{1
function! vimregextools#parse#non_alpha(elems) abort
  " non_alpha ::= '\\A' -> #non_alpha
  let name = '\A'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => non-alphabetic."
  call Debug('non_alpha: ' . string(result))
  return result
endfunction "vimregextools#parser#non_alpha

"nl_or_non_alpha() {{{1
function! vimregextools#parse#nl_or_non_alpha(elems) abort
  " nl_or_non_alpha ::= '\\_A' -> #nl_or_non_alpha
  let name = '\_A'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => non-alphabetic or newline."
  call Debug('nl_or_non_alpha: ' . string(result))
  return result
endfunction "vimregextools#parser#nl_or_non_alpha

"lowercase() {{{1
function! vimregextools#parse#lowercase(elems) abort
  " lowercase ::= '\\l' -> #lowercase
  let name = '\l'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => lowercase."
  call Debug('lowercase: ' . string(result))
  return result
endfunction "vimregextools#parser#lowercase

"nl_or_lowercase() {{{1
function! vimregextools#parse#nl_or_lowercase(elems) abort
  " nl_or_lowercase ::= '\\_l' -> #nl_or_lowercase
  let name = '\_l'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => lowercase or newline."
  call Debug('nl_or_lowercase: ' . string(result))
  return result
endfunction "vimregextools#parser#nl_or_lowercase

"non_lowercase() {{{1
function! vimregextools#parse#non_lowercase(elems) abort
  " non_lowercase ::= '\\L' -> #non_lowercase
  let name = '\L'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => non-lowercase."
  call Debug('non_lowercase: ' . string(result))
  return result
endfunction "vimregextools#parser#non_lowercase

"nl_or_non_lowercase() {{{1
function! vimregextools#parse#nl_or_non_lowercase(elems) abort
  " nl_or_non_lowercase ::= '\\_L' -> #nl_or_non_lowercase
  let name = '\_L'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => non-lowercase or newline."
  call Debug('nl_or_non_lowercase: ' . string(result))
  return result
endfunction "vimregextools#parser#nl_or_non_lowercase

"uppercase() {{{1
function! vimregextools#parse#uppercase(elems) abort
  " uppercase ::= '\\u' -> #uppercase
  let name = '\u'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => uppercase."
  call Debug('uppercase: ' . string(result))
  return result
endfunction "vimregextools#parser#uppercase

"nl_or_uppercase() {{{1
function! vimregextools#parse#nl_or_uppercase(elems) abort
  " nl_or_uppercase ::= '\\_u' -> #nl_or_uppercase
  let name = '\_u'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => uppercase or newline."
  call Debug('nl_or_uppercase: ' . string(result))
  return result
endfunction "vimregextools#parser#nl_or_uppercase

"non_uppercase() {{{1
function! vimregextools#parse#non_uppercase(elems) abort
  " non_uppercase ::= '\\U' -> #non_uppercase
  let name = '\U'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => non-uppercase."
  call Debug('non_uppercase: ' . string(result))
  return result
endfunction "vimregextools#parser#non_uppercase

"nl_or_non_uppercase() {{{1
function! vimregextools#parse#nl_or_non_uppercase(elems) abort
  " nl_or_non_uppercase ::= '\\_U' -> #nl_or_non_uppercase
  let name = '\_U'
  "let result = NoEmpty(a:elems)
  let result = IndentLvl() . name . " => non-uppercase or newline."
  call Debug('nl_or_non_uppercase: ' . string(result))
  return result
endfunction "vimregextools#parser#nl_or_non_uppercase

"chars() {{{1
function! vimregextools#parse#chars(elems) abort
  " chars ::= char + -> #chars
  "let name = 'chars'
  if type(a:elems) == type([])
    let name = join(a:elems, '')
  else
    let name = a:elems
  endif
  "let result = NoEmpty(a:elems)
  let plural = len(split(name, '\(<\a\+>\|.\)\zs')) == 1 ? '' : 's'
  let result = IndentLvl() . name . " => literal character" . plural . "."
  call Debug('chars: ' . string(result))
  return result "len(result) == 1 ? result[0] : result[1]
endfunction "vimregextools#parser#chars

"char() {{{1
function! vimregextools#parse#char(elems) abort
  " char ::= escaped_char | '[^\\[*.]' -> #char
  "let name = 'char'
  call Debug(string(a:elems))
  let result = type(a:elems) == type ('') ? a:elems : len(a:elems) == 1 ? a:elems[0] : a:elems[2]
  let result = substitute(result, ' ', '<Space>', 'g')
  "if type(a:elems[0]) == type([])
  "  let name = a:elems[0][1]
  "else
  "  let name = a:elems[0]
  "endif
  ""let result = NoEmpty(a:elems)
  "let result = IndentLvl() . name . " => literal character(s)."
  call Debug('char: ' . string(result))
  return result "len(result) == 1 ? result[0] : result[1]
endfunction "vimregextools#parser#char

"escaped_char() {{{1
function! vimregextools#parse#escaped_char(elems) abort
  " escaped_char ::= esc | tab | cr | bs | lb | '\\[^@%{}()]' -> #escaped_char
  let name = 'escaped_char'
  let result = NoEmpty(a:elems)
  call Debug('escaped_char: ' . string(result))
  return result
endfunction "vimregextools#parser#escaped_char

"esc() {{{1
function! vimregextools#parse#esc(elems) abort
  " esc ::= '\\e' -> #esc
  let name = '\e'
  "let result = NoEmpty(a:elems)
  let result = '<Esc>'
  call Debug('esc: ' . string(result))
  return result
endfunction "vimregextools#parser#esc

"tab() {{{1
function! vimregextools#parse#tab(elems) abort
  " tab ::= '\\t' -> #tab
  let name = '\t'
  "let result = NoEmpty(a:elems)
  let result = '<Tab>'
  call Debug('tab: ' . string(result))
  return result
endfunction "vimregextools#parser#tab

"cr() {{{1
function! vimregextools#parse#cr(elems) abort
  " cr ::= '\\r' -> #cr
  let name = '\r'
  "let result = NoEmpty(a:elems)
  let result = '<CR>'
  call Debug('cr: ' . string(result))
  return result
endfunction "vimregextools#parser#cr

"bs() {{{1
function! vimregextools#parse#bs(elems) abort
  " bs ::= '\\b' -> #bs
  let name = '\b'
  "let result = NoEmpty(a:elems)
  let result = '<BS>'
  call Debug('bs: ' . string(result))
  return result
endfunction "vimregextools#parser#bs

"lb() {{{1
function! vimregextools#parse#lb(elems) abort
  " lb ::= '\\n' -> #lb
  let name = '\n'
  "let result = NoEmpty(a:elems)
  let result = '<NL>'
  call Debug('lb: ' . string(result))
  return result
endfunction "vimregextools#parser#lb

"escape() {{{1
function! vimregextools#parse#escape(elems) abort
  " escape ::= '\\' -> #escape
  let name = 'escape'
  let result = NoEmpty(a:elems)
  call Debug('escape: ' . string(result))
  return result
endfunction "vimregextools#parser#escape

"eor() {{{1
function! vimregextools#parse#eor(elems) abort
  " eor ::= '$' -> #eor
  let name = 'eor'
  let result = NoEmpty(a:elems)
  call Debug('eor: ' . string(result))
  return result
endfunction "vimregextools#parser#eor

