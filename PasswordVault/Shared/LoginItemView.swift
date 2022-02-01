//
//  LoginItemView.swift
//  PasswordVault
//
//  Created by Michael Simms on 1/31/22.
//

import SwiftUI

// Displays a login item from the vault.
struct LoginItemView: View {
	@ObservedObject var appModel = AppState.shared
	@Binding var isPushed : Bool

	var body: some View {
		NavigationView {
			VStack {
		        Text("Hello World")
			}
		}
    }
}
