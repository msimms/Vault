# Vault

A serverless password manager for macOS and iOS.

## Important Note

This project has not been audited by independent experts. It is for educational and personal use only. Using this in production may cause you to regret your life choices.

## Rationale

Why develop a password manager when there are other options available, including open source options?
* To learn stuff.
* To have a password manager that works without a centralized database.
* I believe password managers should be open source.
* Some password managers leave metadata unencrypted (ex: the website name or URL). This application encrypts everything that is possible to encrypt.

## Major Features

* Uses the iCloud Drive to sync across devices. The vault is stored as a collection of encrypted files that are written to the user's iCloud Drive.
* A password generator to encourage using different passwords for each account.
* Importing of existing data from 1pif files. Other formats may be added as necessary.
* Biometric authentication is available to open a vault with Touch ID or Face ID. When using biometric authentication the vault password is stored in the iCloud Keychain and returned by the operating system when biometric authentication succeeds.
* Multiple vaults

## Planned Features

* The ability to encrypt a vault with multiple passwords, for sharing a vault.
* A browser extension.

## User Documentation

### Creating a vault

Vaults are created from the main landing page, presented before a vault has been opened.

### Enabling Biometric Authentication

Press the biometric authorization button on the main screen and then enter the password and open the vault. The password will be stored in the iCloud Keychain and will be recalled upon successful biometric authentication.

## Architecture

The application is written in Swift and thus only runs on macOS, iOS, and iPadOS. Swift was chosen to have one application that works across the entire Apple ecosystem.

The vaults are stored on the user's iCloud drive. Each subdirectory of the main application directory represents a vault.

Vaults have a main file and a subdirectory of items, where each item in the vault corresponds to one file in the directory.

![Architecture Diagram](https://github.com/msimms/Vault/blob/master/Docs/Architecture.png?raw=true)

## Building

This app is built using Apple XCode. Every attempt is made to stay up-to-date with the latest version of XCode and the latest versions of iOS and macOS. In theory, if you have cloned the source code repository and initialized the submodules, then you should be able to open the project in XCode, build, and deploy.

```
git clone https://github.com/msimms/Vault
cd Vault
```

## Version History

None - still in development, use at your own risk
