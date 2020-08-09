//
//  FunctionWrappers.swift
//  HoneyBee
//
//  Created by Alex Lynch on 4/23/19.
//  Copyright © 2019 IAM Apps. All rights reserved.
//

import Foundation

fileprivate func hname(_ t: Any) -> String {
    "-- \(tname(t))"
}

public struct AsyncZeroArgFunction<R, E: Error, P: AsyncBlockPerformer> {
    let action: String
    let root: Link<Void, E, P>
    let function: () -> Link<R, E, P>

    init(action: String?, root: Link<Void, E, P>, function: @escaping () -> Link<R, E, P>) {
        self.action = action ?? hname(function)
        self.root = root
        self.function = function
    }
    
    @discardableResult
    public func callAsFunction(file: StaticString = #file, line: UInt = #line) -> Link<R, E, P> {
        root+>function().document(action: action, file: file, line: line)
    }
}


public struct AsyncSingleArgFunction<A, R, E: Error, P: AsyncBlockPerformer> {
    let action: String
	let root: Link<Void, E, P>
	let function: (Link<A, E, P>) -> Link<R, E, P>

    init(action: String?, root: Link<Void, E, P>, function: @escaping (Link<A, E, P>) -> Link<R, E, P>) {
        self.action = action ?? hname(function)
        self.root = root
        self.function = function
    }
	
	@discardableResult
    public func callAsFunction(_ a: A, file: StaticString = #file, line: UInt = #line) -> Link<R, E, P> {
        function(root.insert(a)).document(action: action, file: file, line: line)
	}
	
	@discardableResult
    public func callAsFunction(_ link: Link<A, E, P>, file: StaticString = #file, line: UInt = #line) -> Link<R, E, P> {
        function(root +> link).document(action: action, file: file, line: line)
	}

    @discardableResult
    public func callAsFunction(_ link: Link<A, Never, P>, file: StaticString = #file, line: UInt = #line) -> Link<R, E, P> {
        self(link.expect(E.self)).document(action: action, file: file, line: line)
    }
}

extension AsyncSingleArgFunction where E == Never {
    @discardableResult
    public func callAsFunction(_ link: Link<A, Never, P>, file: StaticString = #file, line: UInt = #line) -> Link<R, Never, P> {
        function(root +> link).document(action: action, file: file, line: line)
    }

    @discardableResult
    public func callAsFunction<OtherE: Error>(_ link: Link<A, OtherE, P>, file: StaticString = #file, line: UInt = #line) -> Link<R, OtherE, P> {
        (self.root.expect(OtherE.self) +> link).chain { (a: A, completion: @escaping (Result<R, OtherE>) -> Void) in
            self.function(self.root.insert(a)).expect(OtherE.self).onResult(completion)
        }.document(action: action, file: file, line: line)
    }

}


public struct AsyncDoubleArgFunction<A,B,R, E: Error, P: AsyncBlockPerformer> {
    let action: String
	let root: Link<Void, E, P>
	let function: (Link<A, E, P>, Link<B, E, P>) -> Link<R, E, P>

    init(action: String?, root: Link<Void, E, P>, function: @escaping (Link<A, E, P>, Link<B, E, P>) -> Link<R, E, P>) {
        self.action = action ?? hname(function)
        self.root = root
        self.function = function
    }
	
	public func callAsFunction(_ a: A) -> AsyncSingleArgFunction<B,R,E,P> {
        AsyncSingleArgFunction(action: action, root: self.root) { (b: Link<B, E, P>) -> Link<R, E, P> in
            self.function(self.root.insert(a), b)
        }
	}
	
	public func callAsFunction(_ link: Link<A, E, P>) -> AsyncSingleArgFunction<B,R,E,P> {
        let a = self.root +> link
		let functionReference = self.function
		let wrapped = { (b: Link<B, E, P>) -> Link<R, E, P> in
			return functionReference(a, b)
		}
		return AsyncSingleArgFunction(action: action, root: self.root, function: wrapped)
	}

    public func callAsFunction(_ link: Link<A, Never, P>) -> AsyncSingleArgFunction<B,R,E,P> {
        self(link.expect(E.self))
    }
}

extension AsyncDoubleArgFunction where E == Never {
    public func callAsFunction(_ link: Link<A, Never, P>) -> AsyncSingleArgFunction<B,R,Never,P> {
        let a = self.root +> link
        let functionReference = self.function
        let wrapped = { (b: Link<B, E, P>) -> Link<R, E, P> in
            return functionReference(a, b)
        }
        return AsyncSingleArgFunction(action: action, root: self.root, function: wrapped)
    }

