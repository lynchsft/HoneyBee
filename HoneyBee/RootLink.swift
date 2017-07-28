//
//  RootLink.swift
//  HoneyBee
//
//  Created by Alex Lynch on 7/8/17.
//  Copyright © 2017 IAM Apps. All rights reserved.
//

import Foundation

/// `RootLink` is returned by `HoneyBee.start()`. The only operation supported by `RootLink` is `setErrorHandler`
final public class RootLink<T> : Executable, ErrorHandling {
	
	let path: [String]
	let blockPerformer: AsyncBlockPerformer
	var firstLink: ProcessLink<T>?
	
	init(blockPerformer: AsyncBlockPerformer, path: [String]) {
		self.blockPerformer = blockPerformer
		self.path = path
	}
	
	public func setErrorHandler(_ errorHandler: @escaping (Error, ErrorContext) -> Void ) -> ProcessLink<T> {
		let function = {(a: Any, block: @escaping (FailableResult<T>) -> Void) -> Void in
			guard let t = a as? T else {
				preconditionFailure("a is not of type T")
			}
			block(.success(t))
		}
		self.firstLink = ProcessLink<T>(function: function, errorHandler: errorHandler, blockPerformer: self.blockPerformer, path: self.path, functionFile: #file, functionLine: #line)
		return firstLink!
	}
		
	override func execute(argument: Any, completion: @escaping (Continue) -> Void) -> Void {
		guard let firstLink = self.firstLink else {
			preconditionFailure("Must supply an error handler before executing")
		}
		firstLink.execute(argument: argument, completion: completion)
	}
}
