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
	@State var isReadOnly = false
	@State private var tempSecurityCode : String = ""
	@State private var tempExpiryDate : String = ""

	var body: some View {

		VStack(alignment: .leading) {

			Group() {
				Text("Card")
					.fontWeight(.heavy)
					.font(.system(size: 32))
					.multilineTextAlignment(.center)
				Divider()
				VStack(alignment: .leading) {
					Group() {
						Group() {
							Text("Title")
								.fontWeight(.heavy)
							TextField("Title", text: $item.heading)
								.disabled(isReadOnly)
						}
						Group() {
							Text("Number")
								.fontWeight(.heavy)
							TextField("Number", text: $item.number)
								.disabled(isReadOnly)
							Text("Security Code")
								.fontWeight(.heavy)
							TextField("Security Code", text: $tempSecurityCode)
								.disabled(isReadOnly)
							Text("Expiry Date")
								.fontWeight(.heavy)
							TextField("Expiry Date", text: $tempExpiryDate)
								.disabled(isReadOnly)
						}
						Group() {
							Text("Notes")
								.fontWeight(.heavy)
							TextEditor(text: $item.note)
								.disabled(isReadOnly)
						}
					}
					TagsView(isPushed: self.$isPushed, isReadOnly: self.$isReadOnly, tags: self.$item.tags)
					LastModifiedView(isNewItem: isNewItem, timestamp: self.item.lastModifiedTime)
				}
			}

			Spacer()
			ItemButtonView(isPushed: self.$isPushed, isReadOnly: self.$isReadOnly, item: self.item, isNewItem: self.isNewItem)
		}
		.padding(10)
#if !os(macOS)
		.navigationBarHidden(true)
#endif
	}

	func title() -> String {
		return item.title()
	}
	func subtitle() -> String {
		return ""
	}
}
