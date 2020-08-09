//
//  AsyncCurry.swift
//  HoneyBee
//
//  Created by Alex Lynch on 4/23/19.
//  Copyright © 2019 IAM Apps. All rights reserved.
//

import Foundation

/// Wraps an asynchronous function taking 3 parameters
/// - Parameters:
///   - function: the function to wrap
public func async3<A, B, C, R, E: Error>(_ function: @escaping (A, B, C, ((R?, E?) -> Void)?) -> Void) -> TripleArgFunction<A, B, C, R, E> {
    TripleArgFunction(action: tname(function)) { (a: A, b: B, c: C, completion: @escaping FunctionWrapperCompletion<R, E>) -> Void  in
        let boundFunction = function =<< a =<< b =<< c
        elevate(boundFunction)(completion)
    }
}

/// Wraps an asynchronous function taking two parameters
/// - Parameters:
///   - function: the function to wrap
public func async2<A, B, R, E: Error>(_ function: @escaping (A, B, ((R?, E?) -> Void)?) -> Void) -> DoubleArgFunction<A, B, R, E> {
    DoubleArgFunction(action: tname(function)) { (a: A, b: B, completion: @escaping FunctionWrapperCompletion<R, E>) -> Void in
        let boundFunction = function =<< a =<< b
        elevate(boundFunction)(completion)
    }
}

/// Wraps an asynchronous function taking a single parameter
/// - Parameters:
///   - function: the function to wrap
public func async1<A, R, E: Error>(_ function: @escaping (A, ((R?, E?) -> Void)?) -> Void) -> SingleArgFunction<A, R, E> {
    SingleArgFunction(action: tname(function)) { (a: A, completion: @escaping FunctionWrapperCompletion<R, E>) ->Void in
        let boundFunction = function =<< a
        elevate(boundFunction)(completion)
    }
}

/// Wraps an asynchronous function taking zero parameters
/// - Parameters:
///   - function: the function to wrap
public func async0<R, E: Error>(_ function: @escaping (((R?, E?) -> Void)?) -> Void) -> ZeroArgFunction<R, E> {
    ZeroArgFunction(action: tname(function)) { (completion: @escaping FunctionWrapperCompletion<R, E>) ->Void in
        elevate(function)(completion)
    }
}

/// Wraps an asynchronous function taking zero parameters
/// - Parameters:
///   - function: the function to wrap
public func async0<R, E: Error>(_ function: @escaping (((E?, R?) -> Void)?) -> Void) -> ZeroArgFunction<R, E> {
    ZeroArgFunction(action: tname(function)) { (completion: @escaping FunctionWrapperCompletion<R, E>) ->Void in
        elevate(function)(completion)
    }
}

/// Wraps an asynchronous function taking 3 parameters
/// - Parameters:
///   - function: the function to wrap
public func async3<A, B, C, E: Error>(_ function: @escaping (A, B, C, ((E?) -> Void)?) -> Void) -> TripleArgFunction<A, B, C, Void, E> {
    TripleArgFunction(action: tname(function)) { (a: A, b: B, c: C, completion: @escaping FunctionWrapperCompletion<Void, E>) -> Void in
        let boundFunction = function =<< a =<< b =<< c
        elevate(boundFunction)(completion)
    }
}

/// Wraps an asynchronous function taking a single parameter
/// - Parameters:
///   - function: the function to wrap
public func async1<A, E: Error>(_ function: @escaping (A, ((E?) -> Void)?) -> Void) -> SingleArgFunction<A, Void, E> {
    SingleArgFunction(action: tname(function)) { (a: A, completion: @escaping FunctionWrapperCompletion<Void, E>) ->Void in
        let boundFunction = function =<< a
        elevate(boundFunction)(completion)
    }
}

/// Wraps an asynchronous function taking 3 parameters
/// - Parameters:
///   - function: the function to wrap
public func async3<A, B, C, R>(_ function: @escaping (A, B, C, ((R) -> Void)?) -> Void) -> TripleArgFunction<A, B, C, R, Never> {
    TripleArgFunction(action: tname(function)) { (a: A, b: B, c: C, completion: @escaping FunctionWrapperCompletion<R, Never>)
        -> Void in
        let boundFunction = function =<< a =<< b =<< c
        elevate(boundFunction)(completion)
    }
}

