" Parser compiled on Wed Feb  1 04:59:54 2012,
" with VimPEG v0.2 and VimPEG Compiler v0.1
" from "parser.vimpeg"
" with the following grammar:

" ; Vim regular expression parser
" 
" .skip_white   = false
" .namespace    = 'vimregextools#parse'
" .parser_name  = 'vimregextools#parser#now'
" .root_element = 'regexp'
" .ignore_case  = false
" .debug        = true
" .verbose      = 0
" 
" regexp                 ::= legal_flag ? pattern ? escape ? eor -> #regexp
" pattern                ::= branch ( or branch ) *   -> #pattern
" or                     ::= '\\|'                    -> #or
" branch                 ::= concat ( and concat ) *  -> #branch
" and                    ::= '\\&'                    -> #and
" concat                 ::= piece +                  -> #concat
" piece                  ::= atom multi ? flag *      -> #piece
" atom                   ::= flag * ( non_capture_group | capture_group | ordinary_atom )
" flag                   ::= case_flag | magic_flag | ignore_comb_chars -> #flag
" legal_flag             ::= case_flag | ignore_comb_chars -> #legal_flag
" ignore_comb_chars      ::= '\\Z'                         -> #ignore_comb_chars
" case_flag              ::= ignore_case | match_case      -> #case_flag
" ignore_case            ::= '\\c'                         -> #ignore_case
" match_case             ::= '\\C'                         -> #match_case
" magic_flag             ::= magic | no_magic | very_magic | very_no_magic -> #magic_flag
" magic                  ::= '\\m' -> #magic
" no_magic               ::= '\\M' -> #no_magic
" very_magic             ::= '\\v' -> #very_magic
" very_no_magic          ::= '\\V' -> #very_no_magic
" capture_group          ::= open_capture_group pattern ? close_group -> #capture_group
" non_capture_group      ::= open_non_capture_group pattern ? close_group -> #non_capture_group
" open_capture_group     ::= '\\('  -> #open_capture_group
" open_non_capture_group ::= '\\%(' -> #open_non_capture_group
" close_group            ::= '\\)'  -> #close_group
" multi                  ::= star | plus | equal | question | curly | at -> #multi
" star                   ::= '*'   -> #star
" plus                   ::= '\\+' -> #plus
" equal                  ::= '\\=' -> #equal
" question               ::= '\\?' -> #question
" curly                  ::= start_curly ( greedy | non_greedy ) ? end_curly -> #curly
" start_curly            ::= '\\{'                             -> #start_curly
" end_curly              ::= escape ? '}'                      -> #end_curly
" non_greedy             ::= '-' greedy ?                      -> #non_greedy
" greedy                 ::= lower ( ',' upper ) ? | ',' upper -> #greedy
" lower                  ::= number                            -> #lower
" upper                  ::= number                            -> #upper
" number                 ::= '\d\+'                            -> #number
" at                     ::= at_ahead | at_no_ahead | at_behind | at_no_behind | at_whole -> #at
" at_ahead               ::= '\\@='  -> #at_ahead
" at_no_ahead            ::= '\\@!'  -> #at_no_ahead
" at_behind              ::= '\\@<=' -> #at_behind
" at_no_behind           ::= '\\@<!' -> #at_no_behind
" at_whole               ::= '\\@>'  -> #at_whole
" ordinary_atom          ::= dot | nl_or_dot | anchor | char_class | collection | sequence | back_reference | last_substitution | char -> #ordinary_atom
" dot                    ::= '\.'    -> #dot
" nl_or_dot              ::= '\\_\.' -> #nl_or_dot
" ; Anchors
" anchor         ::= bol | bol_any | eol | eol_any | bow | eow | zs | ze | bof | eof | visual | cursor | mark | line | column | virtual_column -> #anchor
" bol            ::= '\^'                             -> #bol
" bol_any        ::= '\\_\^'                          -> #bol_any
" eol            ::= '\$'                             -> #eol
" eol_any        ::= '\\_\$'                          -> #eol_any
" bow            ::= '\\<'                            -> #bow
" eow            ::= '\\>'                            -> #eow
" zs             ::= '\\zs'                           -> #zs
" ze             ::= '\\ze'                           -> #ze
" bof            ::= '\\%\$'                          -> #bof
" eof            ::= '\\%\^'                          -> #eof
" visual         ::= '\\%V'                           -> #visual
" cursor         ::= '\\%#'                           -> #cursor
" mark           ::= '\\%''[[:alnum:]<>[\]''"^.(){}]' -> #mark
" line           ::= '\\%\d\+l'                       -> #line
" column         ::= '\\%\d\+c'                       -> #column
" virtual_column ::= '\\%\d\+v'                       -> #virtual_column
" char_class     ::= identifier | identifier_no_digits | keyword | non_keyword | file_name | file_name_no_digits |  printable | printable_no_digits | whitespace | non_whitespace | digit | non_digit | hex_digit | non_hex_digit | octal_digit | non_octal_digit | word | non_word | head | non_head | alpha | non_alpha | lowercase | non_lowercase | uppercase | non_uppercase | nl_or_identifier | nl_or_identifier_no_digits | nl_or_keyword | nl_or_non_keyword | nl_or_file_name | nl_or_file_name_no_digits |  nl_or_printable | nl_or_printable_no_digits | nl_or_whitespace | nl_or_non_whitespace | nl_or_digit | nl_or_non_digit | nl_or_hex_digit | nl_or_non_hex_digit | nl_or_octal_digit | nl_or_non_octal_digit | nl_or_word | nl_or_non_word | nl_or_head | nl_or_non_head | nl_or_alpha | nl_or_non_alpha | nl_or_lowercase | nl_or_non_lowercase | nl_or_uppercase | nl_or_non_uppercase -> #char_class
" ; Collection
" collection       ::= start_collection caret ? ( ']' coll_inner * | coll_inner + ) end_collection -> #collection
" coll_inner       ::= range | decimal_char | octal_char | hex_char_low | hex_char_medium | hex_char_high | bracket_class | equivalence | collation | !']' coll_char
" start_collection ::= nl_or ? '\['       -> #start_collection
" end_collection   ::= '\]'               -> #end_collection
" nl_or            ::= '\\_'              -> #nl_or
" caret            ::= '\^'               -> #caret
" range            ::= char '-' char      -> #range
" decimal_char     ::= '\\d\d\+'          -> #decimal_char
" octal_char       ::= '\\o[0-7]\{1,4}'    -> #octal_char
" hex_char_low     ::= '\\x[0-9a-f]\{1,2}' -> #hex_char_low
" hex_char_medium  ::= '\\u[0-9a-f]\{1,4}' -> #hex_char_medium
" hex_char_high    ::= '\\U[0-9a-f]\{1,8}' -> #hex_char_high
" ; Bracket character classes
" bracket_class ::= '[:' ( bc_alpha | bc_alnum | bc_blank | bc_cntrl | bc_digit | bc_graph | bc_lower | bc_print | bc_punct | bc_space | bc_upper | bc_xdigit | bc_return | bc_tab | bc_escape | bc_backspace ) ':]' -> #bracket_class
" bc_alpha      ::= 'alpha'             -> #bc_alpha
" bc_alnum      ::= 'alnum'             -> #bc_alnum
" bc_blank      ::= 'blank'             -> #bc_blank
" bc_cntrl      ::= 'cntrl'             -> #bc_cntrl
" bc_digit      ::= 'digit'             -> #bc_digit
" bc_graph      ::= 'graph'             -> #bc_graph
" bc_lower      ::= 'lower'             -> #bc_lower
" bc_print      ::= 'print'             -> #bc_print
" bc_punct      ::= 'punct'             -> #bc_punct
" bc_space      ::= 'space'             -> #bc_space
" bc_upper      ::= 'upper'             -> #bc_upper
" bc_xdigit     ::= 'xdigit'            -> #bc_xdigit
" bc_return     ::= 'return'            -> #bc_return
" bc_tab        ::= 'tab'               -> #bc_tab
" bc_escape     ::= 'escape'            -> #bc_escape
" bc_backspace  ::= 'backspace'         -> #bc_backspace
" coll_char     ::= !end_collection ( '\\]' | '.' ) -> #coll_char
" ; Sequence
" sequence          ::= start_sequence ( collection | seq_char ) + end_sequence -> #sequence
" seq_char          ::= seq_escaped_char | !']' '.'      -> #seq_char
" seq_escaped_char  ::= esc | tab | cr | bs | lb | '\\.' -> #seq_escaped_char
" start_sequence    ::= '\\%['             -> #start_sequence
" end_sequence      ::= '\]'               -> #end_sequence
" equivalence       ::= '\[=' char '=\]'   -> #equivalence
" collation         ::= '\[\.' char '\.\]' -> #collation
" back_reference    ::= '\\[1-9]'          -> #back_reference
" last_substitution ::= '\~'               -> #last_substitution
" ; Character classes
" identifier                 ::= '\\i'  -> #identifier
" nl_or_identifier           ::= '\\_i' -> #nl_or_identifier
" identifier_no_digits       ::= '\\I'  -> #identifier_no_digits
" nl_or_identifier_no_digits ::= '\\_I' -> #nl_or_identifier_no_digits
" keyword                    ::= '\\k'  -> #keyword
" nl_or_keyword              ::= '\\_k' -> #nl_or_keyword
" non_keyword                ::= '\\K'  -> #non_keyword
" nl_or_non_keyword          ::= '\\_K' -> #nl_or_non_keyword
" file_name                  ::= '\\f'  -> #file_name
" nl_or_file_name            ::= '\\_f' -> #nl_or_file_name
" file_name_no_digits        ::= '\\F'  -> #file_name_no_digits
" nl_or_file_name_no_digits  ::= '\\_F' -> #nl_or_file_name_no_digits
" printable                  ::= '\\p'  -> #printable
" nl_or_printable            ::= '\\_p' -> #nl_or_printable
" printable_no_digits        ::= '\\P'  -> #printable_no_digits
" nl_or_printable_no_digits  ::= '\\_P' -> #nl_or_printable_no_digits
" whitespace                 ::= '\\s'  -> #whitespace
" nl_or_whitespace           ::= '\\_s' -> #nl_or_whitespace
" non_whitespace             ::= '\\S'  -> #non_whitespace
" nl_or_non_whitespace       ::= '\\_S' -> #nl_or_non_whitespace
" digit                      ::= '\\d'  -> #digit
" nl_or_digit                ::= '\\_d' -> #nl_or_digit
" non_digit                  ::= '\\D'  -> #non_digit
" nl_or_non_digit            ::= '\\_D' -> #nl_or_non_digit
" hex_digit                  ::= '\\x'  -> #hex_digit
" nl_or_hex_digit            ::= '\\_x' -> #nl_or_hex_digit
" non_hex_digit              ::= '\\X'  -> #non_hex_digit
" nl_or_non_hex_digit        ::= '\\_X' -> #nl_or_non_hex_digit
" octal_digit                ::= '\\o'  -> #octal_digit
" nl_or_octal_digit          ::= '\\_o' -> #nl_or_octal_digit
" non_octal_digit            ::= '\\O'  -> #non_octal_digit
" nl_or_non_octal_digit      ::= '\\_O' -> #nl_or_non_octal_digit
" word                       ::= '\\w'  -> #word
" nl_or_word                 ::= '\\_w' -> #nl_or_word
" non_word                   ::= '\\W'  -> #non_word
" nl_or_non_word             ::= '\\_W' -> #nl_or_non_word
" head                       ::= '\\h'  -> #head
" nl_or_head                 ::= '\\_h' -> #nl_or_head
" non_head                   ::= '\\H'  -> #non_head
" nl_or_non_head             ::= '\\_H' -> #nl_or_non_head
" alpha                      ::= '\\a'  -> #alpha
" nl_or_alpha                ::= '\\_a' -> #nl_or_alpha
" non_alpha                  ::= '\\A'  -> #non_alpha
" nl_or_non_alpha            ::= '\\_A' -> #nl_or_non_alpha
" lowercase                  ::= '\\l'  -> #lowercase
" nl_or_lowercase            ::= '\\_l' -> #nl_or_lowercase
" non_lowercase              ::= '\\L'  -> #non_lowercase
" nl_or_non_lowercase        ::= '\\_L' -> #nl_or_non_lowercase
" uppercase                  ::= '\\u'  -> #uppercase
" nl_or_uppercase            ::= '\\_u' -> #nl_or_uppercase
" non_uppercase              ::= '\\U'  -> #non_uppercase
" nl_or_non_uppercase        ::= '\\_U' -> #nl_or_non_uppercase
" ; Char
" char                       ::= escaped_char | '[^\\[.]' -> #char
" escaped_char               ::= esc | tab | cr | bs | lb | '\\[^+=?&|@%{}()]' -> #escaped_char
" 
" esc                        ::= '\\e' -> #esc
" tab                        ::= '\\t' -> #tab
" cr                         ::= '\\r' -> #cr
" bs                         ::= '\\b' -> #bs
" lb                         ::= '\\n' -> #lb
" escape                     ::= '\\'  -> #escape
" eor                        ::= '$'   -> #eor
" ; ['\C', [['\m', ['\%(', ['^', ['\|', '|']], '\)']], ['\s', '*'], '\zs', ['\%(', [['\<', 'f', 'u', ['\%[', ['n', 'c', 't', 'i', 'o', 'n'], ']'], '\>'], [['\|', ['\<', ['\%(', [['w', 'h', ['\%[', ['i', 'l', 'e'], ']']], ['\|', ['f', 'o', 'r']]], '\)'], '\>']], ['\|', ['\<', 'i', 'f', '\>']], ['\|', ['\<', 't', 'r', 'y', '\>']], ['\|', ['\<', 'a', 'u', 'g', ['\%[', ['r', 'o', 'u', 'p'], ']'], ['\s', '\+'], [['\%(', ['E', 'N', 'D', '\>'], '\)'], '\@!'], '\S']]]], '\)']]]

