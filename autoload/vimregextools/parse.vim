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

"regexp() {{{1
function! vimregextools#parse#regexp(elems) abort
  " regexp ::= legal_flag ? pattern eor -> #regexp
  let result = NoEmpty(a:elems[:-2])
  echom 'regexp: ' . string(result)
  return result
endfunction "vimregextools#parser#regexp

"pattern() {{{1
function! vimregextools#parse#pattern(elems) abort
  " pattern ::= branch ( or branch ) * -> #pattern
  let result = NoEmpty(a:elems)
  echom 'pattern: ' . string(result)
  return result
endfunction "vimregextools#parser#pattern

"or() {{{1
function! vimregextools#parse#or(elems) abort
  " or ::= '\\|' -> #or
  let result = NoEmpty(a:elems)
  echom 'or: ' . string(result)
  return result
endfunction "vimregextools#parser#or

"branch() {{{1
function! vimregextools#parse#branch(elems) abort
  " branch ::= concat ( and concat ) * -> #branch
  let result = NoEmpty(a:elems)
  echom 'branch: ' . string(result)
  return result
endfunction "vimregextools#parser#branch

"and() {{{1
function! vimregextools#parse#and(elems) abort
  " and ::= '\\&' -> #and
  let result = NoEmpty(a:elems)
  echom 'and: ' . string(result)
  return result
endfunction "vimregextools#parser#and

"concat() {{{1
function! vimregextools#parse#concat(elems) abort
  " concat ::= piece + -> #concat
  let result = NoEmpty(a:elems)
  echom 'concat: ' . string(result)
  return result
endfunction "vimregextools#parser#concat

"piece() {{{1
function! vimregextools#parse#piece(elems) abort
  " piece ::= atom multi ? flag * -> #piece
  let result = NoEmpty(a:elems)
  echom 'piece: ' . string(result)
  return result
endfunction "vimregextools#parser#piece

"atom() {{{1
function! vimregextools#parse#atom(elems) abort
  " atom ::= flag * ( non_capture_group | capture_group | ordinary_atom )
  let result = NoEmpty(a:elems)
  echom 'atom: ' . string(result)
  return result
endfunction "vimregextools#parser#atom

"flag() {{{1
function! vimregextools#parse#flag(elems) abort
  " flag ::= case_flag | magic_flag | ignore_comb_chars -> #flag
  let result = NoEmpty(a:elems)
  echom 'flag: ' . string(result)
  return result
endfunction "vimregextools#parser#flag

"legal_flag() {{{1
function! vimregextools#parse#legal_flag(elems) abort
  " legal_flag ::= case_flag | ignore_comb_chars -> #legal_flag
  let result = NoEmpty(a:elems)
  echom 'legal_flag: ' . string(result)
  return result
endfunction "vimregextools#parser#legal_flag

"ignore_comb_chars() {{{1
function! vimregextools#parse#ignore_comb_chars(elems) abort
  " ignore_comb_chars ::= '\\Z' -> #ignore_comb_chars
  let result = NoEmpty(a:elems)
  echom 'ignore_comb_chars: ' . string(result)
  return result
endfunction "vimregextools#parser#ignore_comb_chars

"case_flag() {{{1
function! vimregextools#parse#case_flag(elems) abort
  " case_flag ::= ignore_case | match_case -> #case_flag
  let result = NoEmpty(a:elems)
  echom 'case_flag: ' . string(result)
  return result
endfunction "vimregextools#parser#case_flag

"ignore_case() {{{1
function! vimregextools#parse#ignore_case(elems) abort
  " ignore_case ::= '\\c' -> #ignore_case
  let result = NoEmpty(a:elems)
  echom 'ignore_case: ' . string(result)
  return result
endfunction "vimregextools#parser#ignore_case

"match_case() {{{1
function! vimregextools#parse#match_case(elems) abort
  " match_case ::= '\\C' -> #match_case
  let result = NoEmpty(a:elems)
  echom 'match_case: ' . string(result)
  return result
endfunction "vimregextools#parser#match_case

"magic_flag() {{{1
function! vimregextools#parse#magic_flag(elems) abort
  " magic_flag ::= magic | no_magic | very_magic | very_no_magic -> #magic_flag
  let result = NoEmpty(a:elems)
  echom 'magic_flag: ' . string(result)
  return result
endfunction "vimregextools#parser#magic_flag

"magic() {{{1
function! vimregextools#parse#magic(elems) abort
  " magic ::= '\\m' -> #magic
  let result = NoEmpty(a:elems)
  echom 'magic: ' . string(result)
  return result
endfunction "vimregextools#parser#magic

"no_magic() {{{1
function! vimregextools#parse#no_magic(elems) abort
  " no_magic ::= '\\M' -> #no_magic
  let result = NoEmpty(a:elems)
  echom 'no_magic: ' . string(result)
  return result
endfunction "vimregextools#parser#no_magic

"very_magic() {{{1
function! vimregextools#parse#very_magic(elems) abort
  " very_magic ::= '\\v' -> #very_magic
  let result = NoEmpty(a:elems)
  echom 'very_magic: ' . string(result)
  return result
endfunction "vimregextools#parser#very_magic

"very_no_magic() {{{1
function! vimregextools#parse#very_no_magic(elems) abort
  " very_no_magic ::= '\\V' -> #very_no_magic
  let result = NoEmpty(a:elems)
  echom 'very_no_magic: ' . string(result)
  return result
endfunction "vimregextools#parser#very_no_magic

"capture_group() {{{1
function! vimregextools#parse#capture_group(elems) abort
  " capture_group ::= open_capture_group pattern close_group -> #capture_group
  let result = NoEmpty(a:elems)
  echom 'capture_group: ' . string(result)
  return result
endfunction "vimregextools#parser#capture_group

"non_capture_group() {{{1
function! vimregextools#parse#non_capture_group(elems) abort
  " non_capture_group ::= open_non_capture_group pattern close_group -> #non_capture_group
  let result = NoEmpty(a:elems)
  echom 'non_capture_group: ' . string(result)
  return result
endfunction "vimregextools#parser#non_capture_group

"open_capture_group() {{{1
function! vimregextools#parse#open_capture_group(elems) abort
  " open_capture_group ::= '\\(' -> #open_capture_group
  let result = NoEmpty(a:elems)
  echom 'open_capture_group: ' . string(result)
  return result