/// Wraps an asynchronous function taking 3 parameters
/// - Parameters:
///   - function: the function to wrap
public func async3<A, B, C, R>(_ function: @escaping (A, B, C, @escaping (R) -> Void) -> Void) -> TripleArgFunction<A, B, C, R, Never> {
    TripleArgFunction(action: tname(function)) { (a: A, b: B, c: C, completion: @escaping FunctionWrapperCompletion<R, Never>) -> Void in
        let boundFunction = function =<< a =<< b =<< c
        elevate(boundFunction)(completion)
    }
}

/// Wraps an asynchronous function taking two parameters
/// - Parameters:
///   - function: the function to wrap
public func async2<A, B, R>(_ function: @escaping (A, B, ((R) -> Void)?) -> Void) -> DoubleArgFunction<A, B, R, Never> {
    DoubleArgFunction(action: tname(function)) { (a: A, b: B, completion: @escaping FunctionWrapperCompletion<R, Never>) -> Void in
        let boundFunction = function =<< a =<< b
        elevate(boundFunction)(completion)
    }
}

/// Wraps an asynchronous function taking two parameters
/// - Parameters:
///   - function: the function to wrap
public func async2<A, B, R>(_ function: @escaping (A, B, @escaping (R) -> Void) -> Void) ->  DoubleArgFunction<A, B, R, Never> {
    DoubleArgFunction(action: tname(function)) { (a: A, b: B, completion: @escaping FunctionWrapperCompletion<R, Never>) -> Void in
        let boundFunction = function =<< a =<< b
        elevate(boundFunction)(completion)
    }
}

/// Wraps an asynchronous function taking a single parameter
/// - Parameters:
///   - function: the function to wrap
public func async1<A, R>(_ function: @escaping (A, ((R) -> Void)?) -> Void) -> SingleArgFunction<A, R, Never> {
    SingleArgFunction(action: tname(function)) { (a: A, completion: @escaping FunctionWrapperCompletion<R, Never>) ->Void in
        let boundFunction = function =<< a
        elevate(boundFunction)(completion)
    }
}

/// Wraps an asynchronous function taking a single parameter
/// - Parameters:
///   - function: the function to wrap
public func async1<A, R>(_ function: @escaping (A, @escaping (R) -> Void) -> Void) -> SingleArgFunction<A, R, Never> {
    SingleArgFunction(action: tname(function)) { (a: A, completion: @escaping FunctionWrapperCompletion<R, Never>) ->Void in
        let boundFunction = function =<< a
        elevate(boundFunction)(completion)
    }
}

/// Wraps an asynchronous function taking zero parameters
/// - Parameters:
///   - function: the function to wrap
public func async0<R>(_ function: @escaping (@escaping (R) -> Void) -> Void) -> ZeroArgFunction<R, Never> {
    ZeroArgFunction(action: tname(function)) { (completion: @escaping FunctionWrapperCompletion<R, Never>) ->Void in
        elevate(function)(completion)
    }
}

/// Wraps an asynchronous function taking 3 parameters
/// - Parameters:
///   - function: the function to wrap
public func async3<A, B, C>(_ function: @escaping (A, B, C, (() -> Void)?) -> Void) -> TripleArgFunction<A, B, C, Void, Never> {
    TripleArgFunction(action: tname(function)) { (a: A, b: B, c: C, completion: @escaping FunctionWrapperCompletion<Void, Never>) -> Void in
        let boundFunction = function =<< a =<< b =<< c
        elevate(boundFunction)(completion)
    }
}

