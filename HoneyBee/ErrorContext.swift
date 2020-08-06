//
//  ErrorContext.swift
//  HoneyBee
//
//  Created by Alex Lynch on 7/23/17.
//  Copyright © 2017 IAM Apps. All rights reserved.
//

import Foundation

/// `ErrorContext` encapsulates all of the available debugging information about an		function in a `Link`.
public struct ErrorContext<E: Error> {
	
	/// The subject of an error captured by a `Link`. The subject is the `A` value of the failing link, which is usually either the receiver or the first argument of the `Link` function.
	public let subject: Any
	
	/// The error which this context encapsulates.
	public let error: E
		
	/// A represention of the path of `Links` which result in the erroring `Link`.
	public let trace: AsyncTrace
}

extension ErrorContext {
    func extend(with asyncTrace: AsyncTrace) -> Self {
        let newContext = ErrorContext(subject: subject, error: error, trace: trace.join(asyncTrace))
        assert(!newContext.trace.trace.contains(.join), "newContext's trace should be a pure extension")
        return newContext
    }
}
