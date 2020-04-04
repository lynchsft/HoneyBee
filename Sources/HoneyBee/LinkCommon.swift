//
//  LinkCommon.swift
//  HoneyBee
//
//  Created by Alex Lynch on 7/17/18.
//  Copyright © 2018 IAM Apps. All rights reserved.
//

import Foundation

/// Protocol for handling Optionals as a protocol. Useful for generic constraints
public protocol OptionalProtocol {
	/// The type which this optional wraps
	associatedtype WrappedType
	
	/// Return an optional value of the wrapped type.
	///
	/// - Returns: an optional value
	func getWrapped() -> WrappedType?
}

func tname(_ t: Any) -> String {
	return String(describing: type(of: t))
}

infix operator <+ : AdditionPrecedence
infix operator +> : AdditionPrecedence