/// Wraps an asynchronous function taking 3 parameters
/// - Parameters:
///   - function: the function to wrap
public func async3<A, B, C>(_ function: @escaping (A, B, C, @escaping () -> Void) -> Void) -> TripleArgFunction<A, B, C, Void, Never> {
    TripleArgFunction(action: tname(function)) { (a: A, b: B, c: C, completion: @escaping FunctionWrapperCompletion<Void, Never>) -> Void in
        let boundFunction = function =<< a =<< b =<< c
        elevate(boundFunction)(completion)
    }
}

/// Wraps an asynchronous function taking two parameters
/// - Parameters:
///   - function: the function to wrap
public func async2<A, B>(_ function: @escaping (A, B, (() -> Void)?) -> Void) -> DoubleArgFunction<A, B, Void, Never> {
    DoubleArgFunction(action: tname(function)) { (a: A, b: B, completion: @escaping FunctionWrapperCompletion<Void, Never>) -> Void in
        let boundFunction = function =<< a =<< b
        elevate(boundFunction)(completion)
    }
}

/// Wraps an asynchronous function taking two parameters
/// - Parameters:
///   - function: the function to wrap
public func async2<A, B>(_ function: @escaping (A, B, @escaping () -> Void) -> Void) -> DoubleArgFunction<A, B, Void, Never> {
    DoubleArgFunction(action: tname(function)) { (a: A, b: B, completion: @escaping FunctionWrapperCompletion<Void, Never>) -> Void in
        let boundFunction = function =<< a =<< b
        elevate(boundFunction)(completion)
    }
}

/// Wraps an asynchronous function taking a single parameter
/// - Parameters:
///   - function: the function to wrap
public func async1<A>(_ function: @escaping (A, (() -> Void)?) -> Void) -> SingleArgFunction<A, Void, Never> {
    SingleArgFunction(action: tname(function))  { (a: A, completion: @escaping FunctionWrapperCompletion<Void, Never>) ->Void in
        let boundFunction = function =<< a
        elevate(boundFunction)(completion)
    }
}

/// Wraps an asynchronous function taking a single parameter
/// - Parameters:
///   - function: the function to wrap
public func async1<A>(_ function: @escaping (A, @escaping () -> Void) -> Void) -> SingleArgFunction<A, Void, Never> {
    SingleArgFunction(action: tname(function)) { (a: A, completion: @escaping FunctionWrapperCompletion<Void, Never>) ->Void in
        let boundFunction = function =<< a
        elevate(boundFunction)(completion)
    }
}

/// Wraps an asynchronous function taking zero parameters
/// - Parameters:
///   - function: the function to wrap
public func async0(_ function: @escaping ((() -> Void)?) -> Void) -> ZeroArgFunction<Void, Never> {
    ZeroArgFunction(action: tname(function)) { (completion: @escaping FunctionWrapperCompletion<Void, Never>) ->Void in
        elevate(function)(completion)
    }
}

/// Wraps an asynchronous function taking zero parameters
/// - Parameters:
///   - function: the function to wrap
public func async0(_ function: @escaping (@escaping () -> Void) -> Void) -> ZeroArgFunction<Void, Never> {
    ZeroArgFunction(action: tname(function)) { (completion: @escaping FunctionWrapperCompletion<Void, Never>) ->Void in
        elevate(function)(completion)
    }
}

/// Wraps an asynchronous function taking zero parameters
/// - Parameters:
///   - function: the function to wrap
public func async0<R>(_ function: @escaping () throws -> R) -> ZeroArgFunction<R, Error>  {
    ZeroArgFunction(action: tname(function)) { (completion: @escaping FunctionWrapperCompletion<R, Error>) ->Void in
        elevate(function)(completion)
    }
}

/// Wraps an asynchronous function taking a single parameter
/// - Parameters:
///   - function: the function to wrap
public func async1<A, R>(_ function: @escaping (A) throws -> R) -> SingleArgFunction<A, R, Error> {
    SingleArgFunction(action: tname(function)) { (a: A, completion: @escaping FunctionWrapperCompletion<R, Error>) ->Void in
        let boundFunction = function =<< a
        elevate(boundFunction)(completion)
    }
}

