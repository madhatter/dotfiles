#	$Id: dot.cshrc,v 1.5 1996/09/21 21:35:35 wosch Exp $
#
# .cshrc - csh resource script, read at beginning 
#	   of execution by each shell
#
# see also csh(1), environ(7).
#
#
# prompt examples ;-)
# set prompt = "[ %U%n%u@%B%m%b:%~ ; dev=%l ; time=%P ] %# "
# set prompt = "[ %l ] [ %n@%B%m%b:%~ ] %# "
# set prompt = "\n%S(%s %U%n%u@%B%m%b:%~ ; dev=%l ; time=%P %S)%s\n %# "
# set prompt="[ `whoami`@hasseroeder: `pwd` ] "
# set prompt="[ `whoami`@`hostname`:`pwd` ] "

set path= ( /Users/$USER/bin /data/home/$USER/bin /usr/bin /bin /sbin /usr/sbin /Library/MySQL/bin /usr/local/bin /usr/local/git/bin /usr/X11R6/bin /usr/local/sbin /home/$USER/bin /usr/games )
setenv MANPATH /usr/share/man:/usr/local/man:/usr/X11R6/man:/usr/share/openssl/man:/usr/share/perl/man:/home/$USER/man
#setenv BLOCKSIZE       K
setenv  LC_CTYPE        de_DE.UTF-8
#setenv  LC_CTYPE        de_DE.ISO8859-15
setenv	TZ		CET
setenv  EDITOR  vim
setenv  NNTPSERVER	News.Individual.DE 
setenv  VIM    /usr/local/share/vim/vim73
# I set SYSSCREENRC to some non-existing file, because the defaults here are buggy
setenv  SYSSCREENRC	$HOME/.screen_default

setenv LD_LIBRARY_PATH $HOME/lib

setenv LESS		"-c"

##Xterm Title Bar Setup
 if ("$term" == "xterm-color") then
  alias cwdcmd 'echo -n "]2;${USER}@${HOST} : $cwd ";echo -n "]1;${USER}@${HOST}"'
  cwdcmd
 endif

if ($?prompt) then
        # An interactive shell -- set some stuff up
        set nobeep
        set filec
        set history = 1000
        set savehist = ( 1000 merge )
        set histdup = erase
        set autolist
        set promptchars = "&#"
        set mail = (/var/mail/$USER)

	# Gimme some keybindings in my tcsh
        if ( $?tcsh ) then
                bindkey "^W" backward-delete-word
                bindkey -k up history-search-backward
                bindkey -k down history-search-forward
		bindkey "^G" complete-word-fwd
        endif

	# who the fsck am I?
        if ( `whoami` == root ) then
                set prompt = "root@%m %# "
        else    
                #set prompt = "%n@%m[%~]%# "
                #set prompt = "[ %l ] [ %n@%B%m%b:%~ ] %# "
                set prompt = "[ %T ] [ %n@%B%m%b:%~ ] %# "
        endif   

	# Some useful aliases
        alias b         logout
        alias h         history 25
        alias j         jobs -l
        alias d         df -h
        alias lr        ls -ltr
        alias ll        ls -Al
        alias cd        cd \!\*\; echo \$cwd
        alias cp        cp -i
        alias mv        mv -i
        alias rm        rm -i
        alias pas       'ps -aux |sort |more'
	alias btd	'btdownloadgui.py --max_upload_rate 2'
	alias holemehl	'fetchmail -aK'
	alias clerasil	'clear'


	# this makes the complete scripts work
	# don't forget to unset noglob at the end
	if ($tcsh != 1) then
		set rev=$tcsh:r
		set rel=$rev:e
		set pat=$tcsh:e
		set rev=$rev:r
	endif
	if ($rev > 5 && $rel > 1) then
		set complete=1
	endif
	unset rev rel pat
endif

# okay I'm lazy like a bone
if ($?complete) then
    set noglob
    set hosts
    foreach f ($HOME/.hosts /usr/local/etc/csh.hosts $HOME/.rhosts)
        if ( -r $f ) then
	    set hosts = ($hosts `grep -v "+" $f | tr -s " " "	" | cut -f 1`)
	endif
    end
    if ( -r $HOME/.netrc ) then
	set f=`awk '/machine/ { print $2 }' < $HOME/.netrc` >& /dev/null
	set hosts=($hosts $f)
    endif
    unset f
    if ( ! $?hosts ) then
	set hosts=(hyperion.ee.cornell.edu phaeton.ee.cornell.edu \
		   guillemin.ee.cornell.edu vangogh.cs.berkeley.edu \
		   ftp.uu.net prep.ai.mit.edu export.lcs.mit.edu \
		   labrea.stanford.edu sumex-aim.stanford.edu \
		   tut.cis.ohio-state.edu)
    endif

    complete ywho  	n/*/\$hosts/	# argument from list in $hosts
    complete rsh	p/1/\$hosts/ c/-/"(l n)"/   n/-l/u/ N/-l/c/ n/-/c/ p/2/c/ p/*/f/
    complete ssh	p/1/\$hosts/ c/-/"(l n)"/   n/-l/u/ N/-l/c/ n/-/c/ p/2/c/ p/*/f/
    complete xrsh	p/1/\$hosts/ c/-/"(l 8 e)"/ n/-l/u/ N/-l/c/ n/-/c/ p/2/c/ p/*/f/
    complete rlogin 	p/1/\$hosts/ c/-/"(l 8 e)"/ n/-l/u/
    complete telnet 	p/1/\$hosts/ p/2/x:'<port>'/ n/*/n/

    complete set	'c/*=/f/' 'p/1/s/=' 'n/=/f/'
    complete unset	n/*/s/
    complete setenv	'p/1/e/' 'c/*:/f/'

    complete finger	c/*@/\$hosts/ n/*/u/@ 
    complete ping	p/1/\$hosts/
    complete traceroute	p/1/\$hosts/

    complete ftp	c/-/"(d i g n v)"/ n/-/\$hosts/ p/1/\$hosts/ n/*/n/
    complete nslookup   p/1/x:'<host>'/ p/2/\$hosts/

    complete kill	'c/-/S/' 'c/%/j/' \
			'n/*/`ps -u $LOGNAME | awk '"'"'{print $1}'"'"'`/'
    
    complete {w3m,lynx}	p/1/\$hosts/
    complete mpg123	n/*/f:*.{mp3,MP3}/
    complete mplayer	n/*/f:*.{avi,mpg,mpeg,asf,MPG,MPEG,wmv,WMV,mov,MOV,mp3,MP3}/

    complete where	'n/*/c/'
    complete which	'n/*/c/'
    complete man	'p/*/c/'

    complete kill	'c/%/j/' 'c/-/S/'

    unset noglob
    unset complete
endif


# Some radio streams 
alias p3='mpg123 -b 1024 http://radio.hiof.no:8000/nrk-petre-128'
alias p2='mpg123 -b 1024 http://radio.hiof.no:8000/nrk-p2-128'   
alias p1='mpg123 -b 1024 http://radio.hiof.no:8000/nrk-p1-128'   
alias relax='mpg123 -b 1024 http://radio.hiof.no:8000/nrk-alltid-klassisk-128'   
alias mpetre='mpg123 -b 1024 http://radio.hiof.no:8000/nrk-mpetre-128'

# Give me some tips in the shell
#[ -x /usr/games/fortune ] && /usr/games/fortune freebsd-tips
#echo ""
