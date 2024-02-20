//
//  HealthStatusView.swift
//  Created by Michael Simms on 12/13/23.
//

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
