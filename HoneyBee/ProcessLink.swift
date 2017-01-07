//
//  ProcessLink.swift
//  HoneyBee
//
//  Created by Alex Lynch on 1/7/17.
//  Copyright © 2017 IAM Apps. All rights reserved.
//

import Foundation

class Executable<A> {
	func execute(argument: A) -> Void {}
}

class ProcessLink<A,B> : Executable<A> {
	
	static func rootProcess() -> ProcessLink<Void,Void> {
		return ProcessLink<Void, Void>(function: {_,block in block()})
	}
	
	private var createdLinks: [Executable<B>] = []
	
	private var function: (A,(B)->Void)->Void
	
	private init(function:  @escaping (A,(B)->Void)->Void) {
		self.function = function
	}
	
	func invoke<C>(_ functor:  @escaping (B)->(C)) -> ProcessLink<B,C> {
		return self.invoke { (b, callback) in
			callback(functor(b))
		}
	}
	
	func invoke<C>(_ functor:  @escaping (B,(C)->Void)->Void) -> ProcessLink<B,C> {
		let link = ProcessLink<B,C>(function: functor)
		createdLinks.append(link)
		return link
	}
	
	func terminate() {
		
	}
	
	override func execute(argument: A) {
		function(argument) { result in
			for createdLink in self.createdLinks {
				createdLink.execute(argument: result)
			}
		}
	}
}

func doProccess(defineBlock: (ProcessLink<Void,Void>)->Void) {
	let root = ProcessLink<Void, Void>.rootProcess()
	defineBlock(root)
	root.execute(argument: ())
}

