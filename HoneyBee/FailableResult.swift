//
//  FailableResult.swift
//  HoneyBee
//
//  Created by Alex Lynch on 1/16/17.
//  Copyright © 2017 IAM Apps. All rights reserved.
//

import Foundation

/// Protocol describing a value which might error.
public protocol FailableResultProtocol {
	/// The type of the wrapped value
	associatedtype Wrapped
	
	/// Either returns the value or throws an error.
	///
	/// - Returns: The contained value
	/// - Throws: An error if the value could not be returned.
	func value() throws -> Wrapped
}

extension Result : FailableResultProtocol {
	public func value() throws -> Success {
		switch(self) {
		case let .success(t) :
			return t
		case let .failure(error) :
			throw error
		}
	}
}

public typealias FailableResult<T> = Result<T, Swift.Error>

public extension Result where Failure == Swift.Error {
	
	internal init<Failable>(_ failable: Failable) where Failable : FailableResultProtocol, Failable.Wrapped == Success {
		do {
			let t =  try failable.value()
			self = .success(t)
		} catch {
			self = .failure(error)
		}
	}
	
	/// implement functor API
	internal func map<R>(_ transform: (Wrapped) throws -> R) -> FailableResult<R> {
		switch self {
		case let .failure(error):
			return .failure(error) // switch generic types
		case let .success(t) :
			do {
				return .success(try transform(t))
			} catch {
				return .failure(error)
			}
		}
	}
}


