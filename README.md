# Dead Man's Vault

A server-less password manager for mac OS and iOS.

## Rationale

Why develop a password manager when there are other options available, including open source options?
* To have a password manager that works without a centralized database.
* Some password managers leave metadata unencrypted (ex: the website name or URL). This application encrypts everything that is possible to encrypt.
* I believe password managers should be open source.

## Major Features

* Uses iCloud Drive to sync across devices. The vault is stored as a collection of encrypted files that are written to the user's iCloud Drive.
* A password generator to encourage using different passwords for each account.
* Importing of existing data from 1pif files. Other formats may be added as necessary.
* Biometric authentication is available to open a vault with Touch ID or Face ID. When using biometric authentication the vault password is stored in the iCloud Keychain and returned by the operating system when biometric authentication succeeds.
* Multiple vaults

## Planned Features

* The ability to encrypt a vault with multiple passwords, for sharing a vault.
* Integration with HealthKit to so that a second user's password will only function when HealthKit hasn't shown any activity from the primary user for an extended period of time (hence the name of the app).

## User Documentation

### Creating a vault

TODO

### Enabling Biometric Authentication

TODO

## Architecture

The application is written in Swift and thus only runs on mac OS, iOS, and iPadOS. Swift was chosen to have one application that works across the entire Apple ecosystem.

The vaults are stored on the user's iCloud drive. Each subdirectory of the main application directory represents a vault.

Vaults have an main file and a subdirectory of items, where each item in the vault corresponds to one file in the directory.

![Architecture Diagram](https://github.com/msimms/PasswordVault/blob/master/Docs/Architecture.png?raw=true)

## Building

This app is built using Apple XCode. Every attempt is made to stay up-to-date with the latest version of XCode and the latest versions of iOS and macOS. In theory, if you have cloned the source code repository and initialized the submodules, then you should be able to open the project in XCode, build, and deploy.

```
git clone https://github.com/msimms/PasswordVault
cd PasswordVault
```

## Version History

None - still in development
