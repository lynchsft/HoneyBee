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
	var firstLink: Link<T>?
	
	init(blockPerformer: AsyncBlockPerformer, path: [String]) {
		self.blockPerformer = blockPerformer
		self.path = path
	}
	
	public func setErrorHandler(_ errorHandler: @escaping (ErrorContext) -> Void ) -> Link<T> {
		let function = {(a: Any, block: @escaping (FailableResult<T>) -> Void) -> Void in
			guard let t = a as? T else {
				preconditionFailure("a is not of type T")
			}
			block(.success(t))
		}
		self.firstLink = Link<T>(function: function,
								 errorHandler: errorHandler,
								 blockPerformer: self.blockPerformer,
								 errorBlockPerformer: self.blockPerformer,
								 path: self.path,
								 functionFile: #file,
								 functionLine: #line)
		return firstLink!
	}
	
	public func setCompletionHandler(_ errorHandler: @escaping (Error?) -> Void ) -> Link<T> {
		return self.setCompletionHandler { (context: ErrorContext?) in
			errorHandler(context?.error)
		}
	}
	
	public func setCompletionHandler(_ errorHandler: @escaping (ErrorContext?) -> Void ) -> Link<T> {
		let finallyCalled: AtomicBool = false
		let blockPerformer = self.blockPerformer
		return self.setErrorHandler({ (context: ErrorContext) in
			finallyCalled.access { called in
				errorHandler(context)
				called = true
			}
		}).finally { link in
			link.chain{ (_:T, completion: @escaping ()->Void) -> Void in
				if finallyCalled.get() == false {
					blockPerformer.asyncPerform {
						errorHandler(nil)
						completion()
					}
				} else {
					completion()
				}
			}
		}
	}
		
	override func execute(argument: Any, completion: @escaping () -> Void) -> Void {
		guard let firstLink = self.firstLink else {
			preconditionFailure("Must supply an error handler before executing")
		}
		firstLink.execute(argument: argument, completion: completion)
	}
}
