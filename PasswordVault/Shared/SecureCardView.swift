//
//  SecureCardView.swift
//  Created by Michael Simms on 5/14/22.
//

import SwiftUI

/// Displays a login item from the vault.
struct SecureCardView: View {
	@ObservedObject var appModel = AppState.shared
	@Binding var isPushed: Bool
	@State var item: SecureCardItem
	@State var isNewItem: Bool = true
	@State var isReadOnly: Bool = false
	@State var showsDatePicker: Bool = false
	@State private var tempSecurityCode: String = ""
	@State private var tempExpiryDate: String = ""

	let dateFormatter: DateFormatter = {
		let df = DateFormatter()
		df.dateStyle = .medium
		return df
	}()

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
//								.keyboardType(.decimalPad)
							HStack {
								Text("Expiry Date")
								Spacer()
								Text("\(self.dateFormatter.string(from: item.expiry))")
									.onTapGesture {
										self.showsDatePicker.toggle()
									}
									.padding(EdgeInsets(top: 2, leading: 10, bottom: 2, trailing: 10))
									.disabled(isReadOnly)
							}
							if self.showsDatePicker {
								DatePicker("", selection: $item.expiry, displayedComponents: .date)
									.datePickerStyle(.graphical)
							}
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
