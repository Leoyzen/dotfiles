" You can enable the existing layers in space-vim and
" exclude the partial plugins in a certain layer.
" The command Layer and Exlcude are vaild in the function Layers().
function! Layers()

    " Default layers, recommended!
    Layer 'fzf'
    Layer 'file-manager'
    Layer 'unite'
    Layer 'better-defaults'
    Layer 'c-c++'
    Layer 'python'
    Layer 'javascript'
    Layer 'html'
    Layer 'ycmd'
    Layer 'programming'
    Layer 'airline'

endfunction

" Put your private plugins here.
function! UserInit()

    " Space has been set as the default leader key,
    " if you want to change it, uncomment and set it here.
     let g:spacevim_leader = ","
    " let g:spacevim_localleader = ','

    " Install private plugins
    " Plug 'extr0py/oni'
    Plug 'morhetz/gruvbox'
    Plug 'scrooloose/nerdcommenter'
    Plug 'zanglg/nova.vim'

endfunction

" Put your costom configurations here, e.g., change the colorscheme.
function! UserConfig()

    " If you enable airline layer and have installed the powerline fonts, set it here.
    " 字体设置
    let g:airline_powerline_fonts=1

    " 24位真彩色
    if has("termguicolors")
        let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
        let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
        set termguicolors
    endif

    " color nova
    color gruvbox
    " Copy
    set clipboard=unnamed
    set wrap
    " If you use vim inside tmux, see https://github.com/vim/vim/issues/993
    " " set Vim-specific sequences for RGB colors
    if has("gui_running")
        set guifont=Source\ Code\ Pro:h14
        if has("gui_gtk2")   "GTK2
            set guifont=Source\ Code\ Pro:h14
        endif
        set guioptions-=T
        set guioptions+=e
        set guioptions-=r
        set guioptions-=L
        set guitablabel=%M\ %t
        set showtabline=1
        set linespace=2
        set noimd
    endif

    "Keybinding
    " 使用方向键切换buffer
    noremap <left> :bp<CR>
    noremap <right> :bn<CR>
    nnoremap <Leader>n :NERDTreeToggle<CR>
    inoremap <Leader>n <ESC>:NERDTreeToggle<CR>

    

endfunction
