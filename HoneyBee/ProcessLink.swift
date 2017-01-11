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
	
	fileprivate var function: (A, @escaping (B)->Void)->Void
	
	fileprivate init(function:  @escaping (A, @escaping (B)->Void)->Void) {
		self.function = function
	}
	
	func chain<C>(_ functor:  @escaping (B)->(C)) -> ProcessLink<B,C> {
		return self.chain { (b, callback) in
			callback(functor(b))
		}
	}
	
	func chain<C>(_ functor:  @escaping (B, @escaping (C)->Void)->Void) -> ProcessLink<B,C> {
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

extension ProcessLink where B : Collection, B.IndexDistance == Int {
	
	func map<C>(_ transform: @escaping (B.Iterator.Element) -> C) -> ProcessLink<B,[C]> {
		let link = ProcessLink<B,[C]>(function:{sequence, callback in
			sequence.asyncMap(transform: transform, completion: callback)
		})
		createdLinks.append(link)
		return link
	}
}

func startProccess(_ defineBlock: (ProcessLink<Void,Void>)->Void) {
	let root = ProcessLink<Void, Void>.rootProcess()
	defineBlock(root)
	root.execute(argument: ())
}

