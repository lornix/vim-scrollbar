##vim-scrollbar

An attempt to display a scrollbar with 'thumb' in curses-based vim.

Uses the 'sign' feature of vim to display a scrollbar on the left-hand side.

![Screenshot]
(screenshot-01.png)

When sourced, starts out enabled.

    let g:loaded_scrollbar=1             " prevents loading

Default settings, can be overridden

    let g:scrollbar_thumb='#'            " default char to draw thumb
    let g:scrollbar_clear='|'            " default char to draw non-thumb

    highlight Scrollbar_Clear ctermfg=green ctermbg=black guifg=green guibg=black cterm=none
    highlight Scrollbar_Thumb ctermfg=red   ctermbg=black guifg=red   guibg=black cterm=reverse

Default mapping to toggle the scrollbar on/off:

    map <leader>sb :call ToggleScrollbar()<cr>

L Nix <lornix@lornix.com>
