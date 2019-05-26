//
//  AwaitCurry.swift
//  HoneyBee
//
//  Created by Alex Lynch on 4/23/19.
//  Copyright © 2019 IAM Apps. All rights reserved.
//

import Foundation

extension Link {
	
	@discardableResult
	public func await(_ function: @escaping () throws -> Void, file: StaticString = #file, line: UInt = #line) -> Link<Void, Performer>  {
		return self.drop().chain(file: file, line: line, functionDescription: tname(function), function)
	}
	@discardableResult
	public func await<R>(_ function: @escaping () throws -> R, file: StaticString = #file, line: UInt = #line) -> Link<R, Performer>  {
		return self.drop().chain(file: file, line: line, functionDescription: tname(function), function)
	}
	public func await<A,R>(_ function: @escaping (A) throws -> R, file: StaticString = #file, line: UInt = #line) -> SingleArgFunction<A,R, Performer> {
		let wrapper = { (a: Link<A, Performer>) -> Link<R, Performer> in
			return a.chain(file: file, line: line, functionDescription: tname(function), function)
		}
		return SingleArgFunction(link: self.drop(), function: wrapper)
	}
	public func await<A,B,R>(_ function: @escaping (A,B) throws -> R, file: StaticString = #file, line: UInt = #line) -> DoubleArgFunction<A,B,R, Performer> {
		let wrapper = { (a: Link<A, Performer>, b: Link<B, Performer>) -> Link<R, Performer> in
			return (a+b).chain(file: file, line: line, functionDescription: tname(function), function)
		}
		return DoubleArgFunction(link: self.drop(), function: wrapper)
	}
	public func await<A,B,C,R>(_ function: @escaping (A,B,C) throws -> R, file: StaticString = #file, line: UInt = #line) -> TripleArgFunction<A,B,C,R, Performer> {
		let wrapper = { (a: Link<A, Performer>, b: Link<B, Performer>, c: Link<C, Performer>) -> Link<R, Performer> in
			return (a+b+c).chain(file: file, line: line, functionDescription: tname(function), function)
		}
		return TripleArgFunction(link: self.drop(), function: wrapper)
	}

	@discardableResult
	public func await<R>(_ function: @escaping (@escaping (R?, Error?) -> Void) -> Void, file: StaticString = #file, line: UInt = #line) -> Link<R, Performer> {
		return self.drop().chain(file: file, line: line, functionDescription: tname(function), function)
	}
	public func await<A,R>(_ function: @escaping (A, @escaping (R?, Error?) -> Void) -> Void, file: StaticString = #file, line: UInt = #line) -> SingleArgFunction<A,R, Performer> {
		let wrapper = { (a: Link<A, Performer>) -> Link<R, Performer> in
			return a.chain(file: file, line: line, functionDescription: tname(function), function)
		}
		return SingleArgFunction(link: self.drop(), function: wrapper)
	}
	public func await<A,B,R>(_ function: @escaping (A,B, @escaping (R?, Error?) -> Void) -> Void, file: StaticString = #file, line: UInt = #line) -> DoubleArgFunction<A,B,R, Performer> {
		let wrapper = { (a: Link<A, Performer>, b: Link<B, Performer>) -> Link<R, Performer> in
			return (a+b).chain(file: file, line: line, functionDescription: tname(function)) { (unwrappedArgs: (a: A, b: B), completion: @escaping (R?, Error?) -> Void) -> Void in
				function(unwrappedArgs.a,unwrappedArgs.b,completion)
			}
		}
		return DoubleArgFunction(link: self.drop(), function: wrapper)
	}
	public func await<A,B,C,R>(_ function: @escaping (A,B,C, @escaping (R?, Error?) -> Void) -> Void, file: StaticString = #file, line: UInt = #line) -> TripleArgFunction<A,B,C,R, Performer> {
		let wrapper = { (a: Link<A, Performer>, b: Link<B, Performer>, c: Link<C, Performer>) -> Link<R, Performer> in
			return (a+b+c).chain(file: file, line: line, functionDescription: tname(function)) { (unwrappedArgs: (a: A, b: B, c: C), completion: @escaping (R?, Error?) -> Void) -> Void in
				function(unwrappedArgs.a,unwrappedArgs.b,unwrappedArgs.c,completion)
			}
		}
		return TripleArgFunction(link: self.drop(), function: wrapper)
	}


