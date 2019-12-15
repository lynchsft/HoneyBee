//
//  AsyncCurry.swift
//  HoneyBee
//
//  Created by Alex Lynch on 4/23/19.
//  Copyright © 2019 IAM Apps. All rights reserved.
//

import Foundation

func async3<A, B, C, R>(_ function: @escaping (A, B, C, ((R?, Error?) -> Void)?) -> Void, file: StaticString, line: UInt) -> TripleArgFunction<A, B, C, R> {
    TripleArgFunction(action: tname(function), file: file, line: line) { (a: A, b: B, c: C, completion: @escaping FunctionWrapperCompletion<R>) -> Void  in
        let boundFunction = function =<< a =<< b =<< c
        elevate(boundFunction)(completion)
    }
}

func async2<A, B, R>(_ function: @escaping (A, B, ((R?, Error?) -> Void)?) -> Void, file: StaticString, line: UInt) -> DoubleArgFunction<A, B, R> {
    DoubleArgFunction(action: tname(function), file: file, line: line) { (a: A, b: B, completion: @escaping FunctionWrapperCompletion<R>) -> Void in
        let boundFunction = function =<< a =<< b
        elevate(boundFunction)(completion)
    }
}

func async1<A, R>(_ function: @escaping (A, ((R?, Error?) -> Void)?) -> Void, file: StaticString, line: UInt) -> SingleArgFunction<A, R> {
    SingleArgFunction(action: tname(function), file: file, line: line) { (a: A, completion: @escaping FunctionWrapperCompletion<R>) ->Void in
        let boundFunction = function =<< a
        elevate(boundFunction)(completion)
    }
}

func async0<R>(_ function: @escaping (((R?, Error?) -> Void)?) -> Void, file: StaticString, line: UInt) -> ZeroArgFunction<R> {
    ZeroArgFunction(action: tname(function), file: file, line: line) { (completion: @escaping FunctionWrapperCompletion<R>) ->Void in
        elevate(function)(completion)
    }
}

func async3<A, B, C>(_ function: @escaping (A, B, C, ((Error?) -> Void)?) -> Void, file: StaticString, line: UInt) -> TripleArgFunction<A, B, C, Void> {
    TripleArgFunction(action: tname(function), file: file, line: line) { (a: A, b: B, c: C, completion: @escaping FunctionWrapperCompletion<Void>) -> Void in
        let boundFunction = function =<< a =<< b =<< c
        elevate(boundFunction)(completion)
    }
}

func async1<A>(_ function: @escaping (A, ((Error?) -> Void)?) -> Void, file: StaticString, line: UInt) -> SingleArgFunction<A, Void> {
    SingleArgFunction(action: tname(function), file: file, line: line) { (a: A, completion: @escaping FunctionWrapperCompletion<Void>) ->Void in
        let boundFunction = function =<< a
        elevate(boundFunction)(completion)
    }
}

func async3<A, B, C, R>(_ function: @escaping (A, B, C, ((R) -> Void)?) throws -> Void, file: StaticString, line: UInt) -> TripleArgFunction<A, B, C, R> {
    TripleArgFunction(action: tname(function), file: file, line: line) { (a: A, b: B, c: C, completion: @escaping FunctionWrapperCompletion<R>)
        -> Void in
        let boundFunction = function =<< a =<< b =<< c
        elevate(boundFunction)(completion)
    }
}

func async3<A, B, C, R>(_ function: @escaping (A, B, C, @escaping (R) -> Void) throws -> Void, file: StaticString, line: UInt) -> TripleArgFunction<A, B, C, R> {
    TripleArgFunction(action: tname(function), file: file, line: line) { (a: A, b: B, c: C, completion: @escaping FunctionWrapperCompletion<R>) -> Void in
        let boundFunction = function =<< a =<< b =<< c
        elevate(boundFunction)(completion)
    }
}

func async2<A, B, R>(_ function: @escaping (A, B, ((R) -> Void)?) throws -> Void, file: StaticString, line: UInt) -> DoubleArgFunction<A, B, R> {
    DoubleArgFunction(action: tname(function), file: file, line: line) { (a: A, b: B, completion: @escaping FunctionWrapperCompletion<R>) -> Void in
        let boundFunction = function =<< a =<< b
        elevate(boundFunction)(completion)
    }
}