let s:p = vimpeg#parser({'root_element': 'regexp', 'skip_white': 0, 'ignore_case': 0, 'verbose': 0, 'parser_name': 'vimregextools#parser#now', 'namespace': 'vimregextools#parse', 'debug': 1})
call s:p.and([s:p.maybe_one('legal_flag'), s:p.maybe_one('pattern'), s:p.maybe_one('escape'), 'eor'],
      \{'id': 'regexp', 'on_match': 'vimregextools#parse#regexp'})
call s:p.and(['branch', s:p.maybe_many(s:p.and(['or', 'branch']))],
      \{'id': 'pattern', 'on_match': 'vimregextools#parse#pattern'})
call s:p.e('\\|',
      \{'id': 'or', 'on_match': 'vimregextools#parse#or'})
call s:p.and(['concat', s:p.maybe_many(s:p.and(['and', 'concat']))],
      \{'id': 'branch', 'on_match': 'vimregextools#parse#branch'})
call s:p.e('\\&',
      \{'id': 'and', 'on_match': 'vimregextools#parse#and'})
call s:p.many('piece',
      \{'id': 'concat', 'on_match': 'vimregextools#parse#concat'})
call s:p.and(['atom', s:p.maybe_one('multi'), s:p.maybe_many('flag')],
      \{'id': 'piece', 'on_match': 'vimregextools#parse#piece'})
