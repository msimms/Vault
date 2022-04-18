//
//  LockView.swift
//  PasswordVault
//
//  Created by Michael Simms on 12/12/21.
//

import SwiftUI

/// Prompts the user for the credentials to open the vault.
struct LockView: View {
	@ObservedObject var appModel = AppState.shared
	@Binding var isPushed : Bool
	@State var pushed : Bool = false
	@State private var password: String = ""
	@State private var showingVaultOpenFailedAlert = false

	var body: some View {
		VStack {
			// Password
			Label("Password", systemImage: "lock.circle")
			SecureField("", text: $password)
				.textFieldStyle(RoundedBorderTextFieldStyle())
				.padding()

			// Opens the vault
			Button("Open") {

				// Open the vault.
				if self.appModel.open(password: self.password) {
				}
				else {
					self.showingVaultOpenFailedAlert = true
				}
			}
			.alert("Failed to create the vault", isPresented: $showingVaultOpenFailedAlert) {
				Button("OK", role: .cancel) { }
			}
			.padding()
			.background(Color.blue)
			.foregroundColor(.white)
			.cornerRadius(40)
			.padding()
		}
	}
}
