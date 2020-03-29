//
//  FunctionWrappers.swift
//  HoneyBee
//
//  Created by Alex Lynch on 4/23/19.
//  Copyright © 2019 IAM Apps. All rights reserved.
//

import Foundation

public struct AsyncZeroArgFunction<R, P: AsyncBlockPerformer> {
    let link: Link<Void, P>
    let function: () -> Link<R, P>
    
    @discardableResult
    public func callAsFunction() -> Link<R, P> {
        link+>function()
    }
}

public struct AsyncSingleArgFunction<A,R, P: AsyncBlockPerformer> {
	let link: Link<Void, P>
	let function: (Link<A, P>) -> Link<R, P>
	
	@discardableResult
    public func callAsFunction(_ a: A) -> Link<R, P> {
        return self.function(link.insert(a))
	}
	
	@discardableResult
    public func callAsFunction(_ link: Link<A, P>) -> Link<R, P> {
        return self.function(self.link +> link)
	}
}

public struct AsyncDoubleArgFunction<A,B,R, P: AsyncBlockPerformer> {
	let link: Link<Void, P>
	let function: (Link<A, P>, Link<B, P>) -> Link<R, P>
	
	public func callAsFunction(_ a: A) -> AsyncSingleArgFunction<B, R, P> {
        let a = self.link.insert(a)
		let functionReference = self.function
		let wrapped = { (b: Link<B, P>) -> Link<R, P> in
			return functionReference(a, b)
		}
		return AsyncSingleArgFunction(link: self.link, function: wrapped)
	}
	
    public func callAsFunction(_ link: Link<A, P>) -> AsyncSingleArgFunction<B, R, P> {
        let a = self.link +> link
		let functionReference = self.function
		let wrapped = { (b: Link<B, P>) -> Link<R, P> in
			return functionReference(a, b)
		}
		return AsyncSingleArgFunction(link: self.link, function: wrapped)
	}
}

public struct AsyncTripleArgFunction<A,B,C,R, P: AsyncBlockPerformer> {
	let link: Link<Void, P>
	let function: (Link<A, P>, Link<B, P>, Link<C, P>) -> Link<R, P>
	
    public func callAsFunction(_ a: A) -> AsyncDoubleArgFunction<B, C, R, P> {
        let a = self.link.insert(a)
		let functionReference = self.function
		let wrapped = { (b: Link<B, P>, c: Link<C, P>) -> Link<R, P> in
			return functionReference(a, b, c)
		}
		return AsyncDoubleArgFunction(link: self.link, function: wrapped)
	}
	
	public func callAsFunction(_ link: Link<A, P>) -> AsyncDoubleArgFunction<B, C, R, P> {
        let a = self.link +> link
		let functionReference = self.function
		let wrapped = { (b: Link<B, P>, c: Link<C, P>) -> Link<R, P> in
			return functionReference(a, b, c)
		}
		return AsyncDoubleArgFunction(link: self.link, function: wrapped)
	}
}

typealias FunctionWrapperCompletion<R> = (Result<R, Error>)->Void

public struct ZeroArgFunction<R> {
    let action: String
    let file: StaticString
    let line: UInt
    let function: (@escaping FunctionWrapperCompletion<R>) -> Void

    @discardableResult
    public func callAsFunction<X, P: AsyncBlockPerformer>(_ link: Link<X, P>) ->  Link<R, P>{
        link.chain(file: self.file, line: self.line, functionDescription: self.action, self.function)
    }

    public func on<P: AsyncBlockPerformer>(_ perfomer: P.Type) -> BoundZeroArgFunction<R,P> {
        BoundZeroArgFunction(zero: self)
    }
}

public struct SingleArgFunction<A,R> {
    let action: String
    let file: StaticString
    let line: UInt
    let function: (A, @escaping FunctionWrapperCompletion<R>) -> Void

    public func callAsFunction<P: AsyncBlockPerformer>(_ link: Link<Void, P>) -> AsyncSingleArgFunction<A, R, P> {
        AsyncSingleArgFunction(link: link) { (link: Link<A, P>) -> Link<R, P> in
            link.chain(file: self.file, line: self.line, functionDescription: self.action, self.function)
        }
    }

    public func callAsFunction(_ a: A) -> ZeroArgFunction<R> {
        ZeroArgFunction<R>(action: action, file: file, line: line) { (completion: @escaping FunctionWrapperCompletion<R>) in
            self.function(a, completion)
        }
    }
    
    @discardableResult
    public func callAsFunction<P: AsyncBlockPerformer>(_ link: Link<A, P>) -> Link<R, P> {
        link.chain(file: self.file, line: self.line, functionDescription: self.action, self.function)
    }

    public func on<P: AsyncBlockPerformer>(_ perfomer: P.Type) -> BoundSingleArgFunction<A,R,P> {
        BoundSingleArgFunction(single: self)
    }
}

public struct DoubleArgFunction<A,B,R> {
    let action: String
    let file: StaticString
    let line: UInt
    let function: (A, B, @escaping FunctionWrapperCompletion<R>) -> Void

