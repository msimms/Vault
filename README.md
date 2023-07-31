# PasswordVault

A serverless password manager for mac OS and iOS.

## Rationale
Why develop a password manager when there are other options available, including open source options?
* To have a password manager that works without a centralized database
* I believe password managers should be open source

## Major Features

* Uses iCloud Drive to sync across devices
* Multiple vaults
* Password Generator
* Importing of existing data from 1pif files
* Biometric authentication

## User Documentation

TODO

## Architecture

The application is written in Swift and thus only runs on mac OS, iOS, and iPadOS. Swift was chosen to have one application that works across the entire Apple ecosystem.

The vaults are stored on the user's iCloud drive. Each subdirectory of the main application directory represents a vault.

Vaults have an main file and a subdirectory of items, where each item in the vault corresponds to one file in the directory.


## Building
This app is built using Apple XCode. Every attempt is made to stay up-to-date with the latest version of XCode and the latest version of iOS. In theory, if you have cloned the source code repository and initialized the submodules, then you should be able to open the project in XCode, build, and deploy.
```
git clone https://github.com/msimms/PasswordVault
cd PasswordVault
```

## Version History

None - still in development
