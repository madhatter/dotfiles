# conf.d/path.fish — PATH additions.
# fish_add_path is idempotent: deduplicates and persists via $fish_user_paths.

fish_add_path $HOME/bin
fish_add_path $HOME/.local/bin
fish_add_path $HOME/.cargo/bin
fish_add_path /usr/local/go/bin
fish_add_path $GOPATH/bin

if test (uname -s) = Darwin
    fish_add_path $JAVA_HOME/bin
    fish_add_path /opt/homebrew/opt/gnu-sed/libexec/gnubin
    fish_add_path /opt/homebrew/opt/ruby/bin
end