endfunction "vimregextools#parser#open_capture_group

"open_non_capture_group() {{{1
function! vimregextools#parse#open_non_capture_group(elems) abort
  " open_non_capture_group ::= '\\%(' -> #open_non_capture_group
  let result = NoEmpty(a:elems)
  echom 'open_non_capture_group: ' . string(result)
  return result
endfunction "vimregextools#parser#open_non_capture_group

"close_group() {{{1
function! vimregextools#parse#close_group(elems) abort
  " close_group ::= '\\)' -> #close_group
  let result = NoEmpty(a:elems)
  echom 'close_group: ' . string(result)
  return result
endfunction "vimregextools#parser#close_group

"multi() {{{1
function! vimregextools#parse#multi(elems) abort
  " multi ::= star | plus | equal | question | curly | look_around -> #multi
  let result = NoEmpty(a:elems)
  echom 'multi: ' . string(result)
  return result
endfunction "vimregextools#parser#multi

"star() {{{1
function! vimregextools#parse#star(elems) abort
  " star ::= '*' -> #star
  let result = NoEmpty(a:elems)
  echom 'star: ' . string(result)
  return result
endfunction "vimregextools#parser#star

"plus() {{{1
function! vimregextools#parse#plus(elems) abort
  " plus ::= '\\+' -> #plus
  let result = NoEmpty(a:elems)
  echom 'plus: ' . string(result)
  return result
endfunction "vimregextools#parser#plus

"equal() {{{1
function! vimregextools#parse#equal(elems) abort
  " equal ::= '\\=' -> #equal
  let result = NoEmpty(a:elems)
  echom 'equal: ' . string(result)
  return result
endfunction "vimregextools#parser#equal

"question() {{{1
function! vimregextools#parse#question(elems) abort
  " question ::= '\\?' -> #question
  let result = NoEmpty(a:elems)
  echom 'question: ' . string(result)
  return result
endfunction "vimregextools#parser#question

"curly() {{{1
function! vimregextools#parse#curly(elems) abort
  " curly ::= start_curly ( greedy | non_greedy ) ? end_curly -> #curly
  let result = NoEmpty(a:elems)
  echom 'curly: ' . string(result)
  return result
endfunction "vimregextools#parser#curly

"start_curly() {{{1
function! vimregextools#parse#start_curly(elems) abort
  " start_curly ::= '\\{' -> #start_curly
  let result = NoEmpty(a:elems)
  echom 'start_curly: ' . string(result)
  return result
endfunction "vimregextools#parser#start_curly

"end_curly() {{{1
function! vimregextools#parse#end_curly(elems) abort
  " end_curly ::= escape ? '}' -> #end_curly
  let result = NoEmpty(a:elems)
  echom 'end_curly: ' . string(result)
  return result
endfunction "vimregextools#parser#end_curly

"non_greedy() {{{1
function! vimregextools#parse#non_greedy(elems) abort
  " non_greedy ::= '-' greedy ? -> #non_greedy
  let result = NoEmpty(a:elems)
  echom 'non_greedy: ' . string(result)
  return result
endfunction "vimregextools#parser#non_greedy

"greedy() {{{1
function! vimregextools#parse#greedy(elems) abort
  " greedy ::= lower ( ',' upper ) ? | ',' upper -> #greedy
  let result = NoEmpty(a:elems)
  echom 'greedy: ' . string(result)
  return result
endfunction "vimregextools#parser#greedy

"lower() {{{1
function! vimregextools#parse#lower(elems) abort
  " lower ::= number -> #lower
  let result = NoEmpty(a:elems)
  echom 'lower: ' . string(result)
  return result
endfunction "vimregextools#parser#lower

"upper() {{{1
function! vimregextools#parse#upper(elems) abort
  " upper ::= number -> #upper
  let result = NoEmpty(a:elems)
  echom 'upper: ' . string(result)
  return result
endfunction "vimregextools#parser#upper

"number() {{{1
function! vimregextools#parse#number(elems) abort
  " number ::= '\d\+' -> #number
  let result = NoEmpty(a:elems)
  echom 'number: ' . string(result)
  return result
endfunction "vimregextools#parser#number

"look_around() {{{1
function! vimregextools#parse#look_around(elems) abort
  " look_around ::= at_ahead | at_no_ahead | at_behind | at_no_behind | at_whole -> #at
  let result = NoEmpty(a:elems)
  echom 'look_around: ' . string(result)
  return result
endfunction "vimregextools#parser#look_around

"at_ahead() {{{1
function! vimregextools#parse#at_ahead(elems) abort
  " at_ahead ::= '\\@=' -> #at_ahead
  let result = NoEmpty(a:elems)
  echom 'at_ahead: ' . string(result)
  return result
endfunction "vimregextools#parser#at_ahead

"at_no_ahead() {{{1
function! vimregextools#parse#at_no_ahead(elems) abort
  " at_no_ahead ::= '\\@!' -> #at_no_ahead
  let result = NoEmpty(a:elems)
  echom 'at_no_ahead: ' . string(result)
  return result
endfunction "vimregextools#parser#at_no_ahead

"at_behind() {{{1
function! vimregextools#parse#at_behind(elems) abort
  " at_behind ::= '\\@<=' -> #at_behind
  let result = NoEmpty(a:elems)
  echom 'at_behind: ' . string(result)
  return result
endfunction "vimregextools#parser#at_behind

"at_no_behind() {{{1
function! vimregextools#parse#at_no_behind(elems) abort
  " at_no_behind ::= '\\@<!' -> #at_no_behind
  let result = NoEmpty(a:elems)
  echom 'at_no_behind: ' . string(result)
  return result
endfunction "vimregextools#parser#at_no_behind

"at_whole() {{{1
function! vimregextools#parse#at_whole(elems) abort
  " at_whole ::= '\\@>' -> #at_whole
  let result = NoEmpty(a:elems)
  echom 'at_whole: ' . string(result)
  return result
endfunction "vimregextools#parser#at_whole

"ordinary_atom() {{{1
function! vimregextools#parse#ordinary_atom(elems) abort
  " ordinary_atom ::= dot | nl_or_dot | anchor | char_class | collection | sequence | back_reference | last_substitution | char -> #ordinary_atom
  let result = NoEmpty(a:elems)
  echom 'ordinary_atom: ' . string(result)
  return result
