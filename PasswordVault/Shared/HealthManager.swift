//
//  HealthManager.swift
//  Created by Michael Simms on 10/7/22.
//

//	MIT License
//
//  Copyright © 2023 Michael J Simms. All rights reserved.
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

import Foundation
import HealthKit
import CoreLocation

class HealthManager : ObservableObject {
	static let shared = HealthManager()

	private let healthStore = HKHealthStore()
	private var queryGroup: DispatchGroup = DispatchGroup() // tracks queries until they are completed
	private var hrQuery: HKQuery? = nil // the query that reads heart rate on the watch
	@Published var maxHr: Double?

	private init() {
	}
	
	func requestAuthorization() {
		
		// Check for HealthKit availability.
		guard HKHealthStore.isHealthDataAvailable() else {
			return
		}
		
		// Request authorization for things to read and write.
		let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!
		let readTypes = Set([heartRateType])
		healthStore.requestAuthorization(toShare: nil, read: readTypes) { result, error in
		}
	}

	func mostRecentQuantitySampleOfType(quantityType: HKQuantityType, callback: @escaping (HKQuantitySample?, Error?) -> ()) {
		
		// Since we are interested in retrieving the user's latest sample, we sort the samples in descending
		// order, and set the limit to 1. We are not filtering the data, and so the predicate is set to nil.
		let timeSortDescriptor = NSSortDescriptor.init(key: HKSampleSortIdentifierEndDate, ascending: false)
		let query = HKSampleQuery.init(sampleType: quantityType, predicate: nil, limit: 1, sortDescriptors: [timeSortDescriptor], resultsHandler: { query, results, error in
			
			// Error case: Call the callback handler, passing nil for the results.
			if results == nil || results!.count == 0 {
				callback(nil, error)
			}
			
			// Normal case: Call the callback handler with the results.
			else {
				let sample = results!.first as! HKQuantitySample?
				callback(sample, error)
			}
		})
		
		// Execute asynchronously.
		self.healthStore.execute(query)
	}

	func recentQuantitySamplesOfType(quantityType: HKQuantityType, callback: @escaping (HKQuantitySample?, Error?) -> ()) {
		
		let oneYear = (365.25 * 24.0 * 60.0 * 60.0)
		let startDate = Date(timeIntervalSince1970: Date().timeIntervalSince1970 - oneYear)
		let predicate = HKQuery.predicateForSamples(withStart: startDate, end: nil, options: [.strictStartDate])

		let query = HKSampleQuery.init(sampleType: quantityType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil, resultsHandler: { query, results, error in
			
			// Error case: Call the callback handler, passing nil for the results.
			if results == nil || results!.count == 0 {
				callback(nil, error ?? nil)
			}
			
			// Normal case: Call the callback handler with the results.
			else {
				for sample in results! {
					let quantitySample = sample as! HKQuantitySample?
					callback(quantitySample, error)
				}
			}
		})
		
		// Execute asynchronously.
		self.healthStore.execute(query)
	}

	func quantitySamplesOfType(quantityType: HKQuantityType, callback: @escaping (HKQuantitySample?, Error?) -> ()) {
		
		// We are not filtering the data, and so the predicate is set to nil.
		let query = HKSampleQuery.init(sampleType: quantityType, predicate: nil, limit: HKObjectQueryNoLimit, sortDescriptors: nil, resultsHandler: { query, results, error in
			
			// Error case: Call the callback handler, passing nil for the results.
			if results == nil || results!.count == 0 {
				callback(nil, error ?? nil)
			}
			
			// Normal case: Call the callback handler with the results.
			else {
				for sample in results! {
					let quantitySample = sample as! HKQuantitySample?
					callback(quantitySample, error)
				}
			}
		})
		
		// Execute asynchronously.
		self.healthStore.execute(query)
	}

	func subscribeToQuantitySamplesOfType(quantityType: HKQuantityType, callback: @escaping (HKQuantity?, Date?, Error?) -> ()) -> HKQuery {

		let datePredicate = HKQuery.predicateForSamples(withStart: Date(), end: nil, options:HKQueryOptions.strictStartDate)
		let query = HKAnchoredObjectQuery.init(type: quantityType, predicate: datePredicate, anchor: nil, limit: HKObjectQueryNoLimit, resultsHandler: { query, addedObjects, deletedObjects, newAnchor, error in
			
			if addedObjects != nil {
				for sample in addedObjects! {
					if let quantitySample = sample as? HKQuantitySample {
						callback(quantitySample.quantity, quantitySample.endDate, error)
					}
				}
			}
		})
		
		query.updateHandler = { query, addedObjects, deletedObjects, newAnchor, error in
			for sample in addedObjects! {
				if let quantitySample = sample as? HKQuantitySample {
					callback(quantitySample.quantity, quantitySample.endDate, error)
				}
			}
		}
		
		// Execute asynchronously.
		self.healthStore.execute(query)

		// Background delivery.
		self.healthStore.enableBackgroundDelivery(for: quantityType, frequency: .immediate, withCompletion: {(succeeded: Bool, error: Error!) in
		})

		return query
	}

	/// @brief Estimates the user's maximum heart rate from the last six months of HealthKit data.
	func getMaxHr() throws {
		let hrType = HKObjectType.quantityType(forIdentifier: .heartRate)!
		
		self.recentQuantitySamplesOfType(quantityType: hrType) { sample, error in
			if sample != nil {
				let hrUnit: HKUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
				let hrValue = sample!.quantity.doubleValue(for: hrUnit)

				if self.maxHr == nil || hrValue > self.maxHr! {
					self.maxHr = hrValue
				}
			}
		}
	}
}
