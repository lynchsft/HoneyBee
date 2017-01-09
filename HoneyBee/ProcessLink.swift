//
//  ProcessLink.swift
//  HoneyBee
//
//  Created by Alex Lynch on 1/7/17.
//  Copyright © 2017 IAM Apps. All rights reserved.
//

import Foundation

class Executable<A> {
	fileprivate func execute(argument: A) -> Void {}
}

class ProcessLink<A,B> : Executable<A> {
	
	static func rootProcess() -> ProcessLink<Void,Void> {
		return ProcessLink<Void, Void>(function: {_,block in block()})
	}
	
	fileprivate var createdLinks: [Executable<B>] = []
	
	fileprivate var function: (A,(B)->Void)->Void
	
	fileprivate init(function:  @escaping (A,(B)->Void)->Void) {
		self.function = function
	}
	
	func link<C>(_ functor:  @escaping (B)->(C)) -> ProcessLink<B,C> {
		return self.link { (b, callback) in
			callback(functor(b))
		}
	}
	
	func link<C>(_ functor:  @escaping (B,(C)->Void)->Void) -> ProcessLink<B,C> {
		let link = ProcessLink<B,C>(function: functor)
		createdLinks.append(link)
		return link
	}
	
	func fork(_ defineBlock: (ProcessLink<A,B>)->Void) {
		defineBlock(self)
	}
	
	func end() {
		
	}
	
	override fileprivate func execute(argument: A) {
		function(argument) { result in
			for createdLink in self.createdLinks {
				DispatchQueue.global().async {
					createdLink.execute(argument: result)
				}
			}
		}
	}
}

func startProccess(_ defineBlock: (ProcessLink<Void,Void>)->Void) {
	let root = ProcessLink<Void, Void>.rootProcess()
	defineBlock(root)
	root.execute(argument: ())
}

