" we want color
syntax on

" explicitly get out of vi-compatible mode
set nocompatible 

" don't use local version of .(g)vimrc, .exrc
set noexrc 

" change color scheme
"if !has("gui_running")
"      colorscheme candy	      " yum candy
"end
"if has("gui_running")
"      colorscheme macvim      " macvim == win
"      set guioptions-=T       " no toolbar
"      set cursorline          " show the cursor line
"end

if (&t_Co == 256 || &t_Co == 88) && !has('gui_running') &&
      \ filereadable(expand("$HOME/.vim/plugin/guicolorscheme.vim"))
      " Use the guicolorscheme plugin to makes 256-color or 88-color
      " terminal use GUI colors rather than cterm colors.
      runtime! plugin/guicolorscheme.vim
      "GuiColorScheme darkbone
      GuiColorScheme darkspectrum
else
     " For 8-color 16-color terminals or for gvim, just use the
     " regular :colorscheme command.
     colorscheme candy
endif

" break the line after
"set textwidth=75

" text encoding
" does not work with --enable-multibyte, dunno
"set encoding=de_DE.UTF-8

" make backspace work like most other apps
set backspace=2

" fast terminal
set ttyfast 

" Enable filetype detection
filetype on                   

" Enable filetype-specific indenting
filetype indent on            

" Enable filetype-specific plugins
filetype plugin on            

" Tab are Tab and Spaces are Spaces!
set noexpandtab

"  backup options
set backup
set backupdir=~/.backup
set viminfo=%100,'100,/100,h,\"500,:100,n~/.viminfo

" make the history longer
set history=500

" highlight current line
set cursorline 

" BUT do highlight as you type you search phrase
set incsearch  
                    
" show statusline
set laststatus=2

" be quiet
set noerrorbells

" don't blink
set novisualbell

" turn on line numbers
"set number 

" make it relative numbers
set relativenumber

" We are good up to 99999 lines
set numberwidth=5 

" four spaces are one TAB
set shiftwidth=8

" String to put at the start of lines that have been wrapped
set showbreak=+

" when a bracket is inserted, briefly jump to the matching one (
set showmatch

" display current mode
set showmode

" enable incremental search
set incsearch

" ignore upper and lower case while searching
set ignorecase

" please be smart enough to recognize upper case in searches
set smartcase

" stay away from the bottom line
set scrolloff=4

" enhanced command-line completion 
set wildmenu

" substitute globally by default
set gdefault 

" autocomplete filenames to the longest or show me a list
set wildmode=longest,list

" When on, the title of the window will be set to the value of
" 'titlestring' (if it is not empty)
set notitle

" fold on syntax automagically, always
"set foldmethod=syntax         

" 2 lines of column for fold showing, always
set foldcolumn=2              

" Define the look of title
"set titlestring=%t%(\ %M%)%(\ (%{expand(\"%:~:.:h\")})%)%(\ %a%) 
set title titlestring=%<%F\ %M%=%l/%L\ -\ %p%% titlelen=70

" Last - but not least - playing with the statusline
" See >:h statusline< for more details
set statusline=[%n][File:%f]%m%=[Row:%l][Col:%c][%p%%]

" Enable compiler support for ruby
compiler ruby

" automatically set some special behavior
" ruby standard 2 spaces, always
au BufRead,BufNewFile *.rb,*.rhtml set shiftwidth=2 
au BufRead,BufNewFile *.rb,*.rhtml set softtabstop=2 
"au BufRead *.rb :so /usr/local/share/vim/vim73/syntax/ruby.vim
au BufRead *.rb :so /home/awarnecke/.vim/syntax/ruby.vim

" 8 spaces are one tab in php
au BufRead,BufNewFile *.php set shiftwidth=8

" Textwidth only for SLRN und Mutt
au BufNewFile,BufRead .followup,.article.*,.letter.*,/tmp/mutt-*,nn.*,snd.*,mutt* set tw=72

" Colors in Mails
au BufNewFile,BufRead /tmp/mutt-* :so /usr/local/share/vim/vim73/syntax/mail.vim

" Colors for slrn's score-file
au BufRead .slrn-score :so /usr/local/share/vim/vim73/syntax/slrnsc.vim

" No Textwidth for HTML 
au BufRead *.htm,*.html,*.shtml set textwidth=0

" Colors for .muttrc and other mutt-related config-files
" nmap <F9> :so /usr/local/share/vim/vim73/syntax/muttrc.vim<CR>
" nope, all beginning with .mutt* automatically please
au BufRead .mutt* :so /usr/local/share/vim/vim73/syntax/muttrc.vim


" Umlaute in HTML documents
autocmd FileType html call Doit()
function Doit()
  set textwidth=75 nobackup
  imap ß &szlig;
  imap ä &auml;
  imap Ä &Auml;
  imap ü &uuml;
  imap Ü &Uuml;
  imap ö &ouml;
  imap Ö &Ouml;
endfunction

" remap key Q
nnoremap Q gq}1G

" php-doc plugin
source ~/.vim/php-doc.vim
inoremap <C-P> <ESC>:call PhpDocSingle()<CR>i
nnoremap <C-P> :call PhpDocSingle()<CR>
vnoremap <C-P> :call PhpDocRange()<CR> 

" keymappings for navigating splitwindows
map <C-J> <C-W>j<C-W>_
map <C-K> <C-W>k<C-W>_
map <C-H> <C-W>h<C-W>_
map <C-L> <C-W>l<C-W>_

