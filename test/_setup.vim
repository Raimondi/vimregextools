" These paths work only if the tests scripts's repos are in the same folder as
" this repo.
"set verbose=20
let &rtp = expand('<sfile>:p:h:h:h').'/runVimTests,'.&rtp
let &rtp = expand('<sfile>:p:h:h:h').'/vimtap,'.&rtp
"so /Users/israel/Documents/Source/runVimTests/autoload/escapings.vim
"so /Users/israel/Documents/Source/runVimTests/autoload/vimtest.vim
"so /Users/israel/Documents/Source/vimtap/autoload/vimtap.vim
"let &rtp = expand('$HOME') . '/.vim/test/runVimTests,'.&rtp
"let &rtp = expand('$HOME') . '/.vim/test/vimtap,'.&rtp
let &rtp = expand('<sfile>:p:h:h:h').'/Vimpeg,'.&rtp.','.expand('<sfile>:p:h:h:h').'/Vimpeg/after'
let &rtp = expand('<sfile>:p:h:h').','.&rtp
