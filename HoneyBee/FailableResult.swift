//
//  FailableResult.swift
//  HoneyBee
//
//  Created by Alex Lynch on 1/16/17.
//  Copyright © 2017 IAM Apps. All rights reserved.
//

import Foundation

public protocol FailableResultProtocol {
	associatedtype Wrapped
	
	func value() throws -> Wrapped
}

public enum FailableResult<T> : FailableResultProtocol{
	case success(T)
	case failure(Swift.Error)
	
	public func value() throws -> T {
		switch(self) {
		case let .success(t) :
			return t
		case let .failure(error) :
			throw error
		}
	}
}


