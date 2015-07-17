#vim-scrollbar

Displays a scrollbar with 'thumb' in curses-based vim (works in terminal).

Uses the 'sign' feature of vim to display a scrollbar on the left-hand side.

![Screenshot]
(screenshot-00.png)

## Settings

When sourced, starts out enabled.

    " Prevents loading.
    let g:loaded_scrollbar=1

Default settings, can be overridden.

    " Default characters to use in the scrollbar.
    let g:scrollbar_thumb='#'
    let g:scrollbar_clear='|'

    " Color settings.
    highlight Scrollbar_Clear ctermfg=green ctermbg=black guifg=green guibg=black cterm=none
    highlight Scrollbar_Thumb ctermfg=blue ctermbg=blue guifg=blue guibg=blue cterm=reverse

Default mapping to toggle the scrollbar on/off is <leader>sb. You can change
this by adding this line to your `.vimrc` and editing the mapping.

    map <leader>sb :call ToggleScrollbar()<cr>

## License
Distributed under the same terms as Vim itself. See `:help license`

## Contributors
Initial Author: Loni Nix <lornix@lornix.com>  
Maintainer: Sam Liu <sam@ambushnetworks.com>
