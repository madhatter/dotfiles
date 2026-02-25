# functions/aws-clear.fish — Revoke all cached AWS profile sessions.

function aws-clear --description 'Clear all AWS profile sessions'
    for profile in default \
            dv-live-admin dv-live-developer \
            dv-nonlive-admin dv-nonlive-developer \
            dv-drlive-admin dv-drlive-developer \
            dv-drnonlive-admin dv-drnonlive-developer
        awsume -k $profile
    end
    set -e AWS_ENV
    echo "All AWS profiles cleared."
end
