//
//  FunctionWrappers.swift
//  HoneyBee
//
//  Created by Alex Lynch on 4/23/19.
//  Copyright © 2019 IAM Apps. All rights reserved.
//

import Foundation


public struct AsyncZeroArgFunction<R, E: Error, P: AsyncBlockPerformer> {
    let link: Link<Void, E, P>
    let function: () -> Link<R, E, P>
    
    @discardableResult
    public func callAsFunction() -> Link<R, E, P> {
        link+>function()
    }
}


public struct AsyncSingleArgFunction<A, R, E: Error, P: AsyncBlockPerformer> {
	let link: Link<Void, E, P>
	let function: (Link<A, E, P>) -> Link<R, E, P>
	
	@discardableResult
    public func callAsFunction(_ a: A) -> Link<R, E, P> {
        return self.function(link.insert(a))
	}
	
	@discardableResult
    public func callAsFunction(_ link: Link<A, E, P>) -> Link<R, E, P> {
        return self.function(self.link +> link)
	}
}


public struct AsyncDoubleArgFunction<A,B,R, E: Error, P: AsyncBlockPerformer> {
	let link: Link<Void, E, P>
	let function: (Link<A, E, P>, Link<B, E, P>) -> Link<R, E, P>
	
	public func callAsFunction(_ a: A) -> AsyncSingleArgFunction<B,R,E,P> {
        let a = self.link.insert(a)
		let functionReference = self.function
		let wrapped = { (b: Link<B, E, P>) -> Link<R, E, P> in
			return functionReference(a, b)
		}
		return AsyncSingleArgFunction(link: self.link, function: wrapped)
	}
	
	public func callAsFunction(_ link: Link<A, E, P>) -> AsyncSingleArgFunction<B,R,E,P> {
        let a = self.link +> link
		let functionReference = self.function
		let wrapped = { (b: Link<B, E, P>) -> Link<R, E, P> in
			return functionReference(a, b)
		}
		return AsyncSingleArgFunction(link: self.link, function: wrapped)
	}
}


public struct AsyncTripleArgFunction<A,B,C,R, E: Error, P: AsyncBlockPerformer> {
	let link: Link<Void, E, P>
	let function: (Link<A, E, P>, Link<B, E, P>, Link<C, E, P>) -> Link<R, E, P>
	
	public func callAsFunction(_ a: A) -> AsyncDoubleArgFunction<B,C,R,E,P> {
        let a = self.link.insert(a)
		let functionReference = self.function
		let wrapped = { (b: Link<B, E, P>, c: Link<C, E, P>) -> Link<R, E, P> in
			return functionReference(a, b, c)
		}
		return AsyncDoubleArgFunction(link: self.link, function: wrapped)
	}
	
	public func callAsFunction(_ link: Link<A, E, P>) -> AsyncDoubleArgFunction<B,C,R,E,P> {
        let a = self.link +> link
		let functionReference = self.function
		let wrapped = { (b: Link<B, E, P>, c: Link<C, E, P>) -> Link<R, E, P> in
			return functionReference(a, b, c)
		}
		return AsyncDoubleArgFunction(link: self.link, function: wrapped)
	}
}

typealias FunctionWrapperCompletion<R, E: Error> = (Result<R, E>)->Void


public struct ZeroArgFunction<R, E: Error> {
    let action: String
    let function: (@escaping FunctionWrapperCompletion<R, E>) -> Void
    
    @discardableResult
    public func callAsFunction<P: AsyncBlockPerformer>(_ link: Link<Void, E, P>, file: StaticString = #file, line: UInt = #line) -> Link<R, E, P> {
        link.chain(file: file, line: line, functionDescription: self.action) { (_: Void, completion: @escaping FunctionWrapperCompletion<R,E>) in
            self.function(completion)
        }
    }

    @discardableResult
    public func callAsFunction<P: AsyncBlockPerformer>(_ link: Link<Void, Never, P>, file: StaticString = #file, line: UInt = #line) -> Link<R, E, P> {
        link.chain(file: file, line: line, functionDescription: self.action) { (_: Void, completion: @escaping FunctionWrapperCompletion<R,E>) in
            self.function(completion)
        }
    }

