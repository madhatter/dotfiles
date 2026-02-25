# functions/asp.fish — AWS profile selection.
# Also defines aws_profiles (helper used by asp; autoloaded alongside it).

function aws_profiles --description 'List configured AWS profiles'
    set -l cfg $HOME/.aws/config
    set -q AWS_CONFIG_FILE; and set cfg $AWS_CONFIG_FILE
    test -r $cfg || return 1
    grep '\[profile' $cfg | sed -e 's/.*profile \([a-zA-Z0-9_\.-]*\).*/\1/'
end

function asp --description 'Set (or clear) the active AWS profile'
    if test (count $argv) -eq 0
        set -e AWS_DEFAULT_PROFILE AWS_PROFILE AWS_EB_PROFILE AWS_DEFAULT_REGION
        echo "AWS profile cleared."
        return
    end

    set -l available (aws_profiles)
    if not contains -- $argv[1] $available
        printf '%sProfile "%s" not found in %s%s\n' \
            (set_color red) $argv[1] \
            (set -q AWS_CONFIG_FILE; and echo $AWS_CONFIG_FILE; or echo $HOME/.aws/config) \
            (set_color normal) >&2
        printf 'Available profiles: %s\n' (string join ', ' $available) >&2
        return 1
    end

    set -gx AWS_DEFAULT_PROFILE $argv[1]
    set -gx AWS_PROFILE $argv[1]
    set -gx AWS_EB_PROFILE $argv[1]
    if test (count $argv) -ge 2
        set -gx AWS_DEFAULT_REGION $argv[2]
    end
end
