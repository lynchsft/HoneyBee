//
//  ConjoinOperator.swift
//  HoneyBee
//
//  Created by Alex Lynch on 8/6/20.
//  Copyright © 2020 IAM Apps. All rights reserved.
//

import Foundation

/// operator syntax for `conjoin` function
public func +<B, C, CommonE: Error, CommonP: AsyncBlockPerformer>(lhs: Link<B, CommonE, CommonP>, rhs: Link<C, CommonE, CommonP>) -> Link<(B,C), CommonE, CommonP> {
    lhs.conjoin(rhs)
}

/// operator syntax for `conjoin` function
public func +<X,Y,C, CommonE: Error, CommonP: AsyncBlockPerformer>(lhs: Link<(X,Y), CommonE, CommonP>, rhs: Link<C, CommonE, CommonP>) -> Link<(X,Y,C), CommonE, CommonP> {
    lhs.conjoin(rhs)
}

/// operator syntax for `conjoin` function
public func +<X,Y,Z,C, CommonE: Error, CommonP: AsyncBlockPerformer>(lhs: Link<(X,Y,Z), CommonE, CommonP>, rhs: Link<C, CommonE, CommonP>) -> Link<(X,Y,Z,C), CommonE, CommonP> {
    lhs.conjoin(rhs)
}


/// operator syntax for `conjoin` function
public func +<B, C, E1: Error, E2: Error, CommonP: AsyncBlockPerformer>(lhs: Link<B, E1, CommonP>, rhs: Link<C, E2, CommonP>) -> Link<(B,C), Error, CommonP> {
    lhs.expect(Error.self).conjoin(rhs.expect(Error.self))
}

/// operator syntax for `conjoin` function
public func +<X,Y,C, E1: Error, E2: Error, CommonP: AsyncBlockPerformer>(lhs: Link<(X,Y), E1, CommonP>, rhs: Link<C, E2, CommonP>) -> Link<(X,Y,C), Error, CommonP> {
    lhs.expect(Error.self).conjoin(rhs.expect(Error.self))
}

/// operator syntax for `conjoin` function
public func +<X,Y,Z,C, E1: Error, E2: Error, CommonP: AsyncBlockPerformer>(lhs: Link<(X,Y,Z), E1, CommonP>, rhs: Link<C, E2, CommonP>) -> Link<(X,Y,Z,C), Error, CommonP> {
    lhs.expect(Error.self).conjoin(rhs.expect(Error.self))
}


/// operator syntax for `conjoin` function
public func +<B, C, E: Error, CommonP: AsyncBlockPerformer>(lhs: Link<B, E, CommonP>, rhs: Link<C, Never, CommonP>) -> Link<(B,C), E, CommonP> {
    lhs.conjoin(rhs.expect(E.self))
}

/// operator syntax for `conjoin` function
public func +<X,Y,C, E: Error, CommonP: AsyncBlockPerformer>(lhs: Link<(X,Y), E, CommonP>, rhs: Link<C, Never, CommonP>) -> Link<(X,Y,C), E, CommonP> {
    lhs.conjoin(rhs.expect(E.self))
}

/// operator syntax for `conjoin` function
public func +<X,Y,Z,C, E: Error, CommonP: AsyncBlockPerformer>(lhs: Link<(X,Y,Z), E, CommonP>, rhs: Link<C, Never, CommonP>) -> Link<(X,Y,Z,C), E, CommonP> {
    lhs.conjoin(rhs.expect(E.self))
}


/// operator syntax for `conjoin` function
public func +<B, C, E: Error, CommonP: AsyncBlockPerformer>(lhs: Link<B, Never, CommonP>, rhs: Link<C, E, CommonP>) -> Link<(B,C), E, CommonP> {
    lhs.expect(E.self).conjoin(rhs)
}

/// operator syntax for `conjoin` function
public func +<X,Y,C, E: Error, CommonP: AsyncBlockPerformer>(lhs: Link<(X,Y), Never, CommonP>, rhs: Link<C, E, CommonP>) -> Link<(X,Y,C), E, CommonP> {
    lhs.expect(E.self).conjoin(rhs)
}

/// operator syntax for `conjoin` function
public func +<X,Y,Z,C, E: Error, CommonP: AsyncBlockPerformer>(lhs: Link<(X,Y,Z), Never, CommonP>, rhs: Link<C, E, CommonP>) -> Link<(X,Y,Z,C), E, CommonP> {
    lhs.expect(E.self).conjoin(rhs)
}


/// operator syntax for `conjoin` function
public func +<B, C, CommonP: AsyncBlockPerformer>(lhs: Link<B, Never, CommonP>, rhs: Link<C, Never, CommonP>) -> Link<(B,C), Never, CommonP> {
    lhs.conjoin(rhs)
}

/// operator syntax for `conjoin` function
public func +<X,Y,C, CommonP: AsyncBlockPerformer>(lhs: Link<(X,Y), Never, CommonP>, rhs: Link<C, Never, CommonP>) -> Link<(X,Y,C), Never, CommonP> {
    lhs.conjoin(rhs)
}

/// operator syntax for `conjoin` function
public func +<X,Y,Z,C, CommonP: AsyncBlockPerformer>(lhs: Link<(X,Y,Z), Never, CommonP>, rhs: Link<C, Never, CommonP>) -> Link<(X,Y,Z,C), Never, CommonP> {
    lhs.conjoin(rhs)
}


