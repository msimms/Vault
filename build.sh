#!/bin/sh

# For debugging build issues
whoami
security list-keychains
security default-keychain
security find-identity -v -p codesigning

if [ -n "${KEYCHAIN_PASSWORD+x}" ]; then
    security set-key-partition-list \
        -S apple-tool:,apple: \
        -s \
        -k "$KEYCHAIN_PASSWORD" \
        "$HOME/Library/Keychains/login.keychain-db"
fi

xcodebuild -workspace Vault.xcworkspace -scheme Vaultsy -configuration Release build