func async2<A, B, R>(_ function: @escaping (A, B, @escaping (R) -> Void) throws -> Void, file: StaticString, line: UInt) ->  DoubleArgFunction<A, B, R> {
    DoubleArgFunction(action: tname(function), file: file, line: line) { (a: A, b: B, completion: @escaping FunctionWrapperCompletion<R>) -> Void in
        let boundFunction = function =<< a =<< b
        elevate(boundFunction)(completion)
    }
}

func async1<A, R>(_ function: @escaping (A, ((R) -> Void)?) throws -> Void, file: StaticString, line: UInt) -> SingleArgFunction<A, R> {
    SingleArgFunction(action: tname(function), file: file, line: line) { (a: A, completion: @escaping FunctionWrapperCompletion<R>) ->Void in
        let boundFunction = function =<< a
        elevate(boundFunction)(completion)
    }
}

func async1<A, R>(_ function: @escaping (A, @escaping (R) -> Void) throws -> Void, file: StaticString, line: UInt) -> SingleArgFunction<A, R> {
    SingleArgFunction(action: tname(function), file: file, line: line) { (a: A, completion: @escaping FunctionWrapperCompletion<R>) ->Void in
        let boundFunction = function =<< a
        elevate(boundFunction)(completion)
    }
}

func async0<R>(_ function: @escaping (@escaping (R) -> Void) throws -> Void, file: StaticString, line: UInt) -> ZeroArgFunction<R> {
    ZeroArgFunction(action: tname(function), file: file, line: line) { (completion: @escaping FunctionWrapperCompletion<R>) ->Void in
        elevate(function)(completion)
    }
}

func async3<A, B, C>(_ function: @escaping (A, B, C, (() -> Void)?) throws -> Void, file: StaticString, line: UInt) -> TripleArgFunction<A, B, C, Void> {
    TripleArgFunction(action: tname(function), file: file, line: line) { (a: A, b: B, c: C, completion: @escaping FunctionWrapperCompletion<Void>) -> Void in
        let boundFunction = function =<< a =<< b =<< c
        elevate(boundFunction)(completion)
    }
}

func async3<A, B, C>(_ function: @escaping (A, B, C, @escaping () -> Void) throws -> Void, file: StaticString, line: UInt) -> TripleArgFunction<A, B, C, Void> {
    TripleArgFunction(action: tname(function), file: file, line: line) { (a: A, b: B, c: C, completion: @escaping FunctionWrapperCompletion<Void>) -> Void in
        let boundFunction = function =<< a =<< b =<< c
        elevate(boundFunction)(completion)
    }
}

func async2<A, B>(_ function: @escaping (A, B, (() -> Void)?) throws -> Void, file: StaticString, line: UInt) -> DoubleArgFunction<A, B, Void> {
    DoubleArgFunction(action: tname(function), file: file, line: line) { (a: A, b: B, completion: @escaping FunctionWrapperCompletion<Void>) -> Void in
        let boundFunction = function =<< a =<< b
        elevate(boundFunction)(completion)
    }
}

func async2<A, B>(_ function: @escaping (A, B, @escaping () -> Void) throws -> Void, file: StaticString, line: UInt) -> DoubleArgFunction<A, B, Void> {
    DoubleArgFunction(action: tname(function), file: file, line: line) { (a: A, b: B, completion: @escaping FunctionWrapperCompletion<Void>) -> Void in
        let boundFunction = function =<< a =<< b
        elevate(boundFunction)(completion)
    }
}

func async1<A>(_ function: @escaping (A, (() -> Void)?) throws -> Void, file: StaticString, line: UInt) -> SingleArgFunction<A, Void> {
    SingleArgFunction(action: tname(function), file: file, line: line)  { (a: A, completion: @escaping FunctionWrapperCompletion<Void>) ->Void in
        let boundFunction = function =<< a
        elevate(boundFunction)(completion)
    }
}

func async1<A>(_ function: @escaping (A, @escaping () -> Void) throws -> Void, file: StaticString, line: UInt) -> SingleArgFunction<A, Void> {
    SingleArgFunction(action: tname(function), file: file, line: line) { (a: A, completion: @escaping FunctionWrapperCompletion<Void>) ->Void in
        let boundFunction = function =<< a
        elevate(boundFunction)(completion)
    }
}

