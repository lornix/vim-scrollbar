" Vim global plugin to display a curses scrollbar
" Version:      0.1.2
" Last Change:  2015 Jul 15
" Author:       Loni Nix <lornix@lornix.com>
"
" License:      Distributed under the same terms as Vim itself. See 
"               `:help license`

" Skip init if the loaded_scrollbar var is set.
if exists('g:loaded_scrollbar')
    finish
endif
let g:loaded_scrollbar=1

" Save cpoptions.
let s:save_cpoptions=&cpoptions
set cpoptions&vim

" Set what character gets displayed for normal vs scrollbar highlighted lines.
" Default to '#' for scrollbar, '|' for non-scrollbar.
if !exists('g:scrollbar_thumb')
    let g:scrollbar_thumb='#'
endif
if !exists('g:scrollbar_clear')
    let g:scrollbar_clear='|'
endif

" Set highlighting scheme.
highlight Scrollbar_Clear ctermfg=green ctermbg=black guifg=green guibg=black cterm=none
highlight Scrollbar_Thumb ctermfg=red   ctermbg=black guifg=red   guibg=black cterm=reverse

" Set signs we're goint to use. http://vimdoc.sourceforge.net/htmldoc/sign.html
exec "sign define sbclear text=".g:scrollbar_clear." texthl=Scrollbar_Clear"
exec "sign define sbthumb text=".g:scrollbar_thumb." texthl=Scrollbar_Thumb"

" Set up a default mapping to toggle the scrollbar (but only if user hasn't
" already done it). Default is <leader>sb.
if !hasmapto('ToggleScrollbar')
    map <silent> <unique> <leader>sb :call ToggleScrollbar()<cr>
endif

" Function to initialize the scrollbar's 'active' vars.
function! <sid>SetScrollbarActive()
    " Checks to ensure the active vars are set for global / this buffer.
    if !exists('b:scrollbar_active')
        if !exists('g:scrollbar_active')
            let g:scrollbar_active=1
        endif
        let b:scrollbar_active=g:scrollbar_active
    endif
endfunction
call <sid>SetScrollbarActive()

" Function to toggle the scrollbar.
function! ToggleScrollbar()
    call <sid>SetScrollbarActive()
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

" Set up autocmds to react to user input.
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

function! <sid>showScrollbar()
    call <sid>SetScrollbarActive()
    " not active, go away
    if g:scrollbar_active==0 || b:scrollbar_active==0
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

" Call setup if vars are set for 'active' scrollbar.
if g:scrollbar_active != 0
    call <sid>SetupScrollbar()
endif
"
" Restore cpoptions.
let &cpoptions=s:save_cpoptions
unlet s:save_cpoptions
"
" vim: set filetype=vim fileformat=unix expandtab softtabstop=4 shiftwidth=4 tabstop=8:
