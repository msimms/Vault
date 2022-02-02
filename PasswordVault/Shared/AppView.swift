//
//  AppView.swift
//  PasswordVault
//
//  Created by Michael Simms on 12/18/21.
//

import SwiftUI

/// This is the first view that is shown to the user.
struct AppView: View {
	@ObservedObject var appModel = AppState.shared
	@State var pushed : Bool = false

	var body: some View {
		NavigationView {
			if appModel.vaultExists() {
				VStack {
					NavigationLink(
						destination: LockView(isPushed: self.$pushed),
						isActive: self.$pushed
					) { EmptyView() }
					.hidden()
					Button("Open Vault") {
						self.pushed = true
					}
					.padding()
					.background(Color.blue)
					.foregroundColor(.white)
					.cornerRadius(40)
					.padding()
				}
			}
			else {
				VStack {
					NavigationLink(
						destination: NewVaultView(isPushed: self.$pushed),
						isActive: self.$pushed
					) { EmptyView() }
					.hidden()
					Button("Create Vault") {
						self.pushed = true
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
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView()
    }
}