	@discardableResult
	public func await<R>(_ function: @escaping (@escaping (Error?, R?) -> Void) -> Void, file: StaticString = #file, line: UInt = #line) -> Link<R, Performer> {
		let wrapper = { (completion: @escaping (R?, Error?) -> Void) -> Void in
			function() { error, r in
				completion(r, error)
			}
		}
		return self.await(wrapper)
	}
	public func await<A,R>(_ function: @escaping (A, @escaping (Error?, R?) -> Void) -> Void, file: StaticString = #file, line: UInt = #line) -> SingleArgFunction<A,R, Performer> {
		let wrapper = { (a: A, completion: @escaping (R?, Error?) -> Void) -> Void in
			function(a) { error, r in
				completion(r, error)
			}
		}
		return self.await(wrapper)
	}
	public func await<A,B,R>(_ function: @escaping (A,B, @escaping (Error?, R?) -> Void) -> Void, file: StaticString = #file, line: UInt = #line) -> DoubleArgFunction<A,B,R, Performer> {
		let wrapper = { (a: A, b: B, completion: @escaping (R?, Error?) -> Void) -> Void in
			function(a, b) { error, r in
				completion(r, error)
			}
		}
		return self.await(wrapper)
	}
	public func await<A,B,C,R>(_ function: @escaping (A,B,C, @escaping (Error?, R?) -> Void) -> Void, file: StaticString = #file, line: UInt = #line) -> TripleArgFunction<A,B,C,R, Performer> {
		let wrapper = { (a: A, b: B, c: C, completion: @escaping (R?, Error?) -> Void) -> Void in
			function(a, b, c) { error, r in
				completion(r, error)
			}
		}
		return self.await(wrapper)
	}

	public func await(_ function: @escaping (((Error?) -> Void)?) -> Void, file: StaticString = #file, line: UInt = #line) -> Link<Void, Performer> {
		return self.drop().chain(file: file, line: line, functionDescription: tname(function), function)
	}
	public func await(_ function: @escaping (@escaping (Error?) -> Void) -> Void, file: StaticString = #file, line: UInt = #line) -> Link<Void, Performer> {
		return self.drop().chain(file: file, line: line, functionDescription: tname(function), function)
	}
	public func await<A>(_ function: @escaping (A, @escaping (Error?) -> Void) -> Void, file: StaticString = #file, line: UInt = #line) -> SingleArgFunction<A,Void, Performer> {
		let wrapper = { (a: Link<A, Performer>) -> Link<Void, Performer> in
			return a.chain(file: file, line: line, functionDescription: tname(function), function).drop()
		}
		return SingleArgFunction(link: self.drop(), function: wrapper)
	}
	public func await<A,B>(_ function: @escaping (A,B, @escaping (Error?) -> Void) -> Void, file: StaticString = #file, line: UInt = #line) -> DoubleArgFunction<A,B,Void, Performer> {
		let wrapper = { (a: Link<A, Performer>, b: Link<B, Performer>) -> Link<Void, Performer> in
			(a+b).chain(file: file, line: line, functionDescription: tname(function)) { (unwrappedArgs: (a: A, b: B), completion: @escaping (Error?) -> Void) -> Void in
				function(unwrappedArgs.a, unwrappedArgs.b, completion)
				}.drop()
		}
		return DoubleArgFunction(link: self.drop(), function: wrapper)
	}
	public func await<A,B,C>(_ function: @escaping (A,B,C, @escaping (Error?) -> Void) -> Void, file: StaticString = #file, line: UInt = #line) -> TripleArgFunction<A,B,C,Void, Performer> {
		let wrapper = { (a: Link<A, Performer>, b: Link<B, Performer>, c: Link<C, Performer>) -> Link<Void, Performer> in
			(a+b+c).chain(file: file, line: line, functionDescription: tname(function)) { (unwrappedArgs: (a: A, b: B, c:C), completion: @escaping (Error?) -> Void) -> Void in
				function(unwrappedArgs.a, unwrappedArgs.b, unwrappedArgs.c, completion)
				}.drop()
		}
		return TripleArgFunction(link: self.drop(), function: wrapper)
	}


