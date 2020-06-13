//
//  FunctionTransformations.swift
//  HoneyBee
//
//  Created by Alex Lynch on 12/13/19.
//  Copyright © 2019 IAM Apps. All rights reserved.
//

import Foundation

func elevate<E>(_ function: @escaping (@escaping (E?)->Void ) -> Void) -> (@escaping (Result<Void, E>) -> Void) -> Void {
    return {(callback: @escaping ((Result<Void, E>) -> Void)) in
        function { error in
            if let error = error {
                callback(.failure(error))
            } else {
                callback(.success(Void()))
            }
        }
    }
}

func elevate<C,E>(_ function: @escaping (@escaping (C?, E?)->Void ) -> Void) -> (@escaping (Result<C, E>) -> Void) -> Void {
    return {(callback: @escaping ((Result<C, E>) -> Void)) in
        function { c, error in
            if let error = error {
                callback(.failure(error))
            } else if let c = c {
                callback(.success(c))
            } else {
                HoneyBee.internalFailureResponse.evaluate(true, "Completion called with two nil values.")
            }
        }
    }
}

func populateVoid<T,E>(result: Result<Void, E>, with t: T) -> Result<T, E> {
    result.map { t }
}

func elevate<C,E>(_ function: @escaping (@escaping (E?, C?)->Void ) -> Void) -> (@escaping (Result<C, E>) -> Void) -> Void {
    elevate { (callback: @escaping (C?, E?) -> Void) in
        function { (error, c) in
            callback(c, error)
        }
    }
}

func elevate<E>(_ function: @escaping (@escaping () -> Void) -> Void) -> (@escaping (Result<Void, E>) -> Void) -> Void {
    return { (callback: @escaping (Result<Void, E>) -> Void) -> Void in
        function {
            callback(.success(Void()))
        }
    }
}

func elevate<E>(_ function: @escaping ((() -> Void)?) -> Void) -> (@escaping (Result<Void, E>) -> Void) -> Void {
    return { (callback: @escaping (Result<Void, E>) -> Void) -> Void in
        function {
            callback(.success(Void()))
        }
    }
}


func elevate<C>(_ function: @escaping () throws -> C) -> (@escaping (Result<C, Error>) -> Void) -> Void {
    return { (callback: @escaping (Result<C, Error>) -> Void) -> Void in
        do {
            try callback(.success(function()))
        } catch {
            callback(.failure(error))
        }
    }
}

func elevate(_ function: @escaping () throws -> Void) -> (@escaping (Result<Void, Error>) -> Void) -> Void {
    return { (callback: @escaping (Result<Void, Error>) -> Void) -> Void in
        do {
            try function()
            callback(.success(Void()))
        } catch {
            callback(.failure(error))
        }
    }
}

func elevate<C,E>(_ function: @escaping () -> C) -> (@escaping (Result<C, E>) -> Void) -> Void {
    return { (callback: @escaping (Result<C, E>) -> Void) -> Void in
        callback(.success(function()))
    }
}

func elevate<E>(_ function: @escaping () -> Void) -> (@escaping (Result<Void, E>) -> Void) -> Void {
    return { (callback: @escaping (Result<Void, E>) -> Void) -> Void in
        function()
        callback(.success(Void()))
    }
}

func elevate<C, E>(_ function: @escaping (@escaping (C) -> Void) -> Void) -> (@escaping (Result<C, E>) -> Void) -> Void {
    return { (callback: @escaping (Result<C, E>) -> Void) -> Void in
        function { result in
            callback(.success(result))
        }
    }
}
