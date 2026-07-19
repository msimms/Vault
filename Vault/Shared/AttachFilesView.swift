//
//  AttachFilesView.swift
//  Created by Michael Simms on 9/6/23.
//

//	MIT License
//
//  Copyright (c) 2021 Michael J Simms. All rights reserved.
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in all
//	copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//	SOFTWARE.

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
					self.item.attachFile(url: url)
				})
			}
#endif
			VStack(alignment: .leading) {
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
