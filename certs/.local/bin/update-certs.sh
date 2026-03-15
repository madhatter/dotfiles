#!/usr/bin/env bash

# Define paths for the certificates
HOMEBREW_CA_BUNDLE="/opt/homebrew/etc/ca-certificates/cert.pem"
CORP_CERT_PATH="$HOME/.config/certs/Ottogroup-Root-CA-v01.pem"
COMBINED_CERT_PATH="$HOME/.config/certs/combined_ca_bundle.pem"

# Ensure the target directory exists
mkdir -p "$(dirname "$COMBINED_CERT_PATH")"

# Check if the Homebrew certificate bundle exists to prevent empty merges
if [ ! -f "$HOMEBREW_CA_BUNDLE" ]; then
    echo "Error: Homebrew CA bundle not found at $HOMEBREW_CA_BUNDLE"
    echo "You might need to install it first: brew install ca-certificates"
    exit 1
fi

# Merge the Homebrew bundle and the corporate certificate into a new file
cat "$HOMEBREW_CA_BUNDLE" "$CORP_CERT_PATH" > "$COMBINED_CERT_PATH"

echo "Successfully created combined CA bundle at: $COMBINED_CERT_PATH"
