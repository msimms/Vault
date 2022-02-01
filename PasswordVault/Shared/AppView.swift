//
//  AppView.swift
//  PasswordVault
//
//  Created by Michael Simms on 12/18/21.
//

import SwiftUI

struct AppView: View {
	@ObservedObject var appModel = AppState.shared
	@State var pushed : Bool = false
	@State var selection: Int? = nil

	var body: some View {
		NavigationView {
			if !appModel.vaultExists() {
				NavigationView {
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
						.cornerRadius(40)
					}
				}
			}
			else {
				NavigationView {
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
						.cornerRadius(40)
					}
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
