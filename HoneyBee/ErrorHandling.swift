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
	associatedtype B
	
	/// Set the error handling function for the receiver.
	///
	/// - Parameter errorHandler: a function which takes an `ErrorContext`. The context contains all available debug information on the erroring function, including the error itself.
	/// - Returns: A `Link` which has `errorHandler` installed
	func setErrorHandler(_ errorHandler: @escaping (ErrorContext) -> Void ) -> Link<B>
}

extension ErrorHandling {
	/// Set the error handling function for the receiver.
	///
	/// - Parameter errorHandler: - Parameter errorHandler: a function which takes an Error argument.
	/// - Returns: A `Link` which has `errorHandler` installed
	public func setErrorHandler(_ errorHandler: @escaping (Error) -> Void ) -> Link<B> {
		return self.setErrorHandler { (context: ErrorContext) in
			errorHandler(context.error)
		}
	}
}
