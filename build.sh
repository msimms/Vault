#!/bin/sh

# For debugging build issues
whoami
security list-keychains
security default-keychain
security find-identity -v -p codesigning

xcodebuild -workspace Vault.xcworkspace -scheme Vaultsy -configuration Release build
