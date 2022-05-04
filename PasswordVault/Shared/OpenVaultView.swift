//
//  ContentView.swift
//  Shared
//
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
	case is SecureLoginItem: SecureLoginView(isPushed: isPushed, item: item as! SecureLoginItem, isNewItem: isNewItem)
	case is SecureNoteItem: SecureNoteView(isPushed: isPushed, item: item as! SecureNoteItem, isNewItem: isNewItem)
	default: EmptyView()
	}
}

func icon(item: SecureVaultItem) -> String {
	switch item {
	case is SecureLoginItem: return "lock";
	case is SecureNoteItem: return "note";
	default: return ""
	}
}

func title(item: SecureVaultItem) -> String {
	switch item {
	case is SecureLoginItem: let item2 = item as! SecureLoginItem; return item2.website;
	case is SecureNoteItem: let item2 = item as! SecureNoteItem; return item2.title;
	default: return ""
	}
}

func subtitle(item: SecureVaultItem) -> String {
	switch item {
	case is SecureLoginItem: let item2 = item as! SecureLoginItem; return item2.email;
	case is SecureNoteItem: return "";
	default: return ""
	}
}

/// Displays all the items within the open vault.
struct OpenVaultView: View {
	@ObservedObject var appModel = AppState.shared
	@Binding var isPushed : Bool
	@State var showNewItem : Bool = false
	@State var newItem : SecureVaultItem = SecureVaultItem()

	var body: some View {

		NavigationView {

			// List of all items in the vault.
			let items = Array(self.appModel.vaultItems.values)
			List(items) { item in
				Image(systemName: icon(item: item))
				VStack(alignment: .leading) {

					let itemView = createVaultItemView(isPushed: $isPushed, item: item, isNewItem: false)
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
			.background(
				
				// Show a blank view for the user to enter new information.
				NavigationLink(destination: createVaultItemView(isPushed: $isPushed, item: self.newItem, isNewItem: true), isActive: $showNewItem) {}
			)
		}
		.toolbar {

			// Toolbar item for creating new entries.
			ToolbarItem() {
				Menu {
					Button(action: {
						self.newItem = SecureLoginItem()
						showNewItem = true
					}) {
						Label("Login", systemImage: "lock")
							.labelStyle(.titleAndIcon)
					}

					Button(action: {
						self.newItem = SecureNoteItem()
						showNewItem = true
					}) {
						Label("Note", systemImage: "doc")
							.labelStyle(.titleAndIcon)
					}
				}
				label: {
					Label("Add", systemImage: "plus")
				}
			}
		}
	}
}
