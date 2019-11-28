//
//  FunctionWrappers.swift
//  HoneyBee
//
//  Created by Alex Lynch on 4/23/19.
//  Copyright © 2019 IAM Apps. All rights reserved.
//

import Foundation

public struct EmptyPair : ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (String, String)...) {
        precondition(elements.count == 0, "Exactly 0 arguments are expected")
    }
}

public struct SinglePair<A> : ExpressibleByDictionaryLiteral {
    fileprivate let value: A
    public init(dictionaryLiteral elements: (String, A)...) {
        precondition(elements.count == 1, "Exactly 1 argument is expected")
        self.value = elements.first!.1
    }
}

@dynamicCallable
public struct ZeroArgFunction<R, Performer: AsyncBlockPerformer> {
    let link: Link<Void, Performer>
    let function: () -> Link<R, Performer>
    
    @discardableResult
    public func dynamicallyCall(withKeywordArguments args: EmptyPair = [:]) -> Link<R, Performer> {
        link+>function()
    }
}

@dynamicCallable
public struct SingleArgFunction<A,R, Performer: AsyncBlockPerformer> {
	let link: Link<Void, Performer>
	let function: (Link<A, Performer>) -> Link<R, Performer>
	
	@discardableResult
    public func dynamicallyCall(withKeywordArguments args: SinglePair<A>) -> Link<R, Performer> {
        return self.function(link.insert(args.value))
	}
	
	@discardableResult
    public func dynamicallyCall(withKeywordArguments args: SinglePair<Link<A, Performer>>) -> Link<R, Performer> {
        return self.function(self.link +> args.value)
	}
}

@dynamicCallable
public struct DoubleArgFunction<A,B,R, Performer: AsyncBlockPerformer> {
	let link: Link<Void, Performer>
	let function: (Link<A, Performer>, Link<B, Performer>) -> Link<R, Performer>
	
	public func dynamicallyCall(withKeywordArguments args: SinglePair<A>) -> SingleArgFunction<B, R, Performer> {
        let a = self.link.insert(args.value)
		let functionReference = self.function
		let wrapped = { (b: Link<B, Performer>) -> Link<R, Performer> in
			return functionReference(a, b)
		}
		return SingleArgFunction(link: self.link, function: wrapped)
	}
	
	public func dynamicallyCall(withKeywordArguments args: SinglePair<Link<A, Performer>>) -> SingleArgFunction<B, R, Performer> {
        let a = self.link +> args.value
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
        let a = self.link.insert(args.value)
		let functionReference = self.function
		let wrapped = { (b: Link<B, Performer>, c: Link<C, Performer>) -> Link<R, Performer> in
			return functionReference(a, b, c)
		}
		return DoubleArgFunction(link: self.link, function: wrapped)
	}
	
	public func dynamicallyCall(withKeywordArguments args: SinglePair<Link<A, Performer>>) -> DoubleArgFunction<B, C, R, Performer> {
        let a = self.link +> args.value
		let functionReference = self.function
		let wrapped = { (b: Link<B, Performer>, c: Link<C, Performer>) -> Link<R, Performer> in
			return functionReference(a, b, c)
		}
		return DoubleArgFunction(link: self.link, function: wrapped)
	}
}

@dynamicCallable
public struct UngroundedZeroArgFunction<R, Performer: AsyncBlockPerformer> {
    let action: String
    let file: StaticString
    let line: UInt
    let function: (Link<Void, Performer>) -> Link<R, Performer>
    
    func ground(_ link: Link<Void, Performer>) -> Link<R, Performer> {
        function(link)
    }
    
    @discardableResult
    public func dynamicallyCall(withKeywordArguments args: SinglePair<Link<Void, Performer>>) -> Link<R, Performer> {
        self.ground(args.value)
    }
}

@dynamicCallable
public struct UngroundedSingleArgFunction<A,R, Performer: AsyncBlockPerformer> {
    let action: String
    let file: StaticString
    let line: UInt
    let function: (Link<A, Performer>) -> Link<R, Performer>
    
    func ground(_ link: Link<Void, Performer>) -> SingleArgFunction<A,R, Performer> {
        SingleArgFunction(link: link, function: self.function)
    }
    
