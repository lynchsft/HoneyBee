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

/// An enum containing the result of an operation which might fail.
///
/// - success: The operation was successful.
/// - failure: The operation was not successful.
/// - let.success:: The result T of the operation.
/// - let.failure:: The error describing the failure.
public enum FailableResult<T> : FailableResultProtocol {
	/// - success: The operation was successful.
	/// - let.success:: The result T of the operation.
	case success(T)
	/// - failure: The operation was not successful.
	/// - let.failure:: The error describing the failure.
	case failure(Swift.Error)
	
	/// If `self` is `.success` returns value of type `T`
	/// Else if `self` is `.failure` throws error of
	/// - Returns: The contained value
	/// - Throws: An error if the value could not be returned.
	public func value() throws -> T {
		switch(self) {
		case let .success(t) :
			return t
		case let .failure(error) :
			throw error
		}
	}
	
	internal init<Failable>(_ failable: Failable) where Failable : FailableResultProtocol, Failable.Wrapped == T {
		do {
			let t =  try failable.value()
			self = .success(t)
		} catch {
			self = .failure(error)
		}
	}
}


