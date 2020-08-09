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
    func mapError<OtherE: Error>(_ transform: (_ error: E) -> OtherE) -> ErrorContext<OtherE> {
        .init(subject: subject, error: transform(error), trace: trace)
    }
}
