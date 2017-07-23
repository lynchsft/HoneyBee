//
//  ErrorHandling.swift
//  HoneyBee
//
//  Created by Alex Lynch on 7/5/17.
//  Copyright © 2017 IAM Apps. All rights reserved.
//

import Foundation

/// Protocol describing common error handling behavior.
public protocol ErrorHandling {
	associatedtype A
	associatedtype B
	
	/// Set the error handling function for the receiver.
	///
	/// - Parameter errorHandler: a function which takes an Error and an `ErrorContext`. The context contains all available debug information on the erroring function.
	/// - Returns: A `ProcessLink` which has `errorHandler` installed
	func setErrorHandler(_ errorHandler: @escaping (Error, ErrorContext) -> Void ) -> ProcessLink<A, B>
}

extension ErrorHandling {
	/// Set the error handling function for the receiver.
	///
	/// - Parameter errorHandler: - Parameter errorHandler: a function which takes an Error argument.
	/// - Returns: A `ProcessLink` which has `errorHandler` installed
	public func setErrorHandler(_ errorHandler: @escaping (Error) -> Void ) -> ProcessLink<A, B> {
		return self.setErrorHandler { (error, context) in
			errorHandler(error)
		}
	}
}
