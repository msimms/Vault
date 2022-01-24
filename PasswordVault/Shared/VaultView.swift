//
//  ContentView.swift
//  Shared
//
//  Created by Michael Simms on 12/12/21.
//

import SwiftUI

struct VaultView: View {
	@ObservedObject var appModel = AppState.shared
	@Binding var isPushed : Bool

	var body: some View {
		List(0..<5) { item in
			Image(systemName: "note")
			VStack(alignment: .leading) {
				Text("Login")
				Text("Some Website")
					.font(.subheadline)
			}
		}
	}
}