func async0(_ function: @escaping ((() -> Void)?) throws -> Void, file: StaticString, line: UInt) -> ZeroArgFunction<Void> {
    ZeroArgFunction(action: tname(function), file: file, line: line) { (completion: @escaping FunctionWrapperCompletion<Void>) ->Void in
        elevate(function)(completion)
    }
}

func async0(_ function: @escaping (@escaping () -> Void) throws -> Void, file: StaticString, line: UInt) -> ZeroArgFunction<Void> {
    ZeroArgFunction(action: tname(function), file: file, line: line) { (completion: @escaping FunctionWrapperCompletion<Void>) ->Void in
        elevate(function)(completion)
    }
}

public func async0<R>(_ function: @escaping () throws -> R, file: StaticString = #file, line: UInt = #line) -> ZeroArgFunction<R>  {
    ZeroArgFunction(action: tname(function), file: file, line: line) { (completion: @escaping FunctionWrapperCompletion<R>) ->Void in
        elevate(function)(completion)
    }
}

public func async1<A, R>(_ function: @escaping (A) throws -> R, file: StaticString = #file, line: UInt = #line) -> SingleArgFunction<A, R> {
    SingleArgFunction(action: tname(function), file: file, line: line) { (a: A, completion: @escaping FunctionWrapperCompletion<R>) ->Void in
        let boundFunction = function =<< a
        elevate(boundFunction)(completion)
    }
}

public func async2<A, B, R>(_ function: @escaping (A,B) throws -> R, file: StaticString = #file, line: UInt = #line) -> DoubleArgFunction<A, B, R> {
    DoubleArgFunction(action: tname(function), file: file, line: line) { (a: A, b: B, completion: @escaping FunctionWrapperCompletion<R>) -> Void in
        let boundFunction = function =<< a =<< b
        elevate(boundFunction)(completion)
    }
}

public func async3<A, B, C, R>(_ function: @escaping (A,B,C) throws -> R, file: StaticString = #file, line: UInt = #line) -> TripleArgFunction<A, B, C, R> {
    TripleArgFunction(action: tname(function), file: file, line: line) { (a: A, b: B, c: C, completion: @escaping FunctionWrapperCompletion<R>) -> Void in
        let boundFunction = function =<< a =<< b =<< c
        elevate(boundFunction)(completion)
    }
}

public func async0<R>(_ function: @escaping (@escaping (R?, Error?) -> Void) -> Void, file: StaticString = #file, line: UInt = #line) -> ZeroArgFunction<R> {
    ZeroArgFunction(action: tname(function), file: file, line: line) { (completion: @escaping FunctionWrapperCompletion<R>) ->Void in
        elevate(function)(completion)
    }
}

public func async1<A, R, E: Error>(_ function: @escaping (A, @escaping (R?, E?) -> Void) -> Void, file: StaticString = #file, line: UInt = #line) -> SingleArgFunction<A, R> {
    SingleArgFunction(action: tname(function), file: file, line: line) { (a: A, completion: @escaping FunctionWrapperCompletion<R>) ->Void in
        let boundFunction = function =<< a
        elevate(boundFunction)(completion)
    }
}

public func async2<A, B, R>(_ function: @escaping (A,B, @escaping (R?, Error?) -> Void) -> Void, file: StaticString = #file, line: UInt = #line) -> DoubleArgFunction<A, B, R> {
    DoubleArgFunction(action: tname(function), file: file, line: line) { (a: A, b: B, completion: @escaping FunctionWrapperCompletion<R>) -> Void in
        let boundFunction = function =<< a =<< b
        elevate(boundFunction)(completion)
    }
}

public func async3<A, B, C, R>(_ function: @escaping (A,B,C, @escaping (R?, Error?) -> Void) -> Void, file: StaticString = #file, line: UInt = #line) -> TripleArgFunction<A, B, C, R> {
    TripleArgFunction(action: tname(function), file: file, line: line) { (a: A, b: B, c: C, completion: @escaping FunctionWrapperCompletion<R>) -> Void in
        let boundFunction = function =<< a =<< b =<< c
        elevate(boundFunction)(completion)
    }
}

