//
//  TagsView.swift
//  Created by Michael Simms on 7/27/22.
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

struct TagsView: View {
	@Binding var isPushed: Bool
	@Binding var isReadOnly: Bool
	@Binding var tags: Array<String>
	@State var isShowingNewTagView: Bool = false
	@State var newTag: String = ""

	var body: some View {

		Group() {
			Text("Tags")
				.fontWeight(.heavy)

			VStack(alignment: .leading) {
				// Existing tags
				if self.tags.count > 0 {
					HStack() {
						ForEach(self.$tags, id: \.self) { $tag in
							Button(action: {}) {
								Text(tag)
							}
							.padding()
							.background(Color.blue)
							.foregroundColor(.white)
							.cornerRadius(10)
							.buttonStyle(PlainButtonStyle())
						}
					}
				}
				else {
					Text("None")
				}

				// Link for moving to the New Tag view.
				NavigationLink(destination: NewTagView(isPushed: self.$isShowingNewTagView, tags: self.$tags)) {
					Label("New Tag...", systemImage: "tag")
				}
				.opacity(self.isReadOnly ? 0 : 1)
				.padding()
			}
		}
	}
}