    public func callAsFunction<OtherE: Error>(_ link: Link<A, OtherE, P>) -> AsyncSingleArgFunction<B,R,OtherE,P> {
        let rootLink = self.root
        let functionReference = self.function
        let a = rootLink.expect(OtherE.self) +> link
        return AsyncSingleArgFunction(action: action, root: link.drop) { (b: Link<B, OtherE, P>) -> Link<R, OtherE, P> in
            (a+b).chain { (a_b: (A, B), completion: @escaping (Result<R, OtherE>) -> Void) in
                functionReference(rootLink.insert(a_b.0), rootLink.insert(a_b.1)).expect(OtherE.self).onResult(completion)
            }
        }
    }
}


public struct AsyncTripleArgFunction<A,B,C,R, E: Error, P: AsyncBlockPerformer> {
    let action: String
	let root: Link<Void, E, P>
	let function: (Link<A, E, P>, Link<B, E, P>, Link<C, E, P>) -> Link<R, E, P>

    init(action: String?, root: Link<Void, E, P>, function: @escaping (Link<A, E, P>, Link<B, E, P>, Link<C, E, P>) -> Link<R, E, P>) {
        self.action = action ?? hname(function)
        self.root = root
        self.function = function
    }
	
	public func callAsFunction(_ a: A) -> AsyncDoubleArgFunction<B,C,R,E,P> {
        let a = self.root.insert(a)
		let functionReference = self.function
		let wrapped = { (b: Link<B, E, P>, c: Link<C, E, P>) -> Link<R, E, P> in
			return functionReference(a, b, c)
		}
		return AsyncDoubleArgFunction(action: action, root: self.root, function: wrapped)
	}
	
	public func callAsFunction(_ link: Link<A, E, P>) -> AsyncDoubleArgFunction<B,C,R,E,P> {
        let a = self.root +> link
		let functionReference = self.function
		let wrapped = { (b: Link<B, E, P>, c: Link<C, E, P>) -> Link<R, E, P> in
			return functionReference(a, b, c)
		}
		return AsyncDoubleArgFunction(action: action, root: self.root, function: wrapped)
	}

    public func callAsFunction(_ link: Link<A, Never, P>) -> AsyncDoubleArgFunction<B,C,R,E,P> {
        self(link.expect(E.self))
    }
}

extension AsyncTripleArgFunction where E == Never {
    public func callAsFunction(_ link: Link<A, Never, P>) -> AsyncDoubleArgFunction<B,C,R,Never,P> {
        let a = self.root +> link
        let functionReference = self.function
        let wrapped = { (b: Link<B, E, P>, c: Link<C, E, P>) -> Link<R, E, P> in
            return functionReference(a, b, c)
        }
        return AsyncDoubleArgFunction(action: action, root: self.root, function: wrapped)
    }

    public func callAsFunction<OtherE: Error>(_ a: Link<A, OtherE, P>) -> AsyncDoubleArgFunction<B,C,R,OtherE,P> {
        AsyncDoubleArgFunction(action: action, root: a.drop) { (b: Link<B, OtherE, P>, c: Link<C, OtherE, P>) -> Link<R, OtherE, P> in
            (a+b+c).chain { (a_b_c: (A, B, C), completion: @escaping (Result<R, OtherE>) -> Void) in
                self.function(self.root.insert(a_b_c.0),
                              self.root.insert(a_b_c.1),
                              self.root.insert(a_b_c.2)).expect(OtherE.self).onResult(completion)
            }
        }
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

    @discardableResult
    public func callAsFunction<OtherE: Error, P: AsyncBlockPerformer>(_ link: Link<Void, OtherE, P>, file: StaticString = #file, line: UInt = #line) -> Link<R, Error, P> {
        link.chain(file: file, line: line, functionDescription: self.action) { (_: Void, completion: @escaping FunctionWrapperCompletion<R,Error>) in
            self.function { result in
                completion(result.mapError {$0})
            }
        }
    }

    public func on<P: AsyncBlockPerformer>(_ perfomer: P.Type) -> BoundZeroArgFunction<R,E,P> {
        BoundZeroArgFunction(zero: self)
    }
}

extension ZeroArgFunction where E == Never {
    @discardableResult
    public func callAsFunction<P: AsyncBlockPerformer>(_ link: Link<Void, Never, P>, file: StaticString = #file, line: UInt = #line) -> Link<R, Never, P> {
        link.chain(file: file, line: line, functionDescription: self.action) { (_: Void, completion: @escaping FunctionWrapperCompletion<R,Never>) in
            self.function(completion)
        }
    }

