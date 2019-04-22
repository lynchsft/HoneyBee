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
/// The outbound type of an implmementing `Link`
	associatedtype B
	associatedtype Performer: AsyncBlockPerformer
	
	/// Return a new link which uses the new error handling function
	///
	/// - Parameter errorHandler: a function which takes an `ErrorContext`. The context contains all available debug information on the erroring function, including the error itself.
	/// - Returns: A new `Link` which has `errorHandler` installed
	func handlingErrors(file: StaticString, line: UInt, with errorHandler: @escaping (ErrorContext) -> Void ) -> Link<B, Performer>
}

extension ErrorHandling {
	/// Set the error handling function for the receiver.
	///
	/// - Parameter errorHandler: - Parameter errorHandler: a function which takes an Error argument.
	/// - Returns: A `Link` which has `errorHandler` installed
	@available(swift, obsoleted: 5.0, renamed: "handlingErrors(with:)")
	public func setErrorHandler(file: StaticString = #file, line: UInt = #line, _ errorHandler: @escaping (Error) -> Void ) -> Link<B, Performer> {
		return self.handlingErrors(file: file, line: line) { (context: ErrorContext) in
			errorHandler(context.error)
		}
	}
	
	/// Return a new link which uses the new error handling function
	///
	/// - Parameter errorHandler: - Parameter errorHandler: a function which takes an Error argument.
	/// - Returns: A `Link` which has `errorHandler` installed
	public func handlingErrors(file: StaticString = #file, line: UInt = #line, with errorHandler: @escaping (Error) -> Void ) -> Link<B, Performer> {
		return self.handlingErrors(file: file, line: line, with: { (context: ErrorContext) in
			errorHandler(context.error)
		})
	}
}
