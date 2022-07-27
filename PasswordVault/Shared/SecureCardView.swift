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
	//private let dateFormatter: DateFormatter

	/*init(isPushed: Binding<Bool>, item: SecureCardItem, isNewItem: Bool) {
		self.isPushed = isPushed
		self.item = item
		self.isNewItem = isNewItem
		self.dateFormatter = DateFormatter()
		self.dateFormatter.dateStyle = .long
		self.dateFormatter.timeStyle = .short
	}*/

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
					TagView(tags: item.tags)
					Text("Last Modified")
						.fontWeight(.heavy)
					//Text(item.lastModifiedTime!, formatter: dateFormatter)
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
