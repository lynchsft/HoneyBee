//
//  ConcurrentFunctionTools.swift
//  HoneyBee
//
//  Created by Alex Lynch on 12/1/17.
//  Copyright © 2017 IAM Apps. All rights reserved.
//

import Foundation

func guarantee<R>(faultResponse: FaultResponse, file: StaticString = #file, line: UInt = #line, _ function: @escaping () -> R) -> () -> R {
	return { () -> R in
		guarantee(faultResponse: faultResponse, file: file, line: line) { (_: Void) -> R in
			return function()
		}(())
	}
}

func guarantee<A,R>(faultResponse: FaultResponse, file: StaticString = #file, line: UInt = #line, _ function: @escaping (A) -> R) -> (A) -> R {
	return { (a:A) -> R in
		guarantee(faultResponse: faultResponse, file: file, line: line) { (a: A, _: Void) -> R in
			return function(a)
		}(a, ())
	}
}

func guarantee<A,B,R>(faultResponse: FaultResponse, file: StaticString = #file, line: UInt = #line, _ function: @escaping (A, B) -> R) -> (A, B) -> R {
	let functionCalled: AtomicBool = false
	functionCalled.guaranteeTrueAtDeinit(faultResponse: faultResponse, file: file, line: line)
	return { (a:A, b:B) -> R in
		faultResponse.evaluate(functionCalled.setTrue() == false, "function called more than once", file: file, line: line)
		return function(a,b)
	}
}