endfunction "vimregextools#parser#ordinary_atom

"dot() {{{1
function! vimregextools#parse#dot(elems) abort
  " dot ::= '\.' -> #dot
  let result = NoEmpty(a:elems)
  echom 'dot: ' . string(result)
  return result
endfunction "vimregextools#parser#dot

"nl_or_dot() {{{1
function! vimregextools#parse#nl_or_dot(elems) abort
  " nl_or_dot ::= '\\_\.' -> #nl_or_dot
  let result = NoEmpty(a:elems)
  echom 'nl_or_dot: ' . string(result)
  return result
endfunction "vimregextools#parser#nl_or_dot

"anchor() {{{1
function! vimregextools#parse#anchor(elems) abort
  " anchor ::= bol | bol_any | eol | eol_any | bow | eow | zs | ze | bof | eof | visual | cursor | mark | line | column | virtual_column -> #anchor
  let result = NoEmpty(a:elems)
  echom 'anchor: ' . string(result)
  return result
endfunction "vimregextools#parser#anchor

"bol() {{{1
function! vimregextools#parse#bol(elems) abort
  " bol ::= '\^' -> #bol
  let result = NoEmpty(a:elems)
  echom 'bol: ' . string(result)
  return result
endfunction "vimregextools#parser#bol

"bol_any() {{{1
function! vimregextools#parse#bol_any(elems) abort
  " bol_any ::= '\\_\^' -> #bol_any
  let result = NoEmpty(a:elems)
  echom 'bol_any: ' . string(result)
  return result
endfunction "vimregextools#parser#bol_any

"eol() {{{1
function! vimregextools#parse#eol(elems) abort
  " eol ::= '\$' -> #eol
  let result = NoEmpty(a:elems)
  echom 'eol: ' . string(result)
  return result
endfunction "vimregextools#parser#eol

"eol_any() {{{1
function! vimregextools#parse#eol_any(elems) abort
  " eol_any ::= '\\_\$' -> #eol_any
  let result = NoEmpty(a:elems)
  echom 'eol_any: ' . string(result)
  return result
endfunction "vimregextools#parser#eol_any

"bow() {{{1
function! vimregextools#parse#bow(elems) abort
  " bow ::= '\\<' -> #bow
  let result = NoEmpty(a:elems)
  echom 'bow: ' . string(result)
  return result
endfunction "vimregextools#parser#bow

"eow() {{{1
function! vimregextools#parse#eow(elems) abort
  " eow ::= '\\>' -> #eow
  let result = NoEmpty(a:elems)
  echom 'eow: ' . string(result)
  return result
endfunction "vimregextools#parser#eow

"zs() {{{1
function! vimregextools#parse#zs(elems) abort
  " zs ::= '\\zs' -> #zs
  let result = NoEmpty(a:elems)
  echom 'zs: ' . string(result)
  return result
endfunction "vimregextools#parser#zs

"ze() {{{1
function! vimregextools#parse#ze(elems) abort
  " ze ::= '\\ze' -> #ze
  let result = NoEmpty(a:elems)
  echom 'ze: ' . string(result)
  return result
endfunction "vimregextools#parser#ze

"bof() {{{1
function! vimregextools#parse#bof(elems) abort
  " bof ::= '\\%\$' -> #bof
  let result = NoEmpty(a:elems)
  echom 'bof: ' . string(result)
  return result
endfunction "vimregextools#parser#bof

"eof() {{{1
function! vimregextools#parse#eof(elems) abort
  " eof ::= '\\%\^' -> #eof
  let result = NoEmpty(a:elems)
  echom 'eof: ' . string(result)
  return result
endfunction "vimregextools#parser#eof

"visual() {{{1
function! vimregextools#parse#visual(elems) abort
  " visual ::= '\\%V' -> #visual
  let result = NoEmpty(a:elems)
  echom 'visual: ' . string(result)
  return result
endfunction "vimregextools#parser#visual

"cursor() {{{1
function! vimregextools#parse#cursor(elems) abort
  " cursor ::= '\\%#' -> #cursor
  let result = NoEmpty(a:elems)
  echom 'cursor: ' . string(result)
  return result
endfunction "vimregextools#parser#cursor

"mark() {{{1
function! vimregextools#parse#mark(elems) abort
  " mark ::= '\\%''[[:alnum:]<>[\]''"^.(){}]' -> #mark
  let result = NoEmpty(a:elems)
  echom 'mark: ' . string(result)
  return result
endfunction "vimregextools#parser#mark

"line() {{{1
function! vimregextools#parse#line(elems) abort
  " line ::= '\\%\d\+l' -> #line
  let result = NoEmpty(a:elems)
  echom 'line: ' . string(result)
  return result
endfunction "vimregextools#parser#line

"column() {{{1
function! vimregextools#parse#column(elems) abort
  " column ::= '\\%\d\+c' -> #column
  let result = NoEmpty(a:elems)
  echom 'column: ' . string(result)
  return result
endfunction "vimregextools#parser#column

"virtual_column() {{{1
function! vimregextools#parse#virtual_column(elems) abort
  " virtual_column ::= '\\%\d\+v' -> #virtual_column
  let result = NoEmpty(a:elems)
  echom 'virtual_column: ' . string(result)
  return result
endfunction "vimregextools#parser#virtual_column

"char_class() {{{1
function! vimregextools#parse#char_class(elems) abort
  " char_class ::= identifier | identifier_no_digits | keyword | non_keyword | file_name | file_name_no_digits | printable | printable_no_digits | whitespace | non_whitespace | digit | non_digit | hex_digit | non_hex_digit | octal_digit | non_octal_digit | word | non_word | head | non_head | alpha | non_alpha | lowercase | non_lowercase | uppercase | non_uppercase | nl_or_identifier | nl_or_identifier_no_digits | nl_or_keyword | nl_or_non_keyword | nl_or_file_name | nl_or_file_name_no_digits | nl_or_printable | nl_or_printable_no_digits | nl_or_whitespace | nl_or_non_whitespace | nl_or_digit | nl_or_non_digit | nl_or_hex_digit | nl_or_non_hex_digit | nl_or_octal_digit | nl_or_non_octal_digit | nl_or_word | nl_or_non_word | nl_or_head | nl_or_non_head | nl_or_alpha | nl_or_non_alpha | nl_or_lowercase | nl_or_non_lowercase | nl_or_uppercase | nl_or_non_uppercase -> #char_class
  let result = NoEmpty(a:elems)
  echom 'char_class: ' . string(result)
  return result
