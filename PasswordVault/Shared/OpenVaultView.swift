//
//  OpenVaultView.swift
//  Created by Michael Simms on 12/12/21.
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

@ViewBuilder
func createVaultItemView(isPushed: Binding<Bool>, item: SecureVaultItem, isNewItem: Bool) -> some View {
	switch item {
	case is SecureCardItem: SecureCardView(isPushed: isPushed, item: item as! SecureCardItem, isNewItem: isNewItem, isReadOnly: true)
	case is SecureLoginItem: SecureLoginView(isPushed: isPushed, item: item as! SecureLoginItem, isNewItem: isNewItem, isReadOnly: true)
	case is SecureNoteItem: SecureNoteView(isPushed: isPushed, item: item as! SecureNoteItem, isNewItem: isNewItem, isReadOnly: true)
	default: EmptyView()
	}
}

func icon(item: SecureVaultItem) -> String {
	switch item {
	case is SecureCardItem: return "creditcard.and.123";
	case is SecureLoginItem: return "lock";
	case is SecureNoteItem: return "note";
	default: return ""
	}
}

func title(item: SecureVaultItem) -> String {
	switch item {
	case is SecureCardItem: let item2 = item as! SecureCardItem; return item2.title();
	case is SecureLoginItem: let item2 = item as! SecureLoginItem; return item2.title();
	case is SecureNoteItem: let item2 = item as! SecureNoteItem; return item2.title();
	default: return ""
	}
}

func subtitle(item: SecureVaultItem) -> String {
	switch item {
	case is SecureCardItem: let item2 = item as! SecureCardItem; return item2.heading;
	case is SecureLoginItem: let item2 = item as! SecureLoginItem; return item2.email;
	case is SecureNoteItem: return "";
	default: return ""
	}
}

/// Displays all the items within the open vault.
struct OpenVaultView: View {
	@ObservedObject var appModel = AppState.shared
	@ObservedObject var vault = AppState.shared.vault
	@Binding var isPushed : Bool
	@State var showNewItem : Bool = false
	@State var newItemType : VaultItemType = VaultItemType.login
	@State private var showingFailedToDeleteAlert = false
	@State private var showingDeleteVaultAlert = false

	var body: some View {

		VStack(alignment: .leading) {

			NavigationView {

				// List of all of the items in the vault.
				List(self.vault.vaultItems) { item in
					Image(systemName: icon(item: item))
					VStack(alignment: .leading) {

						let itemView = createVaultItemView(isPushed: self.$isPushed, item: item, isNewItem: false)
						NavigationLink(destination: itemView) {
							VStack(alignment: .leading) {
								Text(title(item: item))
									.font(.headline)
								Text(subtitle(item: item))
									.font(.subheadline)
							}
						}
					}
				}
				.padding(10)
#if os(macOS)
				.background(

					// Show a blank view for the user to enter new information.
					NavigationLink(destination: NewItemView(isPushed: self.$isPushed, newItemType: self.$newItemType), isActive: $showNewItem) {}
				)
#endif
			}
#if !os(macOS)
			.navigationBarTitle("Password Vault", displayMode: .inline)
			.navigationBarHidden(true)
#endif
			.toolbar {

				// Toolbar item for creating new entries.
				ToolbarItem() {
					HStack {
						Menu {
							
							// New Login
							Button(action: {
								self.newItemType = VaultItemType.login
								showNewItem = true
							}) {
								Label("Login", systemImage: "lock")
									.labelStyle(.titleAndIcon)
							}

							// New Note
							Button(action: {
								self.newItemType = VaultItemType.note
								showNewItem = true
							}) {
								Label("Note", systemImage: "doc")
									.labelStyle(.titleAndIcon)
							}

							// New Card
							Button(action: {
								self.newItemType = VaultItemType.card
								showNewItem = true
							}) {
								Label("Card", systemImage: "creditcard.and.123")
									.labelStyle(.titleAndIcon)
							}
						}
						label: {
							Label("Add", systemImage: "plus")
						}

						Menu {
							// Close the Vault
							Button(action: {
								self.appModel.closeVault()
								self.isPushed = false // Pop to the root view controller
							}) {
								Label("Close Vault", systemImage: "xmark.circle")
									.labelStyle(.titleAndIcon)
							}
							
							// Delete the Vault
							Button(action: {
								self.showingDeleteVaultAlert = true
							}) {
								Label("Delete Vault", systemImage: "trash")
									.labelStyle(.titleAndIcon)
							}
						}
						label: {
							Label("File", systemImage: "folder")
						}
						.alert("Are you sure you want to do this? It cannot be undone.", isPresented: $showingDeleteVaultAlert) {
							Button("No", role: .cancel) { }
								.keyboardShortcut(.defaultAction)
							Button("Yes") {
								if self.appModel.deleteVault() {
									self.appModel.closeVault()
									self.isPushed = false // Pop to the root view controller
								}
								else {
									self.showingFailedToDeleteAlert = true
								}
							}
								.keyboardShortcut(.cancelAction)
						}
						.alert("Failed to delete the vault!", isPresented: $showingFailedToDeleteAlert) {
							Button("OK", role: .cancel) { }
						}
					}
				}
			}
#if !os(macOS)
			.background(

				// Show a blank view for the user to enter new information.
				NavigationLink(destination: NewItemView(isPushed: self.$isPushed, newItemType: self.$newItemType), isActive: $showNewItem) {}
			)
#endif
		}
	}
}
