let &rtp = runvimtests_vimpeg . ',' . &rtp . ',' . runvimtests_vimpeg . '/after'
let &rtp = expand('<sfile>:p:h:h') . ',' . &rtp
