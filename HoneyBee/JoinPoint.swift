//
//  JoinPoint.swift
//  HoneyBee
//
//  Created by Alex Lynch on 2/22/17.
//  Copyright © 2017 IAM Apps. All rights reserved.
//

import Foundation

class Executable<A> {
	typealias Continue = Bool
	func execute(argument: A, completion: @escaping (Continue) -> Void) -> Void {}
}

final class JoinPoint<A> : Executable<A>, PathDescribing {
	typealias ExecutionResult = (A, (Continue) -> Void)
	
	private let resultLock = NSLock()
	private var executionResult: ExecutionResult?
	private var resultCallback: ((ExecutionResult) -> Void)?
	private var queue: DispatchQueue
	private let errorHandler: ((Error, Any) -> Void)
	let path: [String]
	
	init(queue: DispatchQueue, path: [String], errorHandler: @escaping ((Error, Any) -> Void)) {
		self.queue = queue
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
	
	override func execute(argument: A, completion: @escaping (Continue) -> Void) {
		self.resultLock.lock()
		defer {
			self.resultLock.unlock()
		}
		executionResult = (argument, completion)
		
		if let resultCallback = self.resultCallback {
			resultCallback((argument, completion))
		}
	}
	
	func conjoin<B>(_ other: JoinPoint<B>) -> ProcessLink<Void, (A,B)> {
		var tuple: (A,B)! = nil
		
		let link = ProcessLink<Void, (A,B)>(function: { _, callback in
			callback(tuple!)
		}, errorHandler: self.errorHandler, queue: self.queue, path: self.path+["conjoin"])
		
		self.yieldResult { a, myCompletion in
			other.yieldResult { b, otherCompletion in
				tuple = (a, b)
				link.execute(argument: Void(), completion: { (cont) in
					myCompletion(cont)
					otherCompletion(cont)
				})
			}
		}
		
		return link
	}
}