call s:p.and([s:p.maybe_many('flag'), s:p.or(['non_capture_group', 'capture_group', 'ordinary_atom'])],
      \{'id': 'atom'})
call s:p.or(['case_flag', 'magic_flag', 'ignore_comb_chars'],
      \{'id': 'flag', 'on_match': 'vimregextools#parse#flag'})
call s:p.or(['case_flag', 'ignore_comb_chars'],
      \{'id': 'legal_flag', 'on_match': 'vimregextools#parse#legal_flag'})
call s:p.e('\\Z',
      \{'id': 'ignore_comb_chars', 'on_match': 'vimregextools#parse#ignore_comb_chars'})
call s:p.or(['ignore_case', 'match_case'],
      \{'id': 'case_flag', 'on_match': 'vimregextools#parse#case_flag'})
call s:p.e('\\c',
      \{'id': 'ignore_case', 'on_match': 'vimregextools#parse#ignore_case'})
call s:p.e('\\C',
      \{'id': 'match_case', 'on_match': 'vimregextools#parse#match_case'})
call s:p.or(['magic', 'no_magic', 'very_magic', 'very_no_magic'],
      \{'id': 'magic_flag', 'on_match': 'vimregextools#parse#magic_flag'})
call s:p.e('\\m',
      \{'id': 'magic', 'on_match': 'vimregextools#parse#magic'})