public func async0<R>(_ function: @escaping (@escaping (Error?, R?) -> Void) -> Void, file: StaticString = #file, line: UInt = #line) -> ZeroArgFunction<R> {
    ZeroArgFunction(action: tname(function), file: file, line: line) { (completion: @escaping FunctionWrapperCompletion<R>) ->Void in
        elevate(function)(completion)
    }
}

public func async1<A, R>(_ function: @escaping (A, @escaping (Error?, R?) -> Void) -> Void, file: StaticString = #file, line: UInt = #line) -> SingleArgFunction<A, R> {
    SingleArgFunction(action: tname(function), file: file, line: line) { (a: A, completion: @escaping FunctionWrapperCompletion<R>) ->Void in
        let boundFunction = function =<< a
        elevate(boundFunction)(completion)
    }
}

public func async2<A, B, R>(_ function: @escaping (A,B, @escaping (Error?, R?) -> Void) -> Void, file: StaticString = #file, line: UInt = #line) -> DoubleArgFunction<A, B, R> {
    DoubleArgFunction(action: tname(function), file: file, line: line) { (a: A, b: B, completion: @escaping FunctionWrapperCompletion<R>) -> Void in
        let boundFunction = function =<< a =<< b
        elevate(boundFunction)(completion)
    }
}

public func async3<A, B, C, R>(_ function: @escaping (A,B,C, @escaping (Error?, R?) -> Void) -> Void, file: StaticString = #file, line: UInt = #line) -> TripleArgFunction<A, B, C, R> {
    TripleArgFunction(action: tname(function), file: file, line: line) { (a: A, b: B, c: C, completion: @escaping FunctionWrapperCompletion<R>) -> Void in
        let boundFunction = function =<< a =<< b =<< c
        elevate(boundFunction)(completion)
    }
}

public func async0(_ function: @escaping (((Error?) -> Void)?) -> Void, file: StaticString = #file, line: UInt = #line) -> ZeroArgFunction<Void> {
    ZeroArgFunction(action: tname(function), file: file, line: line) { (completion: @escaping FunctionWrapperCompletion<Void>) ->Void in
        elevate(function)(completion)
    }
}

public func async0(_ function: @escaping (@escaping (Error?) -> Void) -> Void, file: StaticString = #file, line: UInt = #line) -> ZeroArgFunction<Void> {
    ZeroArgFunction(action: tname(function), file: file, line: line) { (completion: @escaping FunctionWrapperCompletion<Void>) ->Void in
        elevate(function)(completion)
    }
}

public func async1<A>(_ function: @escaping (A, @escaping (Error?) -> Void) -> Void, file: StaticString = #file, line: UInt = #line) -> SingleArgFunction<A,Void> {
    SingleArgFunction(action: tname(function), file: file, line: line) { (a: A, completion: @escaping FunctionWrapperCompletion<Void>) ->Void in
        let boundFunction = function =<< a
        elevate(boundFunction)(completion)
    }
}

public func async2<A, B>(_ function: @escaping (A,B, @escaping (Error?) -> Void) -> Void, file: StaticString = #file, line: UInt = #line) -> DoubleArgFunction<A,B,Void> {
    DoubleArgFunction(action: tname(function), file: file, line: line) { (a: A, b: B, completion: @escaping FunctionWrapperCompletion<Void>) -> Void in
        let boundFunction = function =<< a =<< b
        elevate(boundFunction)(completion)
    }
}

public func async3<A, B, C>(_ function: @escaping (A,B,C, @escaping (Error?) -> Void) -> Void, file: StaticString = #file, line: UInt = #line) -> TripleArgFunction<A,B,C,Void> {
    TripleArgFunction(action: tname(function), file: file, line: line) { (a: A, b: B, c: C, completion: @escaping FunctionWrapperCompletion<Void>) -> Void in
        let boundFunction = function =<< a =<< b =<< c
        elevate(boundFunction)(completion)
    }
}

public func async2<A,B,E: Error>(_ function: @escaping (A,B, ((E?) -> Void)?) -> Void, file: StaticString = #file, line: UInt = #line) -> DoubleArgFunction<A,B,Void> {
    DoubleArgFunction(action: tname(function), file: file, line: line) { (a: A, b: B, completion: @escaping FunctionWrapperCompletion<Void>) -> Void in
        let boundFunction = function =<< a =<< b
        elevate(boundFunction)(completion)
    }
}

