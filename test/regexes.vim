" Test RegEx strings.
call vimtest#StartTap()
let tests = readfile(expand('<sfile>:p:h') . '/regexes.txt')
call filter(tests, 'v:val !~ "^#\\|^\\s*$"')
" Plan to run a lot of tests.
call vimtap#Plan(len(tests) * 2)
"profile start /profile.txt
"profile func *
for test in tests
  let [__, re, value, match; _] = matchlist(test,
        \ "^\\(.\\{-}\\) \\('\\%(''\\|[^']\\)*'\\) \\([01]\\)$")
  " Run test:
  try
    silent let result = vimregextools#parse#match(re)
  catch
    call vimtap#Diag('Caught: '.v:exception)
  endtry
  " Did it parse the re?
  let msg = 'Parse /' . escape(re, '/') . '/ should '
        \ . (match ? '' : 'not ') . 'match.'
  call vimtap#Is(result.is_matched, match, msg)
  " Did it parse it as expected?
  let msg = 'Result of /' . escape(re, '/') . '/'
  call vimtap#Is(string(result.value), eval(value), msg)
endfor
call vimtest#Quit()
" vim:sw=2 et sts=2
