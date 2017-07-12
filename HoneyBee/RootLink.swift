//
//  RootLink.swift
//  HoneyBee
//
//  Created by Alex Lynch on 7/8/17.
//  Copyright © 2017 IAM Apps. All rights reserved.
//

import Foundation

final public class RootLink<T> : Executable<T>, ErrorHandling {
	
	let path: [String]
	let queue: DispatchQueue
	var firstLink: ProcessLink<T,T>?
	
	init(queue: DispatchQueue, path: [String]) {
		self.queue = queue
		self.path = path
	}
	
	public func setErrorHandler(_ errorHandler: @escaping (Error, Any) -> Void ) -> ProcessLink<T,T> {
		let function = {(a: T, block: @escaping (T) -> Void) throws -> Void
			in block(a)
		}
		self.firstLink = ProcessLink<T, T>(function: function, errorHandler: errorHandler, queue: self.queue, path: self.path + ["root"])
		return firstLink!
	}
		
	override func execute(argument: T, completion: @escaping (Continue) -> Void) -> Void {
		guard let firstLink = self.firstLink else {
			preconditionFailure("Must supply an error handler before executing")
		}
		firstLink.execute(argument: argument, completion: completion)
	}
}
