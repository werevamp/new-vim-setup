set nocompatible

" Color Scheme 
syntax on
color pencil
set background=dark
let g:airline_theme = 'pencil'
execute pathogen#infect()
filetype plugin indent on

if &term == "xterm"
    set t_Co=256
endif

" Basic Options 
set hidden
set ruler
set history=200
set number
set backspace=indent,eol,start
set linespace=0
set showmatch
set autoread
set visualbell
set title
set ttyfast
set lazyredraw
set bomb
set fileencoding=utf-8

if has("multi_byte")
  if &termencoding == ""
    let &termencoding = &encoding
  endif
  set encoding=utf-8                     " better default than latin1
  setglobal fileencoding=utf-8           " change default file encoding when writing new files
endif

au vimresized * exe "normal! \<c-w>="

" scrolling
set scrolloff=8

" indent
set autoindent
set smartindent

set expandtab
set shiftwidth=2
set tabstop=2
set softtabstop=2

" search
set hlsearch
set ignorecase
set smartcase

" highlight conflict markers
match errormsg '^\(<\|=\|>\)\{7\}\([^=].\+\)\?$'

" leader
let mapleader = ","
let maplocalleader = "\\"

" TURN OFF SWAP FILES
set noswapfile
set nobackup
set nowb
set nowritebackup

" Folding 
set foldlevelstart=0

" Space to toggle folds
nnoremap <Space> za
vnoremap <Space> zf

" Binding for command line mode
cnoremap <c-a> <home>
cnoremap <c-e> <end>
cnoremap <c-b>  <Left>
cnoremap <c-f>  <Right>
cnoremap <c-d>  <Delete>
cnoremap <m-b>  <S-Left>
cnoremap <m-f>  <S-Right>
cnoremap <m-d>  <S-right><Delete>
cnoremap <esc>b <S-Left>
cnoremap <esc>f <S-Right>
cnoremap <esc>d <S-right><Delete>
cnoremap <c-g>  <c-c>

" Remove Highlight
nnoremap <leader><space> :nohl<cr>


fun! FoldText()
    let line = getline(v:foldstart)

    let nucolwidth = &fdc + &number * &numberwidth
    let windowwidth = winwidth(0) - nucolwidth - 3
    let folderlinecount = v:foldend - v:foldstart

    let onetab = strpart('    ', 0, &tabstop)
    let line = substitute(line, '\t', onetab, 'g')

    let line = strpart(line, 0, windowwidth - 2 - len(folderlinecount))
    let fillcharcount = windowwidth - len(line) - len(folderlinecount)
    return line . repeat(" ", fillcharcount) . '  ' . folderlinecount . '  ' 
endfun
set foldtext=FoldText()

" Save the state of folds
au BufWinLeave * silent! mkview
au BufWinEnter * silent! loadview

" Key Mapping

" A more intuitive way to go to the start and end line
nnoremap H ^
nnoremap L g_
vnoremap H ^
vnoremap L g_

nnoremap D d$

nnoremap <tab> %
vnoremap <tab> %

" Reversed the back to line buttons
nnoremap ' `
nnoremap ` '

nnoremap * *<c-o>
" Keep search matches in the middle of the window and pulse the line when
" moving to them.
nnoremap n nzzzv
nnoremap N Nzzzv

" Instant quit 
nnoremap <leader>qe :q!<CR>
nnoremap <leader>w :w!<CR>

nnoremap ; :
nnoremap : ;

nnoremap <leader>vimrc :tabe ~/.vimrc<CR>

" paste toggle
set pastetoggle=<F8>

nnoremap <C-k> :bnext<CR>
nnoremap <C-j> :bprev<CR>

nnoremap <C-l> :tabn<CR>
nnoremap <C-h> :tabp<CR>

nnoremap <C-s> :update<CR>

"Change Cases
nnoremap <C-u> gUiw
inoremap <C-u> <esc>gUiwea

" Binding for command line mode
cnoremap <c-a> <home>
cnoremap <c-e> <end>

nnoremap S i<cr><esc>

nnoremap <Right> :vertical resize +5<CR>
nnoremap <Left> :vertical resize -5<CR>
nnoremap <Down> :resize +5<CR>
nnoremap <Up> :resize -5<CR>

nnoremap <silent> <leader>/ :execute 'vimgrep /'.@/.'/g %'<CR>:copen<CR>

" Setting the wild menu like bash tab completion
set wildmode=longest,list,full
set wildmenu


" Delete buffer while keeping window layout (don't close buffer's windows).  " Version 2008-11-18 from http://vim.wikia.com/wiki/VimTip165
if v:version < 700 || exists('loaded_bclose') || &cp
  finish
endif
let loaded_bclose = 1
if !exists('bclose_multiple')
  let bclose_multiple = 1
endif

" Display an error message.
function! s:Warn(msg)
  echohl ErrorMsg
  echomsg a:msg
  echohl NONE
endfunction

" Command ':Bclose' executes ':bd' to delete buffer in current window.
" The window will show the alternate buffer (Ctrl-^) if it exists,
" or the previous buffer (:bp), or a blank buffer if no previous.
" Command ':Bclose!' is the same, but executes ':bd!' (discard changes).
" An optional argument can specify which buffer to close (name or number).
function! s:Bclose(bang, buffer)
  if empty(a:buffer)
    let btarget = bufnr('%')
  elseif a:buffer =~ '^\d\+$'
    let btarget = bufnr(str2nr(a:buffer))
  else
    let btarget = bufnr(a:buffer)
  endif
  if btarget < 0
    call s:Warn('No matching buffer for '.a:buffer)
    return
  endif
  if empty(a:bang) && getbufvar(btarget, '&modified')
    call s:Warn('No write since last change for buffer '.btarget.' (use :Bclose!)')
    return
  endif
  " Numbers of windows that view target buffer which we will delete.
  let wnums = filter(range(1, winnr('$')), 'winbufnr(v:val) == btarget')
  if !g:bclose_multiple && len(wnums) > 1
    call s:Warn('Buffer is in multiple windows (use ":let bclose_multiple=1")')
    return
  endif
  let wcurrent = winnr()
  for w in wnums
    execute w.'wincmd w'
    let prevbuf = bufnr('#')
    if prevbuf > 0 && buflisted(prevbuf) && prevbuf != w
      buffer #
    else
      bprevious
    endif
    if btarget == bufnr('%')
      " Numbers of listed buffers which are not the target to be deleted.
      let blisted = filter(range(1, bufnr('$')), 'buflisted(v:val) && v:val != btarget')
      " Listed, not target, and not displayed.
      let bhidden = filter(copy(blisted), 'bufwinnr(v:val) < 0')
      " Take the first buffer, if any (could be more intelligent).
      let bjump = (bhidden + blisted + [-1])[0]
      if bjump > 0
        execute 'buffer '.bjump
      else
        execute 'enew'.a:bang
      endif
    endif
  endfor
  execute 'bdelete'.a:bang.' '.btarget
  execute wcurrent.'wincmd w'
endfunction
command! -bang -complete=buffer -nargs=? Bclose call s:Bclose('<bang>', '<args>')
nnoremap <silent> <Leader>d :Bclose!<CR>

au BufRead,BufNewFile *.scss setfiletype css

" Plugin
hi Directory ctermfg=3 ctermbg=4
autocmd VimEnter * NERDTree
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif
autocmd VimEnter * :wincmd l
nnoremap <F2> :NERDTreeToggle<cr>


" airline
let g:airline#extensions#tabline#enabled = 1
let g:syntastic_enable_highlighting=0
set guioptions-=mTr
