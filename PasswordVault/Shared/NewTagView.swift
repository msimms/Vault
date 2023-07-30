//
//  NewTagView.swift
//  Created by Michael Simms on 8/2/22.
//

// MIT License
//
// Copyright (c) 2022 Mike Simms
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import SwiftUI

struct NewTagView: View {
	@Binding var isPushed: Bool
	@Binding var tags: Array<String>
	@State var newTag: String = ""

	var body: some View {
		VStack(alignment: .center) {
			Group() {
				Text("New Tag")
					.fontWeight(.heavy)
			}
			.padding(10)
			Divider()
			Group() {
				TextField("New Tag", text: self.$newTag)
			}
			.padding(10)
			Divider()
			Group() {
				HStack() {
#if os(macOS)
					Button(action: {
						self.isPushed = false
					}) {
						Text("Cancel")
					}
#endif
					Button(action: {
						if !self.tags.contains(newTag) {
							self.tags.append(newTag)
						}
						self.isPushed = false
					}) {
						Label("Save", systemImage: "square.and.arrow.down")
					}
				}
			}
			.padding(10)
		}
	}
}
