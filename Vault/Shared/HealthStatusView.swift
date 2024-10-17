//
//  HealthStatusView.swift
//  Created by Michael Simms on 12/13/23.
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

struct HealthStatusView: View {
    var body: some View {
		VStack(alignment: .center) {
			if AppState.shared.healthMgr.isHealthDataAvailable() {
				VStack() {
					Text("Most Recent Health Data")
						.fixedSize(horizontal: false, vertical: true)
						.bold()
					VStack() {
						Image(systemName: "exclamationmark.circle")
						Text("Data from HealthKit is used to know if the vault owner is alive.")
							.fixedSize(horizontal: false, vertical: true)
					}
					.padding(5)
					Group() {
						if AppState.shared.healthMgr.mostRecentHealthRecordDate != nil {
							Text(AppState.shared.healthMgr.mostRecentHealthRecordDate!.ISO8601Format())
						}
						else {
							VStack() {
								Image(systemName: "exclamationmark.circle")
								Text("No health records found!")
							}
						}
					}
					.padding(5)
				}
			}
			else {
				HStack() {
					Image(systemName: "exclamationmark.circle")
					Text("Health data is not available on this device. Data from HealthKit is used to determine if the vault owner is alive.")
						.fixedSize(horizontal: false, vertical: true)
				}
			}
		}
    }
}

#Preview {
    HealthStatusView()
}
