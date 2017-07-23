//
//  RootLink.swift
//  HoneyBee
//
//  Created by Alex Lynch on 7/8/17.
//  Copyright © 2017 IAM Apps. All rights reserved.
//

import Foundation

/// `RootLink` is returned by `HoneyBee.start()`. The only operation supported by `RootLink` is `setErrorHandler`
final public class RootLink<T> : Executable<T>, ErrorHandling {
	
	let path: [String]
	let blockPerformer: AsyncBlockPerformer
	var firstLink: ProcessLink<T,T>?
	
	init(blockPerformer: AsyncBlockPerformer, path: [String]) {
		self.blockPerformer = blockPerformer
		self.path = path
	}
	
	public func setErrorHandler(_ errorHandler: @escaping (Error, ErrorContext) -> Void ) -> ProcessLink<T,T> {
		let function = {(a: T, block: @escaping (T) -> Void) throws -> Void
			in block(a)
		}
		self.firstLink = ProcessLink<T, T>(function: function, errorHandler: errorHandler, blockPerformer: self.blockPerformer, path: self.path + ["root"])
		return firstLink!
	}
		
	override func execute(argument: T, completion: @escaping (Continue) -> Void) -> Void {
		guard let firstLink = self.firstLink else {
			preconditionFailure("Must supply an error handler before executing")
		}
		firstLink.execute(argument: argument, completion: completion)
	}
}
