# functions/mfa.fish — Generate a TOTP code and copy it to the clipboard.
# Keys are stored as ~/.mfa/<name>.mfa (base32 secret).

function mfa --description 'Generate TOTP code for ~/.mfa/<name>.mfa and copy to clipboard'
    if test (count $argv) -eq 0
        echo "Usage: mfa <name>"
        return 1
    end

    set -l code (oathtool --base32 --totp (cat ~/.mfa/$argv[1].mfa))
    echo $code

    if test (uname -s) = Darwin
        printf '%s' $code | pbcopy
    else
        printf '%s' $code | xclip -in -selection c
    end
end