call s:p.e('\\M',
      \{'id': 'no_magic', 'on_match': 'vimregextools#parse#no_magic'})
call s:p.e('\\v',
      \{'id': 'very_magic', 'on_match': 'vimregextools#parse#very_magic'})
call s:p.e('\\V',
      \{'id': 'very_no_magic', 'on_match': 'vimregextools#parse#very_no_magic'})
call s:p.and(['open_capture_group', s:p.maybe_one('pattern'), 'close_group'],
      \{'id': 'capture_group', 'on_match': 'vimregextools#parse#capture_group'})
call s:p.and(['open_non_capture_group', s:p.maybe_one('pattern'), 'close_group'],
      \{'id': 'non_capture_group', 'on_match': 'vimregextools#parse#non_capture_group'})
call s:p.e('\\(',
      \{'id': 'open_capture_group', 'on_match': 'vimregextools#parse#open_capture_group'})
call s:p.e('\\%(',
      \{'id': 'open_non_capture_group', 'on_match': 'vimregextools#parse#open_non_capture_group'})
call s:p.e('\\)',
      \{'id': 'close_group', 'on_match': 'vimregextools#parse#close_group'})
call s:p.or(['star', 'plus', 'equal', 'question', 'curly', 'at'],
      \{'id': 'multi', 'on_match': 'vimregextools#parse#multi'})
call s:p.e('*',
      \{'id': 'star', 'on_match': 'vimregextools#parse#star'})
call s:p.e('\\+',
      \{'id': 'plus', 'on_match': 'vimregextools#parse#plus'})
call s:p.e('\\=',
      \{'id': 'equal', 'on_match': 'vimregextools#parse#equal'})
call s:p.e('\\?',
      \{'id': 'question', 'on_match': 'vimregextools#parse#question'})
call s:p.and(['start_curly', s:p.maybe_one(s:p.or(['greedy', 'non_greedy'])), 'end_curly'],
      \{'id': 'curly', 'on_match': 'vimregextools#parse#curly'})
call s:p.e('\\{',
      \{'id': 'start_curly', 'on_match': 'vimregextools#parse#start_curly'})
call s:p.and([s:p.maybe_one('escape'), s:p.e('}')],
      \{'id': 'end_curly', 'on_match': 'vimregextools#parse#end_curly'})
call s:p.and([s:p.e('-'), s:p.maybe_one('greedy')],
      \{'id': 'non_greedy', 'on_match': 'vimregextools#parse#non_greedy'})
call s:p.or([s:p.and(['lower', s:p.maybe_one(s:p.and([s:p.e(','), 'upper']))]), s:p.and([s:p.e(','), 'upper'])],
      \{'id': 'greedy', 'on_match': 'vimregextools#parse#greedy'})
call s:p.and(['number'],
      \{'id': 'lower', 'on_match': 'vimregextools#parse#lower'})
call s:p.and(['number'],
      \{'id': 'upper', 'on_match': 'vimregextools#parse#upper'})
call s:p.e('\d\+',
      \{'id': 'number', 'on_match': 'vimregextools#parse#number'})