/// operator syntax for `join left` behavior
///
/// - Parameters:
///   - lhs: Link whose value to propagate
///   - rhs: Link whose value to drop
/// - Returns: a Link which contains the value of the left-hand Link
public func <+<B, C, CommonE: Error, CommonP: AsyncBlockPerformer>(lhs: Link<B, CommonE, CommonP>, rhs: Link<C, CommonE, CommonP>) -> Link<B, CommonE, CommonP> {
    (lhs+rhs).chain { (b_c, completion: @escaping (Result<B, CommonE>)->Void) in
        completion(.success(b_c.0))
    }
}

/// operator syntax for `join left` behavior
///
/// - Parameters:
///   - lhs: Link whose value to propagate
///   - rhs: Link whose value to drop
/// - Returns: a Link which contains the value of the left-hand Link
public func <+<B, C, E1: Error, E2: Error, CommonP: AsyncBlockPerformer>(lhs: Link<B, E1, CommonP>, rhs: Link<C, E2, CommonP>) -> Link<B, Error, CommonP> {
    (lhs+rhs).chain { (b_c, completion: @escaping (Result<B, Error>)->Void) in
        completion(.success(b_c.0))
    }
}

/// operator syntax for `join left` behavior
///
/// - Parameters:
///   - lhs: Link whose value to propagate
///   - rhs: Link whose value to drop
/// - Returns: a Link which contains the value of the left-hand Link
public func <+<B, C, E: Error, CommonP: AsyncBlockPerformer>(lhs: Link<B, E, CommonP>, rhs: Link<C, Never, CommonP>) -> Link<B, E, CommonP> {
    (lhs+rhs).chain { (b_c, completion: @escaping (Result<B, E>)->Void) in
        completion(.success(b_c.0))
    }
}

/// operator syntax for `join left` behavior
///
/// - Parameters:
///   - lhs: Link whose value to propagate
///   - rhs: Link whose value to drop
/// - Returns: a Link which contains the value of the left-hand Link
public func <+<B, C, E: Error, CommonP: AsyncBlockPerformer>(lhs: Link<B, Never, CommonP>, rhs: Link<C, E, CommonP>) -> Link<B, E, CommonP> {
    (lhs+rhs).chain { (b_c, completion: @escaping (Result<B, E>)->Void) in
        completion(.success(b_c.0))
    }
}

/// operator syntax for `join left` behavior
///
/// - Parameters:
///   - lhs: Link whose value to propagate
///   - rhs: Link whose value to drop
/// - Returns: a Link which contains the value of the left-hand Link
public func <+<B, C, CommonP: AsyncBlockPerformer>(lhs: Link<B, Never, CommonP>, rhs: Link<C, Never, CommonP>) -> Link<B, Never, CommonP> {
    (lhs+rhs).chain { (b_c, completion: @escaping (Result<B, Never>)->Void) in
        completion(.success(b_c.0))
    }
}


/// operator syntax for `join right` behavior
///
/// - Parameters:
///   - lhs: Link whose value to drop
///   - rhs: Link whose value to propagate
/// - Returns: a Link which contains the value of the left-hand Link
public func +><B, C, CommonE: Error, CommonP: AsyncBlockPerformer>(lhs: Link<B, CommonE, CommonP>, rhs: Link<C, CommonE, CommonP>) -> Link<C, CommonE, CommonP> {
    (lhs+rhs).chain { (b_c, completion: @escaping (Result<C, CommonE>)->Void) in
        completion(.success(b_c.1))
    }
}

/// operator syntax for `join right` behavior
///
/// - Parameters:
///   - lhs: Link whose value to drop
///   - rhs: Link whose value to propagate
/// - Returns: a Link which contains the value of the left-hand Link
public func +><B, C, E1: Error, E2: Error, CommonP: AsyncBlockPerformer>(lhs: Link<B, E1, CommonP>, rhs: Link<C, E2, CommonP>) -> Link<C, Error, CommonP> {
    (lhs+rhs).chain { (b_c, completion: @escaping (Result<C, Error>)->Void) in
        completion(.success(b_c.1))
    }
}

/// operator syntax for `join right` behavior
///
/// - Parameters:
///   - lhs: Link whose value to drop
///   - rhs: Link whose value to propagate
/// - Returns: a Link which contains the value of the left-hand Link
public func +><B, C, E: Error, CommonP: AsyncBlockPerformer>(lhs: Link<B, Never, CommonP>, rhs: Link<C, E, CommonP>) -> Link<C, E, CommonP> {
    (lhs+rhs).chain { (b_c, completion: @escaping (Result<C, E>)->Void) in
        completion(.success(b_c.1))
    }
}

/// operator syntax for `join right` behavior
///
/// - Parameters:
///   - lhs: Link whose value to drop
///   - rhs: Link whose value to propagate
/// - Returns: a Link which contains the value of the left-hand Link
public func +><B, C, E: Error, CommonP: AsyncBlockPerformer>(lhs: Link<B, E, CommonP>, rhs: Link<C, Never, CommonP>) -> Link<C, E, CommonP> {
    (lhs+rhs).chain { (b_c, completion: @escaping (Result<C, E>)->Void) in
        completion(.success(b_c.1))
    }
}

/// operator syntax for `join right` behavior
///
/// - Parameters:
///   - lhs: Link whose value to drop
///   - rhs: Link whose value to propagate
/// - Returns: a Link which contains the value of the left-hand Link
public func +><B, C, CommonP: AsyncBlockPerformer>(lhs: Link<B, Never, CommonP>, rhs: Link<C, Never, CommonP>) -> Link<C, Never, CommonP> {
    (lhs+rhs).chain { (b_c, completion: @escaping (Result<C, Never>)->Void) in
        completion(.success(b_c.1))
    }
}
