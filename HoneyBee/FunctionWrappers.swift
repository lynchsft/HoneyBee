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
public struct ZeroArgAsyncFunction<R, Performer: AsyncBlockPerformer> {
    let link: Link<Void, Performer>
    let function: () -> Link<R, Performer>
    
    @discardableResult
    public func dynamicallyCall(withKeywordArguments args: EmptyPair = [:]) -> Link<R, Performer> {
        link+>function()
    }
}

@dynamicCallable
public struct SingleArgAsyncFunction<A,R, Performer: AsyncBlockPerformer> {
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
public struct DoubleArgAsyncFunction<A,B,R, Performer: AsyncBlockPerformer> {
	let link: Link<Void, Performer>
	let function: (Link<A, Performer>, Link<B, Performer>) -> Link<R, Performer>
	
	public func dynamicallyCall(withKeywordArguments args: SinglePair<A>) -> SingleArgAsyncFunction<B, R, Performer> {
        let a = self.link.insert(args.value)
		let functionReference = self.function
		let wrapped = { (b: Link<B, Performer>) -> Link<R, Performer> in
			return functionReference(a, b)
		}
		return SingleArgAsyncFunction(link: self.link, function: wrapped)
	}
	
	public func dynamicallyCall(withKeywordArguments args: SinglePair<Link<A, Performer>>) -> SingleArgAsyncFunction<B, R, Performer> {
        let a = self.link +> args.value
		let functionReference = self.function
		let wrapped = { (b: Link<B, Performer>) -> Link<R, Performer> in
			return functionReference(a, b)
		}
		return SingleArgAsyncFunction(link: self.link, function: wrapped)
	}
}

@dynamicCallable
public struct TripleArgAsyncFunction<A,B,C,R, Performer: AsyncBlockPerformer> {
	let link: Link<Void, Performer>
	let function: (Link<A, Performer>, Link<B, Performer>, Link<C, Performer>) -> Link<R, Performer>
	
	public func dynamicallyCall(withKeywordArguments args: SinglePair<A>) -> DoubleArgAsyncFunction<B, C, R, Performer> {
        let a = self.link.insert(args.value)
		let functionReference = self.function
		let wrapped = { (b: Link<B, Performer>, c: Link<C, Performer>) -> Link<R, Performer> in
			return functionReference(a, b, c)
		}
		return DoubleArgAsyncFunction(link: self.link, function: wrapped)
	}
	
	public func dynamicallyCall(withKeywordArguments args: SinglePair<Link<A, Performer>>) -> DoubleArgAsyncFunction<B, C, R, Performer> {
        let a = self.link +> args.value
		let functionReference = self.function
		let wrapped = { (b: Link<B, Performer>, c: Link<C, Performer>) -> Link<R, Performer> in
			return functionReference(a, b, c)
		}
		return DoubleArgAsyncFunction(link: self.link, function: wrapped)
	}
}

typealias FunctionWrapperCompletion<R> = (Result<R, Error>)->Void

@dynamicCallable
public struct ZeroArgFunction<R> {
    let action: String
    let file: StaticString
    let line: UInt
    let function: (@escaping FunctionWrapperCompletion<R>) -> Void
    
    func ground<Performer: AsyncBlockPerformer>(_ link: Link<Void, Performer>) -> Link<R, Performer> {
        link.chain(file: self.file, line: self.line, functionDescription: self.action, self.function)
    }
    
    @discardableResult
    public func dynamicallyCall<Performer: AsyncBlockPerformer>(withKeywordArguments args: SinglePair<Link<Void, Performer>>) -> Link<R, Performer> {
        self.ground(args.value)
    }

    public func on<Performer: AsyncBlockPerformer>(_ perfomer: Performer.Type) -> BoundZeroArgFunction<R,Performer> {
        BoundZeroArgFunction(zero: self)
    }
}

@dynamicCallable
public struct SingleArgFunction<A,R> {
    let action: String
    let file: StaticString
    let line: UInt
    let function: (A, @escaping FunctionWrapperCompletion<R>) -> Void
    
    func ground<Performer: AsyncBlockPerformer>(_ link: Link<Void, Performer>) -> SingleArgAsyncFunction<A,R, Performer> {
        SingleArgAsyncFunction(link: link) { (link: Link<A, Performer>) -> Link<R, Performer> in
            link.chain(file: self.file, line: self.line, functionDescription: self.action, self.function)
        }
    }

    public func dynamicallyCall<Performer: AsyncBlockPerformer>(withKeywordArguments args: SinglePair<Link<Void, Performer>>) -> SingleArgAsyncFunction<A, R, Performer> {
        self.ground(args.value)
    }

