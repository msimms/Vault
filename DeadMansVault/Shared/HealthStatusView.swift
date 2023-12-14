//
//  HealthStatusView.swift
//  Created by Michael Simms on 12/13/23.
//

import SwiftUI

struct HealthStatusView: View {
    var body: some View {
		VStack(alignment: .center) {
			if AppState.shared.healthMgr.isHealthDataAvailable() {
				Text("Most Recent Health Data")
				if AppState.shared.healthMgr.mostRecent != nil {
					Text(AppState.shared.healthMgr.mostRecent!.ISO8601Format())
				}
			}
			else {
				Text("Health data is not available on this device.")
			}
		}
    }
}

#Preview {
    HealthStatusView()
}
