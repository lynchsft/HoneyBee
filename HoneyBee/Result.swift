//
//  Result.swift
//  HoneyBee
//
//  Created by Alex Lynch on 1/16/17.
//  Copyright © 2017 IAM Apps. All rights reserved.
//

import Foundation

extension Result {
	public func value() throws -> Success {
		switch(self) {
		case let .success(t) :
			return t
		case let .failure(error) :
			throw error
		}
	}
}

public extension Result where Failure == Error {
	
	/// implement functor API
	internal func map<R>(_ transform: (Success) throws -> R) -> Result<R, Failure> {
		switch self {
		case let .failure(error):
			return .failure(error) // switch generic types
		case let .success(t) :
			do {
				return .success(try transform(t))
			} catch {
				return Result<R, Failure>.failure(error)
			}
		}
	}
}


