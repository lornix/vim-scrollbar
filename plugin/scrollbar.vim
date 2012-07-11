" Vim global plugin to display a curses scrollbar
" Version:      0.1.1
" Last Change:  2012 Jul 06
" Author:       Loni Nix <lornix@lornix.com>
"
" License:      TODO: Have to put something here
"
"
if exists('g:loaded_scrollbar')
    finish
endif
let g:loaded_scrollbar=1
"
" save cpoptions
let s:save_cpoptions=&cpoptions
set cpoptions&vim
"
" some global constants
if !exists('g:scrollbar_thumb')
    let g:scrollbar_thumb='#'
endif
if !exists('g:scrollbar_clear')
    let g:scrollbar_clear='|'
endif
"
"our highlighting scheme
highlight Scrollbar_Clear ctermfg=green ctermbg=black guifg=green guibg=black cterm=none
highlight Scrollbar_Thumb ctermfg=red   ctermbg=black guifg=red   guibg=black cterm=reverse
"
"the signs we're goint to use
exec "sign define sbclear text=".g:scrollbar_clear." texthl=Scrollbar_Clear"
exec "sign define sbthumb text=".g:scrollbar_thumb." texthl=Scrollbar_Thumb"
"
" set up a default mapping to toggle the scrollbar
" but only if user hasn't already done it
if !hasmapto('ToggleScrollbar')
    map <silent> <unique> <leader>sb :call <sid>ToggleScrollbar()<cr>
endif
"
" start out activated or not?
if !exists('s:scrollbar_active')
    " turn on overall
    let s:scrollbar_active=1
    " turn on for this buffer
    let b:scrollbar_active=1
endif
"
function! <sid>ToggleScrollbar()
    if b:scrollbar_active
        let b:scrollbar_active=0
        augroup Scrollbar_augroup
            autocmd!
        augroup END
        :sign unplace *
    else
        let b:scrollbar_active=1
        call <sid>SetupScrollbar()
    endif
endfunction

function! <sid>SetupScrollbar()
    augroup Scrollbar_augroup
        autocmd BufEnter     * :call <sid>showScrollbar()
        autocmd BufWinEnter  * :call <sid>showScrollbar()
        autocmd CursorHold   * :call <sid>showScrollbar()
        autocmd CursorHoldI  * :call <sid>showScrollbar()
        autocmd CursorMoved  * :call <sid>showScrollbar()
        autocmd CursorMovedI * :call <sid>showScrollbar()
        autocmd FocusGained  * :call <sid>showScrollbar()
        autocmd VimResized   * :call <sid>changeScreenSize()|:call <sid>showScrollbar()
    augroup END
    call <sid>showScrollbar()
endfunction
"
function! <sid>showScrollbar()
    " not active, go away
    if s:scrollbar_active==0 || b:scrollbar_active==0
        return
    endif
    "
    let bnum=bufnr("%")
    let total_lines=line('$')
    let current_line=line('.')
    let win_height=winheight(0)
    let win_start=line('w0')+0 "curious, this was only one had to be forced
    let clear_top=float2nr((current_line * win_height) / total_lines) - 1
    if clear_top < 0
        let clear_top=0
    elseif clear_top > (win_height - 1)
        let clear_top=win_height - 1
    endif
    let thumb_height=float2nr((win_height * win_height) / total_lines)
    if thumb_height < 1
        let thumb_height=1
    elseif thumb_height > win_height
        let thumb_height=win_height
    endif
    let thumb_height=thumb_height + clear_top
    let linectr=1
    while linectr <= clear_top
        let dest_line=win_start+linectr-1
        exec ":sign place ".dest_line." line=".dest_line." name=sbclear buffer=".bnum
        let linectr=linectr+1
    endwhile
    while linectr <= thumb_height
        let dest_line=win_start+linectr-1
        exec ":sign place ".dest_line." line=".dest_line." name=sbthumb buffer=".bnum
        let linectr=linectr+1
    endwhile
    while linectr <= win_height
        let dest_line=win_start+linectr-1
        exec ":sign place ".dest_line." line=".dest_line." name=sbclear buffer=".bnum
        let linectr=linectr+1
    endwhile
endfunction
"
" fire it up if we're 'active'
if s:scrollbar_active != 0
    call <sid>SetupScrollbar()
endif
"
" restore cpoptions
let &cpoptions=s:save_cpoptions
unlet s:save_cpoptions
"
" vim: set filetype=vim fileformat=unix expandtab softtabstop=4 shiftwidth=4 tabstop=8:
