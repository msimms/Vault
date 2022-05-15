//
//  SecureCardView.swift
//  Created by Michael Simms on 5/14/22.
//

import SwiftUI

/// Displays a login item from the vault.
struct SecureCardView: View {
	@ObservedObject var appModel = AppState.shared
	@Binding var isPushed : Bool
	@State var item : SecureCardItem
	@State var isNewItem = true
	@State private var showingFailedToAddAlert = false
	@State private var showingFailedToUpdateAlert = false
	@State private var showingFailedToDeleteAlert = false

	var body: some View {
		VStack(alignment: .leading) {
			Text("Card")
				.fontWeight(.heavy)
				.font(.system(size: 32))
				.multilineTextAlignment(.center)
			Divider()
			Text("Title")
				.fontWeight(.heavy)
			TextField("Title", text: $item.heading)
			VStack(alignment: .leading) {
				TextEditor(text: $item.number)
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
		return ""
	}
}