/// Wraps an asynchronous function taking two parameters
/// - Parameters:
///   - function: the function to wrap
public func async2<A, B, R>(_ function: @escaping (A,B) throws -> R) -> DoubleArgFunction<A, B, R, Error> {
    DoubleArgFunction(action: tname(function)) { (a: A, b: B, completion: @escaping FunctionWrapperCompletion<R, Error>) -> Void in
        let boundFunction = function =<< a =<< b
        elevate(boundFunction)(completion)
    }
}

/// Wraps an asynchronous function taking 3 parameters
/// - Parameters:
///   - function: the function to wrap
public func async3<A, B, C, R>(_ function: @escaping (A,B,C) throws -> R) -> TripleArgFunction<A, B, C, R, Error> {
    TripleArgFunction(action: tname(function)) { (a: A, b: B, c: C, completion: @escaping FunctionWrapperCompletion<R, Error>) -> Void in
        let boundFunction = function =<< a =<< b =<< c
        elevate(boundFunction)(completion)
    }
}

/// Wraps an asynchronous function taking zero parameters
/// - Parameters:
///   - function: the function to wrap
public func async0<R>(_ function: @escaping () -> R) -> ZeroArgFunction<R, Never>  {
    ZeroArgFunction(action: tname(function)) { (completion: @escaping FunctionWrapperCompletion<R, Never>) ->Void in
        elevate(function)(completion)
    }
}

/// Wraps an asynchronous function taking a single parameter
/// - Parameters:
///   - function: the function to wrap
public func async1<A, R>(_ function: @escaping (A) -> R) -> SingleArgFunction<A, R, Never> {
    SingleArgFunction(action: tname(function)) { (a: A, completion: @escaping FunctionWrapperCompletion<R, Never>) ->Void in
        let boundFunction = function =<< a
        elevate(boundFunction)(completion)
    }
}

/// Wraps an asynchronous function taking two parameters
/// - Parameters:
///   - function: the function to wrap
public func async2<A, B, R>(_ function: @escaping (A,B) -> R) -> DoubleArgFunction<A, B, R, Never> {
    DoubleArgFunction(action: tname(function)) { (a: A, b: B, completion: @escaping FunctionWrapperCompletion<R, Never>) -> Void in
        let boundFunction = function =<< a =<< b
        elevate(boundFunction)(completion)
    }
}

/// Wraps an asynchronous function taking 3 parameters
/// - Parameters:
///   - function: the function to wrap
public func async3<A, B, C, R>(_ function: @escaping (A,B,C) -> R) -> TripleArgFunction<A, B, C, R, Never> {
    TripleArgFunction(action: tname(function)) { (a: A, b: B, c: C, completion: @escaping FunctionWrapperCompletion<R, Never>) -> Void in
        let boundFunction = function =<< a =<< b =<< c
        elevate(boundFunction)(completion)
    }
}

/// Wraps an asynchronous function taking zero parameters
/// - Parameters:
///   - function: the function to wrap
public func async0<R, E: Error>(_ function: @escaping (@escaping (R?, E?) -> Void) -> Void) -> ZeroArgFunction<R, E> {
    ZeroArgFunction(action: tname(function)) { (completion: @escaping FunctionWrapperCompletion<R, E>) ->Void in
        elevate(function)(completion)
    }
}

/// Wraps an asynchronous function taking a single parameter
/// - Parameters:
///   - function: the function to wrap
public func async1<A, R, E: Error>(_ function: @escaping (A, @escaping (R?, E?) -> Void) -> Void) -> SingleArgFunction<A, R, E> {
    SingleArgFunction(action: tname(function)) { (a: A, completion: @escaping FunctionWrapperCompletion<R, E>) ->Void in
        let boundFunction = function =<< a
        elevate(boundFunction)(completion)
    }
}

/// Wraps an asynchronous function taking two parameters
/// - Parameters:
///   - function: the function to wrap
public func async2<A, B, R, E: Error>(_ function: @escaping (A,B, @escaping (R?, E?) -> Void) -> Void) -> DoubleArgFunction<A, B, R, E> {
    DoubleArgFunction(action: tname(function)) { (a: A, b: B, completion: @escaping FunctionWrapperCompletion<R, E>) -> Void in
        let boundFunction = function =<< a =<< b
        elevate(boundFunction)(completion)
    }
}