    @discardableResult
    public func dynamicallyCall(withKeywordArguments args: SinglePair<Link<Void, Performer>>) -> SingleArgFunction<A, R, Performer> {
        self.ground(args.value)
    }
    
    @discardableResult
    public func dynamicallyCall(withKeywordArguments args: SinglePair<A>) -> UngroundedZeroArgFunction<R, Performer> {
        UngroundedZeroArgFunction<R, Performer>(action: action, file: file, line: line) { (link: Link<Void, Performer>) -> Link<R, Performer> in
            self.function(link.insert(args.value))
        }
    }
    
    @discardableResult
    public func dynamicallyCall(withKeywordArguments args: SinglePair<Link<A, Performer>>) -> Link<R, Performer> {
        self.function(args.value)
    }
}

@dynamicCallable
public struct UngroundedDoubleArgFunction<A,B,R, Performer: AsyncBlockPerformer> {
    let action: String
    let file: StaticString
    let line: UInt
    let function: (Link<A, Performer>, Link<B, Performer>) -> Link<R, Performer>
    
    func ground(_ link: Link<Void, Performer>) -> DoubleArgFunction<A,B,R, Performer> {
        DoubleArgFunction(link: link, function: self.function)
    }
    
    @discardableResult
    public func dynamicallyCall(withKeywordArguments args: SinglePair<Link<Void, Performer>>) -> DoubleArgFunction<A, B, R, Performer> {
        self.ground(args.value)
    }
    
    public func dynamicallyCall(withKeywordArguments args: SinglePair<A>) -> UngroundedSingleArgFunction<B, R, Performer> {
        UngroundedSingleArgFunction<B, R, Performer>(action: action, file: file, line: line) { (link: Link<B, Performer>) -> Link<R, Performer> in
            self.function(link.insert(args.value), link)
        }
    }
    
    public func dynamicallyCall(withKeywordArguments args: SinglePair<Link<A, Performer>>) -> SingleArgFunction<B, R, Performer> {
        let a = args.value
        let functionReference = self.function
        let wrapped = { (b: Link<B, Performer>) -> Link<R, Performer> in
            return functionReference(a, b)
        }
        return SingleArgFunction(link: a.drop, function: wrapped)
    }
}

@dynamicCallable
public struct UngroundedTripleArgFunction<A,B,C,R, Performer: AsyncBlockPerformer> {
    let action: String
    let file: StaticString
    let line: UInt
    let function: (Link<A, Performer>, Link<B, Performer>, Link<C, Performer>) -> Link<R, Performer>
    
    func ground(_ link: Link<Void, Performer>) -> TripleArgFunction<A,B,C,R, Performer> {
        TripleArgFunction(link: link, function: self.function)
    }
    
    @discardableResult
    public func dynamicallyCall(withKeywordArguments args: SinglePair<Link<Void, Performer>>) -> TripleArgFunction<A, B, C, R, Performer> {
        self.ground(args.value)
    }
    
    public func dynamicallyCall(withKeywordArguments args: SinglePair<A>) -> UngroundedDoubleArgFunction<B, C, R, Performer> {
        UngroundedDoubleArgFunction<B, C, R, Performer>(action: action, file: file, line: line) { (b: Link<B, Performer>, c: Link<C, Performer>) -> Link<R, Performer> in
            self.function(b.insert(args.value), b, c)
        }
    }
    
    public func dynamicallyCall(withKeywordArguments args: SinglePair<Link<A, Performer>>) -> DoubleArgFunction<B, C, R, Performer> {
        let a = args.value
        let functionReference = self.function
        let wrapped = { (b: Link<B, Performer>, c: Link<C, Performer>) -> Link<R, Performer> in
            return functionReference(a, b, c)
        }
        return DoubleArgFunction(link: a.drop, function: wrapped)
    }
}

protocol DocumentationBearing {
    var action: String { get }
    var file: StaticString { get }
    var line: UInt { get }
}

extension UngroundedZeroArgFunction : DocumentationBearing {}
extension UngroundedSingleArgFunction : DocumentationBearing {}
extension UngroundedDoubleArgFunction : DocumentationBearing {}
extension UngroundedTripleArgFunction : DocumentationBearing {}
