# functions/vault-login.fish — HashiCorp Vault OIDC login with automatic token renewal.
# Private helpers are defined in the same file and autoloaded alongside vault-login.

function __vault_renew_token
    vault token renew >/dev/null 2>&1
end

function __vault_create_token
    vault login -method=oidc role='pdh-da' >/dev/null 2>&1
    set -l exit_status $status
    cat ~/.vault-token   # stdout captured by the caller
    return $exit_status
end

function vault-login --description 'Log into Vault via OIDC, renewing an existing token if possible'
    if set -q VAULT_TOKEN
        echo "Trying to renew existing token..."
        if __vault_renew_token
            echo "Renewed existing token."
            return 0
        end
    end

    echo "Creating new token..."
    set -l new_token (__vault_create_token)
    set -l exit_status $status
    if test $exit_status -eq 0
        echo "Created new token."
        set -gx VAULT_TOKEN $new_token
    end
    return $exit_status
end
