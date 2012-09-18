" Test RegEx strings.
echon "Starting tests...\r"
call vimtest#StartTap()
let tests = readfile(expand('<sfile>:p:h') . '/regexes.txt')
call filter(tests, 'v:val !~ "^#\\|^\\s*$"')
" Plan to run a lot of tests.
call vimtap#Plan(len(tests) * 2)
"profile start /profile.txt
"profile func *
let total = len(tests)
let current = 0
let list = []
for test in tests
  let current += 1
  echon 'Processing RE ' . current . ' of ' . total . ', ' . (current*100/total) . "% completed.\r"
  let [__, re, value, match; _] = matchlist(test,
        \ "^\\(.\\{-}\\) \\('\\%(''\\|[^']\\)*'\\) \\([01]\\)$")
  " Run test:
  try
    silent let result = vimregextools#parse#match(re)
  catch
    if !exists('result')
      let result = {}
    endif
    let diag = 'DIAG: /' . escape(re, '/') . '/ Caught: '.v:exception
  endtry
  call add(list, {'result': result, 're': re, 'expected': value, 'match': match})
  if exists('diag')
    call extend(list[-1], {'diag':diag})
    unlet diag
  endif
  unlet! result
endfor
for t in list
  "echo keys(t.result)
  if has_key(t, 'diag')
    call vimtap#Diag(t.diag)
  endif
  if !vimtap#Skip(1, !empty(t.result), 'Parsing: "result" was not defined: ' . escape(string(t), '\'))
    " Did it parse the re?
    let msg = '/' . escape(t.re, '/') . '/ should '
          \ . (t.match ? '' : 'not ') . 'be parsed.'
    call vimtap#Ok(t.result.is_matched == t.match, msg)
  endif
endfor
for t in list
  "echo keys(t.result)
  if has_key(t, 'diag')
    call vimtap#Diag(t.diag)
  endif
  if !vimtap#Skip(1, !empty(t.result), 'Output: "result" was not defined: ' . escape(string(t), '\'))
    " Did it parse it as expected?
    let msg = 'Result of /' . escape(t.re, '/') . '/'
    call vimtap#Is(string(t.result.value), eval(t.expected), msg)
  endif
endfor
for d in filter(list, 'has_key(v:val, "diag")')
  call vimtap#Diag(d.diag)
endfor
call vimtest#Quit()
" vim:sw=2 et sts=2