/// Wraps an asynchronous function taking 3 parameters
/// - Parameters:
///   - function: the function to wrap
public func async3<A, B, C, R, E: Error>(_ function: @escaping (A,B,C, @escaping (R?, E?) -> Void) -> Void) -> TripleArgFunction<A, B, C, R, E> {
    TripleArgFunction(action: tname(function)) { (a: A, b: B, c: C, completion: @escaping FunctionWrapperCompletion<R, E>) -> Void in
        let boundFunction = function =<< a =<< b =<< c
        elevate(boundFunction)(completion)
    }
}

/// Wraps an asynchronous function taking zero parameters
/// - Parameters:
///   - function: the function to wrap
public func async0<R, E: Error>(_ function: @escaping (@escaping (E?, R?) -> Void) -> Void) -> ZeroArgFunction<R, E> {
    ZeroArgFunction(action: tname(function)) { (completion: @escaping FunctionWrapperCompletion<R, E>) ->Void in
        elevate(function)(completion)
    }
}

/// Wraps an asynchronous function taking a single parameter
/// - Parameters:
///   - function: the function to wrap
public func async1<A, R, E: Error>(_ function: @escaping (A, @escaping (E?, R?) -> Void) -> Void) -> SingleArgFunction<A, R, E> {
    SingleArgFunction(action: tname(function)) { (a: A, completion: @escaping FunctionWrapperCompletion<R, E>) ->Void in
        let boundFunction = function =<< a
        elevate(boundFunction)(completion)
    }
}

/// Wraps an asynchronous function taking two parameters
/// - Parameters:
///   - function: the function to wrap
public func async2<A, B, R, E: Error>(_ function: @escaping (A,B, @escaping (E?, R?) -> Void) -> Void) -> DoubleArgFunction<A, B, R, E> {
    DoubleArgFunction(action: tname(function)) { (a: A, b: B, completion: @escaping FunctionWrapperCompletion<R, E>) -> Void in
        let boundFunction = function =<< a =<< b
        elevate(boundFunction)(completion)
    }
}

/// Wraps an asynchronous function taking 3 parameters
/// - Parameters:
///   - function: the function to wrap
public func async3<A, B, C, R, E: Error>(_ function: @escaping (A,B,C, @escaping (E?, R?) -> Void) -> Void) -> TripleArgFunction<A, B, C, R, E> {
    TripleArgFunction(action: tname(function)) { (a: A, b: B, c: C, completion: @escaping FunctionWrapperCompletion<R, E>) -> Void in
        let boundFunction = function =<< a =<< b =<< c
        elevate(boundFunction)(completion)
    }
}

/// Wraps an asynchronous function taking zero parameters
/// - Parameters:
///   - function: the function to wrap
public func async0<E: Error>(_ function: @escaping (((E?) -> Void)?) -> Void) -> ZeroArgFunction<Void, E> {
    ZeroArgFunction(action: tname(function)) { (completion: @escaping FunctionWrapperCompletion<Void, E>) ->Void in
        elevate(function)(completion)
    }
}

/// Wraps an asynchronous function taking zero parameters
/// - Parameters:
///   - function: the function to wrap
public func async0<E: Error>(_ function: @escaping (@escaping (E?) -> Void) -> Void) -> ZeroArgFunction<Void, E> {
    ZeroArgFunction(action: tname(function)) { (completion: @escaping FunctionWrapperCompletion<Void, E>) ->Void in
        elevate(function)(completion)
    }
}

/// Wraps an asynchronous function taking a single parameter
/// - Parameters:
///   - function: the function to wrap
public func async1<A, E: Error>(_ function: @escaping (A, @escaping (E?) -> Void) -> Void) -> SingleArgFunction<A, Void, E> {
    SingleArgFunction(action: tname(function)) { (a: A, completion: @escaping FunctionWrapperCompletion<Void, E>) ->Void in
        let boundFunction = function =<< a
        elevate(boundFunction)(completion)
    }
}

