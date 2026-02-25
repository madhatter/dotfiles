# functions/aws-login.fish — AWS SSO login with environment and role selection.
#
# Requires: aws-sso-util, awsume with fish integration.
# Run `awsume --configure` once after `pip install awsume` to install the fish wrapper.

function aws-login --description 'Log into AWS via SSO and assume a profile with awsume'
    if test (count $argv) -eq 0
        echo "Usage: aws-login <env> [role]"
        echo "  env:  live | nonlive | live-dr | nonlive-dr"
        echo "  role: admin | developer  (default: admin)"
        return 1
    end

    set -l env $argv[1]
    set -l role admin
    if test (count $argv) -ge 2
        set role $argv[2]
    end

    set -l profile
    switch $env
        case live
            set profile dv-live-$role
        case nonlive
            set profile dv-nonlive-$role
        case live-dr
            set profile dv-drlive-$role
        case nonlive-dr
            set profile dv-drnonlive-$role
        case '*'
            echo "Unknown environment: $env"
            echo "Usage: aws-login <env> [role]"
            echo "  env:  live | nonlive | live-dr | nonlive-dr"
            echo "  role: admin | developer  (default: admin)"
            return 1
    end

    aws-sso-util login --profile $profile
    awsume $profile

    switch $env
        case live-dr
            set -gx AWS_ENV "🔴 DRLIVE-$role"
        case nonlive-dr
            set -gx AWS_ENV "🟢 DRNONLIVE-$role"
        case live
            set -gx AWS_ENV "🔴 LIVE-$role"
        case nonlive
            set -gx AWS_ENV "🟢 NONLIVE-$role"
    end
end
