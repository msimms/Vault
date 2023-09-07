//
//  SecureCardView.swift
//  Created by Michael Simms on 5/14/22.
//

import SwiftUI

/// Displays a login item from the vault.
struct SecureCardView: View {
	@Binding var isPushed: Bool
	@State var item: SecureCardItem
	@State var isNewItem: Bool = true
	@State var isReadOnly: Bool = false
	@State private var showsDatePicker: Bool = false
	@State private var tempExpiryDate: String = ""

	let dateFormatter: DateFormatter = {
		let df = DateFormatter()
		df.dateFormat = "yyyy-MM"
		return df
	}()

	var body: some View {

		VStack(alignment: .leading) {

			Group() {
				HStack() {
					Image(systemName: icon(item: self.item))
						.imageScale(.large)
					Text("Card")
						.fontWeight(.heavy)
						.font(.system(size: 32))
						.multilineTextAlignment(.center)
				}
				Divider()
				VStack(alignment: .leading) {
					Group() {
						Text("Title")
							.fontWeight(.heavy)
						TextField("Title", text: self.$item.name)
							.disabled(self.isReadOnly)
					}
					Group() {
						Text("Card Holder")
							.fontWeight(.heavy)
						TextField("Card Holder", text: self.$item.cardHolder)
							.disabled(self.isReadOnly)
						Text("Card Type")
							.fontWeight(.heavy)
						TextField("Card Type", text: self.$item.cardType)
							.disabled(self.isReadOnly)
						Text("Number")
							.fontWeight(.heavy)
						TextField("Number", text: self.$item.number)
							.disabled(self.isReadOnly)
						Text("Security Code")
							.fontWeight(.heavy)
						TextField("Security Code", value: self.$item.securityCode, formatter: NumberFormatter())
							.disabled(self.isReadOnly)
						HStack {
							Text("Expiry Date")
								.fontWeight(.heavy)
							Spacer()
							Text("\(self.dateFormatter.string(from: self.item.expiry))")
								.onTapGesture {
									self.showsDatePicker.toggle()
								}
								.padding(EdgeInsets(top: 2, leading: 10, bottom: 2, trailing: 10))
								.disabled(self.isReadOnly)
						}
						if self.showsDatePicker {
							DatePicker("", selection: self.$item.expiry, displayedComponents: .date)
								.datePickerStyle(.graphical)
						}
					}
					Group() {
						AttachFilesView(isReadOnly: self.$isReadOnly, item: self.item)
					}
					Group() {
						Text("Notes")
							.fontWeight(.heavy)
						TextEditor(text: self.$item.note)
							.disabled(self.isReadOnly)
					}
					TagsView(isReadOnly: self.$isReadOnly, tags: self.$item.tags)
					LastModifiedView(isNewItem: isNewItem, timestamp: self.item.lastModifiedTime)
				}
			}

			Spacer()
			ItemButtonView(isReadOnly: self.$isReadOnly, item: self.item, isNewItem: self.isNewItem)
		}
		.padding(10)
	}
}
