//
//  FailureRate.swift
//  HoneyBee
//
//  Created by Alex Lynch on 10/4/17.
//  Copyright © 2017 IAM Apps. All rights reserved.
//

import Foundation

enum FailureRateError : Error {
	case failureRateExceeded(FailureRate)
}

/**
* Enum representing the amount of failure which is acceptable in a SIMD parallel behavior (such as map and filter).
*/
public enum FailureRate {
	/// Expreses acceptable failure rate as a ratio. Must be => 0 and <= 1.
	/// For example `.ratio(0.1)` permits up to, but not more than, ten percent of the parallel operations to fail.
	case ratio(Double)
	/// Expresses acceptable failure rate as a count. Must be => 0
	/// For example `.count(2)` permis up to, but not more than 2 of the parallel operations to fail.
	case count(Int)
	
	/// Convenience property expresssing that no failures are acceptable.
	public static let none = FailureRate.count(0)
	/// Convenience property expresssing that total failure is acceptable.
	public static let full = FailureRate.ratio(1.0)
	
	func checkExceeded(byFailures failures: Int, `in` total: Int) throws -> Void {
		guard failures >= 0 else {
			preconditionFailure("failures must be non-negative")
		}
		
		guard total >= 0 else {
			preconditionFailure("total must be non-negative")
		}
		
		guard failures <= total else {
			preconditionFailure("failures must be <= total")
		}
		
		switch self {
		case .ratio(let ratio):
			guard ratio <= 1.0 && ratio >= 0.0 else {
				preconditionFailure("ratio must be between 0.0 and 1.0")
			}
			let failureRate = Double(failures)/Double(total)
			if failureRate > ratio {
				throw FailureRateError.failureRateExceeded(self)
			}
		case .count(let count):
			guard count >= 0 else {
				preconditionFailure("count must be >= 0")
			}
			if failures > count {
				throw FailureRateError.failureRateExceeded(self)
			}
		}
	}
}
