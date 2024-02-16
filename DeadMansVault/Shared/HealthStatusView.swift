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
						.bold()
					Text("Data from HealthKit is used to determine if the vault owner is dead or alive.")
					if AppState.shared.healthMgr.mostRecentHealthRecordDate != nil {
						Text(AppState.shared.healthMgr.mostRecentHealthRecordDate!.ISO8601Format())
					}
				}
			}
			else {
				HStack() {
					Image(systemName: "exclamationmark.circle")
					Text("Health data is not available on this device. Data from HealthKit is used to determine if the vault owner is dead or alive.")
				}
			}
		}
    }
}

#Preview {
    HealthStatusView()
}
