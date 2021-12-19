//
//  NewVaultView.swift
//  PasswordVault
//
//  Created by Michael Simms on 12/18/21.
//

import SwiftUI

struct NewVaultView: View {
	@ObservedObject var appModel = AppState.shared

	@State private var password: String = ""
	@State private var confirmPassword: String = ""
	@State private var vaultLocation: String = ""
	@State private var showingPasswordsDoNotMatchAlert = false
	@State private var showingVaultCreationFailedAlert = false

	var body: some View {
		Form {
			VStack(alignment: .center) {
				// Password
				Label("Password", systemImage: "lock.circle")
				SecureField("", text: $password)

				// Password Confirmation
				Label("Confirm Password", systemImage: "lock.circle")
				SecureField("", text: $confirmPassword)

				// Vault Location
				Button("Select Location") {
					let panel = NSOpenPanel()

					panel.allowsMultipleSelection = false
					panel.canChooseDirectories = true

					if panel.runModal() == .OK {
						vaultLocation = panel.directoryURL?.absoluteString ?? ""
					}
				}

				// Creates the vault
				Button("Create") {

					// Make sure the passwords match.
					if password == confirmPassword && password.count > 8 {

						// Create the vault.
						if self.appModel.createVault(vaultLocation: self.vaultLocation, password: self.password) {
							
							// Show the vault.
						}
						else {
							self.showingVaultCreationFailedAlert = true
						}
					}
					else {
						self.showingPasswordsDoNotMatchAlert = true
					}
				}
				.alert("The passwords do not match or are not long enough", isPresented: $showingPasswordsDoNotMatchAlert) {
					Button("OK", role: .cancel) { }
				}
				.alert("Failed to create the vault", isPresented: $showingVaultCreationFailedAlert) {
					Button("OK", role: .cancel) { }
				}
			}
		}
		.frame(width: 300, height: 200)
	}
}

struct NewVaultView_Previews: PreviewProvider {
	static var previews: some View {
		NewVaultView()
	}
}
