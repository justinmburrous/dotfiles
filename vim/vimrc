" Vundle setup below
set nocompatible              " be iMproved, required
filetype off                  " required

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim' " required
Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-surround'
Plugin 'airblade/vim-gitgutter'
Plugin 'kien/ctrlp.vim'
Plugin 'bling/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'miyakogi/conoline.vim'
Plugin 'fatih/vim-go'
Plugin 'scrooloose/nerdtree'
Plugin 'rust-lang/rust.vim'

call vundle#end()
filetype plugin indent on

syntax on
setlocal spell spelllang=en_us

set hlsearch
set incsearch
set ignorecase
set smartcase
set ruler
set colorcolumn=100
set visualbell
set backspace=indent,eol,start
set number relativenumber
set t_Co=256
set tabstop=2 softtabstop=0 expandtab shiftwidth=2 smarttab
set splitright
set splitbelow
set shell=/bin/bash

let g:gitgutter_enabled = 1

" Spell-check settings
hi clear SpellBad
hi SpellBad cterm=underline,bold ctermfg=red
" Set style for gVim
hi SpellBad gui=undercurl

" ESC delay
set timeoutlen=1000 ttimeoutlen=10

" Set CTRLP to search all project modules
let g:ctrlp_working_path_mode = ''

" Show hidden files with NERDTree
let NERDTreeShowHidden=1
