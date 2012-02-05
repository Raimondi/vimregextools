" Vim syntax file
" Language:	%Language%
" Maintainer:	%Maintainer% <%Email%>
" Version:	%Version%
" Last Change:	%Date%
" License:	Vim License (see :help license)
" Location:	syntax/%Plugin_File%

" Quit when a (custom) syntax file was already loaded
if exists("b:current_syntax")
  finish
endif

" Allow use of line continuation.
let s:save_cpo = &cpo
set cpo&vim

syn match retestsRegex /^.\{-}\ze '\%(''\|[^']\)*' [01]$/ keepend
syn match retestsOutput /'\%(''\|[^']\)*'\ze [01]$/
syn match retestsValid /[01]$/
syn match retestsComment /^#.*/
syn keyword	retestsTodo	TODO FIXME XXX containedin=retestsComment

" Define the default highlighting.
" Only used when an item doesn't have highlighting yet
hi def link retestsRegex   Constant
hi def link retestsOutput  Normal
hi def link retestsValid   PreProc
hi def link retestsComment Comment
hi def link retestsTodo	   Todo

let b:current_syntax = "retests"

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: et sw=2
