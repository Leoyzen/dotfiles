" Let Vim and NeoVim shares the same plugin directory.
" Comment it out if you don't like
let g:spacevim_plug_home = '~/.vim/plugged'

" The default leader key is space key.
" Uncomment the line below and modify "<\Space>" if you prefer another
" let g:spacevim_leader = "<\Space>"

" The default local leader key is comma.
" Uncomment the line below and modify ',' if you prefer another
" let g:spacevim_localleader = ','

" Enable the existing layers in space-vim
let g:spacevim_layers = [
      \ 'fzf', 'unite', 'better-defaults', 'syntax-checking', 'rust',
      \ 'which-key', 'file-manager', 'emoji', 'git', 'tmux', 'formatting',
      \ 'python', 'git', 'programming', 'editing',
      \ 'text-align', 'better-motion', 'airline', 'lsp']

" If you want to have more control over the layer, try using Layer command.
" if g:spacevim_gui
"   Layer 'airline'
" endif

" Manage your own plugins, refer to vim-plug's instruction for more detials.
function! UserInit()

  " Add plugin via Plug command.
    Plug 'morhetz/gruvbox'
    Plug 'ryanoasis/vim-devicons'
    Plug 'tyrannicaltoucan/vim-quantum'
    " Plug 'cocopon/iceberg.vim'
    " Plug 'ayu-theme/ayu-vim'
    Plug 'vim-airline/vim-airline-themes'
    Plug 'sainnhe/gruvbox-material'

endfunction

" Override the default settings as well as adding extras
function! UserConfig()
    let g:spacevim_leader="<\Space>"
    " let g:gruvbox_contrast_dark="soft"
    " let g:gruvbox_sign_column="bg4"
    " let g:gruvbox_color_column="bg4"
    " let g:gruvbox_vert_split="bg4"
    " " let g:gruvbox_number_column="bg4"
    " let g:gruvbox_improved_strings="1"
    " let g:gruvbox_improved_warnings="1"

    " pymode
    let g:pymode_motion = 1
    let g:pymode_rope=0
    let g:pymode_rope_lookup_project=0
    let g:pymode_trim_whitespaces=1
    let g:pymode_python="python3"
    let g:pymode_options_max_line_length=119
    let g:pymode_trim_whitespaces = 1
    let g:pymode_lint_on_write = 0
    let g:pymode_lint_on_fly = 0
    " let g:pymode_lint_checkers = ['flake8']
    "发现错误时不自动打开QuickFix窗口
    " let g:pymode_lint_cwindow = 0
    "侧边栏不显示python-mode相关的标志
    " let g:pymode_lint_signs = 0

    let g:yapf_style = "google"

    set timeoutlen=1000 ttimeoutlen=0


		" Ale
    let g:ale_linters = {
          \   'javascript': ['eslint'],
          \		'bash': ['shellcheck'],
          \   'python': ['ruff']
          \}
    nmap <silent> <C-p> <Plug>(ale_previous_wrap)
    nmap <silent> <C-n> <Plug>(ale_next_wrap)

    " If you enable airline layer and have installed the powerline fonts, set it here.
    " 字体设置
    let g:airline_powerline_fonts=1
    " let g:airline_theme="gruvbox"
    " let g:airline_theme='quantum'
    " let g:airline_theme="iceberg"
    " let g:airline_theme='ayu'

    " autocmd FileType python setlocal colorcolumn=120
    set textwidth=119
    " set colorcolumn=119
    autocmd FileType python setlocal
                  \ foldmethod=indent
                  \ tabstop=4
                  \ shiftwidth=4
                  \ softtabstop=4
                  \ textwidth=119
                  \ expandtab
                  \ autoindent
                  \ fileformat=unix
                  \ colorcolumn=119
    " 始终使用4个空格
    " set pastetoggle=

    " 24位真彩色
		if exists('$TMUX')
				let &t_SI = "\<Esc>Ptmux;\<Esc>\e[5 q\<Esc>\\"
				let &t_EI = "\<Esc>Ptmux;\<Esc>\e[2 q\<Esc>\\"
		else
				let &t_SI = "\e[5 q"
				let &t_EI = "\e[2 q"
		endif

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

    colorscheme gruvbox-material
    let g:airline_theme="gruvbox_material"
    let g:gruvbox_material_background = 'hard'
    let g:gruvbox_material_palette = 'mix'
    let g:gruvbox_material_statusline_style = 'mix'
    let g:gruvbox_material_enable_italic = 1
    let g:gruvbox_material_enable_bold = 1
    let g:gruvbox_material_visual = 'reverse'
    " color tener
    " color gruvbox
    " colorscheme quantum
    " color iceberg
    " color jellybeans
    " let ayucolor="light"  " for light version of theme
    " let ayucolor="mirage" " for mirage version of theme
    " let ayucolor="dark"   " for dark version of theme
    " colorscheme ayu
    " Copy
    " set background=dark
    set background=dark
    " color hybrid_reverse
    set wrap
    " If you use vim inside tmux, see https://github.com/vim/vim/issues/993
    " " set Vim-specific sequences for RGB colors
    " set macligatures
    if has("gui_running")
      if has("gui_macvim")   "GTK2
          set guifont=Sarasa\ Mono\ SC\ Nerd:h16
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
    " nnoremap <Leader>n :NERDTreeToggle<CR>
    " inoremap <Leader>n <ESC>:NERDTreeToggle<CR>
    " let g:python_host_prog = '/usr/bin/python2'
    let g:python3_host_prog = '/opt/conda/bin/python'

    set mouse=a

    " git-fugitive
    set diffopt+=vertical
    " let g:ycm_semantic_triggers =  {
			" \ 'c,cpp,python,java,go,erlang,perl': ['re!\w{2}'],
			" \ 'cs,lua,javascript': ['re!\w{2}'],
			" \ }

    " ycm
    "
    let g:fzf_colors =
      \ {'fg':      ['fg', 'Normal'],
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
endfunction