	public func await<A,R>(_ function: @escaping (A) -> () throws -> R, file: StaticString = #file, line: UInt = #line) -> SingleArgFunction<A,R, Performer> {
		let wrapped = { (a: Link<A, Performer>) -> Link<R, Performer> in
			return a.chain(file: file, line: line, functionDescription: tname(function)) { (a: A) throws -> R in
				return try function(a)()
			}
		}
		return SingleArgFunction(link: self.drop(), function: wrapped)
	}
	public func await<A,B,R>(_ function: @escaping (A) -> (B) throws -> R, file: StaticString = #file, line: UInt = #line) -> DoubleArgFunction<A,B,R, Performer> {
		let wrapped = { (a: Link<A, Performer>, b: Link<B, Performer>) -> Link<R, Performer> in
			return (a+b).chain(file: file, line: line, functionDescription: tname(function)) { (a: A, b: B) throws -> R in
				return try function(a)(b)
			}
		}
		return DoubleArgFunction(link: self.drop(), function: wrapped)
	}
	public func await<A,B,C,R>(_ function: @escaping (A) -> (B,C) throws -> R, file: StaticString = #file, line: UInt = #line) -> TripleArgFunction<A,B,C,R, Performer> {
		let wrapped = { (a: Link<A, Performer>, b: Link<B, Performer>, c: Link<C, Performer>) -> Link<R, Performer> in
			return (a+b+c).chain(file: file, line: line, functionDescription: tname(function)) { (a: A, b: B, c: C) throws -> R in
				return try function(a)(b,c)
			}
		}
		return TripleArgFunction(link: self.drop(), function: wrapped)
	}
	
	
	public func await<A,B,E: Error>(_ function: @escaping (A,B, ((E?) -> Void)?) -> Void, file: StaticString = #file, line: UInt = #line) -> DoubleArgFunction<A,B,Void, Performer> {
		let wrapper = { (a: Link<A, Performer>, b: Link<B, Performer>) -> Link<Void, Performer> in
			(a+b).chain(file: file, line: line, functionDescription: tname(function)) { (unwrappedArgs: (a: A, b: B), completion: @escaping (Error?) -> Void) -> Void in
				let _ = function(unwrappedArgs.a, unwrappedArgs.b, completion)
				}.drop()
		}
		return DoubleArgFunction(link: self.drop(), function: wrapper)
	}
	

	@discardableResult
	public func await<R,Failable>(_ function: @escaping (@escaping (Failable) -> Void) -> Void, file: StaticString = #file, line: UInt = #line) -> Link<R, Performer> where Failable : FailableResultProtocol, Failable.Wrapped == R {
		return self.drop().chain(file: file, line: line, functionDescription: tname(function), function)
	}
	public func await<A,R,Failable>(_ function: @escaping (A, @escaping (Failable) -> Void) -> Void, file: StaticString = #file, line: UInt = #line) -> SingleArgFunction<A,R, Performer>  where Failable : FailableResultProtocol, Failable.Wrapped == R {
		let wrapper = { (a: Link<A, Performer>) -> Link<R, Performer> in
			return a.chain(file: file, line: line, functionDescription: tname(function), function)
		}
		return SingleArgFunction(link: self.drop(), function: wrapper)
	}
	public func await<A,B,R,Failable>(_ function: @escaping (A,B, @escaping (Failable) -> Void) -> Void, file: StaticString = #file, line: UInt = #line) -> DoubleArgFunction<A,B,R, Performer> where Failable : FailableResultProtocol, Failable.Wrapped == R {
		let wrapper = { (a: Link<A, Performer>, b: Link<B, Performer>) -> Link<R, Performer> in
			return (a+b).chain(file: file, line: line, functionDescription: tname(function)) { (unwrappedArgs: (a: A, b: B), completion: @escaping (Failable) -> Void) -> Void in
				function(unwrappedArgs.a, unwrappedArgs.b, completion)
			}
		}
		return DoubleArgFunction(link: self.drop(), function: wrapper)
	}
	public func await<A,B,C,R,Failable>(_ function: @escaping (A,B,C, @escaping (Failable) -> Void) -> Void, file: StaticString = #file, line: UInt = #line) -> TripleArgFunction<A,B,C,R, Performer> where Failable : FailableResultProtocol, Failable.Wrapped == R {
		let wrapper = { (a: Link<A, Performer>, b: Link<B, Performer>, c: Link<C, Performer>) -> Link<R, Performer> in
			return (a+b+c).chain(file: file, line: line, functionDescription: tname(function)) { (unwrappedArgs: (a: A, b: B, c: C), completion: @escaping (Failable) -> Void) -> Void in
				function(unwrappedArgs.a, unwrappedArgs.b, unwrappedArgs.c, completion)
			}
		}
		return TripleArgFunction(link: self.drop(), function: wrapper)
	}
	

