//
//  SecureLoginView.swift
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
	@ObservedObject var appModel = AppState.shared
	@Binding var isPushed : Bool
	@Binding var isReadOnly : Bool
	@State var item : SecureVaultItem
	@State var isNewItem = true
	@State private var showingFailedToAddAlert = false
	@State private var showingFailedToUpdateAlert = false
	@State private var showingFailedToDeleteAlert = false
	@State private var showingDeleteVaultItemAlert = false
	@State private var editUpdateButtonTitle: String = "Edit"
	@State private var editUpdateButtonImage: String = "pencil"
	
	var body: some View {
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

				Button {
					self.isPushed = false
				} label: {
					Label("Cancel", systemImage: "trash")
				}
			}
			else {
				Button {
					if self.editUpdateButtonTitle == "Edit" {
						editUpdateButtonTitle = "Update"
						editUpdateButtonImage = "square.and.arrow.down"
						self.isReadOnly = false
					}
					else if self.appModel.updateVaultItem(item: self.item) {
						editUpdateButtonTitle = "Edit"
						editUpdateButtonImage = "pencil"
						self.isReadOnly = true
					}
					else {
						showingFailedToUpdateAlert = true
					}
				} label: {
					Label(editUpdateButtonTitle, systemImage: editUpdateButtonImage)
				}
				.alert("Failed to update the vault item!", isPresented: $showingFailedToUpdateAlert) {
					Button("OK", role: .cancel) { }
				}

				Button {
					self.showingDeleteVaultItemAlert = true
				} label: {
					Label("Delete", systemImage: "trash")
				}
				.alert("Are you sure you want to do this? It cannot be undone.", isPresented: $showingDeleteVaultItemAlert) {
					Button("No", role: .cancel) { }
						.keyboardShortcut(.defaultAction)
					Button("Yes") {
						showingFailedToDeleteAlert = !self.appModel.deleteItemFromVault(item: self.item)
						self.isPushed = !showingFailedToDeleteAlert
					}
					.keyboardShortcut(.cancelAction)
				}
				.alert("Failed to delete the vault item!", isPresented: $showingFailedToDeleteAlert) {
					Button("OK", role: .cancel) { }
				}
			}
		}
	}
}
