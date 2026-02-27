# config.fish — Main fish configuration.
# conf.d/ files are sourced before this file (alphabetically).

if status is-interactive
    # Runtime version manager (python, java, rust, jj, …)
    mise activate fish | source

    # Per-directory environment overrides
    direnv hook fish | source

    # fzf: key bindings (Ctrl+R history, Ctrl+T file, Alt+C cd) and ** trigger completions
    fzf --fish | source

    # Ctrl+W: delete back to previous path component (treats / as word boundary,
    # matching the custom backward-delete-word behaviour from zsh)
    bind \cw backward-kill-path-component
end

# GPG needs a TTY to prompt for a passphrase
set -gx GPG_TTY (tty)
