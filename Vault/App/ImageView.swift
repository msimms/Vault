//
//  ImageView.swift
//  Created by Michael Simms on 7/21/26.
//

import SwiftUI

#if canImport(UIKit)
import UIKit
typealias PlatformImage = UIImage
#elseif canImport(AppKit)
import AppKit
typealias PlatformImage = NSImage
#endif

struct ImageView: View {
	let imageData: Data

	var body: some View {
		VStack(alignment: .leading) {
			ScrollView() {
				if self.imageData.count > 0 {
					if let image = PlatformImage(data: self.imageData) {
#if canImport(UIKit)
						Image(uiImage: image)
							.resizable()
							.scaledToFit()
#elseif canImport(AppKit)
						Image(nsImage: image)
							.resizable()
							.scaledToFit()
#endif
					} else {
						ContentUnavailableView("Invalid image", systemImage: "photo")
					}
				}
			}
		}
		.padding(10)
	}
}
