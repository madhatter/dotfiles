# OSX specific settings
#
# Homebrew related paths
export JAVA_HOME="/opt/homebrew/opt/java"
export LDFLAGS="-L/opt/homebrew/opt/ruby/lib"
export CPPFLAGS="-I/opt/homebrew/opt/ruby/include"

#necessary to build on M1 for the real world
export DOCKER_DEFAULT_PLATFORM=linux/amd64

# Colima doesn't expose the default /var/run/docker.sock, so tools that
# bypass the "docker" CLI's context resolution (e.g. Testcontainers via
# docker-java) can't find a valid Docker environment unless DOCKER_HOST is
# set explicitly. Resolve it dynamically from the active colima instance.
if command -v colima >/dev/null 2>&1 && colima status >/dev/null 2>&1; then
  export DOCKER_HOST="$(colima status -j 2>/dev/null | jq -r '.docker_socket // empty')"
  # Testcontainers (Ryuk) bind-mounts the docker socket using the DOCKER_HOST
  # path verbatim, but that host-side path doesn't exist inside colima's Linux
  # VM. Override it with the socket path as seen by the daemon itself.
  export TESTCONTAINERS_DOCKER_SOCKET_OVERRIDE="/var/run/docker.sock"
fi

# fpath for completions
FPATH=$(brew --prefix)/share/zsh-completions:$(brew --prefix)/share/zsh/site-functions:$FPATH

# MFA token generator. It reads the base32 secret from ~/.mfa/NAME.mfa and
# copies the generated token to the clipboard.
mfa() { oathtool --base32 --totp "$(cat ~/.mfa/$1.mfa)" | tee >(tr -d \\n | pbcopy) }

