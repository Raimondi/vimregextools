" RegEx tests.
call vimtest#StartTAP()
echo &rtp
"let tests = readfile(expand('<sfile>:p:h') . '/regexes.txt')
"call filter(tests, 'v:val !~ "^#"')
"call map(tests, "split(v:val, '\\s\\ze\\d$')")
"call vimtap#Diag(string(tests))
" Plan to run a lot of tests.
"call vimtap#Plan(len(tests))
"for [re, ok] in tests
"  let result = vimregextools#parser#now.match(re)
"  call vimtap#OK(result.is_matched == ok, re . ' => ' . string(result.value))
"endfor
let result = vimregextools#parser#now.match('a')
call vimtap#OK(result.is_matched, 'a => ' . string(result.value))
call vimtest#Quit()