    public func on<P: AsyncBlockPerformer>(_ perfomer: P.Type) -> BoundZeroArgFunction<R,E,P> {
        BoundZeroArgFunction(zero: self)
    }
}

extension ZeroArgFunction where E == Never {
    @discardableResult
    public func callAsFunction<P: AsyncBlockPerformer>(_ link: Link<Void, Never, P>, file: StaticString = #file, line: UInt = #line) -> Link<R, E, P> {
        link.chain(file: file, line: line, functionDescription: self.action) { (_: Void, completion: @escaping FunctionWrapperCompletion<R,Never>) in
            self.function(completion)
        }
    }

    @discardableResult
    public func callAsFunction<OtherE: Error, P: AsyncBlockPerformer>(_ link: Link<Void, OtherE, P>, file: StaticString = #file, line: UInt = #line) -> Link<R, OtherE, P> {
        link.chain(file: file, line: line) { (_:Void, completion: @escaping (Result<R, OtherE>) -> Void) in
            self.function { result in
                switch result {
                case .success(let r):
                    completion(.success(r))
                case .failure(_): // Never
                    preconditionFailure()
                }
            }
        }
    }
}


public struct SingleArgFunction<A,R, E: Error> {
    let action: String
    let function: (A, @escaping FunctionWrapperCompletion<R, E>) -> Void
    

    public func callAsFunction<P: AsyncBlockPerformer>(_ link: Link<Void, E, P>, file: StaticString = #file, line: UInt = #line) -> AsyncSingleArgFunction<A,R,E,P> {
        AsyncSingleArgFunction(link: link) { (link: Link<A, E, P>) -> Link<R, E, P> in
            link.chain(file: file, line: line, functionDescription: self.action, self.function)
        }
    }

    public func callAsFunction<OtherE: Error, P: AsyncBlockPerformer>(_ link: Link<Void, OtherE, P>, file: StaticString = #file, line: UInt = #line) -> AsyncSingleArgFunction<A,R,OtherE,P> where E == Never {
        let errorLifting = link.chain { (_, completion: @escaping (Result<Void, OtherE>) -> Void) in
            completion(.success(Void()))
        }
        return AsyncSingleArgFunction(link: errorLifting) { (link: Link<A, OtherE, P>) -> Link<R, OtherE, P> in
            link.chain(file: file, line: line, functionDescription: self.action, self.function)
        }
    }

    public func callAsFunction<P: AsyncBlockPerformer>(_ link: Link<Void, Never, P>, file: StaticString = #file, line: UInt = #line) -> AsyncSingleArgFunction<A,R,E,P> {
        let errorLifting = link.chain { (_, completion: @escaping (Result<Void, E>) -> Void) in
            completion(.success(Void()))
        }
        return AsyncSingleArgFunction(link: errorLifting) { (link: Link<A, E, P>) -> Link<R, E, P> in
            link.chain(file: file, line: line, functionDescription: self.action, self.function)
        }
    }

    public func callAsFunction(_ a: A) -> ZeroArgFunction<R, E> {
        return ZeroArgFunction<R, E>(action: action) { (completion: @escaping FunctionWrapperCompletion<R, E>) in
            self.function(a, completion)
        }
    }
    
    @discardableResult
    public func callAsFunction<P: AsyncBlockPerformer>(_ link: Link<A, E, P>, file: StaticString = #file, line: UInt = #line) -> Link<R, E, P> {
        link.chain(file: file, line: line, functionDescription: self.action, self.function)
    }

    @discardableResult
    public func callAsFunction<P: AsyncBlockPerformer>(_ link: Link<A, Never, P>, file: StaticString = #file, line: UInt = #line) -> Link<R, E, P> {
        link.chain(file: file, line: line, functionDescription: self.action, self.function)
    }

    @discardableResult
    public func callAsFunction<P: AsyncBlockPerformer>(_ link: Link<A, Never, P>, file: StaticString = #file, line: UInt = #line) -> Link<R, E, P> where E == Never{
        link.chain(file: file, line: line, functionDescription: self.action, self.function)
    }