call s:p.or(['at_ahead', 'at_no_ahead', 'at_behind', 'at_no_behind', 'at_whole'],
      \{'id': 'at', 'on_match': 'vimregextools#parse#at'})
call s:p.e('\\@=',
      \{'id': 'at_ahead', 'on_match': 'vimregextools#parse#at_ahead'})
call s:p.e('\\@!',
      \{'id': 'at_no_ahead', 'on_match': 'vimregextools#parse#at_no_ahead'})
call s:p.e('\\@<=',
      \{'id': 'at_behind', 'on_match': 'vimregextools#parse#at_behind'})
call s:p.e('\\@<!',
      \{'id': 'at_no_behind', 'on_match': 'vimregextools#parse#at_no_behind'})
call s:p.e('\\@>',
      \{'id': 'at_whole', 'on_match': 'vimregextools#parse#at_whole'})
call s:p.or(['dot', 'nl_or_dot', 'anchor', 'char_class', 'collection', 'sequence', 'back_reference', 'last_substitution', 'char'],
      \{'id': 'ordinary_atom', 'on_match': 'vimregextools#parse#ordinary_atom'})
call s:p.e('\.',
      \{'id': 'dot', 'on_match': 'vimregextools#parse#dot'})
call s:p.e('\\_\.',
      \{'id': 'nl_or_dot', 'on_match': 'vimregextools#parse#nl_or_dot'})
call s:p.or(['bol', 'bol_any', 'eol', 'eol_any', 'bow', 'eow', 'zs', 'ze', 'bof', 'eof', 'visual', 'cursor', 'mark', 'line', 'column', 'virtual_column'],
      \{'id': 'anchor', 'on_match': 'vimregextools#parse#anchor'})
call s:p.e('\^',
      \{'id': 'bol', 'on_match': 'vimregextools#parse#bol'})
call s:p.e('\\_\^',
      \{'id': 'bol_any', 'on_match': 'vimregextools#parse#bol_any'})
call s:p.e('\$',
      \{'id': 'eol', 'on_match': 'vimregextools#parse#eol'})
call s:p.e('\\_\$',
      \{'id': 'eol_any', 'on_match': 'vimregextools#parse#eol_any'})
call s:p.e('\\<',
      \{'id': 'bow', 'on_match': 'vimregextools#parse#bow'})
call s:p.e('\\>',
      \{'id': 'eow', 'on_match': 'vimregextools#parse#eow'})
call s:p.e('\\zs',
      \{'id': 'zs', 'on_match': 'vimregextools#parse#zs'})
call s:p.e('\\ze',
      \{'id': 'ze', 'on_match': 'vimregextools#parse#ze'})
call s:p.e('\\%\$',
      \{'id': 'bof', 'on_match': 'vimregextools#parse#bof'})
call s:p.e('\\%\^',
      \{'id': 'eof', 'on_match': 'vimregextools#parse#eof'})
call s:p.e('\\%V',
      \{'id': 'visual', 'on_match': 'vimregextools#parse#visual'})
call s:p.e('\\%#',
      \{'id': 'cursor', 'on_match': 'vimregextools#parse#cursor'})
call s:p.e('\\%''[[:alnum:]<>[\]''"^.(){}]',
      \{'id': 'mark', 'on_match': 'vimregextools#parse#mark'})
call s:p.e('\\%\d\+l',
      \{'id': 'line', 'on_match': 'vimregextools#parse#line'})
call s:p.e('\\%\d\+c',
      \{'id': 'column', 'on_match': 'vimregextools#parse#column'})
call s:p.e('\\%\d\+v',
      \{'id': 'virtual_column', 'on_match': 'vimregextools#parse#virtual_column'})
call s:p.or(['identifier', 'identifier_no_digits', 'keyword', 'non_keyword', 'file_name', 'file_name_no_digits', 'printable', 'printable_no_digits', 'whitespace', 'non_whitespace', 'digit', 'non_digit', 'hex_digit', 'non_hex_digit', 'octal_digit', 'non_octal_digit', 'word', 'non_word', 'head', 'non_head', 'alpha', 'non_alpha', 'lowercase', 'non_lowercase', 'uppercase', 'non_uppercase', 'nl_or_identifier', 'nl_or_identifier_no_digits', 'nl_or_keyword', 'nl_or_non_keyword', 'nl_or_file_name', 'nl_or_file_name_no_digits', 'nl_or_printable', 'nl_or_printable_no_digits', 'nl_or_whitespace', 'nl_or_non_whitespace', 'nl_or_digit', 'nl_or_non_digit', 'nl_or_hex_digit', 'nl_or_non_hex_digit', 'nl_or_octal_digit', 'nl_or_non_octal_digit', 'nl_or_word', 'nl_or_non_word', 'nl_or_head', 'nl_or_non_head', 'nl_or_alpha', 'nl_or_non_alpha', 'nl_or_lowercase', 'nl_or_non_lowercase', 'nl_or_uppercase', 'nl_or_non_uppercase'],
      \{'id': 'char_class', 'on_match': 'vimregextools#parse#char_class'})
