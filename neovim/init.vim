set encoding=utf-8
set fileencodings=utf-8,iso-2022-jp,euc-jp,sjis
set fileformats=unix,dos,mac
"dein Scripts-----------------------------
" dein.vim がなければ github から落としてくる
let s:plugin_test = 0

if s:plugin_test
  let s:dein_dir = expand('~/dotfiles/neovim/test-dein')
else
  let s:dein_dir = expand('~/dotfiles/neovim/neo-dein')
endif

let s:dein_repo_dir = s:dein_dir . '/repos/github.com/Shougo/dein.vim'
if &runtimepath !~# '/dein.vim'
  if !isdirectory(s:dein_repo_dir)
    execute '!git clone https://github.com/Shougo/dein.vim' s:dein_repo_dir
  endif
  execute 'set runtimepath^=' . fnamemodify(s:dein_repo_dir, ':p')
endif

if dein#load_state(s:dein_dir)
  call dein#begin(s:dein_dir)
  let s:tomltest = '~/dotfiles/neovim/dein_test.toml'
  let s:tomlnvim = '~/dotfiles/neovim/dein_nvim.toml'

  if s:plugin_test
    call dein#load_toml(s:tomltest, {'lazy': 0})
  else
    call dein#load_toml(s:tomlnvim, {'lazy': 0})
  endif

  call dein#end()
  call dein#save_state()
endif

 if dein#check_install()
   call dein#install()
 endif

" 未アンインストールされていないものがあればアンインストール
let s:removed_plugins = dein#check_clean()
if len(s:removed_plugins) > 0
  call map(s:removed_plugins, "delete(v:val, 'rf')")
  call dein#recache_runtimepath()
endif

let g:dein#install_max_processes = 16

 "End dein Scripts-------------------------

 "setting https://qiita.com/hide/items/229ff9460e75426a2d07
 "文字コードをUFT-8に設定
 "set fenc=utf-8
 " バックアップファイルを作らない
 "set nobackup
 " スワップファイルを作らない
 set noswapfile
 " 編集中のファイルが変更されたら自動で読み直す
 set autoread
 " バッファが編集中でもその他のファイルを開けるように
 set hidden
 " 入力中のコマンドをステータスに表示する
 set showcmd

 " 見た目系
 " 行番号を表示
 set number
 " 現在の行を強調表示
 "set cursorline
 " 現在の行を強調表示（縦）
 "set cursorcolumn
 " 行末の1文字先までカーソルを移動できるように
 set virtualedit=onemore

set hls                "検索した文字をハイライトする
set termguicolors      "TrueColor対応"

"通常モードはブロック型点滅有り
"挿入モードはライン型点滅有り
let &t_SI .= "\e[5 q"
let &t_EI .= "\e[1 q"
" ビープ音を可視化
set visualbell
" 括弧入力時の対応する括弧を表示
set showmatch
" ステータスラインを常に表示
set laststatus=2
" コマンドラインの補完
set wildmode=list:longest
" 折り返し時に表示行単位での移動できるようにする
nnoremap j gj
nnoremap k gk
" diff時 set wrapをデフォルトに
autocmd FilterWritePre * if &diff | setlocal wrap< | endif
let mapleader = ","
nnoremap <Leader>d :Gdiff<CR>:windo set wrap<CR>

"タブ、空白、改行の可視化
set list
set listchars=tab:\▸\-,trail:◀,extends:>,precedes:<,nbsp:%

"全角スペースをハイライト表示
function! ZenkakuSpace()
    highlight ZenkakuSpace cterm=reverse ctermfg=DarkMagenta gui=reverse guifg=DarkMagenta
endfunction
if has('syntax')
    augroup ZenkakuSpace
        autocmd!
        autocmd ColorScheme       * call ZenkakuSpace()
        autocmd VimEnter,WinEnter * match ZenkakuSpace /　/
    augroup END
    call ZenkakuSpace()
endif

" 検索系
" 検索文字列が小文字の場合は大文字小文字を区別なく検索する
set ignorecase
" 検索文字列に大文字が含まれている場合は区別して検索する
set smartcase
" 検索文字列入力時に順次対象文字列にヒットさせる
set incsearch
" 検索語をハイライト表示
set hlsearch
" ESC連打でハイライト解除
nmap <Esc><Esc> :nohlsearch<CR><Esc>

"行頭
nmap <C-h> 0
vmap <C-h> 0
"行末
nmap <C-l> $
vmap <C-l> $

" タイポ修正
inoremap <C-t> <Esc><Left>"zx"zpa

vmap <BS> <Del>
imap <BS> <BS>
" 挿入モードーノーマルモード間移動を高速化
set ttimeoutlen=10

set mouse=a

" ウィンドウの幅より長い行は折り返され、次の行に続けて表示される
set wrap

set number
"4nvim
"set clipboard+=autoselect
set clipboard+=unnamed
set showmatch
set matchtime=1
set matchpairs& matchpairs+=<:>
set hidden
set whichwrap=b,s,<,>,[,]
vnoremap <silent> <C-p> "0p<CR>

set t_Co=256
cnoremap w!! w !sudo tee > /dev/null %<CR>

"visualモードで選択してからのインデント調整で調整後に選択範囲を開放しない
vnoremap > >gv
vnoremap < <gv
"======================indent===================
"自動インデント
set smartindent
set autoindent
" Tab文字を半角スペースにする
set expandtab

let s:switchTab=1
let s:switchTabMessage="4スペ"
set sw=4 "shiftwidth
set ts=4 "tabstop
noremap <C-o> :call SwitchIndent()<CR>
function! SwitchIndent()
    if (s:switchTab == 1)
        let s:switchTab=2
        set expandtab
        set sw=2
        set ts=2
        let s:switchTabMessage="2スペ"
    elseif (s:switchTab == 2)
        let s:switchTab=3
        set noexpandtab
        set sw=4
        set ts=4
        let s:switchTabMessage="タブ"
    elseif (s:switchTab == 3)
        let s:switchTab=1
        set expandtab
        set sw=4
        set ts=4
        let s:switchTabMessage="4スペ"
    endif
    echo "SwitchIndent: " . s:switchTabMessage
endfunction

"============== 不要になったら削除する =====================
"function! _RestartGRPC()
"   exe ":!docker-compose -f /Users/enotiru/Development/youbride/youbride-rails/docker/local/docker-compose.yml restart api"
"endfunction
"
"command! RestartGRPC call _RestartGRPC()
"autocmd BufWrite *.{rb} :RestartGRPC
"
"function! _RestartServer()
"   exe ":!docker-compose -f /Users/enotiru/Development/youbride/youbride-server/docker-compose.yml restart admin"
"endfunction
"
"command! RestartServer call _RestartServer()
"
"autocmd BufWrite *.{pm} :RestartServer
"==========================================================