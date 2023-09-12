//
//  AttachFilesView.swift
//  Created by Michael Simms on 9/6/23.
//

import SwiftUI
import UniformTypeIdentifiers

struct VaultAttachment: FileDocument {
	static var readableContentTypes: [UTType] { [.data] }
	
	var data: Data
	
	init(data: Data) {
		self.data = data
	}
	
	init(configuration: ReadConfiguration) throws {
		guard let data = configuration.file.regularFileContents else {
			throw CocoaError(.fileReadCorruptFile)
		}
		self.data = data
	}
	
	func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
		return FileWrapper(regularFileWithContents: self.data)
	}
}

struct AttachFilesView: View {
	@Binding var isReadOnly: Bool
	@State var item: SecureVaultItem
	@State private var isShowingFileSourceSelection: Bool = false
	@State private var isShowingSavePanel: Bool = false
	
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
				Button(action: {
					self.isShowingSavePanel = true
				}, label: {
					HStack() {
						Image(systemName: "doc")
							.foregroundColor(.secondary)
						Text(attachmentName)
					}
				})
				.fileExporter(isPresented: self.$isShowingSavePanel,
							  document: VaultAttachment(data: getAttachment(attachmentName: attachmentName)),
							  contentType: .data,
							  defaultFilename: attachmentName) { result in
				}
			}
		}
	}

	private var allKeys: [String] {
		return self.item.attachments.keys.sorted().map { String($0) }
	}
	
	private func getAttachment(attachmentName: String) -> Data {
		do {
			let data = self.item.attachments[attachmentName]!
			let expandedData = try (data as NSData).decompressed(using: .lzfse)
			return Data(expandedData)
		}
		catch {
		}
		return Data()
	}
}
