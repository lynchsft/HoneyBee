//
//  OperatorSyntax.swift
//  HoneyBee
//
//  Created by Alex Lynch on 2/19/17.
//  Copyright © 2017 IAM Apps. All rights reserved.
//

import Foundation

// N.B. Other operator syntaxes are declared in files named XXXOperator.swift

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

@discardableResult public func ^? <A,B : OptionalProtocol, X, Y>(left: ProcessLink<A,B>, right: @escaping (ProcessLink<B.WrappedType, B.WrappedType>) -> ProcessLink<X, Y>) -> ProcessLink<Void,Void> {
	return left.optionally(right)
}



