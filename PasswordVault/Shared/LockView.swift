//
//  LockView.swift
//  PasswordVault
//
//  Created by Michael Simms on 12/12/21.
//

import SwiftUI

// Prompts the user for the credentials to open the vault.
struct LockView: View {
	@ObservedObject var appModel = AppState.shared
	@Binding var isPushed : Bool
	@State private var password: String = ""

	var body: some View {
		NavigationView {
			VStack {
				// Password
				Label("Password", systemImage: "lock.circle")
				SecureField("", text: $password)

				// Login button
				NavigationLink(destination: VaultView(isPushed: $isPushed)) {
					Image(systemName: "lock.circle")
					Text("Login")
						.fontWeight(.semibold)
				}
				.padding()
				.background(Color.blue)
				.foregroundColor(.white)
				.cornerRadius(40)
				.padding()
			}
		}
	}
}