endfunction "vimregextools#parser#char_class

"collection() {{{1
function! vimregextools#parse#collection(elems) abort
  " collection ::= start_collection caret ? ']' ? ( range | decimal_char | octal_char | hex_char_low | hex_char_medium | hex_char_high | bracket_class | equivalence | collation | coll_esc_char | !']' char ) * end_collection -> #collection
  let result = NoEmpty(a:elems)
  echom 'collection: ' . string(result)
  return result
endfunction "vimregextools#parser#collection

"start_collection() {{{1
function! vimregextools#parse#start_collection(elems) abort
  " start_collection ::= nl_or ? '\[' -> #start_collection
  let result = NoEmpty(a:elems)
  echom 'start_collection: ' . string(result)
  return result
endfunction "vimregextools#parser#start_collection

"end_collection() {{{1
function! vimregextools#parse#end_collection(elems) abort
  " end_collection ::= '\]' -> #end_collection
  let result = NoEmpty(a:elems)
  echom 'end_collection: ' . string(result)
  return result
endfunction "vimregextools#parser#end_collection

"nl_or() {{{1
function! vimregextools#parse#nl_or(elems) abort
  " nl_or ::= '\\_' -> #nl_or
  let result = NoEmpty(a:elems)
  echom 'nl_or: ' . string(result)
  return result
endfunction "vimregextools#parser#nl_or

"caret() {{{1
function! vimregextools#parse#caret(elems) abort
  " caret ::= '\^' -> #caret
  let result = NoEmpty(a:elems)
  echom 'caret: ' . string(result)
  return result
endfunction "vimregextools#parser#caret

"range() {{{1
function! vimregextools#parse#range(elems) abort
  " range ::= char '-' char -> #range
  let result = NoEmpty(a:elems)
  echom 'range: ' . string(result)
  return result
endfunction "vimregextools#parser#range

"decimal_char() {{{1
function! vimregextools#parse#decimal_char(elems) abort
  " decimal_char ::= '\\d\d\+' -> #decimal_char
  let result = NoEmpty(a:elems)
  echom 'decimal_char: ' . string(result)
  return result
endfunction "vimregextools#parser#decimal_char

"octal_char() {{{1
function! vimregextools#parse#octal_char(elems) abort
  " octal_char ::= '\\o[0-7]\{,4}' -> #octal_char
  let result = NoEmpty(a:elems)
  echom 'octal_char: ' . string(result)
  return result
endfunction "vimregextools#parser#octal_char

"hex_char_low() {{{1
function! vimregextools#parse#hex_char_low(elems) abort
  " hex_char_low ::= '\\x[0-9a-f]\{,2}' -> #hex_char_low
  let result = NoEmpty(a:elems)
  echom 'hex_char_low: ' . string(result)
  return result
endfunction "vimregextools#parser#hex_char_low

"hex_char_medium() {{{1
function! vimregextools#parse#hex_char_medium(elems) abort
  " hex_char_medium ::= '\\u[0-9a-f]\{,4}' -> #hex_char_medium
  let result = NoEmpty(a:elems)
  echom 'hex_char_medium: ' . string(result)
  return result
endfunction "vimregextools#parser#hex_char_medium

"hex_char_high() {{{1
function! vimregextools#parse#hex_char_high(elems) abort
  " hex_char_high ::= '\\U[0-9a-f]\{,8}' -> #hex_char_high
  let result = NoEmpty(a:elems)
  echom 'hex_char_high: ' . string(result)
  return result
endfunction "vimregextools#parser#hex_char_high

"bracket_class() {{{1
function! vimregextools#parse#bracket_class(elems) abort
  " bracket_class ::= '[:' ( bc_alpha | bc_alnum | bc_blank | bc_cntrl | bc_digit | bc_graph | bc_lower | bc_print | bc_punct | bc_space | bc_upper | bc_xdigit | bc_return | bc_tab | bc_escape | bc_backspace ) ':]' -> #bracket_class
  let result = NoEmpty(a:elems)
  echom 'bracket_class: ' . string(result)
  return result
endfunction "vimregextools#parser#bracket_class

"bc_alpha() {{{1
function! vimregextools#parse#bc_alpha(elems) abort
  " bc_alpha ::= 'alpha' -> #bc_alpha
  let result = NoEmpty(a:elems)
  echom 'bc_alpha: ' . string(result)
  return result
endfunction "vimregextools#parser#bc_alpha

"bc_alnum() {{{1
function! vimregextools#parse#bc_alnum(elems) abort
  " bc_alnum ::= 'alnum' -> #bc_alnum
  let result = NoEmpty(a:elems)
  echom 'bc_alnum: ' . string(result)
  return result
endfunction "vimregextools#parser#bc_alnum

"bc_blank() {{{1
function! vimregextools#parse#bc_blank(elems) abort
  " bc_blank ::= 'blank' -> #bc_blank
  let result = NoEmpty(a:elems)
  echom 'bc_blank: ' . string(result)
  return result
endfunction "vimregextools#parser#bc_blank

"bc_cntrl() {{{1
function! vimregextools#parse#bc_cntrl(elems) abort
  " bc_cntrl ::= 'cntrl' -> #bc_cntrl
  let result = NoEmpty(a:elems)
  echom 'bc_cntrl: ' . string(result)
  return result
endfunction "vimregextools#parser#bc_cntrl

"bc_digit() {{{1
function! vimregextools#parse#bc_digit(elems) abort
  " bc_digit ::= 'digit' -> #bc_digit
  let result = NoEmpty(a:elems)
  echom 'bc_digit: ' . string(result)
  return result
endfunction "vimregextools#parser#bc_digit

"bc_graph() {{{1
function! vimregextools#parse#bc_graph(elems) abort
  " bc_graph ::= 'graph' -> #bc_graph
  let result = NoEmpty(a:elems)
  echom 'bc_graph: ' . string(result)
  return result
endfunction "vimregextools#parser#bc_graph

"bc_lower() {{{1
function! vimregextools#parse#bc_lower(elems) abort
  " bc_lower ::= 'lower' -> #bc_lower
  let result = NoEmpty(a:elems)
  echom 'bc_lower: ' . string(result)
  return result
