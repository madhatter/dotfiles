# conf.d/abbreviations.fish — Abbreviations (expand in-place on space/enter) and aliases.

# Git
abbr -a gp   'git pull'
abbr -a st   'git status -s'
abbr -a cl   'git clone'
abbr -a ci   'git commit'
abbr -a cm   'git commit -m'
abbr -a co   'git checkout'
abbr -a glog "git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"

# Navigation
abbr -a cdg "cd $HOME/code/go/src/github.com/madhatter"

# Tools
abbr -a rtin 'tin -r'
abbr -a pip  'pip3'

# Debug helpers
abbr -a dphp  'php -d xdebug.remote_autostart=1'
abbr -a druby "ruby -I$HOME/lib/rubylib -r $HOME/lib/rubylib/rdbgp.rb"

# ls with colour (alias wraps the command rather than expanding in-place)
if test (uname -s) = Darwin
    alias ls='ls -G'
else
    alias ls='ls --color=auto'
end
alias ll='ls -la'