    public func dynamicallyCall(withKeywordArguments args: SinglePair<A>) -> ZeroArgFunction<R> {
        let a = args.value
        return ZeroArgFunction<R>(action: action, file: file, line: line) { (completion: @escaping FunctionWrapperCompletion<R>) in
            self.function(a, completion)
        }
    }
    
    @discardableResult
    public func dynamicallyCall<Performer: AsyncBlockPerformer>(withKeywordArguments args: SinglePair<Link<A, Performer>>) -> Link<R, Performer> {
        args.value.chain(file: self.file, line: self.line, functionDescription: self.action, self.function)
    }

    public func on<Performer: AsyncBlockPerformer>(_ perfomer: Performer.Type) -> BoundSingleArgFunction<A,R,Performer> {
        BoundSingleArgFunction(single: self)
    }
}

@dynamicCallable
public struct DoubleArgFunction<A,B,R> {
    let action: String
    let file: StaticString
    let line: UInt
    let function: (A, B, @escaping FunctionWrapperCompletion<R>) -> Void
    
    func ground<Performer: AsyncBlockPerformer>(_ link: Link<Void, Performer>) -> DoubleArgAsyncFunction<A,B,R, Performer> {
        DoubleArgAsyncFunction(link: link) { (a: Link<A, Performer>, b: Link<B, Performer>) -> Link<R, Performer> in
            (a+b).chain(file: self.file, line: self.line, functionDescription: self.action) { (a_b: (A, B), completion: @escaping FunctionWrapperCompletion<R>) in
                self.function(a_b.0, a_b.1, completion)
            }
        }
    }

    public func dynamicallyCall<Performer: AsyncBlockPerformer>(withKeywordArguments args: SinglePair<Link<Void, Performer>>) -> DoubleArgAsyncFunction<A, B, R, Performer> {
        self.ground(args.value)
    }
    
    public func dynamicallyCall(withKeywordArguments args: SinglePair<A>) -> SingleArgFunction<B, R> {
        let a = args.value
        return SingleArgFunction<B, R>(action: action, file: file, line: line) { (b: B, completion: @escaping FunctionWrapperCompletion<R>)  in
            self.function(a, b, completion)
        }
    }
    
    public func dynamicallyCall<Performer: AsyncBlockPerformer>(withKeywordArguments args: SinglePair<Link<A, Performer>>) -> SingleArgAsyncFunction<B, R, Performer> {
        let a = args.value
        return SingleArgAsyncFunction(link: a.drop) { (b: Link<B, Performer>) -> Link<R, Performer> in
            (a+b).chain(file: self.file, line: self.line, functionDescription: self.action) { (a_b: (A, B), completion: @escaping FunctionWrapperCompletion<R>) in
                self.function(a_b.0, a_b.1, completion)
            }
        }
    }

    public func on<Performer: AsyncBlockPerformer>(_ perfomer: Performer.Type) -> BoundDoubleArgFunction<A,B,R,Performer> {
        BoundDoubleArgFunction(double: self)
    }
}

@dynamicCallable
public struct TripleArgFunction<A,B,C,R> {
    let action: String
    let file: StaticString
    let line: UInt
    let function: (A, B, C, @escaping FunctionWrapperCompletion<R>) -> Void
    
    func ground<Performer: AsyncBlockPerformer>(_ link: Link<Void, Performer>) -> TripleArgAsyncFunction<A,B,C,R, Performer> {
        TripleArgAsyncFunction(link: link) { (a: Link<A, Performer>, b: Link<B, Performer>, c: Link<C, Performer>) -> Link<R, Performer> in
            (a+b+c).chain(file: self.file, line: self.line, functionDescription: self.action) { (a_b_c: (A, B, C), completion: @escaping FunctionWrapperCompletion<R>) in
                self.function(a_b_c.0, a_b_c.1, a_b_c.2, completion)
            }
        }
    }

    public func dynamicallyCall<Performer: AsyncBlockPerformer>(withKeywordArguments args: SinglePair<Link<Void, Performer>>) -> TripleArgAsyncFunction<A, B, C, R, Performer> {
        self.ground(args.value)
    }
    
    public func dynamicallyCall(withKeywordArguments args: SinglePair<A>) -> DoubleArgFunction<B, C, R> {
        let a = args.value
        return DoubleArgFunction<B, C, R>(action: action, file: file, line: line) { (b: B, c: C, completion: @escaping FunctionWrapperCompletion<R>) -> Void in
            self.function(a, b, c, completion)
        }
    }
    
