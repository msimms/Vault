//
//  AttachFilesView.swift
//  Created by Michael Simms on 9/6/23.
//

import SwiftUI

struct AttachFilesView: View {
	@Binding var isReadOnly: Bool
	@State var item: SecureVaultItem
	@State private var isShowingFileSourceSelection: Bool = false
	
	var body: some View {
		Text("Attached Files")
			.fontWeight(.heavy)
		Button(action: {
#if os(macOS)
			let selectedUrl = showOpenPanel()
			if selectedUrl != nil {
				self.item.attachFile(url: selectedUrl!)
			}
#else
			self.isShowingFileSourceSelection = true
#endif
		}) {
			HStack() {
				Image(systemName: "doc")
					.foregroundColor(.secondary)
				Text("Attach files...")
			}
		}
		.confirmationDialog("Select the source of the file", isPresented: self.$isShowingFileSourceSelection, titleVisibility: .visible) {
			Button("Photos") {
#if os(iOS)
				PhotoPicker(callback: { image in
					self.item.attachPhoto(image: image)
				})
#endif
			}
			Button("Cancel") {
			}
		}
		.disabled(self.isReadOnly)
		VStack() {
			ForEach(allKeys, id: \.self) { attachmentName in
				HStack() {
					Image(systemName: "doc")
						.foregroundColor(.secondary)
					Text(attachmentName)
				}
			}
		}
	}
	
	private var allKeys: [String] {
		return self.item.attachments.keys.sorted().map { String($0) }
	}
}
