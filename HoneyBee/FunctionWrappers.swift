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
public struct AsyncZeroArgFunction<R, P: AsyncBlockPerformer> {
    let link: Link<Void, P>
    let function: () -> Link<R, P>
    
    @discardableResult
    public func dynamicallyCall(withKeywordArguments args: EmptyPair = [:]) -> Link<R, P> {
        link+>function()
    }
}

@dynamicCallable
public struct AsyncSingleArgFunction<A,R, P: AsyncBlockPerformer> {
	let link: Link<Void, P>
	let function: (Link<A, P>) -> Link<R, P>
	
	@discardableResult
    public func dynamicallyCall(withKeywordArguments args: SinglePair<A>) -> Link<R, P> {
        return self.function(link.insert(args.value))
	}
	
	@discardableResult
    public func dynamicallyCall(withKeywordArguments args: SinglePair<Link<A, P>>) -> Link<R, P> {
        return self.function(self.link +> args.value)
	}
}

@dynamicCallable
public struct AsyncDoubleArgFunction<A,B,R, P: AsyncBlockPerformer> {
	let link: Link<Void, P>
	let function: (Link<A, P>, Link<B, P>) -> Link<R, P>
	
	public func dynamicallyCall(withKeywordArguments args: SinglePair<A>) -> AsyncSingleArgFunction<B, R, P> {
        let a = self.link.insert(args.value)
		let functionReference = self.function
		let wrapped = { (b: Link<B, P>) -> Link<R, P> in
			return functionReference(a, b)
		}
		return AsyncSingleArgFunction(link: self.link, function: wrapped)
	}
	
	public func dynamicallyCall(withKeywordArguments args: SinglePair<Link<A, P>>) -> AsyncSingleArgFunction<B, R, P> {
        let a = self.link +> args.value
		let functionReference = self.function
		let wrapped = { (b: Link<B, P>) -> Link<R, P> in
			return functionReference(a, b)
		}
		return AsyncSingleArgFunction(link: self.link, function: wrapped)
	}
}

@dynamicCallable
public struct AsyncTripleArgFunction<A,B,C,R, P: AsyncBlockPerformer> {
	let link: Link<Void, P>
	let function: (Link<A, P>, Link<B, P>, Link<C, P>) -> Link<R, P>
	
	public func dynamicallyCall(withKeywordArguments args: SinglePair<A>) -> AsyncDoubleArgFunction<B, C, R, P> {
        let a = self.link.insert(args.value)
		let functionReference = self.function
		let wrapped = { (b: Link<B, P>, c: Link<C, P>) -> Link<R, P> in
			return functionReference(a, b, c)
		}
		return AsyncDoubleArgFunction(link: self.link, function: wrapped)
	}
	
	public func dynamicallyCall(withKeywordArguments args: SinglePair<Link<A, P>>) -> AsyncDoubleArgFunction<B, C, R, P> {
        let a = self.link +> args.value
		let functionReference = self.function
		let wrapped = { (b: Link<B, P>, c: Link<C, P>) -> Link<R, P> in
			return functionReference(a, b, c)
		}
		return AsyncDoubleArgFunction(link: self.link, function: wrapped)
	}
}

typealias FunctionWrapperCompletion<R> = (Result<R, Error>)->Void

@dynamicCallable
public struct ZeroArgFunction<R> {
    let action: String
    let file: StaticString
    let line: UInt
    let function: (@escaping FunctionWrapperCompletion<R>) -> Void
    
    func ground<P: AsyncBlockPerformer>(_ link: Link<Void, P>) -> Link<R, P> {
        link.chain(file: self.file, line: self.line, functionDescription: self.action, self.function)
    }
    
    @discardableResult
    public func dynamicallyCall<P: AsyncBlockPerformer>(withKeywordArguments args: SinglePair<Link<Void, P>>) -> Link<R, P> {
        self.ground(args.value)
    }

    public func on<P: AsyncBlockPerformer>(_ perfomer: P.Type) -> BoundZeroArgFunction<R,P> {
        BoundZeroArgFunction(zero: self)
    }
}

@dynamicCallable
public struct SingleArgFunction<A,R> {
    let action: String
    let file: StaticString
    let line: UInt
    let function: (A, @escaping FunctionWrapperCompletion<R>) -> Void
    
    func ground<P: AsyncBlockPerformer>(_ link: Link<Void, P>) -> AsyncSingleArgFunction<A,R, P> {
        AsyncSingleArgFunction(link: link) { (link: Link<A, P>) -> Link<R, P> in
            link.chain(file: self.file, line: self.line, functionDescription: self.action, self.function)
        }
    }

