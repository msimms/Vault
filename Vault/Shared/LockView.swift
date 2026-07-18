//
//  LockView.swift
//  Created by Michael Simms on 12/12/21.
//

//	MIT License
//
//  Copyright (c) 2021 Michael J Simms. All rights reserved.
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in all
//	copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//	SOFTWARE.

import SwiftUI

/// Prompts the user for the credentials to open the vault.
struct LockView: View {
	@Environment(\.dismiss) var dismiss
	@State private var password: String = ""
	@State private var showingVaultOpenFailedAlert: Bool = false
	@State private var showingNoVaultSelectedAlert: Bool = false
	@State private var showPassword: Bool = false
	@State private var showingBiometricSetupAlert: Bool = false
	@State private var isBusy: Bool = false
	@State private var selectedVault: String? = Preferences.defaultVaultName()

	func vaultIsSelected() -> Bool {
		return self.selectedVault != nil && self.selectedVault!.count > 0
	}

	func openVault() {
		if AppState.shared.openVault(password: self.password) {
			self.showingVaultOpenFailedAlert = false
//			self.dismiss()
		}
		else {
			self.showingVaultOpenFailedAlert = true
		}
	}

	var body: some View {
		VStack(alignment: .center) {
			// Allow the user to toggle between multiple vaults
			Label("Vault Selection", systemImage: "lock.circle")
			ZStack(alignment: Alignment(horizontal: .trailing, vertical: .center), content: {
				Menu {
					let vaultNames = AppState.shared.listVaults()
					ForEach(vaultNames, id: \.self) { name in
						Button(action: {
							self.selectedVault = name
							Preferences.setDefaultVaultName(name: name)
						}) {
							Label(name, systemImage: "lock")
								.labelStyle(.titleAndIcon)
						}
					}
					if !vaultNames.isEmpty {
						Divider()
					}
					Button(action: {
						VaultDisplayState.shared.vaultState = VaultState.CreateNewVault
					}) {
						Label("Create a New Vault", systemImage: "plus")
							.labelStyle(.titleAndIcon)
					}
				} label: {
					if self.vaultIsSelected() {
						Text("\(self.selectedVault!)")
					}
					else {
						Text("Choose Vault")
					}
				}
				.padding()
			})

			// Password
			Label("Password", systemImage: "lock.circle")
			ZStack(alignment: Alignment(horizontal: .trailing, vertical: .center), content: {
				if self.showPassword {
					TextField("Password", text: self.$password)
						.textFieldStyle(RoundedBorderTextFieldStyle())
						.padding()
						.onSubmit {
							self.openVault()
						}
				}
				else {
					SecureField("Password", text: self.$password)
						.textFieldStyle(RoundedBorderTextFieldStyle())
						.padding()
						.onSubmit {
							self.openVault()
						}
				}
				Button(action: { self.showPassword.toggle() }) {
					Image(systemName: "eye")
						.foregroundColor(.secondary)
				}
				.help("View")
				.padding()
			})

			// Opens the vault
			Button {
				if self.vaultIsSelected() {
					self.isBusy = true
					self.openVault()
					self.isBusy = false
				}
				else {
					self.showingNoVaultSelectedAlert = true
				}
			} label: {
				Label("Open", systemImage: "lock")
					.padding()
			}
			.alert("A vault was not specified!", isPresented: self.$showingNoVaultSelectedAlert) {
				Button("OK", role: .cancel) { }
					.keyboardShortcut(KeyboardShortcut.defaultAction)
			}
			.alert("Failed to open the vault!", isPresented: self.$showingVaultOpenFailedAlert) {
				Button("OK", role: .cancel) { }
					.keyboardShortcut(KeyboardShortcut.defaultAction)
			}
			.foregroundColor(.white)
			.background(Color.gray)
			.cornerRadius(40)
			.padding()
#if !os(macOS)
			.navigationBarBackButtonHidden(true)
#endif
			.buttonStyle(PlainButtonStyle())
			.sheet(isPresented: self.$isBusy) {
				ProgressView("Loading...")
			}

			// Biometric ID
			if AppState.shared.isBiometricIdAvailable() && self.vaultIsSelected() {
				let biometricAuthType = AppState.shared.biometricAuthType()

				Button {
					if AppState.shared.isBiometricIdEnabledForVault(vaultName: self.selectedVault!) {
						self.openVault()
					}
					else {
						self.showingBiometricSetupAlert = true
					}
				} label: {
					if biometricAuthType == .touchID {
						Image(systemName: "touchid")
							.resizable()
					}
					else if biometricAuthType == .faceID {
						Image(systemName: "faceid")
							.resizable()
					}
				}
				.alert("Do you want to configure biometric authentication for this vault?", isPresented: self.$showingBiometricSetupAlert) {
					Button("No", role: .cancel) { }
						.keyboardShortcut(.defaultAction)
					Button("Yes") {
						AppState.shared.flagVaultForBiometricAuthSetup(vaultName: self.selectedVault!)
					}
				}
				.frame(width: 32.0, height: 32.0)
				.buttonStyle(PlainButtonStyle())
				.padding(10)
			}
		}
		.onAppear() {
			if AppState.shared.hasOpenedAVault == false && self.vaultIsSelected() {
				if AppState.shared.isBiometricIdEnabledForVault(vaultName: self.selectedVault!) {
					self.openVault()
				}
			}
		}
	}
}