call s:p.and(['start_collection', s:p.maybe_one('caret'), s:p.or([s:p.and([s:p.e(']'), s:p.maybe_many('coll_inner')]), s:p.many('coll_inner')]), 'end_collection'],
      \{'id': 'collection', 'on_match': 'vimregextools#parse#collection'})
call s:p.or(['range', 'decimal_char', 'octal_char', 'hex_char_low', 'hex_char_medium', 'hex_char_high', 'bracket_class', 'equivalence', 'collation', s:p.and([s:p.not_has(s:p.e(']')), 'coll_char'])],
      \{'id': 'coll_inner'})
call s:p.and([s:p.maybe_one('nl_or'), s:p.e('\[')],
      \{'id': 'start_collection', 'on_match': 'vimregextools#parse#start_collection'})
call s:p.e('\]',
      \{'id': 'end_collection', 'on_match': 'vimregextools#parse#end_collection'})
call s:p.e('\\_',
      \{'id': 'nl_or', 'on_match': 'vimregextools#parse#nl_or'})
call s:p.e('\^',
      \{'id': 'caret', 'on_match': 'vimregextools#parse#caret'})
call s:p.and(['char', s:p.e('-'), 'char'],
      \{'id': 'range', 'on_match': 'vimregextools#parse#range'})
call s:p.e('\\d\d\+',
      \{'id': 'decimal_char', 'on_match': 'vimregextools#parse#decimal_char'})
call s:p.e('\\o[0-7]\{1,4}',
      \{'id': 'octal_char', 'on_match': 'vimregextools#parse#octal_char'})
call s:p.e('\\x[0-9a-f]\{1,2}',
      \{'id': 'hex_char_low', 'on_match': 'vimregextools#parse#hex_char_low'})
call s:p.e('\\u[0-9a-f]\{1,4}',
      \{'id': 'hex_char_medium', 'on_match': 'vimregextools#parse#hex_char_medium'})
call s:p.e('\\U[0-9a-f]\{1,8}',
      \{'id': 'hex_char_high', 'on_match': 'vimregextools#parse#hex_char_high'})
call s:p.and([s:p.e('[:'), s:p.or(['bc_alpha', 'bc_alnum', 'bc_blank', 'bc_cntrl', 'bc_digit', 'bc_graph', 'bc_lower', 'bc_print', 'bc_punct', 'bc_space', 'bc_upper', 'bc_xdigit', 'bc_return', 'bc_tab', 'bc_escape', 'bc_backspace']), s:p.e(':]')],
      \{'id': 'bracket_class', 'on_match': 'vimregextools#parse#bracket_class'})
call s:p.e('alpha',
      \{'id': 'bc_alpha', 'on_match': 'vimregextools#parse#bc_alpha'})
call s:p.e('alnum',
      \{'id': 'bc_alnum', 'on_match': 'vimregextools#parse#bc_alnum'})
call s:p.e('blank',
      \{'id': 'bc_blank', 'on_match': 'vimregextools#parse#bc_blank'})
call s:p.e('cntrl',
      \{'id': 'bc_cntrl', 'on_match': 'vimregextools#parse#bc_cntrl'})
call s:p.e('digit',
      \{'id': 'bc_digit', 'on_match': 'vimregextools#parse#bc_digit'})
call s:p.e('graph',
      \{'id': 'bc_graph', 'on_match': 'vimregextools#parse#bc_graph'})
call s:p.e('lower',
      \{'id': 'bc_lower', 'on_match': 'vimregextools#parse#bc_lower'})
call s:p.e('print',
      \{'id': 'bc_print', 'on_match': 'vimregextools#parse#bc_print'})
call s:p.e('punct',
      \{'id': 'bc_punct', 'on_match': 'vimregextools#parse#bc_punct'})
call s:p.e('space',
      \{'id': 'bc_space', 'on_match': 'vimregextools#parse#bc_space'})
call s:p.e('upper',
      \{'id': 'bc_upper', 'on_match': 'vimregextools#parse#bc_upper'})
call s:p.e('xdigit',
      \{'id': 'bc_xdigit', 'on_match': 'vimregextools#parse#bc_xdigit'})
call s:p.e('return',
      \{'id': 'bc_return', 'on_match': 'vimregextools#parse#bc_return'})
call s:p.e('tab',
      \{'id': 'bc_tab', 'on_match': 'vimregextools#parse#bc_tab'})
call s:p.e('escape',
      \{'id': 'bc_escape', 'on_match': 'vimregextools#parse#bc_escape'})
call s:p.e('backspace',
      \{'id': 'bc_backspace', 'on_match': 'vimregextools#parse#bc_backspace'})
call s:p.and([s:p.not_has('end_collection'), s:p.or([s:p.e('\\]'), s:p.e('.')])],
      \{'id': 'coll_char', 'on_match': 'vimregextools#parse#coll_char'})