endfunction "vimregextools#parser#bc_lower

"bc_print() {{{1
function! vimregextools#parse#bc_print(elems) abort
  " bc_print ::= 'print' -> #bc_print
  let result = NoEmpty(a:elems)
  echom 'bc_print: ' . string(result)
  return result
endfunction "vimregextools#parser#bc_print

"bc_punct() {{{1
function! vimregextools#parse#bc_punct(elems) abort
  " bc_punct ::= 'punct' -> #bc_punct
  let result = NoEmpty(a:elems)
  echom 'bc_punct: ' . string(result)
  return result
endfunction "vimregextools#parser#bc_punct

"bc_space() {{{1
function! vimregextools#parse#bc_space(elems) abort
  " bc_space ::= 'space' -> #bc_space
  let result = NoEmpty(a:elems)
  echom 'bc_space: ' . string(result)
  return result
endfunction "vimregextools#parser#bc_space

"bc_upper() {{{1
function! vimregextools#parse#bc_upper(elems) abort
  " bc_upper ::= 'upper' -> #bc_upper
  let result = NoEmpty(a:elems)
  echom 'bc_upper: ' . string(result)
  return result
endfunction "vimregextools#parser#bc_upper

"bc_xdigit() {{{1
function! vimregextools#parse#bc_xdigit(elems) abort
  " bc_xdigit ::= 'xdigit' -> #bc_xdigit
  let result = NoEmpty(a:elems)
  echom 'bc_xdigit: ' . string(result)
  return result
endfunction "vimregextools#parser#bc_xdigit

"bc_return() {{{1
function! vimregextools#parse#bc_return(elems) abort
  " bc_return ::= 'return' -> #bc_return
  let result = NoEmpty(a:elems)
  echom 'bc_return: ' . string(result)
  return result
endfunction "vimregextools#parser#bc_return

"bc_tab() {{{1
function! vimregextools#parse#bc_tab(elems) abort
  " bc_tab ::= 'tab' -> #bc_tab
  let result = NoEmpty(a:elems)
  echom 'bc_tab: ' . string(result)
  return result
endfunction "vimregextools#parser#bc_tab

"bc_escape() {{{1
function! vimregextools#parse#bc_escape(elems) abort
  " bc_escape ::= 'escape' -> #bc_escape
  let result = NoEmpty(a:elems)
  echom 'bc_escape: ' . string(result)
  return result
endfunction "vimregextools#parser#bc_escape

"bc_backspace() {{{1
function! vimregextools#parse#bc_backspace(elems) abort
  " bc_backspace ::= 'backspace' -> #bc_backspace
  let result = NoEmpty(a:elems)
  echom 'bc_backspace: ' . string(result)
  return result
endfunction "vimregextools#parser#bc_backspace

"coll_char() {{{1
function! vimregextools#parse#coll_char(elems) abort
  " coll_char ::= '\\[^\]^\bdertnoUux-]' -> #coll_char
  let result = NoEmpty(a:elems)
  echom 'coll_char: ' . string(result)
  return result
endfunction "vimregextools#parser#coll_char

"sequence() {{{1
function! vimregextools#parse#sequence(elems) abort
  " sequence ::= start_sequence ']' ? ( collection | seq_char ) * end_sequence -> #sequence
  let result = NoEmpty(a:elems)
  echom 'sequence: ' . string(result)
  return result
endfunction "vimregextools#parser#sequence

"seq_char() {{{1
function! vimregextools#parse#seq_char(elems) abort
  " seq_char ::= seq_escaped_char | !']' '.' -> #seq_char
  let result = NoEmpty(a:elems)
  echom 'seq_char: ' . string(result)
  return result
endfunction "vimregextools#parser#seq_char

"seq_escaped_char() {{{1
function! vimregextools#parse#seq_escaped_char(elems) abort
  " seq_escaped_char ::= esc | tab | cr | bs | lb | '\\.' -> #seq_escaped_char
  let result = NoEmpty(a:elems)
  echom 'seq_escaped_char: ' . string(result)
  return result
endfunction "vimregextools#parser#seq_escaped_char

"start_sequence() {{{1
function! vimregextools#parse#start_sequence(elems) abort
  " start_sequence ::= '\\%[' -> #start_sequence
  let result = NoEmpty(a:elems)
  echom 'start_sequence: ' . string(result)
  return result
endfunction "vimregextools#parser#start_sequence

"end_sequence() {{{1
function! vimregextools#parse#end_sequence(elems) abort
  " end_sequence ::= '\]' -> #end_sequence
  let result = NoEmpty(a:elems)
  echom 'end_sequence: ' . string(result)
  return result
endfunction "vimregextools#parser#end_sequence

"equivalence() {{{1
function! vimregextools#parse#equivalence(elems) abort
  " equivalence ::= '\[=' char '=\]' -> #equivalence
  let result = NoEmpty(a:elems)
  echom 'equivalence: ' . string(result)
  return result
endfunction "vimregextools#parser#equivalence

"collation() {{{1
function! vimregextools#parse#collation(elems) abort
  " collation ::= '\[\.' char '\.\]' -> #collation
  let result = NoEmpty(a:elems)
  echom 'collation: ' . string(result)
  return result
endfunction "vimregextools#parser#collation

"back_reference() {{{1
function! vimregextools#parse#back_reference(elems) abort
  " back_reference ::= '\\[1-9]' -> #back_reference
  let result = NoEmpty(a:elems)
  echom 'back_reference: ' . string(result)
  return 'Back-reference number '.result[-1:]
  return result
endfunction "vimregextools#parser#back_reference

"last_substitution() {{{1
function! vimregextools#parse#last_substitution(elems) abort
  " last_substitution ::= '\~' -> #last_substitution
  let result = NoEmpty(a:elems)
  echom 'last_substitution: ' . string(result)
  return result
endfunction "vimregextools#parser#last_substitution

"identifier() {{{1
function! vimregextools#parse#identifier(elems) abort
  " identifier ::= '\\i' -> #identifier
  let result = NoEmpty(a:elems)
  echom 'identifier: ' . string(result)
  return result
endfunction "vimregextools#parser#identifier

"nl_or_identifier() {{{1
function! vimregextools#parse#nl_or_identifier(elems) abort
  " nl_or_identifier ::= '\\_i' -> #nl_or_identifier
  let result = NoEmpty(a:elems)
  echom 'nl_or_identifier: ' . string(result)
  return result
