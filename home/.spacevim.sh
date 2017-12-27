" You can enable the existing layers in space-vim and
" exclude the partial plugins in a certain layer.
" The command Layer and Exlcude are vaild in the function Layers().
function! Layers()

    " Default layers, recommended!
    Layer 'syntax-checking'
    Layer 'spacevim'
    Layer 'fzf'
    Layer 'file-manager'
    Layer 'emoji'
    Layer 'better-defaults'
    " Layer 'c-c++'
    Layer 'python'
    " Layer 'javascript'
    Layer 'docker'
    " Layer 'html'
    Layer 'auto-completion'
    " Layer 'ycmd'
    Layer 'git'
    Layer 'programming'
    Layer 'editing'
    Layer 'airline'
    Layer 'text-align'
    Layer 'better-motion'

endfunction

" Put your private plugins here.
function! UserInit()

    " Space has been set as the default leader key,
    " if you want to change it, uncomment and set it here.
    let g:spacevim_leader=","

    " Install private plugins
    Plug 'morhetz/gruvbox'
    Plug 'cocopon/iceberg.vim'
    Plug 'nanotech/jellybeans.vim'
    Plug 'ayu-theme/ayu-vim'
    " Plug 'roxma/nvim-cm-tern', {'do': 'npm install'}

endfunction

" Put your costom configurations here, e.g., change the colorscheme.
function! UserConfig()
    let g:gruvbox_contrast_dark="soft"
    let g:gruvbox_sign_column="bg4"
    let g:gruvbox_color_column="bg4"
    let g:gruvbox_vert_split="bg4"
    " let g:gruvbox_number_column="bg4"
    let g:gruvbox_improved_strings="1"
    let g:gruvbox_improved_warnings="1"
    " pymode
    let g:pymode_rope=0
    let g:pymode_rope_lookup_project=0
    let g:pymode_trim_whitespaces=1
    let g:pymode_python="python3"
    let g:pymode_options_max_line_length=120
    " let g:pymode_rope_goto_definition_bind="<C-g>"
    " let g:pymode_rope_goto_definition_cmd="vnew"

    " If you enable airline layer and have installed the powerline fonts, set it here.
    " 字体设置
    let g:airline_powerline_fonts=1
    " let g:airline_theme="gruvbox"
    let g:airline_theme="iceberg"
    " let g:airline_theme='jellybean'

    " autocmd FileType python setlocal colorcolumn=120
    set textwidth=179
    " set colorcolumn=179
    autocmd FileType python setlocal
                  \ foldmethod=indent
                  \ tabstop=4
                  \ shiftwidth=4
                  \ softtabstop=4
                  \ textwidth=179
                  \ expandtab
                  \ autoindent
                  \ fileformat=unix
                  \ colorcolumn=179
    " 始终使用4个空格
    " set pastetoggle=

    " 24位真彩色
		if (has("nvim"))
		" For Neovim 0.1.3 and 0.1.4 < https://github.com/neovim/neovim/pull/2198 >
			let $NVIM_TUI_ENABLE_TRUE_COLOR=1
		endif
		" For Neovim > 0.1.5 and Vim > patch 7.4.1799 < https://github.com/vim/vim/commit/61be73bb0f965a895bfb064ea3e55476ac175162 >
		" Based on Vim patch 7.4.1770 (`guicolors` option) < https://github.com/vim/vim/commit/8a633e3427b47286869aa4b96f2bfc1fe65b25cd >
		" < https://github.com/neovim/neovim/wiki/Following-HEAD#20160511 >
		if (has("termguicolors"))
			let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
			let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
			set termguicolors
		endif

    " color tener
    " color gruvbox
    " color iceberg
    " color jellybeans
    " let ayucolor="light"  " for light version of theme
    " let ayucolor="mirage" " for mirage version of theme
    let ayucolor="dark"   " for dark version of theme
    colorscheme ayu
    " Copy
    " set background=dark
    set background=dark
    " color hybrid_reverse
    set wrap
    " If you use vim inside tmux, see https://github.com/vim/vim/issues/993
    " " set Vim-specific sequences for RGB colors
    " set macligatures
    if has("gui_running")
      if has("gui_gtk2")   "GTK2
          set guifont=Fira\ Code\ Medium:h14
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

    " 使用方向键切换buffer
    nnoremap ; :
    noremap <left> :bp<CR>
    noremap <right> :bn<CR>
    nnoremap <Leader>n :NERDTreeToggle<CR>
    inoremap <Leader>n <ESC>:NERDTreeToggle<CR>
    " let g:python_host_prog = '/home/.pyenv/versions/madmed2/bin/python'
    let g:python3_host_prog = '$HOME/.pyenv/versions/madmed/bin/python3.6'

    " Python-Mode
    set mouse=a

		let g:fzf_colors =
			\ { 'fg':      ['fg', 'Normal'],
			\ 'bg':      ['bg', 'Normal'],
			\ 'hl':      ['fg', 'Comment'],
			\ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
			\ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
			\ 'hl+':     ['fg', 'Statement'],
			\ 'info':    ['fg', 'PreProc'],
			\ 'border':  ['fg', 'Ignore'],
			\ 'prompt':  ['fg', 'Conditional'],
			\ 'pointer': ['fg', 'Exception'],
			\ 'marker':  ['fg', 'Keyword'],
			\ 'spinner': ['fg', 'Label'],
			\ 'header':  ['fg', 'Comment'] }
    " Python-Mode
    let g:pymode_trim_whitespaces = 1
endfunction
