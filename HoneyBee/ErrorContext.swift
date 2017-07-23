//
//  ErrorContext.swift
//  HoneyBee
//
//  Created by Alex Lynch on 7/23/17.
//  Copyright © 2017 IAM Apps. All rights reserved.
//

import Foundation

/// `ErrorContext` encapsulates all of the available debugging information about an erroring function in a `ProcessLink`.
public struct ErrorContext {
	
	/// The subject of an error captured by a `ProcessLink`. The subject is the `A` value of the failing link, which is usually either the receiver or the first argument of the `ProcessLink` function.
	public let subject: Any
}
