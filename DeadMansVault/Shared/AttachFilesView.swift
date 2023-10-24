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
	@State private var isShowingDeleteConfirmation: Bool = false
	@State private var isShowingPhotoPicker: Bool = false
	@State private var isShowingDocPicker: Bool = false
	
	var body: some View {
		Group() {
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
#if os(iOS)
				Button("Photos") {
					self.isShowingPhotoPicker = true
				}
				Button("iCloud Drive") {
					self.isShowingDocPicker = true
				}
#endif
			}
			.disabled(self.isReadOnly)
#if os(iOS)
			.sheet(isPresented: self.$isShowingPhotoPicker) {
				PhotoPicker(callback: { image, name in
					self.item.attachPhoto(image: image, name: name)
				})
			}
			.sheet(isPresented: self.$isShowingDocPicker) {
				let _ = DocumentPicker(contentTypes: [UTType.pdf, UTType.text], callback: { url in
				})
			}
#endif
			VStack() {
				ForEach(allKeys, id: \.self) { attachmentName in
					HStack() {
						// Item button
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
						
						// Delete button
						Button(action: {
							self.isShowingDeleteConfirmation = true
						}, label: {
							HStack() {
								Image(systemName: "trash")
									.foregroundColor(.red)
								Text("Delete")
							}
						})
						.confirmationDialog("Are you sure you want to delete this? This cannot be undone.", isPresented: self.$isShowingDeleteConfirmation, titleVisibility: .visible) {
							Button("Yes", role: .destructive) {
								self.item.removeAttachment(name: attachmentName)
							}
							Button("No", role: .cancel) {
							}
						}
						.disabled(self.isReadOnly)
					}
				}
			}
		}
		.padding(EdgeInsets(top: 2.5, leading: 0, bottom: 0, trailing: 0))
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
