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

	var body: some View {
		VStack(alignment: .leading) {
			Group() {
				Text("Card")
					.fontWeight(.heavy)
					.font(.system(size: 32))
					.multilineTextAlignment(.center)
				Divider()
				VStack(alignment: .leading) {
					Text("Title")
						.fontWeight(.heavy)
					TextField("Title", text: $item.heading)
					Text("Number")
						.fontWeight(.heavy)
					TextField("Number", text: $item.number)
					Text("Notes")
						.fontWeight(.heavy)
					TextEditor(text: $item.note)
					TagsView(tags: item.tags)
					LastModifiedView(isNewItem: isNewItem, timestamp: item.lastModifiedTime)
				}
			}
			Spacer()
			ItemButtonView(isPushed: self.$isPushed, item: self.item, isNewItem: self.isNewItem)
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
