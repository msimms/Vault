//
//  NoteView.swift
//  PasswordVault
//
//  Created by Michael Simms on 4/22/22.
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
struct SecureNoteView: View {
	@ObservedObject var appModel = AppState.shared
	@Binding var isPushed : Bool
	@State var item : SecureNoteItem
	@State var isNewItem = true
	@State private var showingFailedToAddAlert = false
	@State private var showingFailedToUpdateAlert = false
	@State private var showingFailedToDeleteAlert = false

	var body: some View {
		VStack(alignment: .leading) {
			Text("Note")
				.fontWeight(.heavy)
				.font(.system(size: 32))
				.multilineTextAlignment(.center)
			Divider()
			Text("Title")
				.fontWeight(.heavy)
			TextField("Title", text: $item.title)
			VStack(alignment: .leading) {
				TextEditor(text: $item.note)
			}
			Spacer()
			HStack() {
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
				}
				else {
					Button {
						showingFailedToUpdateAlert = !self.appModel.updateVaultItem(item: self.item)
					} label: {
						Label("Save", systemImage: "square.and.arrow.down")
					}
					.alert("Failed to update the vault item!", isPresented: $showingFailedToUpdateAlert) {
						Button("OK", role: .cancel) { }
					}
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
		.padding(10)
	}

	func title() -> String {
		return "Note"
	}
	func subtitle() -> String {
		return ""
	}
}
