//
//  JoinPoint.swift
//  HoneyBee
//
//  Created by Alex Lynch on 2/22/17.
//  Copyright © 2017 IAM Apps. All rights reserved.
//

import Foundation

final class JoinPoint<A, Performer: AsyncBlockPerformer> : Executable {
	typealias ExecutionResult = (Any?, () -> Void)
	
	private let resultLock = NSLock()
	private var executionResult: ExecutionResult?
	private var resultCallback: ((ExecutionResult) -> Void)?
	private let blockPerformer: Performer
	private let errorHandler: ((ErrorContext) -> Void)
	let trace: AsyncTrace
	
	init(blockPerformer: Performer, trace: AsyncTrace, errorHandler: @escaping ((ErrorContext) -> Void)) {
		self.blockPerformer = blockPerformer
		self.trace = trace
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
	
	override func execute(argument: Any?, completion: @escaping () -> Void) {
		self.resultLock.lock()
		defer {
			self.resultLock.unlock()
		}

		executionResult = (argument, guarantee(faultResponse: HoneyBee.internalFailureResponse, completion))
		
		if let resultCallback = self.resultCallback {
			resultCallback(executionResult!)
		}
	}
	
	override func ancestorFailed() {
		self.execute(argument: nil, completion:  {/* empty completion */})
	}
	
	func conjoin<B>(_ other: JoinPoint<B, Performer>) -> Link<(A,B), Performer> {
		HoneyBee.mismatchedConjoinResponse.evaluate(self.blockPerformer == other.blockPerformer,
												 "conjoin detected between Links with different AsyncBlockPerformers. This can lead to unexpected results.")
		var tuple: (A,B)? = nil
		guard let otherLastComp = other.trace.last else {
			HoneyBee.internalFailureResponse.evaluate(false, "AsyncTrace with no components joined.")
			preconditionFailure("AsyncTrace with no components joined.")
		}
		
		var newTrace = self.trace
		let link = Link<(A,B), Performer>(function: { _, callback in
			callback(.success(tuple!))
		}, errorHandler: self.errorHandler,
		   blockPerformer: self.blockPerformer,
		   trace: other.trace.join(newTrace),
		   functionFile: #file,
		   functionLine: #line)
		
		self.yieldResult { a, myCompletion in
			other.yieldResult { b, otherCompletion in
				func callback() {
					myCompletion()
					otherCompletion()
				}
				guard let aa = a as? A,
					let bb = b as? B else {
					// ancestorFailure
					callback()
					link.ancestorFailed()
					return
				}
				tuple = (aa, bb)
				link.execute(argument: Void(), completion: {
					callback()
				})
			}
		}
		
		return link
	}
}

#warning("Check this")
/// This is a best-effort check. Both of the known conformers of AsyncBlockPerformer are NSObject
/// (yes, even DispatchQueue, I checked). We pass anything that we can't explictly verify is wrong.
fileprivate func ==(lhs: AsyncBlockPerformer, rhs: AsyncBlockPerformer) -> Bool {
	switch (lhs, rhs) {
	case (let lqueue as NSObject, let rqueue as NSObject):
		return lqueue == rqueue
	default:
		return true
	}
}
