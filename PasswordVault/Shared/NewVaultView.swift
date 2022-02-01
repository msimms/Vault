//
//  NewVaultView.swift
//  PasswordVault
//
//  Created by Michael Simms on 12/18/21.
//

import SwiftUI

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

struct NewVaultView: View {
	@ObservedObject var appModel = AppState.shared
	@Binding var isPushed : Bool
	@State private var password: String = ""
	@State private var confirmPassword: String = ""
	@State private var vaultLocation: String = ""
	@State private var showingPasswordsDoNotMatchAlert = false
	@State private var showingVaultCreationFailedAlert = false

	var body: some View {
		NavigationView {
			Form {
				VStack(alignment: .center) {
					// Password
					Label("Password", systemImage: "lock.circle")
					SecureField("", text: $password)

					// Password Confirmation
					Label("Confirm Password", systemImage: "lock.circle")
					SecureField("", text: $confirmPassword)

					// Allows the user to select the vault location
					/*Button("Select Location...") {
						let panel = NSOpenPanel()

						panel.allowsMultipleSelection = false
						panel.canChooseDirectories = true

						if panel.runModal() == .OK {
							vaultLocation = panel.directoryURL?.absoluteString ?? ""
						}
					}
					.padding()
					.background(Color.blue)
					.cornerRadius(40)*/

					// Creates the vault
					Button("Create") {

						// Make sure the passwords match.
						if password == confirmPassword && password.count > 8 {

							// Create the vault.
							if self.appModel.createVault(vaultLocation: self.vaultLocation, password: self.password) {
								
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
					.alert("The passwords do not match or are not long enough", isPresented: $showingPasswordsDoNotMatchAlert) {
						Button("OK", role: .cancel) { }
					}
					.alert("Failed to create the vault", isPresented: $showingVaultCreationFailedAlert) {
						Button("OK", role: .cancel) { }
					}
					.padding()
					.background(Color.blue)
					.cornerRadius(40)
				}
			}
			.frame(width: 300, height: 200)
		}
	}
}
