//
//  NewVaultView.swift
//  Created by Michael Simms on 12/18/21.
//

// MIT License
//
// Copyright (c) 2022 Mike Simms
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import SwiftUI

#if os(macOS)
func openFolderSelection() -> URL? {
	let openPanel = NSOpenPanel()

	openPanel.allowsMultipleSelection = false
	openPanel.canChooseDirectories = true
	openPanel.canCreateDirectories = true
	openPanel.canChooseFiles = false
	openPanel.begin
		{ (result) -> Void in
			if result.rawValue == NSApplication.ModalResponse.OK.rawValue
			{
//				storeFolderInBookmark(url: openPanel.url!)
			}
	}
	return openPanel.url
}
#endif

/// Prompts the user for everything needed to create a new vault.
struct NewVaultView: View {
	@ObservedObject var appModel = AppState.shared
	@Binding var isPushed : Bool

	@State private var password: String = ""
	@State private var confirmPassword: String = ""
	@State private var vaultLocation: String = ""
	@State private var vaultName: String = "Main Vault"
	@State private var showingPasswordsDoNotMatchAlert = false
	@State private var showingVaultCreationFailedAlert = false
	@State private var showPassword = false

	func createVault() {

		// Make sure the vault has a name.
		if vaultName.count == 0 {
			self.showingVaultCreationFailedAlert = true
			return
		}

		// Make sure the passwords match.
		if password == confirmPassword && password.count > 8 {
			
			// Create the vault.
			if self.appModel.createVault(vaultLocation: self.vaultLocation, name: self.vaultName, password: self.password) {
				
				// Show the vault by popping to the root view controller.
				self.isPushed = false
			}
			else {
				self.showingVaultCreationFailedAlert = true
			}
		}
		else {
			self.showingPasswordsDoNotMatchAlert = true
		}
	}

	var body: some View {

		VStack(alignment: .center) {

			// Name
			Label("Vault Name", systemImage: "signpost.right")
			TextField("", text: $vaultName)
				.textFieldStyle(RoundedBorderTextFieldStyle())
				.padding()

			// Password
			Label("Password", systemImage: "lock.circle")
			ZStack(alignment: Alignment(horizontal: .trailing, vertical: .center), content: {
				if showPassword {
					TextField("Password", text: $password)
						.textFieldStyle(RoundedBorderTextFieldStyle())
						.padding()
						.onSubmit {
							createVault()
						}
				}
				else {
					SecureField("Password", text: $password)
						.textFieldStyle(RoundedBorderTextFieldStyle())
						.padding()
						.onSubmit {
							createVault()
						}
				}
				Button(action: { self.showPassword.toggle() }) {
					Image(systemName: "eye")
						.foregroundColor(.secondary)
				}
				.padding()
			})

			// Password Confirmation
			Label("Confirm Password", systemImage: "lock.circle")
			ZStack(alignment: Alignment(horizontal: .trailing, vertical: .center), content: {
				if showPassword {
					TextField("Confirm Password", text: $confirmPassword)
						.textFieldStyle(RoundedBorderTextFieldStyle())
						.padding()
						.onSubmit {
							createVault()
						}
				}
				else {
					SecureField("Confirm Password", text: $confirmPassword)
						.textFieldStyle(RoundedBorderTextFieldStyle())
						.padding()
						.onSubmit {
							createVault()
						}
				}
				Button(action: { self.showPassword.toggle() }) {
					Image(systemName: "eye")
						.foregroundColor(.secondary)
				}
				.padding()
			})

			// Allows the user to select the vault location
#if os(macOS)
			/*Button("Select Location...") {
				let panel = NSOpenPanel()

				panel.allowsMultipleSelection = false
				panel.canChooseDirectories = true

				if panel.runModal() == .OK {
					vaultLocation = panel.directoryURL?.absoluteString ?? ""
				}
			}
			.background(Color.blue)
			.foregroundColor(.white)
			.cornerRadius(40)
			.padding()*/
#endif

			// Opens the vault
			Button {
				self.createVault()
			} label: {
				Label("Create", systemImage: "lock")
					.padding()
			}
			.alert("The passwords do not match or are not long enough", isPresented: $showingPasswordsDoNotMatchAlert) {
				Button("OK", role: .cancel) { }
			}
			.alert("Failed to create the vault", isPresented: $showingVaultCreationFailedAlert) {
				Button("OK", role: .cancel) { }
			}
			.padding()
			.background(Color.blue)
			.foregroundColor(.white)
			.cornerRadius(40)
			.padding()
#if !os(macOS)
			.navigationBarBackButtonHidden(true)
#endif
		}
	}
}
