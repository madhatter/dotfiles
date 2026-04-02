# Linux specific shell settings
#
# default browser for urlscan
export BROWSER=/bin/firefox

# fpath for completions
FPATH=/usr/share/zsh/site-functions:~/.zsh/site-functions:$FPATH                                        

# MFA token generator. It reads the base32 secret from ~/.mfa/NAME.mfa and
# copies the generated token to the clipboard.
mfa() { oathtool --base32 --totp "$(cat ~/.mfa/$1.mfa)" | tee >(xclip -in -selection c) }

# Aliases for quick audio output switching
alias audio-samsung='pactl set-card-profile alsa_card.pci-0000_0b_00.1 output:hdmi-stereo'
alias audio-m32up='pactl set-card-profile alsa_card.pci-0000_0b_00.1 output:hdmi-stereo-extra1'