    @discardableResult
    public func callAsFunction<OtherE: Error, P: AsyncBlockPerformer>(_ link: Link<Void, OtherE, P>, file: StaticString = #file, line: UInt = #line) -> Link<R, OtherE, P> {
        link.chain(file: file, line: line, functionDescription: self.action) { (_:Void, completion: @escaping (Result<R, OtherE>) -> Void) in
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

    public func callAsFunction(_ a: A) -> ZeroArgFunction<R, E> {
        ZeroArgFunction<R, E>(action: action) { (completion: @escaping FunctionWrapperCompletion<R, E>) in
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
    public func callAsFunction<OtherE: Error, P: AsyncBlockPerformer>(_ link: Link<A, OtherE, P>, file: StaticString = #file, line: UInt = #line) -> Link<R, Error, P> {
        link.chain(file: file, line: line, functionDescription: self.action, self.function)
    }

    public func on<P: AsyncBlockPerformer>(_ perfomer: P.Type) -> BoundSingleArgFunction<A,R,E,P> {
        BoundSingleArgFunction(single: self)
    }
}

extension SingleArgFunction where E == Never {
    @discardableResult
    public func callAsFunction<P: AsyncBlockPerformer>(_ link: Link<A, Never, P>, file: StaticString = #file, line: UInt = #line) -> Link<R, Never, P> {
        link.chain(file: file, line: line, functionDescription: self.action, self.function)
    }

    public func callAsFunction<OtherE: Error, P: AsyncBlockPerformer>(_ link: Link<A, OtherE, P>, file: StaticString = #file, line: UInt = #line) -> Link<R, OtherE, P> {
        link.chain(file: file, line: line, functionDescription: self.action, self.function)
    }

}


public struct DoubleArgFunction<A,B,R, E: Error> {
    let action: String
    let function: (A, B, @escaping FunctionWrapperCompletion<R, E>) -> Void
    
    public func callAsFunction(_ a: A) -> SingleArgFunction<B,R,E> {
        SingleArgFunction(action: action) { (b: B, completion: @escaping FunctionWrapperCompletion<R, E>)  in
            self.function(a, b, completion)
        }
    }
    
    public func callAsFunction<P: AsyncBlockPerformer>(_ a: Link<A, E, P>) -> AsyncSingleArgFunction<B,R,E,P> {
        AsyncSingleArgFunction(action: action, root: a.drop) { (b: Link<B, E, P>) -> Link<R, E, P> in
            (a+b).chain { (a_b: (A, B), completion: @escaping FunctionWrapperCompletion<R, E>) in
                self.function(a_b.0, a_b.1, completion)
            }
        }
    }

    public func callAsFunction<P: AsyncBlockPerformer>(_ link: Link<A, Never, P>) -> AsyncSingleArgFunction<B,R,E,P> {
        self(link.expect(E.self))
    }

    public func callAsFunction<OtherE: Error, P: AsyncBlockPerformer>(_ a: Link<A, OtherE, P>) -> AsyncSingleArgFunction<B,R,Error,P> {
        AsyncSingleArgFunction(action: action, root: a.drop.expect(Error.self)) { (b: Link<B, Error, P>) -> Link<R, Error, P> in
            (a+b).chain { (a_b: (A, B), completion: @escaping FunctionWrapperCompletion<R, E>) in
                self.function(a_b.0, a_b.1, completion)
            }
        }
    }

    public func on<P: AsyncBlockPerformer>(_ perfomer: P.Type) -> BoundDoubleArgFunction<A,B,R,E,P> {
        BoundDoubleArgFunction(double: self)
    }
}

extension DoubleArgFunction where E == Never {
    public func callAsFunction<P: AsyncBlockPerformer>(_ a: Link<A, Never, P>) -> AsyncSingleArgFunction<B,R,Never,P> {
        AsyncSingleArgFunction(action: action, root: a.drop) { (b: Link<B, E, P>) -> Link<R, E, P> in
            (a+b).chain { (a_b: (A, B), completion: @escaping FunctionWrapperCompletion<R, E>) in
                self.function(a_b.0, a_b.1, completion)
            }
        }
    }

    public func callAsFunction<OtherE: Error, P: AsyncBlockPerformer>(_ a: Link<A, OtherE, P>) -> AsyncSingleArgFunction<B,R,OtherE,P> {
        AsyncSingleArgFunction<B,R,OtherE,P>(action: action, root: a.drop) { (b: Link<B, OtherE, P>) -> Link<R, OtherE, P> in
            (a+b).chain { (a_b: (A, B), completion: @escaping FunctionWrapperCompletion<R, OtherE>) in
                self.function(a_b.0, a_b.1) { (result: Result<R, Never>) in
                    switch result {
                    case .success(let r):
                        completion(.success(r))
                    case .failure(_): //Never
                        preconditionFailure()
                    }
                }
            }
        }
    }
}


public struct TripleArgFunction<A,B,C,R, E: Error> {
    let action: String
    let function: (A, B, C, @escaping FunctionWrapperCompletion<R, E>) -> Void
    
    public func callAsFunction(_ a: A) -> DoubleArgFunction<B,C,R,E> {
        DoubleArgFunction(action: action) { (b: B, c: C, completion: @escaping FunctionWrapperCompletion<R, E>) -> Void in
            self.function(a, b, c, completion)
        }
    }
    
    public func callAsFunction<P: AsyncBlockPerformer>(_ a: Link<A, E, P>) -> AsyncDoubleArgFunction<B,C,R,E,P> {
        AsyncDoubleArgFunction(action: action, root: a.drop) { (b: Link<B, E, P>, c: Link<C, E, P>) -> Link<R, E, P> in
            (a+b+c).chain { (a_b_c: (A, B, C), completion: @escaping FunctionWrapperCompletion<R, E>) in
                self.function(a_b_c.0, a_b_c.1, a_b_c.2, completion)
            }
        }
    }

    public func callAsFunction<P: AsyncBlockPerformer>(_ link: Link<A, Never, P>) -> AsyncDoubleArgFunction<B,C,R,E,P> {
        self(link.expect(E.self))
    }

    public func callAsFunction<OtherE: Error, P: AsyncBlockPerformer>(_ a: Link<A, OtherE, P>) -> AsyncDoubleArgFunction<B,C,R,Error,P> {
        AsyncDoubleArgFunction<B,C,R,Error,P>(action: action, root: a.drop.expect(Error.self)) { (b: Link<B, Error, P>, c: Link<C, Error, P>) -> Link<R, Error, P> in
            (a+b+c).chain { (a_b_c: (A, B, C), completion: @escaping FunctionWrapperCompletion<R, Error>) in
                self.function(a_b_c.0, a_b_c.1, a_b_c.2) { result in
                    completion(result.mapError{$0})
                }
            }
        }
    }

    public func on<P: AsyncBlockPerformer>(_ perfomer: P.Type) -> BoundTripleArgFunction<A,B,C,R,E,P> {
        BoundTripleArgFunction(triple: self)
    }
}

extension TripleArgFunction where E == Never {
    public func callAsFunction<P: AsyncBlockPerformer>(_ a: Link<A, Never, P>) -> AsyncDoubleArgFunction<B,C,R,Never,P> {
        AsyncDoubleArgFunction(action: action, root: a.drop) { (b: Link<B, E, P>, c: Link<C, E, P>) -> Link<R, E, P> in
            (a+b+c).chain { (a_b_c: (A, B, C), completion: @escaping FunctionWrapperCompletion<R, E>) in
                self.function(a_b_c.0, a_b_c.1, a_b_c.2, completion)
            }
        }
    }

    public func callAsFunction<OtherE: Error, P: AsyncBlockPerformer>(_ a: Link<A, OtherE, P>) -> AsyncDoubleArgFunction<B,C,R,OtherE,P> {
        AsyncDoubleArgFunction(action: action, root: a.drop) { (b: Link<B, OtherE, P>, c: Link<C, OtherE, P>) -> Link<R, OtherE, P> in
            (a+b+c).chain { (a_b_c: (A, B, C), completion: @escaping FunctionWrapperCompletion<R, OtherE>) in
                self.function(a_b_c.0, a_b_c.1, a_b_c.2) { (result: Result<R, Never>) in
                    switch result {
                    case .success(let r):
                        completion(.success(r))
                    case .failure(_): //Never
                        preconditionFailure()
                    }
                }
            }
        }
    }
}

public struct BoundZeroArgFunction<R, E: Error,P: AsyncBlockPerformer> {
    let zero: ZeroArgFunction<R, E>
    init(zero: ZeroArgFunction<R, E>) {
        self.zero = zero
    }

    @discardableResult
    public func callAsFunction(_ link: Link<Void, E, P>, file: StaticString = #file, line: UInt = #line) -> Link<R, E, P> {
        self.zero(link, file: file, line: line)
    }

    public func callAsFunction<OtherE: Error>(_ link: Link<Void, OtherE, P>, file: StaticString = #file, line: UInt = #line) -> Link<R, Error, P> {
        self.zero(link, file: file, line: line)
    }
}

extension BoundZeroArgFunction where E == Never {
    @discardableResult
    public func callAsFunction(_ link: Link<Void, Never, P>, file: StaticString = #file, line: UInt = #line) -> Link<R, Never, P> {
        self.zero(link, file: file, line: line)
    }

    @discardableResult
    public func callAsFunction<OtherE: Error>(_ link: Link<Void, OtherE, P>, file: StaticString = #file, line: UInt = #line) -> Link<R, OtherE, P> {
        self.zero(link, file: file, line: line)
    }
}


public struct BoundSingleArgFunction<A,R, E: Error,P: AsyncBlockPerformer> {
    let single: SingleArgFunction<A,R,E>
    init(single: SingleArgFunction<A,R,E>) {
        self.single = single
    }

    public func callAsFunction(_ a: A) -> BoundZeroArgFunction<R, E, P> {
        .init(zero: self.single(a))
    }

    @discardableResult
    public func callAsFunction(_ link: Link<A, E, P>, file: StaticString = #file, line: UInt = #line) -> Link<R, E, P> {
        self.single(link, file: file, line: line)
    }

    @discardableResult
    public func callAsFunction(_ link: Link<A, Never, P>, file: StaticString = #file, line: UInt = #line) -> Link<R, E, P> {
        self.single(link, file: file, line: line)
    }

    @discardableResult
    public func callAsFunction<OtherE: Error>(_ link: Link<A, OtherE, P>, file: StaticString = #file, line: UInt = #line) -> Link<R, Error, P> {
        self.single(link, file: file, line: line)
    }
}

extension BoundSingleArgFunction where E == Never {
    @discardableResult
    public func callAsFunction(_ link: Link<A, Never, P>, file: StaticString = #file, line: UInt = #line) -> Link<R, Never, P> {
        self.single(link, file: file, line: line)
    }

    @discardableResult
    public func callAsFunction<OtherE: Error>(_ link: Link<A, OtherE, P>, file: StaticString = #file, line: UInt = #line) -> Link<R, OtherE, P> {
        self.single(link, file: file, line: line)
    }
}


public struct BoundDoubleArgFunction<A,B,R, E: Error,P: AsyncBlockPerformer> {
    let double: DoubleArgFunction<A,B,R,E>
    init(double: DoubleArgFunction<A,B,R,E>) {
        self.double = double
    }

    public func callAsFunction(_ a: A) -> BoundSingleArgFunction<B,R,E,P> {
        .init(single: self.double(a))
    }

    public func callAsFunction(_ link: Link<A, E, P>) -> AsyncSingleArgFunction<B,R,E,P> {
        self.double(link)
    }

    public func callAsFunction(_ link: Link<A, Never, P>) -> AsyncSingleArgFunction<B,R,E,P> {
        self.double(link)
    }

    public func callAsFunction<OtherE: Error>(_ link: Link<A, OtherE, P>) -> AsyncSingleArgFunction<B,R,Error,P> {
        self.double(link)
    }
}

extension BoundDoubleArgFunction where E == Never {
    public func callAsFunction(_ link: Link<A, Never, P>) -> AsyncSingleArgFunction<B,R,E,P> {
        self.double(link)
    }

    public func callAsFunction<OtherE: Error>(_ link: Link<A, OtherE, P>) -> AsyncSingleArgFunction<B,R,OtherE,P> {
        self.double(link)
    }
}


public struct BoundTripleArgFunction<A,B,C,R, E: Error,P: AsyncBlockPerformer> {
    let triple: TripleArgFunction<A,B,C,R,E>
    init(triple: TripleArgFunction<A,B,C,R,E>) {
        self.triple = triple
    }

    public func callAsFunction(_ a: A) -> BoundDoubleArgFunction<B,C,R,E,P> {
        .init(double: self.triple(a))
    }

    public func callAsFunction(_ link: Link<A, E, P>) -> AsyncDoubleArgFunction<B,C,R,E,P> {
        self.triple(link)
    }

    public func callAsFunction<OtherE: Error>(_ link: Link<A, OtherE, P>) -> AsyncDoubleArgFunction<B,C,R,Error,P> {
        self.triple(link)
    }
}

extension BoundTripleArgFunction where E == Never {
    public func callAsFunction(_ link: Link<A, Never, P>) -> AsyncDoubleArgFunction<B,C,R,E,P> {
        self.triple(link)
    }

    public func callAsFunction<OtherE: Error>(_ link: Link<A, OtherE, P>) -> AsyncDoubleArgFunction<B,C,R,OtherE,P> {
        self.triple(link)
    }
}
