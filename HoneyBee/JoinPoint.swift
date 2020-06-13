//
//  JoinPoint.swift
//  HoneyBee
//
//  Created by Alex Lynch on 2/22/17.
//  Copyright © 2017 IAM Apps. All rights reserved.
//

import Foundation

extension ErrorContext : Error {}

final class JoinPoint<A, E: Error, P: AsyncBlockPerformer> : Executable<E> {
	typealias ExecutionResult = (Result<A, ErrorContext<E>>, () -> Void)
	
    private let executionBox = ConcurrentBox<ExecutionResult>()

	private let blockPerformer: P
	var trace: AsyncTrace
	
	init(blockPerformer: P, trace: AsyncTrace) {
		self.blockPerformer = blockPerformer
		self.trace = trace
	}
	
	private func yieldResult(_ callback: @escaping (ExecutionResult) -> Void) {
        self.executionBox.yieldValue(callback)
	}

    private func handleAncestorResult(_ result: Result<A, ErrorContext<E>>, completion: @escaping () -> Void) {
        self.executionBox.setValue((result, completion))
    }

	override func execute(argument: Any?, completion: @escaping () -> Void) {
        guard let a = argument as? A else {
            HoneyBee.internalFailureResponse.evaluate(true, "Agrument is not of type A")
            completion()
            return
        }

        self.handleAncestorResult(.success(a), completion: completion)
	}
	
    override func ancestorFailed(_ context: ErrorContext<E>) {
        self.handleAncestorResult(.failure(context), completion: { /* no op */ })
	}
	
	func conjoin<B>(_ other: JoinPoint<B, E, P>) -> Link<(A,B), E, P> {
		HoneyBee.mismatchedConjoinResponse.evaluate(self.blockPerformer == other.blockPerformer,
												 "conjoin detected between Links with different AsyncBlockPerformers. This can lead to unexpected results.")
		var tuple: (A,B)? = nil
		
        let newTrace = self.trace.join(other.trace)
		let link = Link<(A,B), E, P>(function: { _, callback in
			callback(.success(tuple!))
		}, 
		   blockPerformer: self.blockPerformer,
		   trace: newTrace)
		
		self.yieldResult { a, myCompletion in
			other.yieldResult { b, otherCompletion in
				func callback() {
					myCompletion()
					otherCompletion()
				}
                let aa: A
                let bb: B

                switch a {
                case let .success(a):
                    aa = a
                case let .failure(context):
                    link.ancestorFailed(context)
                    callback()
                    return
                }

                switch b {
                case let .success(b):
                    bb = b
                case let .failure(context):
                    link.ancestorFailed(context)
                    callback()
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