    public func callAsFunction<OtherE: Error, P: AsyncBlockPerformer>(_ link: Link<A, OtherE, P>, file: StaticString = #file, line: UInt = #line) -> Link<R, OtherE, P> where E == Never {
        link.chain(file: file, line: line, functionDescription: self.action, self.function)
    }

    public func on<P: AsyncBlockPerformer>(_ perfomer: P.Type) -> BoundSingleArgFunction<A,R,E,P> {
        BoundSingleArgFunction(single: self)
    }
}


public struct DoubleArgFunction<A,B,R, E: Error> {
    let action: String
    let function: (A, B, @escaping FunctionWrapperCompletion<R, E>) -> Void

    public func callAsFunction<P: AsyncBlockPerformer>(_ link: Link<Void, E, P>, file: StaticString = #file, line: UInt = #line) -> AsyncDoubleArgFunction<A,B,R,E,P> {
        AsyncDoubleArgFunction(link: link) { (a: Link<A, E, P>, b: Link<B, E, P>) -> Link<R, E, P> in
            (a+b).chain(file: file, line: line, functionDescription: self.action) { (a_b: (A, B), completion: @escaping FunctionWrapperCompletion<R, E>) in
                self.function(a_b.0, a_b.1, completion)
            }
        }
    }

    public func callAsFunction<P: AsyncBlockPerformer>(_ link: Link<Void, Never, P>, file: StaticString = #file, line: UInt = #line) -> AsyncDoubleArgFunction<A,B,R,E,P> {
        let errorLifting = link.chain { (_, completion: @escaping (Result<Void, E>) -> Void) in
            completion(.success(Void()))
        }
        return AsyncDoubleArgFunction(link: errorLifting) { (a: Link<A, E, P>, b: Link<B, E, P>) -> Link<R, E, P> in
            (a+b).chain(file: file, line: line, functionDescription: self.action) { (a_b: (A, B), completion: @escaping FunctionWrapperCompletion<R, E>) in
                self.function(a_b.0, a_b.1, completion)
            }
        }
    }
    
    public func callAsFunction(_ a: A) -> SingleArgFunction<B,R,E> {
        SingleArgFunction<B,R,E>(action: action) { (b: B, completion: @escaping FunctionWrapperCompletion<R, E>)  in
            self.function(a, b, completion)
        }
    }
    
    public func callAsFunction<P: AsyncBlockPerformer>(_ link: Link<A, E, P>, file: StaticString = #file, line: UInt = #line) -> AsyncSingleArgFunction<B,R,E,P> {
        let a = link
        return AsyncSingleArgFunction(link: a.drop) { (b: Link<B, E, P>) -> Link<R, E, P> in
            (a+b).chain(file: file, line: line, functionDescription: self.action) { (a_b: (A, B), completion: @escaping FunctionWrapperCompletion<R, E>) in
                self.function(a_b.0, a_b.1, completion)
            }
        }
    }

    public func on<P: AsyncBlockPerformer>(_ perfomer: P.Type) -> BoundDoubleArgFunction<A,B,R,E,P> {
        BoundDoubleArgFunction(double: self)
    }
}


public struct TripleArgFunction<A,B,C,R, E: Error> {
    let action: String
    let function: (A, B, C, @escaping FunctionWrapperCompletion<R, E>) -> Void

    public func callAsFunction<P: AsyncBlockPerformer>(_ link: Link<Void, E, P>, file: StaticString = #file, line: UInt = #line) -> AsyncTripleArgFunction<A,B,C,R,E,P> {
        AsyncTripleArgFunction(link: link) { (a: Link<A, E, P>, b: Link<B, E, P>, c: Link<C, E, P>) -> Link<R, E, P> in
            (a+b+c).chain(file: file, line: line, functionDescription: self.action) { (a_b_c: (A, B, C), completion: @escaping FunctionWrapperCompletion<R, E>) in
                self.function(a_b_c.0, a_b_c.1, a_b_c.2, completion)
            }
        }
    }

