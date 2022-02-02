//
//  ContentView.swift
//  Shared
//
//  Created by Michael Simms on 12/12/21.
//

import SwiftUI

/// Displays all the items within the open vault.
struct VaultView: View {
	@ObservedObject var appModel = AppState.shared
	@Binding var isPushed : Bool

	var body: some View {
		VStack {
			List(0..<5) { item in
				Image(systemName: "note")
				VStack(alignment: .leading) {
					NavigationLink(destination: LoginItemView(isPushed: $isPushed)) {
						Text("Login")
						Text("Some Website")
							.font(.subheadline)
					}
				}
			}
		}
	}
}