	public func await<A,R,Failable>(_ function: @escaping (A) -> (@escaping (Failable) -> Void) -> Void, file: StaticString = #file, line: UInt = #line) -> SingleArgFunction<A,R, Performer>  where Failable : FailableResultProtocol, Failable.Wrapped == R {
		let wrapper = { (a: Link<A, Performer>) -> Link<R, Performer> in
			return a.chain(file: file, line: line, functionDescription: tname(function)) { (a: A, completion: @escaping (Failable) -> Void) in
				function(a)(completion)
			}
		}
		return SingleArgFunction(link: self.drop(), function: wrapper)
	}
	public func await<A,B,R,Failable>(_ function: @escaping (A) -> (B, @escaping (Failable) -> Void) -> Void, file: StaticString = #file, line: UInt = #line) -> DoubleArgFunction<A,B,R, Performer> where Failable : FailableResultProtocol, Failable.Wrapped == R {
		let wrapper = { (a: Link<A, Performer>, b: Link<B, Performer>) -> Link<R, Performer> in
			return (a+b).chain(file: file, line: line, functionDescription: tname(function)){ (unwrappedArgs: (a: A, b: B), completion: @escaping (Failable) -> Void) -> Void in
				function(unwrappedArgs.a)(unwrappedArgs.b, completion)
			}
		}
		return DoubleArgFunction(link: self.drop(), function: wrapper)
	}
	public func await<A,B,C,R,Failable>(_ function: @escaping (A) -> (B,C, @escaping (Failable) -> Void) -> Void, file: StaticString = #file, line: UInt = #line) -> TripleArgFunction<A,B,C,R, Performer> where Failable : FailableResultProtocol, Failable.Wrapped == R {
		let wrapper = { (a: Link<A, Performer>, b: Link<B, Performer>, c: Link<C, Performer>) -> Link<R, Performer> in
			return (a+b+c).chain(file: file, line: line, functionDescription: tname(function)) { (unwrappedArgs: (a: A, b: B, c: C), completion: @escaping (Failable) -> Void) -> Void in
				function(unwrappedArgs.a)(unwrappedArgs.b, unwrappedArgs.c, completion)
			}
		}
		return TripleArgFunction(link: self.drop(), function: wrapper)
	}


	public func await<A,R>(_ function: @escaping (A) -> (@escaping (R?, Error?) -> Void) -> Void, file: StaticString = #file, line: UInt = #line) -> SingleArgFunction<A,R, Performer>  {
		let wrapper = { (a: Link<A, Performer>) -> Link<R, Performer> in
			return a.chain(file: file, line: line, functionDescription: tname(function)) { (a: A, completion: @escaping (R?, Error?) -> Void) in
				function(a)(completion)
			}
		}
		return SingleArgFunction(link: self.drop(), function: wrapper)
	}
	public func await<A,B,R>(_ function: @escaping (A) -> (B, @escaping (R?, Error?) -> Void) -> Void, file: StaticString = #file, line: UInt = #line) -> DoubleArgFunction<A,B,R, Performer> {
		let wrapper = { (a: Link<A, Performer>, b: Link<B, Performer>) -> Link<R, Performer> in
			return (a+b).chain(file: file, line: line, functionDescription: tname(function)) { (unwrappedArgs: (a: A, b: B), completion: @escaping (R?, Error?) -> Void) -> Void in
				function(unwrappedArgs.a)(unwrappedArgs.b, completion)
			}
		}
		return DoubleArgFunction(link: self.drop(), function: wrapper)
	}
	public func await<A,B,C,R>(_ function: @escaping (A) -> (B,C, @escaping (R?, Error?) -> Void) -> Void, file: StaticString = #file, line: UInt = #line) -> TripleArgFunction<A,B,C,R, Performer>  {
		let wrapper = { (a: Link<A, Performer>, b: Link<B, Performer>, c: Link<C, Performer>) -> Link<R, Performer> in
			return (a+b+c).chain(file: file, line: line, functionDescription: tname(function)) { (unwrappedArgs: (a: A, b: B, c: C), completion: @escaping (R?, Error?) -> Void) -> Void in
				function(unwrappedArgs.a)(unwrappedArgs.b, unwrappedArgs.c, completion)
			}
		}
		return TripleArgFunction(link: self.drop(), function: wrapper)
	}