endfunction "vimregextools#parser#nl_or_identifier

"identifier_no_digits() {{{1
function! vimregextools#parse#identifier_no_digits(elems) abort
  " identifier_no_digits ::= '\\I' -> #identifier_no_digits
  let result = NoEmpty(a:elems)
  echom 'identifier_no_digits: ' . string(result)
  return result
endfunction "vimregextools#parser#identifier_no_digits

"nl_or_identifier_no_digits() {{{1
function! vimregextools#parse#nl_or_identifier_no_digits(elems) abort
  " nl_or_identifier_no_digits ::= '\\_I' -> #nl_or_identifier_no_digits
  let result = NoEmpty(a:elems)
  echom 'nl_or_identifier_no_digits: ' . string(result)
  return result
endfunction "vimregextools#parser#nl_or_identifier_no_digits

"keyword() {{{1
function! vimregextools#parse#keyword(elems) abort
  " keyword ::= '\\k' -> #keyword
  let result = NoEmpty(a:elems)
  echom 'keyword: ' . string(result)
  return result
endfunction "vimregextools#parser#keyword

"nl_or_keyword() {{{1
function! vimregextools#parse#nl_or_keyword(elems) abort
  " nl_or_keyword ::= '\\_k' -> #nl_or_keyword
  let result = NoEmpty(a:elems)
  echom 'nl_or_keyword: ' . string(result)
  return result
endfunction "vimregextools#parser#nl_or_keyword

"non_keyword() {{{1
function! vimregextools#parse#non_keyword(elems) abort
  " non_keyword ::= '\\K' -> #non_keyword
  let result = NoEmpty(a:elems)
  echom 'non_keyword: ' . string(result)
  return result
endfunction "vimregextools#parser#non_keyword

"nl_or_non_keyword() {{{1
function! vimregextools#parse#nl_or_non_keyword(elems) abort
  " nl_or_non_keyword ::= '\\_K' -> #nl_or_non_keyword
  let result = NoEmpty(a:elems)
  echom 'nl_or_non_keyword: ' . string(result)
  return result
endfunction "vimregextools#parser#nl_or_non_keyword

"file_name() {{{1
function! vimregextools#parse#file_name(elems) abort
  " file_name ::= '\\f' -> #file_name
  let result = NoEmpty(a:elems)
  echom 'file_name: ' . string(result)
  return result
endfunction "vimregextools#parser#file_name

"nl_or_file_name() {{{1
function! vimregextools#parse#nl_or_file_name(elems) abort
  " nl_or_file_name ::= '\\_f' -> #nl_or_file_name
  let result = NoEmpty(a:elems)
  echom 'nl_or_file_name: ' . string(result)
  return result
endfunction "vimregextools#parser#nl_or_file_name

"file_name_no_digits() {{{1
function! vimregextools#parse#file_name_no_digits(elems) abort
  " file_name_no_digits ::= '\\F' -> #file_name_no_digits
  let result = NoEmpty(a:elems)
  echom 'file_name_no_digits: ' . string(result)
  return result
endfunction "vimregextools#parser#file_name_no_digits

"nl_or_file_name_no_digits() {{{1
function! vimregextools#parse#nl_or_file_name_no_digits(elems) abort
  " nl_or_file_name_no_digits ::= '\\_F' -> #nl_or_file_name_no_digits
  let result = NoEmpty(a:elems)
  echom 'nl_or_file_name_no_digits: ' . string(result)
  return result
endfunction "vimregextools#parser#nl_or_file_name_no_digits

"printable() {{{1
function! vimregextools#parse#printable(elems) abort
  " printable ::= '\\p' -> #printable
  let result = NoEmpty(a:elems)
  echom 'printable: ' . string(result)
  return result
endfunction "vimregextools#parser#printable

"nl_or_printable() {{{1
function! vimregextools#parse#nl_or_printable(elems) abort
  " nl_or_printable ::= '\\_p' -> #nl_or_printable
  let result = NoEmpty(a:elems)
  echom 'nl_or_printable: ' . string(result)
  return result
endfunction "vimregextools#parser#nl_or_printable

"printable_no_digits() {{{1
function! vimregextools#parse#printable_no_digits(elems) abort
  " printable_no_digits ::= '\\P' -> #printable_no_digits
  let result = NoEmpty(a:elems)
  echom 'printable_no_digits: ' . string(result)
  return result
endfunction "vimregextools#parser#printable_no_digits

"nl_or_printable_no_digits() {{{1
function! vimregextools#parse#nl_or_printable_no_digits(elems) abort
  " nl_or_printable_no_digits ::= '\\_P' -> #nl_or_printable_no_digits
  let result = NoEmpty(a:elems)
  echom 'nl_or_printable_no_digits: ' . string(result)
  return result
endfunction "vimregextools#parser#nl_or_printable_no_digits

"whitespace() {{{1
function! vimregextools#parse#whitespace(elems) abort
  " whitespace ::= '\\s' -> #whitespace
  let result = NoEmpty(a:elems)
  echom 'whitespace: ' . string(result)
  return result
endfunction "vimregextools#parser#whitespace

"nl_or_whitespace() {{{1
function! vimregextools#parse#nl_or_whitespace(elems) abort
  " nl_or_whitespace ::= '\\_s' -> #nl_or_whitespace
  let result = NoEmpty(a:elems)
  echom 'nl_or_whitespace: ' . string(result)
  return result
endfunction "vimregextools#parser#nl_or_whitespace

"non_whitespace() {{{1
function! vimregextools#parse#non_whitespace(elems) abort
  " non_whitespace ::= '\\S' -> #non_whitespace
  let result = NoEmpty(a:elems)
  echom 'non_whitespace: ' . string(result)
  return result
endfunction "vimregextools#parser#non_whitespace

"nl_or_non_whitespace() {{{1
function! vimregextools#parse#nl_or_non_whitespace(elems) abort
  " nl_or_non_whitespace ::= '\\_S' -> #nl_or_non_whitespace
  let result = NoEmpty(a:elems)
  echom 'nl_or_non_whitespace: ' . string(result)
  return result
endfunction "vimregextools#parser#nl_or_non_whitespace

