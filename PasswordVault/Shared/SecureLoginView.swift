//
//  LoginItemView.swift
//  PasswordVault
//
//  Created by Michael Simms on 1/31/22.
//

// MIT License
//
// Copyright (c) 2022 Mike Simms
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import SwiftUI

/// Displays a login item from the vault.
struct SecureLoginView: View {
	@ObservedObject var appModel = AppState.shared
	@Binding var isPushed : Bool
	@State var item : SecureLoginItem
	@State private var showingFailedToUpdateAlert = false
	@State private var showingFailedToDeleteAlert = false

	var body: some View {
		VStack(alignment: .leading) {
			Text("Login")
				.fontWeight(.heavy)
				.font(.system(size: 32))
				.multilineTextAlignment(.center)
			Spacer()
			Text("Website")
				.fontWeight(.heavy)
			TextField("Website", text: $item.website)
			Text("Username")
				.fontWeight(.heavy)
			TextField("Username", text: $item.username)
			Text("Email")
				.fontWeight(.heavy)
			TextField("Email", text: $item.email)
			Spacer()
			HStack() {
				Button {
					if !self.appModel.updateVaultItem(item: self.item) {
					}
				} label: {
					Label("Save", systemImage: "square.and.arrow.down")
				}
				.alert("Failed to update the vault item!", isPresented: $showingFailedToUpdateAlert) {
					Button("OK", role: .cancel) { }
				}
				Button {
					if !self.appModel.deleteItemFromVault(item: self.item) {
					}
				} label: {
					Label("Delete", systemImage: "trash")
				}
				.alert("Failed to delete the vault item!", isPresented: $showingFailedToDeleteAlert) {
					Button("OK", role: .cancel) { }
				}
			}
		}
    }

	func title() -> String {
		return item.website
	}
	func subtitle() -> String {
		return item.email
	}
}