	public func await<A,R>(_ function: @escaping (A) -> (@escaping (Error?, R?) -> Void) -> Void, file: StaticString = #file, line: UInt = #line) -> SingleArgFunction<A,R, Performer>  {
		let wrapper = { (a: Link<A, Performer>) -> Link<R, Performer> in
			return a.chain(file: file, line: line, functionDescription: tname(function)) { (a: A, completion: @escaping (R?, Error?) -> Void) in
				function(a)(){ r, error in
					completion(error,r)
				}
			}
		}
		return SingleArgFunction(link: self.drop(), function: wrapper)
	}
	public func await<A,B,R>(_ function: @escaping (A) -> (B, @escaping (Error?, R?) -> Void) -> Void, file: StaticString = #file, line: UInt = #line) -> DoubleArgFunction<A,B,R, Performer> {
		let wrapper = { (a: Link<A, Performer>, b: Link<B, Performer>) -> Link<R, Performer> in
			return (a+b).chain(file: file, line: line, functionDescription: tname(function)) { (unwrappedArgs: (a: A, b: B), completion: @escaping (R?, Error?) -> Void) -> Void in
				function(unwrappedArgs.a)(unwrappedArgs.b){ r, error in
					completion(error,r)
				}
			}
		}
		return DoubleArgFunction(link: self.drop(), function: wrapper)
	}
	public func await<A,B,C,R>(_ function: @escaping (A) -> (B,C, @escaping (Error?, R?) -> Void) -> Void, file: StaticString = #file, line: UInt = #line) -> TripleArgFunction<A,B,C,R, Performer>  {
		let wrapper = { (a: Link<A, Performer>, b: Link<B, Performer>, c: Link<C, Performer>) -> Link<R, Performer> in
			return (a+b+c).chain(file: file, line: line, functionDescription: tname(function)) { (unwrappedArgs: (a: A, b: B, c: C), completion: @escaping (R?, Error?) -> Void) -> Void in
				function(unwrappedArgs.a)(unwrappedArgs.b, unwrappedArgs.c){ r, error in
					completion(error,r)
				}
			}
		}
		return TripleArgFunction(link: self.drop(), function: wrapper)
	}

	
	public func await<A,E: Error>(_ function: @escaping (A) -> (((E?) -> Void)?) -> Void, file: StaticString = #file, line: UInt = #line) -> SingleArgFunction<A,Void, Performer>  {
		let wrapper = { (a: Link<A, Performer>) -> Link<Void, Performer> in
			return a.chain(file: file, line: line, functionDescription: tname(function)) { (a: A, completion: @escaping (Error?) -> Void) in
				function(a)(completion)
				}.drop()
		}
		return SingleArgFunction(link: self.drop(), function: wrapper)
	}
	
