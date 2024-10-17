//
//  PhotoPicker.swift
//  Created by Michael Simms on 8/7/23.
//

//	MIT License
//
//  Copyright (c) 2023 Michael J Simms. All rights reserved.
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
import PhotosUI

#if os(iOS)

typealias PhotoResponse = (_: UIImage, _: String) -> ()

struct PhotoPicker: UIViewControllerRepresentable {
	var callback: PhotoResponse

	func makeUIViewController(context: Context) -> PHPickerViewController {
		var config = PHPickerConfiguration()
		config.selectionLimit = 3
		config.filter = .images

		let picker = PHPickerViewController(configuration: config)
		picker.delegate = context.coordinator

		return picker
	}

	func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
	}

	func makeCoordinator() -> PhotoPickerCoordinator {
		PhotoPickerCoordinator(self)
	}
}

class PhotoPickerCoordinator: NSObject, PHPickerViewControllerDelegate {
	let parent: PhotoPicker
	
	init(_ parent: PhotoPicker) {
		self.parent = parent
	}
	
	func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
		picker.dismiss(animated: true)
		
		for result in results {
			let provider = result.itemProvider
			
			if provider.canLoadObject(ofClass: UIImage.self) {
				provider.loadObject(ofClass: UIImage.self) { image, _ in
					if let tempImage = image as? UIImage {
						self.parent.callback(tempImage, provider.suggestedName ?? "Image")
					}
				}
			}
		}
	}
}

#endif