    public func callAsFunction<P: AsyncBlockPerformer>(_ link: Link<Void, P>) -> AsyncDoubleArgFunction<A, B, R, P> {
        AsyncDoubleArgFunction(link: link) { (a: Link<A, P>, b: Link<B, P>) -> Link<R, P> in
            (a+b).chain(file: self.file, line: self.line, functionDescription: self.action) { (a_b: (A, B), completion: @escaping FunctionWrapperCompletion<R>) in
                self.function(a_b.0, a_b.1, completion)
            }
        }
    }
    
    public func callAsFunction(_ a: A) -> SingleArgFunction<B, R> {
        SingleArgFunction<B, R>(action: action, file: file, line: line) { (b: B, completion: @escaping FunctionWrapperCompletion<R>)  in
            self.function(a, b, completion)
        }
    }
    
    public func callAsFunction<P: AsyncBlockPerformer>(_ a: Link<A, P>) -> AsyncSingleArgFunction<B, R, P> {
        AsyncSingleArgFunction(link: a.drop) { (b: Link<B, P>) -> Link<R, P> in
            (a+b).chain(file: self.file, line: self.line, functionDescription: self.action) { (a_b: (A, B), completion: @escaping FunctionWrapperCompletion<R>) in
                self.function(a_b.0, a_b.1, completion)
            }
        }
    }

    public func on<P: AsyncBlockPerformer>(_ perfomer: P.Type) -> BoundDoubleArgFunction<A,B,R,P> {
        BoundDoubleArgFunction(double: self)
    }
}

public struct TripleArgFunction<A,B,C,R> {
    let action: String
    let file: StaticString
    let line: UInt
    let function: (A, B, C, @escaping FunctionWrapperCompletion<R>) -> Void

    public func callAsFunction<P: AsyncBlockPerformer>(_ link: Link<Void, P>) -> AsyncTripleArgFunction<A, B, C, R, P> {
        AsyncTripleArgFunction(link: link) { (a: Link<A, P>, b: Link<B, P>, c: Link<C, P>) -> Link<R, P> in
            (a+b+c).chain(file: self.file, line: self.line, functionDescription: self.action) { (a_b_c: (A, B, C), completion: @escaping FunctionWrapperCompletion<R>) in
                self.function(a_b_c.0, a_b_c.1, a_b_c.2, completion)
            }
        }
    }
    
    public func callAsFunction(_ a: A) -> DoubleArgFunction<B, C, R> {
        DoubleArgFunction<B, C, R>(action: action, file: file, line: line) { (b: B, c: C, completion: @escaping FunctionWrapperCompletion<R>) -> Void in
            self.function(a, b, c, completion)
        }
    }
    
    public func callAsFunction<P: AsyncBlockPerformer>(_ a: Link<A, P>) -> AsyncDoubleArgFunction<B, C, R, P> {
        AsyncDoubleArgFunction(link: a.drop) { (b: Link<B, P>, c: Link<C, P>) -> Link<R, P> in
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

public struct BoundZeroArgFunction<R,P: AsyncBlockPerformer> {
    let zero: ZeroArgFunction<R>
    init(zero: ZeroArgFunction<R>) {
        self.zero = zero
    }

    @discardableResult
    public func callAsFunction<X, P: AsyncBlockPerformer>(_ link: Link<X, P>) ->  Link<R, P>{
        zero(link)
    }
}

public struct BoundSingleArgFunction<A,R,P: AsyncBlockPerformer> {
    let single: SingleArgFunction<A,R>
    init(single: SingleArgFunction<A, R>) {
        self.single = single
    }

    public func callAsFunction(_ link: Link<Void, P>) -> AsyncSingleArgFunction<A, R, P> {
        self.single(link)
    }

    public func callAsFunction(_ a: A) -> ZeroArgFunction<R> {
        self.single(a)
    }

    @discardableResult
    public func callAsFunction(_ link: Link<A, P>) -> Link<R, P> {
        self.single(link)
    }
}

public struct BoundDoubleArgFunction<A,B,R,P: AsyncBlockPerformer> {
    let double: DoubleArgFunction<A,B,R>
    init(double: DoubleArgFunction<A,B,R>) {
        self.double = double
    }

    public func callAsFunction(_ link: Link<Void, P>) -> AsyncDoubleArgFunction<A,B,R,P> {
        self.double(link)
    }

    public func callAsFunction(_ a: A) -> SingleArgFunction<B,R> {
        self.double(a)
    }

    public func callAsFunction(_ link: Link<A, P>) -> AsyncSingleArgFunction<B,R,P> {
        self.double(link)
    }
}

public struct BoundTripleArgFunction<A,B,C,R,P: AsyncBlockPerformer> {
    let triple: TripleArgFunction<A,B,C,R>
    init(triple: TripleArgFunction<A,B,C,R>) {
        self.triple = triple
    }

    public func callAsFunction(_ link: Link<Void, P>) -> AsyncTripleArgFunction<A,B,C,R,P> {
        self.triple(link)
    }

    public func callAsFunction(_ a: A) -> DoubleArgFunction<B,C,R> {
        self.triple(a)
    }

    public func callAsFunction(_ link: Link<A, P>) -> AsyncDoubleArgFunction<B,C,R,P> {
        self.triple(link)
    }
}