	public func await<A,E: Error>(_ function: @escaping (A) -> (@escaping (E?) -> Void) -> Void, file: StaticString = #file, line: UInt = #line) -> SingleArgFunction<A,Void, Performer>  {
		let wrapper = { (a: Link<A, Performer>) -> Link<Void, Performer> in
			return a.chain(file: file, line: line, functionDescription: tname(function)) { (a: A, completion: @escaping (Error?) -> Void) in
				function(a)(completion)
				}.drop()
		}
		return SingleArgFunction(link: self.drop(), function: wrapper)
	}
	public func await<A,B>(_ function: @escaping (A) -> (B, @escaping (Error?) -> Void) -> Void, file: StaticString = #file, line: UInt = #line) -> DoubleArgFunction<A,B,Void, Performer> {
		let wrapper = { (a: Link<A, Performer>, b: Link<B, Performer>) -> Link<Void, Performer> in
			return (a+b).chain(file: file, line: line, functionDescription: tname(function)) { (unwrappedArgs: (a: A, b: B), completion: @escaping (Error?) -> Void) -> Void in
				function(unwrappedArgs.a)(unwrappedArgs.b, completion)
			}.drop()
		}
		return DoubleArgFunction(link: self.drop(), function: wrapper)
	}
	public func await<A,B,C>(_ function: @escaping (A) -> (B,C, @escaping (Error?) -> Void) -> Void, file: StaticString = #file, line: UInt = #line) -> TripleArgFunction<A,B,C,Void, Performer>  {
		let wrapper = { (a: Link<A, Performer>, b: Link<B, Performer>, c: Link<C, Performer>) -> Link<Void, Performer> in
			return (a+b+c).chain(file: file, line: line, functionDescription: tname(function)) { (unwrappedArgs: (a: A, b: B, c: C), completion: @escaping (Error?) -> Void) -> Void in
				function(unwrappedArgs.a)(unwrappedArgs.b, unwrappedArgs.c, completion)
			}.drop()
		}
		return TripleArgFunction(link: self.drop(), function: wrapper)
	}


	@discardableResult
	public func await<R>(_ function: @escaping (((R) -> Void)?) throws -> Void, file: StaticString = #file, line: UInt = #line) -> Link<R, Performer> {
		return self.drop().chain(file: file, line: line, functionDescription: tname(function), function)
	}
	@discardableResult
	public func await<R>(_ function: @escaping (@escaping (R) -> Void) -> Void, file: StaticString = #file, line: UInt = #line) -> Link<R, Performer> {
		return self.drop().chain(file: file, line: line, functionDescription: tname(function), function)
	}
	public func await<A,R>(_ function: @escaping (A, @escaping (R) -> Void) -> Void, file: StaticString = #file, line: UInt = #line) -> SingleArgFunction<A,R, Performer> {
		let wrapper = { (a: Link<A, Performer>) -> Link<R, Performer> in
			return a.chain(file: file, line: line, functionDescription: tname(function), function)
		}
		return SingleArgFunction(link: self.drop(), function: wrapper)
	}
	public func await<A,B,R>(_ function: @escaping (A,B, @escaping (R) -> Void) -> Void, file: StaticString = #file, line: UInt = #line) -> DoubleArgFunction<A,B,R, Performer> {
		let wrapper = { (a: Link<A, Performer>, b: Link<B, Performer>) -> Link<R, Performer> in
			return (a+b).chain(file: file, line: line, functionDescription: tname(function)) { (unwrappedArgs: (a: A, b: B), completion: @escaping (R) -> Void) -> Void in
				function(unwrappedArgs.a,unwrappedArgs.b,completion)
			}
		}
		return DoubleArgFunction(link: self.drop(), function: wrapper)
	}
	public func await<A,B,C,R>(_ function: @escaping (A,B,C, @escaping (R) -> Void) -> Void, file: StaticString = #file, line: UInt = #line) -> TripleArgFunction<A,B,C,R, Performer> {
		let wrapper = { (a: Link<A, Performer>, b: Link<B, Performer>, c: Link<C, Performer>) -> Link<R, Performer> in
			return (a+b+c).chain(file: file, line: line, functionDescription: tname(function)) { (unwrappedArgs: (a: A, b: B, c: C), completion: @escaping (R) -> Void) -> Void in
				function(unwrappedArgs.a,unwrappedArgs.b,unwrappedArgs.c,completion)
			}
		}
		return TripleArgFunction(link: self.drop(), function: wrapper)
	}


	#warning("Document")
	public var mute: Void {
		return ()
	}
}
