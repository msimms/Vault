//
//  VaultView.swift
//  PasswordVault (iOS)
//
//  Created by Michael Simms on 4/22/22.
//

import SwiftUI
import Combine

// -*- coding: utf-8 -*-
//
// # MIT License
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

protocol VaultViewModel : ObservableObject {
	var title: String { get set }
	var subtitle: String { get set }
}

struct VaultItemView<Model>: View where Model: VaultViewModel {
	@ObservedObject var viewModel: Model

	var body: some View {
		VStack {
			TextField("Item Title", text: $viewModel.title)
			TextField("Item Subtitle", text: $viewModel.subtitle)
		}
	}
}

extension VaultViewModel {
	var title: String {
		get { "Defaullt Title" }
		set { }
	}
	var subtitle: String {
		get { "Default Subtitle" }
		set { }
	}
}

class SecureLoginModel: VaultViewModel {
	@Published var title: String
	@Published var subtitle: String

	init(_ title: String, subtitle: String) {
		self.title = title
		self.subtitle = subtitle
	}
}
