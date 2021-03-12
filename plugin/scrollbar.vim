" Vim global plugin to display a curses scrollbar
" Version:              0.2.1
" Last Change:          2016 Jun 05
" Initial Author:       Loni Nix <lornix@lornix.com>
" Contributors:         Samuel Chern-Shinn Liu <sam@ambushnetworks.com>
"
" License:              Distributed under the same terms as Vim itself. See
"                       `:help license`

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
" (User can override these!)
if !exists('g:scrollbar_thumb')
    let g:scrollbar_thumb='#'
endif
if !exists('g:scrollbar_clear')
    let g:scrollbar_clear='|'
endif

" Set highlighting scheme. (User can override these!)
highlight Scrollbar_Clear ctermfg=green ctermbg=black guifg=green guibg=black cterm=none
highlight Scrollbar_Thumb ctermfg=darkgreen ctermbg=darkgreen guifg=darkgreen guibg=black cterm=reverse

" Set signs we're goint to use. http://vimdoc.sourceforge.net/htmldoc/sign.html
exec "sign define sbclear text=".g:scrollbar_clear." texthl=Scrollbar_Clear"
exec "sign define sbthumb text=".g:scrollbar_thumb." texthl=Scrollbar_Thumb"

" Set up a default mapping to toggle the scrollbar (but only if user hasn't
" already done it). Default is <leader>sb.
if !hasmapto('ToggleScrollbar')
    map <silent> <unique> <leader>sb :call ToggleScrollbar()<cr>
endif

" Function to initialize the scrollbar's 'active' vars.
function! <sid>SetScrollbarActiveIfUninitialized()
    " Checks to ensure the active vars are set for global / this buffer.
    if !exists('b:scrollbar_active')
        if !exists('g:scrollbar_active')
            let g:scrollbar_active=1
        endif
        let b:scrollbar_active=g:scrollbar_active
    endif
    if !exists('g:scrollbar_binding_active')
        let g:scrollbar_binding_active=0
    endif
endfunction
call <sid>SetScrollbarActiveIfUninitialized()

" Function to toggle the scrollbar.
function! ToggleScrollbar()
    call <sid>SetScrollbarActiveIfUninitialized()

    let g:scrollbar_active = !g:scrollbar_active

    if b:scrollbar_active
        " Toggle to inactive mode.
        let b:scrollbar_active=0

        " Unset all autocmds for scrollbar.
        augroup Scrollbar_augroup
            autocmd!
        augroup END

        " Remove all signs that have been set.
        :sign unplace *
    else
        " Toggle to active. Setup the scrollbar.
        let b:scrollbar_active=1
        call <sid>SetupScrollbar()
    endif
endfunction

function RefreshScrollbar()
    call <sid>showScrollbar()
endfunction

" Set up autocmds to react to user input.
function! <sid>SetupScrollbar()
    augroup Scrollbar_augroup
        autocmd BufEnter     * :call <sid>showScrollbar()
        autocmd BufWinEnter  * :call <sid>showScrollbar()
        "autocmd CursorMoved  * :call <sid>showScrollbar()
        "autocmd CursorMovedI * :call <sid>showScrollbar()
        autocmd FocusGained  * :call <sid>showScrollbar()
        autocmd VimResized   * :call <sid>changeScreenSize()|:call <sid>showScrollbar()
    augroup END
    call <sid>showScrollbar()
endfunction

" Set up keybindings that update scrollbar state.
function! SetupScrollbarBindings()
    let g:scrollbar_binding_active=1
    " Trigger scrollbar refreshes with buffer-moving commands.
    :nnoremap <silent> <C-E> <C-E>:call RefreshScrollbar()<CR>
    :nnoremap <silent> <C-Y> <C-Y>:call RefreshScrollbar()<CR>

    :nnoremap <silent> <C-F> <C-F>:call RefreshScrollbar()<CR>
    :nnoremap <silent> <C-B> <C-B>:call RefreshScrollbar()<CR>

    :nnoremap <silent> <C-D> <C-D>:call RefreshScrollbar()<CR>
    :nnoremap <silent> <C-U> <C-U>:call RefreshScrollbar()<CR>

    :nnoremap <silent> j j:call RefreshScrollbar()<CR>
    :nnoremap <silent> k k:call RefreshScrollbar()<CR>

    :nnoremap <silent> N N:call RefreshScrollbar()<CR>
    :nnoremap <silent> n n:call RefreshScrollbar()<CR>

    :nnoremap <silent> <UP> <UP>:call RefreshScrollbar()<CR>
    :nnoremap <silent> <DOWN> <DOWN>:call RefreshScrollbar()<CR>
endfunction

" Main function that is called every time a user navigates the current buffer.
function! <sid>showScrollbar()
    call <sid>SetScrollbarActiveIfUninitialized()
    " Quit if the initialized active vars are set to false.
    if g:scrollbar_active==0 || b:scrollbar_active==0
        return
    endif

    " Buffer number.
    let buffer_number=bufnr("%")
    " Total # lines.
    let total_lines=line('$')
    " First line visible in the current window (at top of the buffer).
    let buffer_top=line('w0')
    " Last line visible in the current window. (at bottom of the buffer).
    let buffer_bottom=line('w$')
    " Text height.
    let text_height=buffer_bottom-buffer_top

    " If the window height is the same or greater than the total # of lines, we
    " don't need to show a scrollbar. The whole page is visible in the buffer!
    if winheight(0) >= total_lines
        return
    endif

    " Performance enhancer: don't redraw unless buffer window is changed.
    if !exists('b:buffer_top') || !exists('b:buffer_bottom')
        let b:buffer_top=buffer_top
        let b:buffer_bottom=buffer_bottom
    elseif b:buffer_top==buffer_top && b:buffer_bottom==buffer_bottom
        return
    else
        let b:buffer_top=buffer_top
        let b:buffer_bottom=buffer_bottom
    endif

    " How much padding at the top and bottom to give the scrollbar.
    let padding_top=float2nr(float2nr((buffer_top*1000 / total_lines) * text_height) / 1000)
    let padding_bottom=float2nr(float2nr(((total_lines - buffer_bottom)*1000 / total_lines) * text_height) / 1000)

    " Draw the signs based on the delimiters calculated above!
    let curr_line = buffer_top
    while curr_line <= buffer_bottom
        if curr_line >= (buffer_top+padding_top) && curr_line <= (buffer_bottom-padding_bottom)
            exec ":sign place ".curr_line." line=".curr_line." name=sbthumb buffer=".buffer_number
        else
            exec ":sign place ".curr_line." line=".curr_line." name=sbclear buffer=".buffer_number
        endif
        let curr_line=curr_line+1
    endwhile
endfunction

" Call setup if vars are set for 'active' scrollbar.
if g:scrollbar_active != 0
    call <sid>SetupScrollbar()
endif
if g:scrollbar_binding_active != 1
    call SetupScrollbarBindings()
endif
"
" Restore cpoptions.
let &cpoptions=s:save_cpoptions
unlet s:save_cpoptions
"
" vim: set filetype=vim fileformat=unix expandtab softtabstop=4 shiftwidth=4 tabstop=8:
