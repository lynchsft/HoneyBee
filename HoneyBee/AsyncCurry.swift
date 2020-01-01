//
//  AsyncCurry.swift
//  HoneyBee
//
//  Created by Alex Lynch on 4/23/19.
//  Copyright © 2019 IAM Apps. All rights reserved.
//

import Foundation

public func async3<A, B, C, R>(file: StaticString = #file, line: UInt = #line, _ function: @escaping (A, B, C, ((R?, Error?) -> Void)?) -> Void) -> TripleArgFunction<A, B, C, R> {
    TripleArgFunction(action: tname(function), file: file, line: line) { (a: A, b: B, c: C, completion: @escaping FunctionWrapperCompletion<R>) -> Void  in
        let boundFunction = function =<< a =<< b =<< c
        elevate(boundFunction)(completion)
    }
}

public func async2<A, B, R>(file: StaticString = #file, line: UInt = #line, _ function: @escaping (A, B, ((R?, Error?) -> Void)?) -> Void) -> DoubleArgFunction<A, B, R> {
    DoubleArgFunction(action: tname(function), file: file, line: line) { (a: A, b: B, completion: @escaping FunctionWrapperCompletion<R>) -> Void in
        let boundFunction = function =<< a =<< b
        elevate(boundFunction)(completion)
    }
}

public func async1<A, R>(file: StaticString = #file, line: UInt = #line, _ function: @escaping (A, ((R?, Error?) -> Void)?) -> Void) -> SingleArgFunction<A, R> {
    SingleArgFunction(action: tname(function), file: file, line: line) { (a: A, completion: @escaping FunctionWrapperCompletion<R>) ->Void in
        let boundFunction = function =<< a
        elevate(boundFunction)(completion)
    }
}

public func async0<R>(file: StaticString = #file, line: UInt = #line, _ function: @escaping (((R?, Error?) -> Void)?) -> Void) -> ZeroArgFunction<R> {
    ZeroArgFunction(action: tname(function), file: file, line: line) { (completion: @escaping FunctionWrapperCompletion<R>) ->Void in
        elevate(function)(completion)
    }
}

public func async3<A, B, C>(file: StaticString = #file, line: UInt = #line, _ function: @escaping (A, B, C, ((Error?) -> Void)?) -> Void) -> TripleArgFunction<A, B, C, Void> {
    TripleArgFunction(action: tname(function), file: file, line: line) { (a: A, b: B, c: C, completion: @escaping FunctionWrapperCompletion<Void>) -> Void in
        let boundFunction = function =<< a =<< b =<< c
        elevate(boundFunction)(completion)
    }
}

public func async1<A>(file: StaticString = #file, line: UInt = #line, _ function: @escaping (A, ((Error?) -> Void)?) -> Void) -> SingleArgFunction<A, Void> {
    SingleArgFunction(action: tname(function), file: file, line: line) { (a: A, completion: @escaping FunctionWrapperCompletion<Void>) ->Void in
        let boundFunction = function =<< a
        elevate(boundFunction)(completion)
    }
}

public func async3<A, B, C, R>(file: StaticString = #file, line: UInt = #line, _ function: @escaping (A, B, C, ((R) -> Void)?) throws -> Void) -> TripleArgFunction<A, B, C, R> {
    TripleArgFunction(action: tname(function), file: file, line: line) { (a: A, b: B, c: C, completion: @escaping FunctionWrapperCompletion<R>)
        -> Void in
        let boundFunction = function =<< a =<< b =<< c
        elevate(boundFunction)(completion)
    }
}

public func async3<A, B, C, R>(file: StaticString = #file, line: UInt = #line, _ function: @escaping (A, B, C, @escaping (R) -> Void) throws -> Void) -> TripleArgFunction<A, B, C, R> {
    TripleArgFunction(action: tname(function), file: file, line: line) { (a: A, b: B, c: C, completion: @escaping FunctionWrapperCompletion<R>) -> Void in
        let boundFunction = function =<< a =<< b =<< c
        elevate(boundFunction)(completion)
    }
}

public func async2<A, B, R>(file: StaticString = #file, line: UInt = #line, _ function: @escaping (A, B, ((R) -> Void)?) throws -> Void) -> DoubleArgFunction<A, B, R> {
    DoubleArgFunction(action: tname(function), file: file, line: line) { (a: A, b: B, completion: @escaping FunctionWrapperCompletion<R>) -> Void in
        let boundFunction = function =<< a =<< b
        elevate(boundFunction)(completion)
    }
}

public func async2<A, B, R>(file: StaticString = #file, line: UInt = #line, _ function: @escaping (A, B, @escaping (R) -> Void) throws -> Void) ->  DoubleArgFunction<A, B, R> {
    DoubleArgFunction(action: tname(function), file: file, line: line) { (a: A, b: B, completion: @escaping FunctionWrapperCompletion<R>) -> Void in
        let boundFunction = function =<< a =<< b
        elevate(boundFunction)(completion)
    }
}

public func async1<A, R>(file: StaticString = #file, line: UInt = #line, _ function: @escaping (A, ((R) -> Void)?) throws -> Void) -> SingleArgFunction<A, R> {
    SingleArgFunction(action: tname(function), file: file, line: line) { (a: A, completion: @escaping FunctionWrapperCompletion<R>) ->Void in
        let boundFunction = function =<< a
        elevate(boundFunction)(completion)
    }
}

public func async1<A, R>(file: StaticString = #file, line: UInt = #line, _ function: @escaping (A, @escaping (R) -> Void) throws -> Void) -> SingleArgFunction<A, R> {
    SingleArgFunction(action: tname(function), file: file, line: line) { (a: A, completion: @escaping FunctionWrapperCompletion<R>) ->Void in
        let boundFunction = function =<< a
        elevate(boundFunction)(completion)
    }
}

public func async0<R>(file: StaticString = #file, line: UInt = #line, _ function: @escaping (@escaping (R) -> Void) throws -> Void) -> ZeroArgFunction<R> {
    ZeroArgFunction(action: tname(function), file: file, line: line) { (completion: @escaping FunctionWrapperCompletion<R>) ->Void in
        elevate(function)(completion)
    }
}

public func async3<A, B, C>(file: StaticString = #file, line: UInt = #line, _ function: @escaping (A, B, C, (() -> Void)?) throws -> Void) -> TripleArgFunction<A, B, C, Void> {
    TripleArgFunction(action: tname(function), file: file, line: line) { (a: A, b: B, c: C, completion: @escaping FunctionWrapperCompletion<Void>) -> Void in
        let boundFunction = function =<< a =<< b =<< c
        elevate(boundFunction)(completion)
    }
}

public func async3<A, B, C>(file: StaticString = #file, line: UInt = #line, _ function: @escaping (A, B, C, @escaping () -> Void) throws -> Void) -> TripleArgFunction<A, B, C, Void> {
    TripleArgFunction(action: tname(function), file: file, line: line) { (a: A, b: B, c: C, completion: @escaping FunctionWrapperCompletion<Void>) -> Void in
        let boundFunction = function =<< a =<< b =<< c
        elevate(boundFunction)(completion)
    }
}

public func async2<A, B>(file: StaticString = #file, line: UInt = #line, _ function: @escaping (A, B, (() -> Void)?) throws -> Void) -> DoubleArgFunction<A, B, Void> {
    DoubleArgFunction(action: tname(function), file: file, line: line) { (a: A, b: B, completion: @escaping FunctionWrapperCompletion<Void>) -> Void in
        let boundFunction = function =<< a =<< b
        elevate(boundFunction)(completion)
    }
}

public func async2<A, B>(file: StaticString = #file, line: UInt = #line, _ function: @escaping (A, B, @escaping () -> Void) throws -> Void) -> DoubleArgFunction<A, B, Void> {
    DoubleArgFunction(action: tname(function), file: file, line: line) { (a: A, b: B, completion: @escaping FunctionWrapperCompletion<Void>) -> Void in
        let boundFunction = function =<< a =<< b
        elevate(boundFunction)(completion)
    }
}

public func async1<A>(file: StaticString = #file, line: UInt = #line, _ function: @escaping (A, (() -> Void)?) throws -> Void) -> SingleArgFunction<A, Void> {
    SingleArgFunction(action: tname(function), file: file, line: line)  { (a: A, completion: @escaping FunctionWrapperCompletion<Void>) ->Void in
        let boundFunction = function =<< a
        elevate(boundFunction)(completion)
    }
}

public func async1<A>(file: StaticString = #file, line: UInt = #line, _ function: @escaping (A, @escaping () -> Void) throws -> Void) -> SingleArgFunction<A, Void> {
    SingleArgFunction(action: tname(function), file: file, line: line) { (a: A, completion: @escaping FunctionWrapperCompletion<Void>) ->Void in
        let boundFunction = function =<< a
        elevate(boundFunction)(completion)
    }
}

public func async0(file: StaticString = #file, line: UInt = #line, _ function: @escaping ((() -> Void)?) throws -> Void) -> ZeroArgFunction<Void> {
    ZeroArgFunction(action: tname(function), file: file, line: line) { (completion: @escaping FunctionWrapperCompletion<Void>) ->Void in
        elevate(function)(completion)
    }
}

public func async0(file: StaticString = #file, line: UInt = #line, _ function: @escaping (@escaping () -> Void) throws -> Void) -> ZeroArgFunction<Void> {
    ZeroArgFunction(action: tname(function), file: file, line: line) { (completion: @escaping FunctionWrapperCompletion<Void>) ->Void in
        elevate(function)(completion)
    }
}

public func async0<R>(file: StaticString = #file, line: UInt = #line, _ function: @escaping () throws -> R) -> ZeroArgFunction<R>  {
    ZeroArgFunction(action: tname(function), file: file, line: line) { (completion: @escaping FunctionWrapperCompletion<R>) ->Void in
        elevate(function)(completion)
    }
}

public func async1<A, R>(file: StaticString = #file, line: UInt = #line, _ function: @escaping (A) throws -> R) -> SingleArgFunction<A, R> {
    SingleArgFunction(action: tname(function), file: file, line: line) { (a: A, completion: @escaping FunctionWrapperCompletion<R>) ->Void in
        let boundFunction = function =<< a
        elevate(boundFunction)(completion)
    }
}

public func async2<A, B, R>(file: StaticString = #file, line: UInt = #line, _ function: @escaping (A,B) throws -> R) -> DoubleArgFunction<A, B, R> {
    DoubleArgFunction(action: tname(function), file: file, line: line) { (a: A, b: B, completion: @escaping FunctionWrapperCompletion<R>) -> Void in
        let boundFunction = function =<< a =<< b
        elevate(boundFunction)(completion)
    }
}

public func async3<A, B, C, R>(file: StaticString = #file, line: UInt = #line, _ function: @escaping (A,B,C) throws -> R) -> TripleArgFunction<A, B, C, R> {
    TripleArgFunction(action: tname(function), file: file, line: line) { (a: A, b: B, c: C, completion: @escaping FunctionWrapperCompletion<R>) -> Void in
        let boundFunction = function =<< a =<< b =<< c
        elevate(boundFunction)(completion)
    }
}

public func async0<R>(file: StaticString = #file, line: UInt = #line, _ function: @escaping (@escaping (R?, Error?) -> Void) -> Void) -> ZeroArgFunction<R> {
    ZeroArgFunction(action: tname(function), file: file, line: line) { (completion: @escaping FunctionWrapperCompletion<R>) ->Void in
        elevate(function)(completion)
    }
}

public func async1<A, R, E: Error>(file: StaticString = #file, line: UInt = #line, _ function: @escaping (A, @escaping (R?, E?) -> Void) -> Void) -> SingleArgFunction<A, R> {
    SingleArgFunction(action: tname(function), file: file, line: line) { (a: A, completion: @escaping FunctionWrapperCompletion<R>) ->Void in
        let boundFunction = function =<< a
        elevate(boundFunction)(completion)
    }
}

public func async2<A, B, R>(file: StaticString = #file, line: UInt = #line, _ function: @escaping (A,B, @escaping (R?, Error?) -> Void) -> Void) -> DoubleArgFunction<A, B, R> {
    DoubleArgFunction(action: tname(function), file: file, line: line) { (a: A, b: B, completion: @escaping FunctionWrapperCompletion<R>) -> Void in
        let boundFunction = function =<< a =<< b
        elevate(boundFunction)(completion)
    }
}

public func async3<A, B, C, R>(file: StaticString = #file, line: UInt = #line, _ function: @escaping (A,B,C, @escaping (R?, Error?) -> Void) -> Void) -> TripleArgFunction<A, B, C, R> {
    TripleArgFunction(action: tname(function), file: file, line: line) { (a: A, b: B, c: C, completion: @escaping FunctionWrapperCompletion<R>) -> Void in
        let boundFunction = function =<< a =<< b =<< c
        elevate(boundFunction)(completion)
    }
}

public func async0<R>(file: StaticString = #file, line: UInt = #line, _ function: @escaping (@escaping (Error?, R?) -> Void) -> Void) -> ZeroArgFunction<R> {
    ZeroArgFunction(action: tname(function), file: file, line: line) { (completion: @escaping FunctionWrapperCompletion<R>) ->Void in
        elevate(function)(completion)
    }
}

public func async1<A, R>(file: StaticString = #file, line: UInt = #line, _ function: @escaping (A, @escaping (Error?, R?) -> Void) -> Void) -> SingleArgFunction<A, R> {
    SingleArgFunction(action: tname(function), file: file, line: line) { (a: A, completion: @escaping FunctionWrapperCompletion<R>) ->Void in
        let boundFunction = function =<< a
        elevate(boundFunction)(completion)
    }
}

public func async2<A, B, R>(file: StaticString = #file, line: UInt = #line, _ function: @escaping (A,B, @escaping (Error?, R?) -> Void) -> Void) -> DoubleArgFunction<A, B, R> {
    DoubleArgFunction(action: tname(function), file: file, line: line) { (a: A, b: B, completion: @escaping FunctionWrapperCompletion<R>) -> Void in
        let boundFunction = function =<< a =<< b
        elevate(boundFunction)(completion)
    }
}

public func async3<A, B, C, R>(file: StaticString = #file, line: UInt = #line, _ function: @escaping (A,B,C, @escaping (Error?, R?) -> Void) -> Void) -> TripleArgFunction<A, B, C, R> {
    TripleArgFunction(action: tname(function), file: file, line: line) { (a: A, b: B, c: C, completion: @escaping FunctionWrapperCompletion<R>) -> Void in
        let boundFunction = function =<< a =<< b =<< c
        elevate(boundFunction)(completion)
    }
}

public func async0(file: StaticString = #file, line: UInt = #line, _ function: @escaping (((Error?) -> Void)?) -> Void) -> ZeroArgFunction<Void> {
    ZeroArgFunction(action: tname(function), file: file, line: line) { (completion: @escaping FunctionWrapperCompletion<Void>) ->Void in
        elevate(function)(completion)
    }
}

public func async0(file: StaticString = #file, line: UInt = #line, _ function: @escaping (@escaping (Error?) -> Void) -> Void) -> ZeroArgFunction<Void> {
    ZeroArgFunction(action: tname(function), file: file, line: line) { (completion: @escaping FunctionWrapperCompletion<Void>) ->Void in
        elevate(function)(completion)
    }
}

public func async1<A>(file: StaticString = #file, line: UInt = #line, _ function: @escaping (A, @escaping (Error?) -> Void) -> Void) -> SingleArgFunction<A,Void> {
    SingleArgFunction(action: tname(function), file: file, line: line) { (a: A, completion: @escaping FunctionWrapperCompletion<Void>) ->Void in
        let boundFunction = function =<< a
        elevate(boundFunction)(completion)
    }
}

public func async2<A, B>(file: StaticString = #file, line: UInt = #line, _ function: @escaping (A,B, @escaping (Error?) -> Void) -> Void) -> DoubleArgFunction<A,B,Void> {
    DoubleArgFunction(action: tname(function), file: file, line: line) { (a: A, b: B, completion: @escaping FunctionWrapperCompletion<Void>) -> Void in
        let boundFunction = function =<< a =<< b
        elevate(boundFunction)(completion)
    }
}

public func async3<A, B, C>(file: StaticString = #file, line: UInt = #line, _ function: @escaping (A,B,C, @escaping (Error?) -> Void) -> Void) -> TripleArgFunction<A,B,C,Void> {
    TripleArgFunction(action: tname(function), file: file, line: line) { (a: A, b: B, c: C, completion: @escaping FunctionWrapperCompletion<Void>) -> Void in
        let boundFunction = function =<< a =<< b =<< c
        elevate(boundFunction)(completion)
    }
}

public func async2<A,B,E: Error>(file: StaticString = #file, line: UInt = #line, _ function: @escaping (A,B, ((E?) -> Void)?) -> Void) -> DoubleArgFunction<A,B,Void> {
    DoubleArgFunction(action: tname(function), file: file, line: line) { (a: A, b: B, completion: @escaping FunctionWrapperCompletion<Void>) -> Void in
        let boundFunction = function =<< a =<< b
        elevate(boundFunction)(completion)
    }
}

public func async0<R,Failable>(file: StaticString = #file, line: UInt = #line, _ function: @escaping (@escaping (Failable) -> Void) -> Void) -> ZeroArgFunction<R> where Failable : FailableResultProtocol, Failable.Wrapped == R {
    ZeroArgFunction(action: tname(function), file: file, line: line) { (completion: @escaping FunctionWrapperCompletion<R>) ->Void in
        function { (failable: Failable) -> Void in
            completion(FailableResult(failable))
        }
    }
}

public func async1<A,R,Failable>(file: StaticString = #file, line: UInt = #line, _ function: @escaping (A, @escaping (Failable) -> Void) -> Void) -> SingleArgFunction<A, R>  where Failable : FailableResultProtocol, Failable.Wrapped == R {
    SingleArgFunction(action: tname(function), file: file, line: line) { (a: A, completion: @escaping FunctionWrapperCompletion<R>) ->Void in
        let boundFunction = function =<< a
        boundFunction { (failable: Failable) -> Void in
            completion(FailableResult(failable))
        }
    }
}

public func async2<A,B,R,Failable>(file: StaticString = #file, line: UInt = #line, _ function: @escaping (A,B, @escaping (Failable) -> Void) -> Void) -> DoubleArgFunction<A, B, R> where Failable : FailableResultProtocol, Failable.Wrapped == R {
    DoubleArgFunction(action: tname(function), file: file, line: line) { (a: A, b: B, completion: @escaping FunctionWrapperCompletion<R>) -> Void in
        let boundFunction = function =<< a =<< b
        boundFunction { (failable: Failable) -> Void in
            completion(FailableResult(failable))
        }
    }
}

public func async3<A,B,C,R,Failable>(file: StaticString = #file, line: UInt = #line, _ function: @escaping (A,B,C, @escaping (Failable) -> Void) -> Void) -> TripleArgFunction<A, B, C, R> where Failable : FailableResultProtocol, Failable.Wrapped == R {
    TripleArgFunction(action: tname(function), file: file, line: line) { (a: A, b: B, c: C, completion: @escaping FunctionWrapperCompletion<R>) in
        let boundFunction = function =<< a =<< b =<< c
        boundFunction { (failable: Failable) -> Void in
            completion(FailableResult(failable))
        }
    }
}

public func async0<R>(file: StaticString = #file, line: UInt = #line, _ function: @escaping (((R) -> Void)?) throws -> Void) -> ZeroArgFunction<R> {
    ZeroArgFunction(action: tname(function), file: file, line: line) { (completion: @escaping FunctionWrapperCompletion<R>) ->Void in
        elevate(function)(completion)
    }
}

public func async0<R>(file: StaticString = #file, line: UInt = #line, _ function: @escaping (@escaping (R) -> Void) -> Void) -> ZeroArgFunction<R> {
    ZeroArgFunction(action: tname(function), file: file, line: line) { (completion: @escaping FunctionWrapperCompletion<R>) ->Void in
        elevate(function)(completion)
    }
}

public func async1<A, R>(file: StaticString = #file, line: UInt = #line, _ function: @escaping (A, @escaping (R) -> Void) -> Void) -> SingleArgFunction<A, R> {
    SingleArgFunction(action: tname(function), file: file, line: line) { (a: A, completion: @escaping FunctionWrapperCompletion<R>) ->Void in
        let boundFunction = function =<< a
        elevate(boundFunction)(completion)
    }
}

public func async2<A, B, R>(file: StaticString = #file, line: UInt = #line, _ function: @escaping (A,B, @escaping (R) -> Void) -> Void) -> DoubleArgFunction<A, B, R> {
    DoubleArgFunction(action: tname(function), file: file, line: line) { (a: A, b: B, completion: @escaping FunctionWrapperCompletion<R>) in
        let boundFunction = function =<< a =<< b
        elevate(boundFunction)(completion)
    }
}

public func async3<A, B, C, R>(file: StaticString = #file, line: UInt = #line, _ function: @escaping (A,B,C, @escaping (R) -> Void) -> Void) -> TripleArgFunction<A, B, C, R> {
    TripleArgFunction(action: tname(function), file: file, line: line) { (a: A, b: B, c: C, completion: @escaping FunctionWrapperCompletion<R>) in
        let boundFunction = function =<< a =<< b =<< c
        elevate(boundFunction)(completion)
    }
}
