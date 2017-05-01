//
//  JoinPoint.swift
//  HoneyBee
//
//  Created by Alex Lynch on 2/22/17.
//  Copyright © 2017 IAM Apps. All rights reserved.
//

import Foundation

class Executable<A> {
	func execute(argument: A, completion: @escaping () -> Void) -> Void {}
}

final class JoinPoint<A> : Executable<A> {
	private let resultLock = NSLock()
	private var result: A?
	private var resultCallback: ((A) -> Void)?
	private var queue: DispatchQueue
	private var conjoinLink: Executable<Void>?
	
	init(queue: DispatchQueue) {
		self.queue = queue
	}
	
	private func yieldResult(_ callback: @escaping (A) -> Void) {
		self.resultLock.lock()
		defer {
			self.resultLock.unlock()
		}
		// this needs to be atomic
		if let result = result {
			callback(result)
		} else {
			self.resultCallback = callback
		}
	}
	
	override func execute(argument: A, completion: @escaping (Void) -> Void) {
		if let link = self.conjoinLink {
			link.execute(argument: Void(), completion:  completion)
		}
		
		self.resultLock.lock()
		defer {
			self.resultLock.unlock()
		}
		result = argument
		
		if let resultCallback = self.resultCallback {
			resultCallback(argument)
		}
	}
	
	func conjoin<B>(_ other: JoinPoint<B>) -> ProcessLink<Void, (A,B)> {
		let yeildFunction = self.yieldResult
		let link = ProcessLink<Void, (A,B)>(function: { _, callback in
			yeildFunction { a in
				other.yieldResult { b in
					callback((a, b))
				}
			}
		}, queue: self.queue, path: ["conjoin"])
		
		self.conjoinLink = link
		return link
	}
}