    public func dynamicallyCall<P: AsyncBlockPerformer>(withKeywordArguments args: SinglePair<Link<Void, P>>) -> AsyncSingleArgFunction<A, R, P> {
        self.ground(args.value)
    }

    public func dynamicallyCall(withKeywordArguments args: SinglePair<A>) -> ZeroArgFunction<R> {
        let a = args.value
        return ZeroArgFunction<R>(action: action, file: file, line: line) { (completion: @escaping FunctionWrapperCompletion<R>) in
            self.function(a, completion)
        }
    }
    
    @discardableResult
    public func dynamicallyCall<P: AsyncBlockPerformer>(withKeywordArguments args: SinglePair<Link<A, P>>) -> Link<R, P> {
        args.value.chain(file: self.file, line: self.line, functionDescription: self.action, self.function)
    }

    public func on<P: AsyncBlockPerformer>(_ perfomer: P.Type) -> BoundSingleArgFunction<A,R,P> {
        BoundSingleArgFunction(single: self)
    }
}

@dynamicCallable
public struct DoubleArgFunction<A,B,R> {
    let action: String
    let file: StaticString
    let line: UInt
    let function: (A, B, @escaping FunctionWrapperCompletion<R>) -> Void
    
    func ground<P: AsyncBlockPerformer>(_ link: Link<Void, P>) -> AsyncDoubleArgFunction<A,B,R, P> {
        AsyncDoubleArgFunction(link: link) { (a: Link<A, P>, b: Link<B, P>) -> Link<R, P> in
            (a+b).chain(file: self.file, line: self.line, functionDescription: self.action) { (a_b: (A, B), completion: @escaping FunctionWrapperCompletion<R>) in
                self.function(a_b.0, a_b.1, completion)
            }
        }
    }

    public func dynamicallyCall<P: AsyncBlockPerformer>(withKeywordArguments args: SinglePair<Link<Void, P>>) -> AsyncDoubleArgFunction<A, B, R, P> {
        self.ground(args.value)
    }
    
    public func dynamicallyCall(withKeywordArguments args: SinglePair<A>) -> SingleArgFunction<B, R> {
        let a = args.value
        return SingleArgFunction<B, R>(action: action, file: file, line: line) { (b: B, completion: @escaping FunctionWrapperCompletion<R>)  in
            self.function(a, b, completion)
        }
    }
    
    public func dynamicallyCall<P: AsyncBlockPerformer>(withKeywordArguments args: SinglePair<Link<A, P>>) -> AsyncSingleArgFunction<B, R, P> {
        let a = args.value
        return AsyncSingleArgFunction(link: a.drop) { (b: Link<B, P>) -> Link<R, P> in
            (a+b).chain(file: self.file, line: self.line, functionDescription: self.action) { (a_b: (A, B), completion: @escaping FunctionWrapperCompletion<R>) in
                self.function(a_b.0, a_b.1, completion)
            }
        }
    }

    public func on<P: AsyncBlockPerformer>(_ perfomer: P.Type) -> BoundDoubleArgFunction<A,B,R,P> {
        BoundDoubleArgFunction(double: self)
    }
}

@dynamicCallable
public struct TripleArgFunction<A,B,C,R> {
    let action: String
    let file: StaticString
    let line: UInt
    let function: (A, B, C, @escaping FunctionWrapperCompletion<R>) -> Void
    
    func ground<P: AsyncBlockPerformer>(_ link: Link<Void, P>) -> AsyncTripleArgFunction<A,B,C,R, P> {
        AsyncTripleArgFunction(link: link) { (a: Link<A, P>, b: Link<B, P>, c: Link<C, P>) -> Link<R, P> in
            (a+b+c).chain(file: self.file, line: self.line, functionDescription: self.action) { (a_b_c: (A, B, C), completion: @escaping FunctionWrapperCompletion<R>) in
                self.function(a_b_c.0, a_b_c.1, a_b_c.2, completion)
            }
        }
    }

    public func dynamicallyCall<P: AsyncBlockPerformer>(withKeywordArguments args: SinglePair<Link<Void, P>>) -> AsyncTripleArgFunction<A, B, C, R, P> {
        self.ground(args.value)
    }
    
    public func dynamicallyCall(withKeywordArguments args: SinglePair<A>) -> DoubleArgFunction<B, C, R> {
        let a = args.value
        return DoubleArgFunction<B, C, R>(action: action, file: file, line: line) { (b: B, c: C, completion: @escaping FunctionWrapperCompletion<R>) -> Void in
            self.function(a, b, c, completion)
        }
    }
    