call s:p.and(['start_sequence', s:p.many(s:p.or(['collection', 'seq_char'])), 'end_sequence'],
      \{'id': 'sequence', 'on_match': 'vimregextools#parse#sequence'})
call s:p.or(['seq_escaped_char', s:p.and([s:p.not_has(s:p.e(']')), s:p.e('.')])],
      \{'id': 'seq_char', 'on_match': 'vimregextools#parse#seq_char'})
call s:p.or(['esc', 'tab', 'cr', 'bs', 'lb', s:p.e('\\.')],
      \{'id': 'seq_escaped_char', 'on_match': 'vimregextools#parse#seq_escaped_char'})
call s:p.e('\\%[',
      \{'id': 'start_sequence', 'on_match': 'vimregextools#parse#start_sequence'})
call s:p.e('\]',
      \{'id': 'end_sequence', 'on_match': 'vimregextools#parse#end_sequence'})
call s:p.and([s:p.e('\[='), 'char', s:p.e('=\]')],
      \{'id': 'equivalence', 'on_match': 'vimregextools#parse#equivalence'})
call s:p.and([s:p.e('\[\.'), 'char', s:p.e('\.\]')],
      \{'id': 'collation', 'on_match': 'vimregextools#parse#collation'})
call s:p.e('\\[1-9]',
      \{'id': 'back_reference', 'on_match': 'vimregextools#parse#back_reference'})
call s:p.e('\~',
      \{'id': 'last_substitution', 'on_match': 'vimregextools#parse#last_substitution'})
call s:p.e('\\i',
      \{'id': 'identifier', 'on_match': 'vimregextools#parse#identifier'})
call s:p.e('\\_i',
      \{'id': 'nl_or_identifier', 'on_match': 'vimregextools#parse#nl_or_identifier'})
call s:p.e('\\I',
      \{'id': 'identifier_no_digits', 'on_match': 'vimregextools#parse#identifier_no_digits'})
call s:p.e('\\_I',
      \{'id': 'nl_or_identifier_no_digits', 'on_match': 'vimregextools#parse#nl_or_identifier_no_digits'})
call s:p.e('\\k',
      \{'id': 'keyword', 'on_match': 'vimregextools#parse#keyword'})
call s:p.e('\\_k',
      \{'id': 'nl_or_keyword', 'on_match': 'vimregextools#parse#nl_or_keyword'})
call s:p.e('\\K',
      \{'id': 'non_keyword', 'on_match': 'vimregextools#parse#non_keyword'})
call s:p.e('\\_K',
      \{'id': 'nl_or_non_keyword', 'on_match': 'vimregextools#parse#nl_or_non_keyword'})
call s:p.e('\\f',
      \{'id': 'file_name', 'on_match': 'vimregextools#parse#file_name'})
call s:p.e('\\_f',
      \{'id': 'nl_or_file_name', 'on_match': 'vimregextools#parse#nl_or_file_name'})
call s:p.e('\\F',
      \{'id': 'file_name_no_digits', 'on_match': 'vimregextools#parse#file_name_no_digits'})
call s:p.e('\\_F',
      \{'id': 'nl_or_file_name_no_digits', 'on_match': 'vimregextools#parse#nl_or_file_name_no_digits'})
call s:p.e('\\p',
      \{'id': 'printable', 'on_match': 'vimregextools#parse#printable'})
call s:p.e('\\_p',
      \{'id': 'nl_or_printable', 'on_match': 'vimregextools#parse#nl_or_printable'})
call s:p.e('\\P',
      \{'id': 'printable_no_digits', 'on_match': 'vimregextools#parse#printable_no_digits'})
call s:p.e('\\_P',
      \{'id': 'nl_or_printable_no_digits', 'on_match': 'vimregextools#parse#nl_or_printable_no_digits'})
call s:p.e('\\s',
      \{'id': 'whitespace', 'on_match': 'vimregextools#parse#whitespace'})
call s:p.e('\\_s',
      \{'id': 'nl_or_whitespace', 'on_match': 'vimregextools#parse#nl_or_whitespace'})
call s:p.e('\\S',
      \{'id': 'non_whitespace', 'on_match': 'vimregextools#parse#non_whitespace'})
call s:p.e('\\_S',
      \{'id': 'nl_or_non_whitespace', 'on_match': 'vimregextools#parse#nl_or_non_whitespace'})
call s:p.e('\\d',
      \{'id': 'digit', 'on_match': 'vimregextools#parse#digit'})
call s:p.e('\\_d',
      \{'id': 'nl_or_digit', 'on_match': 'vimregextools#parse#nl_or_digit'})
call s:p.e('\\D',
      \{'id': 'non_digit', 'on_match': 'vimregextools#parse#non_digit'})
call s:p.e('\\_D',
      \{'id': 'nl_or_non_digit', 'on_match': 'vimregextools#parse#nl_or_non_digit'})
call s:p.e('\\x',
      \{'id': 'hex_digit', 'on_match': 'vimregextools#parse#hex_digit'})
