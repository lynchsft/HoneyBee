//
//  SyntacticSugar.swift
//  HoneyBee
//
//  Created by Alex Lynch on 2/19/17.
//  Copyright © 2017 IAM Apps. All rights reserved.
//

import Foundation

precedencegroup HoneyBeeErrorHandlingPrecedence {
	associativity: left
	higherThan: LogicalConjunctionPrecedence
}

infix operator ^! : HoneyBeeErrorHandlingPrecedence

public func ^!<F>(left: F, right: @escaping (Error) -> Void) -> FunctionWithErrorHandler<F> {
	return FunctionWithErrorHandler(function: left, errorHandler: right)
}


infix operator ^^ : LogicalConjunctionPrecedence

public struct FunctionWithErrorHandler<F> {
	let function: F
	let errorHandler: (Error) -> Void
}

@discardableResult public func ^^<A,B,C>(left: ProcessLink<A,B>, right: FunctionWithErrorHandler<(B, (C) -> Void) throws -> Void>) -> ProcessLink<B, C> {
	return left.chain(right.function, right.errorHandler)
}

@discardableResult public func ^^<A,B,C>(left: ProcessLink<A,B>, right:@escaping (B)->(C)) -> ProcessLink<B,C>{
	return left.chain(right)
}

@discardableResult public func ^^<A,B,C>(left: ProcessLink<A,B>, right:@escaping (B,(C)->Void)->Void) -> ProcessLink<B,C>{
	return left.chain(right)
}

@discardableResult public func ^^<A,B,C>(left: ProcessLink<A,B>, right: FunctionWithErrorHandler<(B) throws -> (C)>) -> ProcessLink<B,C>{
	return left.chain(right.function, right.errorHandler)
}

@discardableResult public func ^^<A,B,C>(left: ProcessLink<A,B>, right:@escaping (B, ((C) -> Void)?) -> Void) -> ProcessLink<B,C>{
	return left.chain(right)
}

@discardableResult public func ^^<A,B,C>(left: ProcessLink<A,B>, right: FunctionWithErrorHandler<(B, ((C) -> Void)?) throws -> Void>) -> ProcessLink<B,C>{
	return left.chain(right.function, right.errorHandler)
}

@discardableResult public func ^^<A,B>(left: ProcessLink<A,B>, right: FunctionWithErrorHandler<(B) -> ((Error?) -> Void) -> Void>) -> ProcessLink<FailableResult<B>, B>{
	return left.chain(right.function, right.errorHandler)
}

@discardableResult public func ^^<A,B>(left: ProcessLink<A,B>, right: FunctionWithErrorHandler<(B) -> (((Error?) -> Void)?) -> Void>) -> ProcessLink<FailableResult<B>, B>{
	return left.chain(right.function, right.errorHandler)
}

@discardableResult public func ^^<A,B>(left: ProcessLink<A,B>, right: FunctionWithErrorHandler<(B, (Error?) -> Void) -> Void>) -> ProcessLink<FailableResult<B>, B>{
	return left.chain(right.function, right.errorHandler)
}

@discardableResult public func ^^<A,B>(left: ProcessLink<A,B>, right: FunctionWithErrorHandler<(B, ((Error?) -> Void)?) -> Void>) -> ProcessLink<FailableResult<B>, B>{
	return left.chain(right.function, right.errorHandler)
}

@discardableResult public func ^^<A,B,C>(left: ProcessLink<A,B>, right: FunctionWithErrorHandler<(B, (C?, Error?) -> Void) -> Void>) -> ProcessLink<FailableResult<C>,C>{
	return left.chain(right.function, right.errorHandler)
}

@discardableResult public func ^^<A,B,C>(left: ProcessLink<A,B>, right: FunctionWithErrorHandler<(B, ((C?, Error?) -> Void)?) -> Void>) -> ProcessLink<FailableResult<C>,C>{
	return left.chain(right.function, right.errorHandler)
}

@discardableResult public func ^^<A,B,C>(left: ProcessLink<A,B>, right:@escaping (B) -> ((C) -> Void) -> Void) -> ProcessLink<B,C>{
	return left.chain(right)
}

@discardableResult public func ^^<A,B,C>(left: ProcessLink<A,B>, right:@escaping (B) -> (((C) -> Void)?) -> Void) -> ProcessLink<B,C>{
	return left.chain(right)
}

@discardableResult public func ^^<A,B,C>(left: ProcessLink<A,B>, right:@escaping (B) -> (() -> C)) -> ProcessLink<B,C>{
	return left.chain(right)
}

@discardableResult public func ^^<A,B>(left: ProcessLink<A,B>, right:@escaping (B) -> (() -> Void)) -> ProcessLink<B,Void>{
	return left.chain(right)
}


infix operator ^< : LogicalConjunctionPrecedence

public func ^< <A,B>(left: ProcessLink<A,B>, right: (ProcessLink<A, B>) -> Void) -> Void {
	return left.fork(right)
}


infix operator ^+ : LogicalConjunctionPrecedence

public func ^+ <A,B,C,X>(left: ProcessLink<A,B>, right: ProcessLink<X,C>) -> ProcessLink<Void, (B,C)> {
	return left.conjoin(right)
}


infix operator ^% : LogicalConjunctionPrecedence

public func ^% <A,B,C>(left: ProcessLink<A,B>, right: C) -> ProcessLink<B, C> {
	return left.value(right)
}


infix operator ^? : LogicalConjunctionPrecedence

@discardableResult public func ^? <A,B : OptionalProtocol>(left: ProcessLink<A,B>, right: @escaping (ProcessLink<B.WrappedType, B.WrappedType>) -> Void) -> ProcessLink<B,Void> {
	return left.optionally(right)
}



