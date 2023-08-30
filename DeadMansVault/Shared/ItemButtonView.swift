//
//  ItemButtonView.swift
//  Created by Michael Simms on 7/27/22.
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

struct ItemButtonView: View {
	@Environment(\.dismiss) var dismiss
	@Binding var isReadOnly: Bool
	@State var item: SecureVaultItem
	@State var isNewItem: Bool = true
	@State private var showingFailedToAddAlert: Bool = false
	@State private var showingFailedToUpdateAlert: Bool = false
	@State private var showingFailedToDeleteAlert: Bool = false
	@State private var showingDeleteVaultItemAlert: Bool = false
	@State private var editUpdateButtonTitle: String = "Edit"
	@State private var editUpdateButtonImage: String = "pencil"
	
	var body: some View {
		HStack() {
			Spacer()
			if self.isNewItem {

				// Save button
				Button {
					if AppState.shared.addItemToVault(item: self.item) {
						self.dismiss()
					}
					else {
						self.showingFailedToAddAlert = true
					}
				} label: {
					Label("Save", systemImage: "square.and.arrow.down")
				}
				.alert("Failed to add the vault item!", isPresented: self.$showingFailedToAddAlert) {
					Button("OK", role: .cancel) { }
				}

				// Cancel button
				Button {
					self.dismiss()
				} label: {
					Label("Cancel", systemImage: "trash")
				}
			}
			else {
				// Cancel button
				Button {
					self.isReadOnly = true
					self.editUpdateButtonTitle = "Edit"
					self.editUpdateButtonImage = "pencil"
				} label: {
					Label("Cancel", systemImage: "trash")
				}
				.opacity(self.isReadOnly ? 0 : 1)

				// Edit/Update button
				Button {
					if self.editUpdateButtonTitle == "Edit" {
						self.editUpdateButtonTitle = "Update"
						self.editUpdateButtonImage = "square.and.arrow.down"
						self.isReadOnly = false
					}
					else if AppState.shared.updateVaultItem(item: self.item) {
						self.editUpdateButtonTitle = "Edit"
						self.editUpdateButtonImage = "pencil"
						self.isReadOnly = true
					}
					else {
						self.showingFailedToUpdateAlert = true
					}
				} label: {
					Label(self.editUpdateButtonTitle, systemImage: self.editUpdateButtonImage)
				}
				.alert("Failed to update the vault item!", isPresented: self.$showingFailedToUpdateAlert) {
					Button("OK", role: .cancel) { }
				}

				// Delete button
				Button {
					self.showingDeleteVaultItemAlert = true
				} label: {
					Label("Delete", systemImage: "trash")
				}
				.alert("Are you sure you want to do this? It cannot be undone.", isPresented: self.$showingDeleteVaultItemAlert) {
					Button("No", role: .cancel) { }
						.keyboardShortcut(.defaultAction)
					Button("Yes") {
						if AppState.shared.deleteItemFromVault(item: self.item) {
							self.dismiss()
						}
						else {
							self.showingFailedToDeleteAlert = true
						}
					}
					.keyboardShortcut(.cancelAction)
				}
				.alert("Failed to delete the vault item!", isPresented: self.$showingFailedToDeleteAlert) {
					Button("OK", role: .cancel) { }
				}
			}
		}
	}
}
