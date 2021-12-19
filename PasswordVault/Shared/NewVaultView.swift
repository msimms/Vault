//
//  NewVaultView.swift
//  PasswordVault
//
//  Created by Michael Simms on 12/18/21.
//

import SwiftUI

struct NewVaultView: View {
	@ObservedObject var appModel = AppState.shared

	@State var password: String = ""
	@State var confirmPassword: String = ""

	var body: some View {
		NavigationView {
			Form {
				Label("Password", systemImage: "lock.circle")
				SecureField("", text: $password)
				Label("Confirm Password", systemImage: "lock.circle")
				SecureField("", text: $confirmPassword)
			}
		}
	}
}

struct NewVaultView_Previews: PreviewProvider {
	static var previews: some View {
		NewVaultView()
	}
}