"digit() {{{1
function! vimregextools#parse#digit(elems) abort
  " digit ::= '\\d' -> #digit
  let result = NoEmpty(a:elems)
  echom 'digit: ' . string(result)
  return result
endfunction "vimregextools#parser#digit

"nl_or_digit() {{{1
function! vimregextools#parse#nl_or_digit(elems) abort
  " nl_or_digit ::= '\\_d' -> #nl_or_digit
  let result = NoEmpty(a:elems)
  echom 'nl_or_digit: ' . string(result)
  return result
endfunction "vimregextools#parser#nl_or_digit

"non_digit() {{{1
function! vimregextools#parse#non_digit(elems) abort
  " non_digit ::= '\\D' -> #non_digit
  let result = NoEmpty(a:elems)
  echom 'non_digit: ' . string(result)
  return result
endfunction "vimregextools#parser#non_digit

"nl_or_non_digit() {{{1
function! vimregextools#parse#nl_or_non_digit(elems) abort
  " nl_or_non_digit ::= '\\_D' -> #nl_or_non_digit
  let result = NoEmpty(a:elems)
  echom 'nl_or_non_digit: ' . string(result)
  return result
endfunction "vimregextools#parser#nl_or_non_digit

"hex_digit() {{{1
function! vimregextools#parse#hex_digit(elems) abort
  " hex_digit ::= '\\x' -> #hex_digit
  let result = NoEmpty(a:elems)
  echom 'hex_digit: ' . string(result)
  return result
endfunction "vimregextools#parser#hex_digit

"nl_or_hex_digit() {{{1
function! vimregextools#parse#nl_or_hex_digit(elems) abort
  " nl_or_hex_digit ::= '\\_x' -> #nl_or_hex_digit
  let result = NoEmpty(a:elems)
  echom 'nl_or_hex_digit: ' . string(result)
  return result
endfunction "vimregextools#parser#nl_or_hex_digit

"non_hex_digit() {{{1
function! vimregextools#parse#non_hex_digit(elems) abort
  " non_hex_digit ::= '\\X' -> #non_hex_digit
  let result = NoEmpty(a:elems)
  echom 'non_hex_digit: ' . string(result)
  return result
endfunction "vimregextools#parser#non_hex_digit

"nl_or_non_hex_digit() {{{1
function! vimregextools#parse#nl_or_non_hex_digit(elems) abort
  " nl_or_non_hex_digit ::= '\\_X' -> #nl_or_non_hex_digit
  let result = NoEmpty(a:elems)
  echom 'nl_or_non_hex_digit: ' . string(result)
  return result
endfunction "vimregextools#parser#nl_or_non_hex_digit

"octal_digit() {{{1
function! vimregextools#parse#octal_digit(elems) abort
  " octal_digit ::= '\\o' -> #octal_digit
  let result = NoEmpty(a:elems)
  echom 'octal_digit: ' . string(result)
  return result
endfunction "vimregextools#parser#octal_digit

"nl_or_octal_digit() {{{1
function! vimregextools#parse#nl_or_octal_digit(elems) abort
  " nl_or_octal_digit ::= '\\_o' -> #nl_or_octal_digit
  let result = NoEmpty(a:elems)
  echom 'nl_or_octal_digit: ' . string(result)
  return result
endfunction "vimregextools#parser#nl_or_octal_digit

"non_octal_digit() {{{1
function! vimregextools#parse#non_octal_digit(elems) abort
  " non_octal_digit ::= '\\O' -> #non_octal_digit
  let result = NoEmpty(a:elems)
  echom 'non_octal_digit: ' . string(result)
  return result
endfunction "vimregextools#parser#non_octal_digit

"nl_or_non_octal_digit() {{{1
function! vimregextools#parse#nl_or_non_octal_digit(elems) abort
  " nl_or_non_octal_digit ::= '\\_O' -> #nl_or_non_octal_digit
  let result = NoEmpty(a:elems)
  echom 'nl_or_non_octal_digit: ' . string(result)
  return result
endfunction "vimregextools#parser#nl_or_non_octal_digit

"word() {{{1
function! vimregextools#parse#word(elems) abort
  " word ::= '\\w' -> #word
  let result = NoEmpty(a:elems)
  echom 'word: ' . string(result)
  return result
endfunction "vimregextools#parser#word

"nl_or_word() {{{1
function! vimregextools#parse#nl_or_word(elems) abort
  " nl_or_word ::= '\\_w' -> #nl_or_word
  let result = NoEmpty(a:elems)
  echom 'nl_or_word: ' . string(result)
  return result
endfunction "vimregextools#parser#nl_or_word

"non_word() {{{1
function! vimregextools#parse#non_word(elems) abort
  " non_word ::= '\\W' -> #non_word
  let result = NoEmpty(a:elems)
  echom 'non_word: ' . string(result)
  return result
endfunction "vimregextools#parser#non_word

"nl_or_non_word() {{{1
function! vimregextools#parse#nl_or_non_word(elems) abort
  " nl_or_non_word ::= '\\_W' -> #nl_or_non_word
  let result = NoEmpty(a:elems)
  echom 'nl_or_non_word: ' . string(result)
  return result
endfunction "vimregextools#parser#nl_or_non_word

"head() {{{1
function! vimregextools#parse#head(elems) abort
  " head ::= '\\h' -> #head
  let result = NoEmpty(a:elems)
  echom 'head: ' . string(result)
  return result
endfunction "vimregextools#parser#head

"nl_or_head() {{{1
function! vimregextools#parse#nl_or_head(elems) abort
  " nl_or_head ::= '\\_h' -> #nl_or_head
  let result = NoEmpty(a:elems)
  echom 'nl_or_head: ' . string(result)
  return result
endfunction "vimregextools#parser#nl_or_head

"non_head() {{{1
function! vimregextools#parse#non_head(elems) abort
  " non_head ::= '\\H' -> #non_head
  let result = NoEmpty(a:elems)
  echom 'non_head: ' . string(result)
  return result
endfunction "vimregextools#parser#non_head

"nl_or_non_head() {{{1
function! vimregextools#parse#nl_or_non_head(elems) abort
  " nl_or_non_head ::= '\\_H' -> #nl_or_non_head
  let result = NoEmpty(a:elems)
  echom 'nl_or_non_head: ' . string(result)
  return result
endfunction "vimregextools#parser#nl_or_non_head

