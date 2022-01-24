//
//  LockView.swift
//  PasswordVault
//
//  Created by Michael Simms on 12/12/21.
//

import SwiftUI

struct LockView: View {
	@ObservedObject var appModel = AppState.shared
	@Binding var isPushed : Bool

	var body: some View {
		NavigationView {
			VStack {
				NavigationLink(destination: VaultView(isPushed: $isPushed)) {
					Image(systemName: "lock.circle")
						.font(.title)
					Text("Login")
						.fontWeight(.semibold)
						.font(.title)
				}
				.padding()
				.foregroundColor(.white)
				.background(Color.blue)
				.cornerRadius(40)
			}
		}
	}
}
