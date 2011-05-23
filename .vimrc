" we want color
syntax on

" explicitly get out of vi-compatible mode
set nocompatible 

" don't use local version of .(g)vimrc, .exrc
set noexrc 

" change color scheme
:colorscheme oceandeep
":colorscheme darkblue
":colorscheme dante

" break the line after
"set textwidth=75

" text encoding
set encoding=iso-8859-15

" Tab are Tab and Spaces are Spaces!
set noexpandtab

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
set number 

" We are good up to 99999 lines
set numberwidth=5 

" four spaces are one TAB
set shiftwidth=4

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

" autocomplete filenames to the longest or show me a list
set wildmode=longest,list

" When on, the title of the window will be set to the value of
" 'titlestring' (if it is not empty)
set notitle

" Define the look of title
"set titlestring=%t%(\ %M%)%(\ (%{expand(\"%:~:.:h\")})%)%(\ %a%) 
set title titlestring=%<%F\ %M%=%l/%L\ -\ %p%% titlelen=70

" Last - but not least - playing with the statusline
" See >:h statusline< for more details
set statusline=[%n][File:%f]%m%=[Row:%l][Col:%c][%p%%]

" automatically set some special behavior
" ruby standard 2 spaces, always
au BufRead,BufNewFile *.rb,*.rhtml set shiftwidth=2 
au BufRead,BufNewFile *.rb,*.rhtml set softtabstop=2 

" Textwidth only for SLRN und Mutt
au BufNewFile,BufRead .followup,.article.*,.letter.*,/tmp/mutt-*,nn.*,snd.*,mutt* set tw=72

" Colors in Mails
au BufNewFile,BufRead /tmp/mutt-* :so /usr/share/vim/vim72/syntax/mail.vim

" Colors for slrn's score-file
au BufRead .slrn-score :so /usr/share/vim/vim72/syntax/slrnsc.vim

" No Textwidth for HTML 
au BufRead *.htm,*.html,*.shtml set textwidth=0

" Colors for .muttrc and other mutt-related config-files
" nmap <F9> :so /usr/local/share/vim/vim72/syntax/muttrc.vim<CR>
" nope, all beginning with .mutt* automatically please
au BufRead .mutt* :so /usr/share/vim/vim72/syntax/muttrc.vim


" Umlaute in HTML documents
autocmd FileType html call Doit()
function Doit()
  set textwidth=75 nonu nobackup
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

" keymappings for navigating splitwindows
map <C-J> <C-W>j<C-W>_
map <C-K> <C-W>k<C-W>_