/// Wraps an asynchronous function taking two parameters
/// - Parameters:
///   - function: the function to wrap
public func async2<A, B, E: Error>(_ function: @escaping (A,B, @escaping (E?) -> Void) -> Void) -> DoubleArgFunction<A, B, Void, E> {
    DoubleArgFunction(action: tname(function)) { (a: A, b: B, completion: @escaping FunctionWrapperCompletion<Void, E>) -> Void in
        let boundFunction = function =<< a =<< b
        elevate(boundFunction)(completion)
    }
}

/// Wraps an asynchronous function taking 3 parameters
/// - Parameters:
///   - function: the function to wrap
public func async3<A, B, C, E: Error>(_ function: @escaping (A,B,C, @escaping (E?) -> Void) -> Void) -> TripleArgFunction<A, B, C, Void, E> {
    TripleArgFunction(action: tname(function)) { (a: A, b: B, c: C, completion: @escaping FunctionWrapperCompletion<Void, E>) -> Void in
        let boundFunction = function =<< a =<< b =<< c
        elevate(boundFunction)(completion)
    }
}

/// Wraps an asynchronous function taking two parameters
/// - Parameters:
///   - function: the function to wrap
public func async2<A,B,E: Error>(_ function: @escaping (A,B, ((E?) -> Void)?) -> Void) -> DoubleArgFunction<A, B, Void, E> {
    DoubleArgFunction(action: tname(function)) { (a: A, b: B, completion: @escaping FunctionWrapperCompletion<Void, E>) -> Void in
        let boundFunction = function =<< a =<< b
        elevate(boundFunction)(completion)
    }
}

/// Wraps an asynchronous function taking zero parameters
/// - Parameters:
///   - function: the function to wrap
public func async0<R, E: Error>(_ function: @escaping (@escaping (Result<R, E>) -> Void) -> Void) -> ZeroArgFunction<R, E> {
    ZeroArgFunction(action: tname(function), function: function)
}

/// Wraps an asynchronous function taking a single parameter
/// - Parameters:
///   - function: the function to wrap
public func async1<A, R, E: Error>(_ function: @escaping (A, @escaping (Result<R, E>) -> Void) -> Void) -> SingleArgFunction<A, R, E> {
    SingleArgFunction(action: tname(function)) { (a: A, completion: @escaping FunctionWrapperCompletion<R, E>) ->Void in
        let boundFunction = function =<< a
        boundFunction(completion)
    }
}

/// Wraps an asynchronous function taking two parameters
/// - Parameters:
///   - function: the function to wrap
public func async2<A, B, R, E: Error>(_ function: @escaping (A,B, @escaping (Result<R, E>) -> Void) -> Void) -> DoubleArgFunction<A, B, R, E> {
    DoubleArgFunction(action: tname(function)) { (a: A, b: B, completion: @escaping FunctionWrapperCompletion<R, E>) -> Void in
        let boundFunction = function =<< a =<< b
        boundFunction(completion)
    }
}

/// Wraps an asynchronous function taking 3 parameters
/// - Parameters:
///   - function: the function to wrap
public func async3<A, B, C, R, E: Error>(_ function: @escaping (A,B,C, @escaping (Result<R, E>) -> Void) -> Void) -> TripleArgFunction<A, B, C, R, E> {
    TripleArgFunction(action: tname(function)) { (a: A, b: B, c: C, completion: @escaping FunctionWrapperCompletion<R, E>) in
        let boundFunction = function =<< a =<< b =<< c
        boundFunction(completion)
    }
}

/// Wraps an asynchronous function taking zero parameters
/// - Parameters:
///   - function: the function to wrap
public func async0<R>(_ function: @escaping (((R) -> Void)?) -> Void) -> ZeroArgFunction<R, Never> {
    ZeroArgFunction(action: tname(function)) { (completion: @escaping FunctionWrapperCompletion<R, Never>) ->Void in
        elevate(function)(completion)
    }
}
