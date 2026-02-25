# conf.d/exports.fish — Environment variables.

set -gx EDITOR nvim
set -gx PAGER less
set -gx TZ CET
set -gx WORKSPACE $HOME/workspace
set -gx NNTPSERVER news.individual.de

# Go
set -gx GOPATH $HOME/code/go
set -gx GOPROXY https://proxy.golang.org

# Node — SSL interception workaround for office network
set -gx NODE_OPTIONS --use-openssl-ca
set -gx NODE_EXTRA_CA_CERTS $HOME/Ottogroup-Root-CA-v01.pem

# Git SSH key
set -gx GIT_SSH_COMMAND "ssh -i $HOME/.ssh/id_ed25519 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"

# macOS / Homebrew
if test (uname -s) = Darwin
    # Homebrew environment (sets HOMEBREW_PREFIX, HOMEBREW_CELLAR, prepends brew paths to PATH)
    if test -x /opt/homebrew/bin/brew
        /opt/homebrew/bin/brew shellenv | source
    end

    set -gx JAVA_HOME /opt/homebrew/opt/java
    set -gx DOCKER_DEFAULT_PLATFORM linux/amd64
    set -gx LDFLAGS -L/opt/homebrew/opt/ruby/lib
    set -gx CPPFLAGS -I/opt/homebrew/opt/ruby/include
    set -gx SSL_CERT_FILE /etc/ssl/cert.pem
end