    public func dynamicallyCall<P: AsyncBlockPerformer>(withKeywordArguments args: SinglePair<Link<A, P>>) -> AsyncDoubleArgFunction<B, C, R, P> {
        let a = args.value
        return AsyncDoubleArgFunction(link: a.drop) { (b: Link<B, P>, c: Link<C, P>) -> Link<R, P> in
            (a+b+c).chain(file: self.file, line: self.line, functionDescription: self.action) { (a_b_c: (A, B, C), completion: @escaping FunctionWrapperCompletion<R>) in
                self.function(a_b_c.0, a_b_c.1, a_b_c.2, completion)
            }
        }
    }

    public func on<P: AsyncBlockPerformer>(_ perfomer: P.Type) -> BoundTripleArgFunction<A,B,C,R,P> {
        BoundTripleArgFunction(triple: self)
    }
}

protocol DocumentationBearing {
    var action: String { get }
    var file: StaticString { get }
    var line: UInt { get }
}

extension ZeroArgFunction : DocumentationBearing {}
extension SingleArgFunction : DocumentationBearing {}
extension DoubleArgFunction : DocumentationBearing {}
extension TripleArgFunction : DocumentationBearing {}

@dynamicCallable
public struct BoundZeroArgFunction<R,P: AsyncBlockPerformer> {
    let zero: ZeroArgFunction<R>
    init(zero: ZeroArgFunction<R>) {
        self.zero = zero
    }

    func ground(_ link: Link<Void, P>) -> Link<R, P> {
        self.zero.ground(link)
    }

    @discardableResult
    public func dynamicallyCall(withKeywordArguments args: SinglePair<Link<Void, P>>) -> Link<R, P> {
        self.zero.dynamicallyCall(withKeywordArguments: args)
    }
}

@dynamicCallable
public struct BoundSingleArgFunction<A,R,P: AsyncBlockPerformer> {
    let single: SingleArgFunction<A,R>
    init(single: SingleArgFunction<A, R>) {
        self.single = single
    }

    func ground(_ link: Link<Void, P>) -> AsyncSingleArgFunction<A,R, P> {
        self.single.ground(link)
    }

    public func dynamicallyCall(withKeywordArguments args: SinglePair<Link<Void, P>>) -> AsyncSingleArgFunction<A, R, P> {
        self.single.dynamicallyCall(withKeywordArguments: args)
    }

    public func dynamicallyCall(withKeywordArguments args: SinglePair<A>) -> ZeroArgFunction<R> {
        self.single.dynamicallyCall(withKeywordArguments: args)
    }

    @discardableResult
    public func dynamicallyCall(withKeywordArguments args: SinglePair<Link<A, P>>) -> Link<R, P> {
        self.single.dynamicallyCall(withKeywordArguments: args)
    }
}

@dynamicCallable
public struct BoundDoubleArgFunction<A,B,R,P: AsyncBlockPerformer> {
    let double: DoubleArgFunction<A,B,R>
    init(double: DoubleArgFunction<A,B,R>) {
        self.double = double
    }

    func ground(_ link: Link<Void, P>) -> AsyncDoubleArgFunction<A,B,R,P> {
        self.double.ground(link)
    }

    public func dynamicallyCall(withKeywordArguments args: SinglePair<Link<Void, P>>) -> AsyncDoubleArgFunction<A,B,R,P> {
        self.double.dynamicallyCall(withKeywordArguments: args)
    }

    public func dynamicallyCall(withKeywordArguments args: SinglePair<A>) -> SingleArgFunction<B,R> {
        self.double.dynamicallyCall(withKeywordArguments: args)
    }

    public func dynamicallyCall(withKeywordArguments args: SinglePair<Link<A, P>>) -> AsyncSingleArgFunction<B,R,P> {
        self.double.dynamicallyCall(withKeywordArguments: args)
    }
}

@dynamicCallable
public struct BoundTripleArgFunction<A,B,C,R,P: AsyncBlockPerformer> {
    let triple: TripleArgFunction<A,B,C,R>
    init(triple: TripleArgFunction<A,B,C,R>) {
        self.triple = triple
    }

    func ground(_ link: Link<Void, P>) -> AsyncTripleArgFunction<A,B,C,R,P> {
        self.triple.ground(link)
    }

    public func dynamicallyCall(withKeywordArguments args: SinglePair<Link<Void, P>>) -> AsyncTripleArgFunction<A,B,C,R,P> {
        self.triple.dynamicallyCall(withKeywordArguments: args)
    }

    public func dynamicallyCall(withKeywordArguments args: SinglePair<A>) -> DoubleArgFunction<B,C,R> {
        self.triple.dynamicallyCall(withKeywordArguments: args)
    }

    public func dynamicallyCall(withKeywordArguments args: SinglePair<Link<A, P>>) -> AsyncDoubleArgFunction<B,C,R,P> {
        self.triple.dynamicallyCall(withKeywordArguments: args)
    }
}