    public func callAsFunction<P: AsyncBlockPerformer>(_ link: Link<Void, Never, P>, file: StaticString = #file, line: UInt = #line) -> AsyncTripleArgFunction<A,B,C,R,E,P> {
        let errorLifting = link.chain { (_, completion: @escaping (Result<Void, E>) -> Void) in
            completion(.success(Void()))
        }
        return AsyncTripleArgFunction(link: errorLifting) { (a: Link<A, E, P>, b: Link<B, E, P>, c: Link<C, E, P>) -> Link<R, E, P> in
            (a+b+c).chain(file: file, line: line, functionDescription: self.action) { (a_b_c: (A, B, C), completion: @escaping FunctionWrapperCompletion<R, E>) in
                self.function(a_b_c.0, a_b_c.1, a_b_c.2, completion)
            }
        }
    }
    
    public func callAsFunction(_ a: A) -> DoubleArgFunction<B,C,R,E> {
        DoubleArgFunction<B,C,R,E>(action: action) { (b: B, c: C, completion: @escaping FunctionWrapperCompletion<R, E>) -> Void in
            self.function(a, b, c, completion)
        }
    }
    
    public func callAsFunction<P: AsyncBlockPerformer>(_ link: Link<A, E, P>, file: StaticString = #file, line: UInt = #line) -> AsyncDoubleArgFunction<B,C,R,E,P> {
        let a = link
        return AsyncDoubleArgFunction(link: a.drop) { (b: Link<B, E, P>, c: Link<C, E, P>) -> Link<R, E, P> in
            (a+b+c).chain(file: file, line: line, functionDescription: self.action) { (a_b_c: (A, B, C), completion: @escaping FunctionWrapperCompletion<R, E>) in
                self.function(a_b_c.0, a_b_c.1, a_b_c.2, completion)
            }
        }
    }

    public func on<P: AsyncBlockPerformer>(_ perfomer: P.Type) -> BoundTripleArgFunction<A,B,C,R,E,P> {
        BoundTripleArgFunction(triple: self)
    }
}

public struct BoundZeroArgFunction<R, E: Error,P: AsyncBlockPerformer> {
    let zero: ZeroArgFunction<R, E>
    init(zero: ZeroArgFunction<R, E>) {
        self.zero = zero
    }

    @discardableResult
    public func callAsFunction(_ link: Link<Void, E, P>) -> Link<R, E, P> {
        self.zero(link)
    }
}


public struct BoundSingleArgFunction<A,R, E: Error,P: AsyncBlockPerformer> {
    let single: SingleArgFunction<A,R,E>
    init(single: SingleArgFunction<A,R,E>) {
        self.single = single
    }

    public func callAsFunction(_ link: Link<Void, E, P>) -> AsyncSingleArgFunction<A,R,E,P> {
        self.single(link)
    }

    public func callAsFunction(_ a: A) -> ZeroArgFunction<R, E> {
        self.single(a)
    }

    @discardableResult
    public func callAsFunction(_ link: Link<A, E, P>) -> Link<R, E, P> {
        self.single(link)
    }
}


public struct BoundDoubleArgFunction<A,B,R, E: Error,P: AsyncBlockPerformer> {
    let double: DoubleArgFunction<A,B,R,E>
    init(double: DoubleArgFunction<A,B,R,E>) {
        self.double = double
    }

    public func callAsFunction(_ link: Link<Void, E, P>) -> AsyncDoubleArgFunction<A,B,R,E,P> {
        self.double(link)
    }

    public func callAsFunction(_ a: A) -> SingleArgFunction<B,R,E> {
        self.double(a)
    }

    public func callAsFunction(_ link: Link<A, E, P>) -> AsyncSingleArgFunction<B,R,E,P> {
        self.double(link)
    }
}


public struct BoundTripleArgFunction<A,B,C,R, E: Error,P: AsyncBlockPerformer> {
    let triple: TripleArgFunction<A,B,C,R,E>
    init(triple: TripleArgFunction<A,B,C,R,E>) {
        self.triple = triple
    }

    public func callAsFunction(_ link: Link<Void, E, P>) -> AsyncTripleArgFunction<A,B,C,R,E,P> {
        self.triple(link)
    }

    public func callAsFunction(_ a: A) -> DoubleArgFunction<B,C,R,E> {
        self.triple(a)
    }

    public func callAsFunction(_ link: Link<A, E, P>) -> AsyncDoubleArgFunction<B,C,R,E,P> {
        self.triple(link)
    }
}
