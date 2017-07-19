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
	/// - Parameter errorHandler: a function which takes an Error and an `Any` context object. The context object is usual the object which was being acted upon when the error occurred.
	/// - Returns: A `ProcessLink` which has `errorHandler` installed
	func setErrorHandler(_ errorHandler: @escaping (Error, Any) -> Void ) -> ProcessLink<A, B>
}
