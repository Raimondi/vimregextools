" Test RegEx strings.
call vimtest#StartTap()
let tests = readfile(expand('<sfile>:p:h') . '/regexes.txt')
call filter(tests, 'v:val !~ "^#\\|^\\s*$"')
"call map(tests, "split(v:val, '\\s\\ze\\d$')")
"call vimtap#Diag(string(tests))
" Plan to run a lot of tests.
call vimtap#Plan(len(tests) * 2)
"profile start /profile.txt
"profile func *
"echo vimregextools#parser#now
" Time wasted {{{
let len = len(tests)
let ccount = 0
let left = localtime() % 2
let object = left ? '<'.':'.'3'.' '.')'.'~'.'~'.'~'.'~' : '/'.'/'.'/'.'\'.'o'.'o'.'/'.'\'.'\'.'\'
let lenght = &co - (len(object) + 2) " }}}
for test in tests
  " More time wasted {{{
  let ccount += 1
  let progress = ((lenght * ccount) / len)
  echon
        \ repeat(' ', (left ? lenght - progress : progress)) .
        \ object .
        \ repeat(' ', (left ? progress : lenght - progress)) . "\r"
  "}}}
  let re = matchstr(test, "^.\\{-}\\ze '\\%(''\\|[^']\\)*' [01]$")
  let value = matchstr(test, "^.\\{-} \\zs'\\%(''\\|[^']\\)*'\\ze [01]$")
  let match = matchstr(test, '[01]$')

  " Run test:
  silent let result = vimregextools#parse#match(re)

  " Did it parse the re?
  let passed = match == result.is_matched
  " Report:
  let msg = '/' . escape(re, '/') . '/ is ' . (match ? '' : 'not ') .
        \ 'valid and it was ' . (result.is_matched ? '' : 'not ') . 'matched.'
  call vimtap#Ok(passed, msg)

  " Did it parse it as expected?
  let passed = eval(value) == string(result.value)
  let msg = '/' . escape(re, '/') . '/ was ' . (passed ? '' : 'not ') .
        \ 'parsed as expected => ' . string(result.value)
  call vimtap#Ok(passed, msg)

endfor
call vimtest#Quit()
" vim:sw=2 et sts=2