call s:p.e('\\_x',
      \{'id': 'nl_or_hex_digit', 'on_match': 'vimregextools#parse#nl_or_hex_digit'})
call s:p.e('\\X',
      \{'id': 'non_hex_digit', 'on_match': 'vimregextools#parse#non_hex_digit'})
call s:p.e('\\_X',
      \{'id': 'nl_or_non_hex_digit', 'on_match': 'vimregextools#parse#nl_or_non_hex_digit'})
call s:p.e('\\o',
      \{'id': 'octal_digit', 'on_match': 'vimregextools#parse#octal_digit'})
call s:p.e('\\_o',
      \{'id': 'nl_or_octal_digit', 'on_match': 'vimregextools#parse#nl_or_octal_digit'})
call s:p.e('\\O',
      \{'id': 'non_octal_digit', 'on_match': 'vimregextools#parse#non_octal_digit'})
call s:p.e('\\_O',
      \{'id': 'nl_or_non_octal_digit', 'on_match': 'vimregextools#parse#nl_or_non_octal_digit'})
call s:p.e('\\w',
      \{'id': 'word', 'on_match': 'vimregextools#parse#word'})
call s:p.e('\\_w',
      \{'id': 'nl_or_word', 'on_match': 'vimregextools#parse#nl_or_word'})
call s:p.e('\\W',
      \{'id': 'non_word', 'on_match': 'vimregextools#parse#non_word'})
call s:p.e('\\_W',
      \{'id': 'nl_or_non_word', 'on_match': 'vimregextools#parse#nl_or_non_word'})
call s:p.e('\\h',
      \{'id': 'head', 'on_match': 'vimregextools#parse#head'})
call s:p.e('\\_h',
      \{'id': 'nl_or_head', 'on_match': 'vimregextools#parse#nl_or_head'})
call s:p.e('\\H',
      \{'id': 'non_head', 'on_match': 'vimregextools#parse#non_head'})
call s:p.e('\\_H',
      \{'id': 'nl_or_non_head', 'on_match': 'vimregextools#parse#nl_or_non_head'})
call s:p.e('\\a',
      \{'id': 'alpha', 'on_match': 'vimregextools#parse#alpha'})
call s:p.e('\\_a',
      \{'id': 'nl_or_alpha', 'on_match': 'vimregextools#parse#nl_or_alpha'})
call s:p.e('\\A',
      \{'id': 'non_alpha', 'on_match': 'vimregextools#parse#non_alpha'})
call s:p.e('\\_A',
      \{'id': 'nl_or_non_alpha', 'on_match': 'vimregextools#parse#nl_or_non_alpha'})
call s:p.e('\\l',
      \{'id': 'lowercase', 'on_match': 'vimregextools#parse#lowercase'})
call s:p.e('\\_l',
      \{'id': 'nl_or_lowercase', 'on_match': 'vimregextools#parse#nl_or_lowercase'})
call s:p.e('\\L',
      \{'id': 'non_lowercase', 'on_match': 'vimregextools#parse#non_lowercase'})
call s:p.e('\\_L',
      \{'id': 'nl_or_non_lowercase', 'on_match': 'vimregextools#parse#nl_or_non_lowercase'})
call s:p.e('\\u',
      \{'id': 'uppercase', 'on_match': 'vimregextools#parse#uppercase'})
call s:p.e('\\_u',
      \{'id': 'nl_or_uppercase', 'on_match': 'vimregextools#parse#nl_or_uppercase'})
call s:p.e('\\U',
      \{'id': 'non_uppercase', 'on_match': 'vimregextools#parse#non_uppercase'})
call s:p.e('\\_U',
      \{'id': 'nl_or_non_uppercase', 'on_match': 'vimregextools#parse#nl_or_non_uppercase'})
call s:p.or(['escaped_char', s:p.e('[^\\[.]')],
      \{'id': 'char', 'on_match': 'vimregextools#parse#char'})
call s:p.or(['esc', 'tab', 'cr', 'bs', 'lb', s:p.e('\\[^+=?&|@%{}()]')],
      \{'id': 'escaped_char', 'on_match': 'vimregextools#parse#escaped_char'})
call s:p.e('\\e',
      \{'id': 'esc', 'on_match': 'vimregextools#parse#esc'})
call s:p.e('\\t',
      \{'id': 'tab', 'on_match': 'vimregextools#parse#tab'})
call s:p.e('\\r',
      \{'id': 'cr', 'on_match': 'vimregextools#parse#cr'})
call s:p.e('\\b',
      \{'id': 'bs', 'on_match': 'vimregextools#parse#bs'})
call s:p.e('\\n',
      \{'id': 'lb', 'on_match': 'vimregextools#parse#lb'})
call s:p.e('\\',
      \{'id': 'escape', 'on_match': 'vimregextools#parse#escape'})
call s:p.e('$',
      \{'id': 'eor', 'on_match': 'vimregextools#parse#eor'})

let g:vimregextools#parser#now = s:p.GetSym('regexp')
