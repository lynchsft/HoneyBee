//
//  RootLink.swift
//  HoneyBee
//
//  Created by Alex Lynch on 7/8/17.
//  Copyright © 2017 IAM Apps. All rights reserved.
//

import Foundation

/// `RootLink` is returned by `HoneyBee.start()`. The only operation supported by `RootLink` is `setErrorHandler`
final public class RootLink : Executable, ErrorHandling {
	public typealias B = Void
	
	
	let path: [String]
	let blockPerformer: AsyncBlockPerformer
	var firstLink: Link<B>?
	
	init(blockPerformer: AsyncBlockPerformer, path: [String]) {
		self.blockPerformer = blockPerformer
		self.path = path
	}
	
	public func setErrorHandler(_ errorHandler: @escaping (ErrorContext) -> Void ) -> Link<B> {
		let function = {(a: Any, block: @escaping (FailableResult<B>) -> Void) -> Void in
			guard let t = a as? B else {
				preconditionFailure("a is not of type B")
			}
			block(.success(t))
		}
		self.firstLink = Link<B>(function: function,
								 errorHandler: errorHandler,
								 blockPerformer: self.blockPerformer,
								 errorBlockPerformer: self.blockPerformer,
								 path: self.path,
								 functionFile: #file,
								 functionLine: #line)
		
		self.blockPerformer.asyncPerform {
			self.execute(argument: Void(), completion: { })
		}
		
		return firstLink!
	}
	
	/// Set the completion handling function for the recipe.
	/// The completion handler will be invoked exactly one time per error in the recipe or
	/// if the recipe does not error, the completion handler will be invoked with a nil argument
	/// once after the entire recipe has completed.
	///
	/// - Parameter completionHandler: a function which takes an optional error.
	/// - Returns: A `Link` which has the completion handler installed.
	public func setCompletionHandler(_ completionHandler: @escaping (Error?) -> Void ) -> Link<B> {
		return self.setCompletionHandler { (context: ErrorContext?) in
			completionHandler(context?.error)
		}
	}
	
	/// Set the completion handling function for the recipe.
	/// The completion handler will be invoked exactly one time per error in the recipe or
	/// if the recipe does not error, the completion handler will be invoked with a nil argument
	/// once after the entire recipe has completed.
	///
	/// - Parameter completionHandler: a function which takes an optional `ErrorContext`. The context contains all available debug information on the erroring function, including the error itself.
	/// - Returns: A `Link` which has the completion handler installed.
	public func setCompletionHandler(_ completionHandler: @escaping (ErrorContext?) -> Void ) -> Link<B> {
		let finallyCalled: AtomicBool = false
		let blockPerformer = self.blockPerformer
		return self.setErrorHandler({ (context: ErrorContext) in
			finallyCalled.access { called in
				completionHandler(context)
				called = true
			}
		}).finally { link in
			link.chain{ (_:B, completion: @escaping ()->Void) -> Void in
				if finallyCalled.get() == false {
					blockPerformer.asyncPerform {
						completionHandler(nil)
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