public func async0<R,Failable>(_ function: @escaping (@escaping (Failable) -> Void) -> Void, file: StaticString = #file, line: UInt = #line) -> ZeroArgFunction<R> where Failable : FailableResultProtocol, Failable.Wrapped == R {
    ZeroArgFunction(action: tname(function), file: file, line: line) { (completion: @escaping FunctionWrapperCompletion<R>) ->Void in
        function { (failable: Failable) -> Void in
            completion(FailableResult(failable))
        }
    }
}

public func async1<A,R,Failable>(_ function: @escaping (A, @escaping (Failable) -> Void) -> Void, file: StaticString = #file, line: UInt = #line) -> SingleArgFunction<A, R>  where Failable : FailableResultProtocol, Failable.Wrapped == R {
    SingleArgFunction(action: tname(function), file: file, line: line) { (a: A, completion: @escaping FunctionWrapperCompletion<R>) ->Void in
        let boundFunction = function =<< a
        boundFunction { (failable: Failable) -> Void in
            completion(FailableResult(failable))
        }
    }
}

public func async2<A,B,R,Failable>(_ function: @escaping (A,B, @escaping (Failable) -> Void) -> Void, file: StaticString = #file, line: UInt = #line) -> DoubleArgFunction<A, B, R> where Failable : FailableResultProtocol, Failable.Wrapped == R {
    DoubleArgFunction(action: tname(function), file: file, line: line) { (a: A, b: B, completion: @escaping FunctionWrapperCompletion<R>) -> Void in
        let boundFunction = function =<< a =<< b
        boundFunction { (failable: Failable) -> Void in
            completion(FailableResult(failable))
        }
    }
}

public func async3<A,B,C,R,Failable>(_ function: @escaping (A,B,C, @escaping (Failable) -> Void) -> Void, file: StaticString = #file, line: UInt = #line) -> TripleArgFunction<A, B, C, R> where Failable : FailableResultProtocol, Failable.Wrapped == R {
    TripleArgFunction(action: tname(function), file: file, line: line) { (a: A, b: B, c: C, completion: @escaping FunctionWrapperCompletion<R>) in
        let boundFunction = function =<< a =<< b =<< c
        boundFunction { (failable: Failable) -> Void in
            completion(FailableResult(failable))
        }
    }
}

public func async0<R>(_ function: @escaping (((R) -> Void)?) throws -> Void, file: StaticString = #file, line: UInt = #line) -> ZeroArgFunction<R> {
    ZeroArgFunction(action: tname(function), file: file, line: line) { (completion: @escaping FunctionWrapperCompletion<R>) ->Void in
        elevate(function)(completion)
    }
}

public func async0<R>(_ function: @escaping (@escaping (R) -> Void) -> Void, file: StaticString = #file, line: UInt = #line) -> ZeroArgFunction<R> {
    ZeroArgFunction(action: tname(function), file: file, line: line) { (completion: @escaping FunctionWrapperCompletion<R>) ->Void in
        elevate(function)(completion)
    }
}

public func async1<A, R>(_ function: @escaping (A, @escaping (R) -> Void) -> Void, file: StaticString = #file, line: UInt = #line) -> SingleArgFunction<A, R> {
    SingleArgFunction(action: tname(function), file: file, line: line) { (a: A, completion: @escaping FunctionWrapperCompletion<R>) ->Void in
        let boundFunction = function =<< a
        elevate(boundFunction)(completion)
    }
}

public func async2<A, B, R>(_ function: @escaping (A,B, @escaping (R) -> Void) -> Void, file: StaticString = #file, line: UInt = #line) -> DoubleArgFunction<A, B, R> {
    DoubleArgFunction(action: tname(function), file: file, line: line) { (a: A, b: B, completion: @escaping FunctionWrapperCompletion<R>) in
        let boundFunction = function =<< a =<< b
        elevate(boundFunction)(completion)
    }
}

public func async3<A, B, C, R>(_ function: @escaping (A,B,C, @escaping (R) -> Void) -> Void, file: StaticString = #file, line: UInt = #line) -> TripleArgFunction<A, B, C, R> {
    TripleArgFunction(action: tname(function), file: file, line: line) { (a: A, b: B, c: C, completion: @escaping FunctionWrapperCompletion<R>) in
        let boundFunction = function =<< a =<< b =<< c
        elevate(boundFunction)(completion)
    }
}
