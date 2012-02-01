" Test RegEx strings.
call vimtest#StartTap()
let tests = readfile(expand('<sfile>:p:h') . '/regexes.txt')
call filter(tests, 'v:val !~ "^#\\|^\\s*$"')
call map(tests, "split(v:val, '\\s\\ze\\d$')")
"call vimtap#Diag(string(tests))
" Plan to run a lot of tests.
call vimtap#Plan(len(tests))
for [re, match] in tests
  echo re
  silent let result = vimregextools#parser#now.match(re)
  let passed = match == result.is_matched
  let msg = '/'.escape(re, '/').'/ is '.(match ? '' : 'not ').'valid'
  call vimtap#Ok(passed,
        \ msg . ' => ' . string(result.value))
endfor
call vimtest#Quit()
