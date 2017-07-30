//
//  JoinPoint.swift
//  HoneyBee
//
//  Created by Alex Lynch on 2/22/17.
//  Copyright © 2017 IAM Apps. All rights reserved.
//

import Foundation

/// Super type of executable types.
public class Executable {
	typealias Continue = Bool
	func execute(argument: Any, completion: @escaping (Continue) -> Void) -> Void {}
}

final class JoinPoint<A> : Executable, PathDescribing {
	typealias ExecutionResult = (Any, (Continue) -> Void)
	
	private let resultLock = NSLock()
	private var executionResult: ExecutionResult?
	private var resultCallback: ((ExecutionResult) -> Void)?
	private var blockPerformer: AsyncBlockPerformer
	private let errorHandler: ((Error, ErrorContext) -> Void)
	let path: [String]
	
	init(blockPerformer: AsyncBlockPerformer, path: [String], errorHandler: @escaping ((Error, ErrorContext) -> Void)) {
		self.blockPerformer = blockPerformer
		self.path = path
		self.errorHandler = errorHandler
	}
	
	private func yieldResult(_ callback: @escaping (ExecutionResult) -> Void) {
		self.resultLock.lock()
		defer {
			self.resultLock.unlock()
		}
		// this needs to be atomic
		if let result = executionResult {
			callback(result)
		} else {
			self.resultCallback = callback
		}
	}
	
	override func execute(argument: Any, completion: @escaping (Continue) -> Void) {
		self.resultLock.lock()
		defer {
			self.resultLock.unlock()
		}
		executionResult = (argument, completion)
		
		if let resultCallback = self.resultCallback {
			resultCallback((argument, completion))
		}
	}
	
	func conjoin<B>(_ other: JoinPoint<B>) -> ProcessLink<(A,B)> {
		var tuple: (A,B)! = nil
		
		let link = ProcessLink<(A,B)>(function: { _, callback in
			callback(.success(tuple!))
		}, errorHandler: self.errorHandler,
		   blockPerformer: self.blockPerformer,
		   path: self.path+["conjoin"],
		   functionFile: #file,
		   functionLine: #line)
		
		self.yieldResult { a, myCompletion in
			other.yieldResult { b, otherCompletion in
				guard let aa = a as? A else {
					preconditionFailure("a is not of type A")
				}
				guard let bb = b as? B else {
					preconditionFailure("b is not of type B")
				}
				tuple = (aa, bb)
				link.execute(argument: Void(), completion: { (cont) in
					myCompletion(cont)
					otherCompletion(cont)
				})
			}
		}
		
		return link
	}
}
