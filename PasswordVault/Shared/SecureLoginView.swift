//
//  SecureLoginView.swift
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
	@State var isNewItem = true
	@State private var showingFailedToAddAlert = false
	@State private var showingFailedToUpdateAlert = false
	@State private var showingFailedToDeleteAlert = false
	@State private var newTag = ""

	var body: some View {
		VStack(alignment: .leading) {
			Text("Login")
				.fontWeight(.heavy)
				.font(.system(size: 32))
				.multilineTextAlignment(.center)
			Divider()
			VStack(alignment: .leading) {
				Text("Website")
					.fontWeight(.heavy)
				TextField("Website", text: $item.website)
				Text("Username")
					.fontWeight(.heavy)
				TextField("Username", text: $item.username)
				Text("Email")
					.fontWeight(.heavy)
				TextField("Email", text: $item.email)
				Text("Notes")
					.fontWeight(.heavy)
				TextEditor(text: $item.note)
				Text("Tags")
					.fontWeight(.heavy)
				HStack(spacing: 10) {
					ForEach($item.tags, id: \.self) { $tag in
						Button(action: {}) {
							HStack {
								Text(tag)
							}
						}
					}
				}
			}
			Spacer()
			HStack(spacing: 10) {
				Spacer()
				if self.isNewItem {
					Button {
						showingFailedToAddAlert = !self.appModel.addItemToVault(item: self.item)
					} label: {
						Label("Save", systemImage: "square.and.arrow.down")
					}
					.alert("Failed to add the vault item!", isPresented: $showingFailedToAddAlert) {
						Button("OK", role: .cancel) { }
					}
					Button {
						self.isPushed = false
					} label: {
						Label("Cancel", systemImage: "trash")
					}
				}
				else {
					Button {
						showingFailedToUpdateAlert = !self.appModel.updateVaultItem(item: self.item)
					} label: {
						Label("Edit", systemImage: "square.and.arrow.down")
					}
					.alert("Failed to update the vault item!", isPresented: $showingFailedToUpdateAlert) {
						Button("OK", role: .cancel) { }
					}
					Button {
						showingFailedToDeleteAlert = !self.appModel.deleteItemFromVault(item: self.item)
						self.isPushed = false
					} label: {
						Label("Delete", systemImage: "trash")
					}
					.alert("Failed to delete the vault item!", isPresented: $showingFailedToDeleteAlert) {
						Button("OK", role: .cancel) { }
					}
				}
			}
		}
		.padding(10)
    }

	func title() -> String {
		return item.title()
	}
	func subtitle() -> String {
		return item.email
	}
}
