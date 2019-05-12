//
//  FunctionWrappers.swift
//  HoneyBee
//
//  Created by Alex Lynch on 4/23/19.
//  Copyright © 2019 IAM Apps. All rights reserved.
//

import Foundation

public struct SinglePair<A> : ExpressibleByDictionaryLiteral {
	fileprivate let value: A
	public init(dictionaryLiteral elements: (String, A)...) {
		precondition(elements.count == 1, "Exactly 1 argument is expected")
		self.value = elements.first!.1
	}
}

@dynamicCallable
public struct SingleArgFunction<A,R, Performer: AsyncBlockPerformer> {
	let link: Link<Void, Performer>
	let function: (Link<A, Performer>) -> Link<R, Performer>
	
	@discardableResult
	public func dynamicallyCall(withKeywordArguments args: SinglePair<A>) -> Link<R, Performer> {
		return self[args.value]
	}
	
	@discardableResult
	public func dynamicallyCall(withKeywordArguments args: SinglePair<Link<A, Performer>>) -> Link<R, Performer> {
		return self[args.value]
	}
	
	public subscript(_ a: A) -> Link<R, Performer> {
		return self.function(self.link.insert(a))
	}
	
	
	public subscript(_ a: Link<A, Performer>) -> Link<R, Performer> {
		return self.function(self.link +> a)
	}
}

@dynamicCallable
public struct DoubleArgFunction<A,B,R, Performer: AsyncBlockPerformer> {
	let link: Link<Void, Performer>
	let function: (Link<A, Performer>, Link<B, Performer>) -> Link<R, Performer>
	
	public func dynamicallyCall(withKeywordArguments args: SinglePair<A>) -> SingleArgFunction<B, R, Performer> {
		return self[args.value]
	}
	
	public subscript(_ a: A) -> SingleArgFunction<B, R, Performer> {
		let a = self.link.insert(a)
		let functionReference = self.function
		let wrapped = { (b: Link<B, Performer>) -> Link<R, Performer> in
			return functionReference(a, b)
		}
		return SingleArgFunction(link: self.link, function: wrapped)
	}
	
	public func dynamicallyCall(withKeywordArguments args: SinglePair<Link<A, Performer>>) -> SingleArgFunction<B, R, Performer> {
		return self[args.value]
	}
	
	public subscript(_ a: Link<A, Performer>) -> SingleArgFunction<B, R, Performer> {
		let a = self.link +> a
		let functionReference = self.function
		let wrapped = { (b: Link<B, Performer>) -> Link<R, Performer> in
			return functionReference(a, b)
		}
		return SingleArgFunction(link: self.link, function: wrapped)
	}
}

@dynamicCallable
public struct TripleArgFunction<A,B,C,R, Performer: AsyncBlockPerformer> {
	let link: Link<Void, Performer>
	let function: (Link<A, Performer>, Link<B, Performer>, Link<C, Performer>) -> Link<R, Performer>
	
	public func dynamicallyCall(withKeywordArguments args: SinglePair<A>) -> DoubleArgFunction<B, C, R, Performer> {
		return self[args.value]
	}
	
	public subscript(_ a: A) -> DoubleArgFunction<B, C, R, Performer> {
		let a = self.link.insert(a)
		let functionReference = self.function
		let wrapped = { (b: Link<B, Performer>, c: Link<C, Performer>) -> Link<R, Performer> in
			return functionReference(a, b, c)
		}
		return DoubleArgFunction(link: self.link, function: wrapped)
	}
	
	public func dynamicallyCall(withKeywordArguments args: SinglePair<Link<A, Performer>>) -> DoubleArgFunction<B, C, R, Performer> {
		return self[args.value]
	}
	
	public subscript(_ a: Link<A, Performer>) -> DoubleArgFunction<B, C, R, Performer> {
		let a = self.link +> a
		let functionReference = self.function
		let wrapped = { (b: Link<B, Performer>, c: Link<C, Performer>) -> Link<R, Performer> in
			return functionReference(a, b, c)
		}
		return DoubleArgFunction(link: self.link, function: wrapped)
	}
}
