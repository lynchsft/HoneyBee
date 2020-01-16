//
//  FunctionTransformations.swift
//  HoneyBee
//
//  Created by Alex Lynch on 12/13/19.
//  Copyright © 2019 IAM Apps. All rights reserved.
//

import Foundation

func elevate(_ function: @escaping (@escaping (Error?)->Void ) -> Void) -> (@escaping (Result<Void, Error>) -> Void) -> Void {
    return {(callback: @escaping ((Result<Void, Error>) -> Void)) in
        function { error in
            if let error = error {
                callback(.failure(error))
            } else {
                callback(.success(Void()))
            }
        }
    }
}

func elevate<C>(_ function: @escaping (@escaping (C?, Error?)->Void ) -> Void) -> (@escaping (Result<C, Error>) -> Void) -> Void {
    return {(callback: @escaping ((Result<C, Error>) -> Void)) in
        function { c, error in
            if let error = error {
                callback(.failure(error))
            } else if let c = c {
                callback(.success(c))
            } else {
                callback(.failure(NSError(domain: "Completion called with two nil values.", code: -99, userInfo: nil)))
            }
        }
    }
}

func populateVoid<T>(failableResult: Result<Void, Error>, with t: T) -> Result<T, Error> {
    switch failableResult {
    case let .failure(error):
        return .failure(error)
    case .success():
        return .success(t)
    }
}

func elevate<C>(_ function: @escaping (@escaping (Error?, C?)->Void ) -> Void) -> (@escaping (Result<C, Error>) -> Void) -> Void {
    elevate { (callback: @escaping (C?, Error?) -> Void) in
        function { (error, c) in
            callback(c, error)
        }
    }
}

func elevate<T>(_ function: @escaping (T) -> (@escaping (Error?) -> Void) -> Void) -> (T, @escaping (Result<T, Error>) -> Void) -> Void {
    return { (t: T, callback: @escaping (Result<T, Error>) -> Void) -> Void in
        elevate(function(t))({ result in
            callback(populateVoid(failableResult: result, with: t))
        })
    }
}

func elevate<T>(_ function: @escaping (T, @escaping (Error?) -> Void) -> Void) -> (T, @escaping (Result<T, Error>) -> Void) -> Void {
    return { (t: T, callback: @escaping (Result<T, Error>) -> Void) -> Void in
        elevate(function =<< t)({ result in
            callback(populateVoid(failableResult: result, with: t))
        })
    }
}

func elevate<T>(_ function: @escaping (@escaping (Error?) -> Void) -> Void) -> (T, @escaping (Result<T, Error>) -> Void) -> Void {
    return { (t: T, callback: @escaping (Result<T, Error>) -> Void) -> Void in
        elevate(function)({ result in
            callback(populateVoid(failableResult: result, with: t))
        })
    }
}

func elevate(_ function: @escaping (@escaping () -> Void) throws -> Void) -> (@escaping (Result<Void, Error>) -> Void) -> Void {
    return { (callback: @escaping (Result<Void, Error>) -> Void) -> Void in
        do {
            try function {
                callback(.success(Void()))
            }
        } catch {
            callback(.failure(error))
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


func elevate<T, C>(_ function: @escaping (T, @escaping (C?, Error?) -> Void) -> Void) -> (T, @escaping (Result<C, Error>) -> Void) -> Void {
    return { (t: T, callback: @escaping (Result<C, Error>) -> Void) -> Void in
        elevate(bind(function, t))(callback)
    }
}

func elevate<C>(_ function: @escaping (@escaping (C) -> Void) throws -> Void) -> (@escaping (Result<C, Error>) -> Void) -> Void {
    return { (callback: @escaping (Result<C, Error>) -> Void) -> Void in
        do {
            try function { result in
                callback(.success(result))
            }
        } catch {
            callback(.failure(error))
        }
    }
}

func elevate<T, C>(_ function: @escaping (T) -> (@escaping (C?, Error?) -> Void) -> Void) -> (T, @escaping (Result<C, Error>) -> Void) -> Void {
    return { (t: T, callback: @escaping (Result<C, Error>) -> Void) -> Void in
        elevate(function(t))(callback)
    }
}