"alpha() {{{1
function! vimregextools#parse#alpha(elems) abort
  " alpha ::= '\\a' -> #alpha
  let result = NoEmpty(a:elems)
  echom 'alpha: ' . string(result)
  return result
endfunction "vimregextools#parser#alpha

"nl_or_alpha() {{{1
function! vimregextools#parse#nl_or_alpha(elems) abort
  " nl_or_alpha ::= '\\_a' -> #nl_or_alpha
  let result = NoEmpty(a:elems)
  echom 'nl_or_alpha: ' . string(result)
  return result
endfunction "vimregextools#parser#nl_or_alpha

"non_alpha() {{{1
function! vimregextools#parse#non_alpha(elems) abort
  " non_alpha ::= '\\A' -> #non_alpha
  let result = NoEmpty(a:elems)
  echom 'non_alpha: ' . string(result)
  return result
endfunction "vimregextools#parser#non_alpha

"nl_or_non_alpha() {{{1
function! vimregextools#parse#nl_or_non_alpha(elems) abort
  " nl_or_non_alpha ::= '\\_A' -> #nl_or_non_alpha
  let result = NoEmpty(a:elems)
  echom 'nl_or_non_alpha: ' . string(result)
  return result
endfunction "vimregextools#parser#nl_or_non_alpha

"lowercase() {{{1
function! vimregextools#parse#lowercase(elems) abort
  " lowercase ::= '\\l' -> #lowercase
  let result = NoEmpty(a:elems)
  echom 'lowercase: ' . string(result)
  return result
endfunction "vimregextools#parser#lowercase

"nl_or_lowercase() {{{1
function! vimregextools#parse#nl_or_lowercase(elems) abort
  " nl_or_lowercase ::= '\\_l' -> #nl_or_lowercase
  let result = NoEmpty(a:elems)
  echom 'nl_or_lowercase: ' . string(result)
  return result
endfunction "vimregextools#parser#nl_or_lowercase

"non_lowercase() {{{1
function! vimregextools#parse#non_lowercase(elems) abort
  " non_lowercase ::= '\\L' -> #non_lowercase
  let result = NoEmpty(a:elems)
  echom 'non_lowercase: ' . string(result)
  return result
endfunction "vimregextools#parser#non_lowercase

"nl_or_non_lowercase() {{{1
function! vimregextools#parse#nl_or_non_lowercase(elems) abort
  " nl_or_non_lowercase ::= '\\_L' -> #nl_or_non_lowercase
  let result = NoEmpty(a:elems)
  echom 'nl_or_non_lowercase: ' . string(result)
  return result
endfunction "vimregextools#parser#nl_or_non_lowercase

"uppercase() {{{1
function! vimregextools#parse#uppercase(elems) abort
  " uppercase ::= '\\u' -> #uppercase
  let result = NoEmpty(a:elems)
  echom 'uppercase: ' . string(result)
  return result
endfunction "vimregextools#parser#uppercase

"nl_or_uppercase() {{{1
function! vimregextools#parse#nl_or_uppercase(elems) abort
  " nl_or_uppercase ::= '\\_u' -> #nl_or_uppercase
  let result = NoEmpty(a:elems)
  echom 'nl_or_uppercase: ' . string(result)
  return result
endfunction "vimregextools#parser#nl_or_uppercase

"non_uppercase() {{{1
function! vimregextools#parse#non_uppercase(elems) abort
  " non_uppercase ::= '\\U' -> #non_uppercase
  let result = NoEmpty(a:elems)
  echom 'non_uppercase: ' . string(result)
  return result
endfunction "vimregextools#parser#non_uppercase

"nl_or_non_uppercase() {{{1
function! vimregextools#parse#nl_or_non_uppercase(elems) abort
  " nl_or_non_uppercase ::= '\\_U' -> #nl_or_non_uppercase
  let result = NoEmpty(a:elems)
  echom 'nl_or_non_uppercase: ' . string(result)
  return result
endfunction "vimregextools#parser#nl_or_non_uppercase

"char() {{{1
function! vimregextools#parse#char(elems) abort
  " char ::= escaped_char | '[^\\[*.]' -> #char
  let result = NoEmpty(a:elems)
  echom 'char: ' . string(result)
  return result
endfunction "vimregextools#parser#char

"escaped_char() {{{1
function! vimregextools#parse#escaped_char(elems) abort
  " escaped_char ::= esc | tab | cr | bs | lb | '\\[^@%{}()]' -> #escaped_char
  let result = NoEmpty(a:elems)
  echom 'escaped_char: ' . string(result)
  return result
endfunction "vimregextools#parser#escaped_char

"esc() {{{1
function! vimregextools#parse#esc(elems) abort
  " esc ::= '\\e' -> #esc
  let result = NoEmpty(a:elems)
  echom 'esc: ' . string(result)
  return result
endfunction "vimregextools#parser#esc

"tab() {{{1
function! vimregextools#parse#tab(elems) abort
  " tab ::= '\\t' -> #tab
  let result = NoEmpty(a:elems)
  echom 'tab: ' . string(result)
  return result
endfunction "vimregextools#parser#tab

"cr() {{{1
function! vimregextools#parse#cr(elems) abort
  " cr ::= '\\r' -> #cr
  let result = NoEmpty(a:elems)
  echom 'cr: ' . string(result)
  return result
endfunction "vimregextools#parser#cr

"bs() {{{1
function! vimregextools#parse#bs(elems) abort
  " bs ::= '\\b' -> #bs
  let result = NoEmpty(a:elems)
  echom 'bs: ' . string(result)
  return result
endfunction "vimregextools#parser#bs

"lb() {{{1
function! vimregextools#parse#lb(elems) abort
  " lb ::= '\\n' -> #lb
  let result = NoEmpty(a:elems)
  echom 'lb: ' . string(result)
  return result
endfunction "vimregextools#parser#lb

"escape() {{{1
function! vimregextools#parse#escape(elems) abort
  " escape ::= '\\' -> #escape
  let result = NoEmpty(a:elems)
  echom 'escape: ' . string(result)
  return result
endfunction "vimregextools#parser#escape

"eor() {{{1
function! vimregextools#parse#eor(elems) abort
  " eor ::= '$' -> #eor
  let result = NoEmpty(a:elems)
  echom 'eor: ' . string(result)
  return result
endfunction "vimregextools#parser#eor