    public func dynamicallyCall<Performer: AsyncBlockPerformer>(withKeywordArguments args: SinglePair<Link<A, Performer>>) -> DoubleArgAsyncFunction<B, C, R, Performer> {
        let a = args.value
        return DoubleArgAsyncFunction(link: a.drop) { (b: Link<B, Performer>, c: Link<C, Performer>) -> Link<R, Performer> in
            (a+b+c).chain(file: self.file, line: self.line, functionDescription: self.action) { (a_b_c: (A, B, C), completion: @escaping FunctionWrapperCompletion<R>) in
                self.function(a_b_c.0, a_b_c.1, a_b_c.2, completion)
            }
        }
    }

    public func on<Performer: AsyncBlockPerformer>(_ perfomer: Performer.Type) -> BoundTripleArgFunction<A,B,C,R,Performer> {
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
public struct BoundZeroArgFunction<R,Performer: AsyncBlockPerformer> {
    let zero: ZeroArgFunction<R>
    init(zero: ZeroArgFunction<R>) {
        self.zero = zero
    }

    func ground(_ link: Link<Void, Performer>) -> Link<R, Performer> {
        self.zero.ground(link)
    }

    @discardableResult
    public func dynamicallyCall(withKeywordArguments args: SinglePair<Link<Void, Performer>>) -> Link<R, Performer> {
        self.zero.dynamicallyCall(withKeywordArguments: args)
    }
}

@dynamicCallable
public struct BoundSingleArgFunction<A,R,Performer: AsyncBlockPerformer> {
    let single: SingleArgFunction<A,R>
    init(single: SingleArgFunction<A, R>) {
        self.single = single
    }

    func ground(_ link: Link<Void, Performer>) -> SingleArgAsyncFunction<A,R, Performer> {
        self.single.ground(link)
    }

    public func dynamicallyCall(withKeywordArguments args: SinglePair<Link<Void, Performer>>) -> SingleArgAsyncFunction<A, R, Performer> {
        self.single.dynamicallyCall(withKeywordArguments: args)
    }

    public func dynamicallyCall(withKeywordArguments args: SinglePair<A>) -> ZeroArgFunction<R> {
        self.single.dynamicallyCall(withKeywordArguments: args)
    }

    @discardableResult
    public func dynamicallyCall(withKeywordArguments args: SinglePair<Link<A, Performer>>) -> Link<R, Performer> {
        self.single.dynamicallyCall(withKeywordArguments: args)
    }
}

@dynamicCallable
public struct BoundDoubleArgFunction<A,B,R,Performer: AsyncBlockPerformer> {
    let double: DoubleArgFunction<A,B,R>
    init(double: DoubleArgFunction<A,B,R>) {
        self.double = double
    }

    func ground(_ link: Link<Void, Performer>) -> DoubleArgAsyncFunction<A,B,R,Performer> {
        self.double.ground(link)
    }

    public func dynamicallyCall(withKeywordArguments args: SinglePair<Link<Void, Performer>>) -> DoubleArgAsyncFunction<A,B,R,Performer> {
        self.double.dynamicallyCall(withKeywordArguments: args)
    }

    public func dynamicallyCall(withKeywordArguments args: SinglePair<A>) -> SingleArgFunction<B,R> {
        self.double.dynamicallyCall(withKeywordArguments: args)
    }

    public func dynamicallyCall(withKeywordArguments args: SinglePair<Link<A, Performer>>) -> SingleArgAsyncFunction<B,R,Performer> {
        self.double.dynamicallyCall(withKeywordArguments: args)
    }
}

@dynamicCallable
public struct BoundTripleArgFunction<A,B,C,R,Performer: AsyncBlockPerformer> {
    let triple: TripleArgFunction<A,B,C,R>
    init(triple: TripleArgFunction<A,B,C,R>) {
        self.triple = triple
    }

    func ground(_ link: Link<Void, Performer>) -> TripleArgAsyncFunction<A,B,C,R,Performer> {
        self.triple.ground(link)
    }

    public func dynamicallyCall(withKeywordArguments args: SinglePair<Link<Void, Performer>>) -> TripleArgAsyncFunction<A,B,C,R,Performer> {
        self.triple.dynamicallyCall(withKeywordArguments: args)
    }

    public func dynamicallyCall(withKeywordArguments args: SinglePair<A>) -> DoubleArgFunction<B,C,R> {
        self.triple.dynamicallyCall(withKeywordArguments: args)
    }

    public func dynamicallyCall(withKeywordArguments args: SinglePair<Link<A, Performer>>) -> DoubleArgAsyncFunction<B,C,R,Performer> {
        self.triple.dynamicallyCall(withKeywordArguments: args)
    }
}
