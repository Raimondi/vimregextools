" Test RegEx strings.
call vimtest#StartTap()
let tests = readfile(expand('<sfile>:p:h') . '/regexes.txt')
call filter(tests, 'v:val !~ "^#\\|^\\s*$"')
call map(tests, "split(v:val, '\\s\\ze\\d$')")
"call vimtap#Diag(string(tests))
" Plan to run a lot of tests.
call vimtap#Plan(len(tests))
"profile start /profile.txt
"profile func *
"echo vimregextools#parser#now
" Time wasted {{{
let len = len(tests)
let ccount = 0
let left = localtime() % 2
let object = left ? '<'.':'.'3'.' '.')'.'~'.'~'.'~'.'~' : '/'.'/'.'/'.'\'.'o'.'o'.'/'.'\'.'\'.'\'
let lenght = &co - (len(object) + 2) " }}}
for [re, match] in tests
  " More time wasted {{{
  let ccount += 1
  let progress = ((lenght * ccount) / len)
  echon
        \ repeat(' ', (left ? lenght - progress : progress)) .
        \ object .
        \ repeat(' ', (left ? progress : lenght - progress)) . "\r"
  "}}}
  " Run test:
  silent let result = vimregextools#parser#now.match(re)
  " Did it pass?
  let passed = match == result.is_matched
  " Report:
  let msg = '/'.escape(re, '/').'/ is '.(match ? '' : 'not ').'valid'
  call vimtap#Ok(passed,
        \ msg . ' => ' . string(result.value))
endfor
call vimtest#Quit()
