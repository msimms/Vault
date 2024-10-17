//
//  LastModifiedView.swift
//  Created by Michael Simms on 7/27/22.
//

//	MIT License
//
//  Copyright (c) 2022 Michael J Simms. All rights reserved.
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

struct LastModifiedView: View {
	private let dateFormatter: DateFormatter
	private var timestamp: Date?
	
	init(isNewItem: Bool, timestamp: Date?) {
		self.dateFormatter = DateFormatter()
		self.dateFormatter.dateStyle = .long
		self.dateFormatter.timeStyle = .short
		self.timestamp = timestamp
	}

	var body: some View {
		Group() {
			Text("Last Modified")
				.fontWeight(.heavy)
			if timestamp != nil {
				Text(timestamp!, formatter: dateFormatter)
			}
			else {
				Text("Not set")
			}
		}
		.padding(EdgeInsets(top: 2.5, leading: 0, bottom: 0, trailing: 0))
	}
}
