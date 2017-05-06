
/// Generated chain operator functions.

public struct FunctionWithErrorHandler<Func,Cause> {
	let function: Func
	let errorHandler: (Error,Cause) -> Void
}

precedencegroup HoneyBeeErrorHandlingPrecedence {
	associativity: left
	higherThan: LogicalConjunctionPrecedence
}

infix operator ^! : HoneyBeeErrorHandlingPrecedence

public func ^!<F,Cause>(left: F, right: @escaping (Error,Cause) -> Void) -> FunctionWithErrorHandler<F,Cause> {
	return FunctionWithErrorHandler(function: left, errorHandler: right)
}

infix operator ^^ : LogicalConjunctionPrecedence

infix operator ^- : LogicalConjunctionPrecedence

///operator syntax for ProcessLink.chain
@discardableResult public func ^-<A,B,C>(left: ProcessLink<A,B>, right: @escaping () -> C) -> ProcessLink<B, C> {
	return left.splice(right)
}

///operator syntax for ProcessLink.chain
@discardableResult public func ^^<A,B,C>(left: ProcessLink<A,B>, right: @escaping (B) -> C) -> ProcessLink<B, C> {
	return left.chain(right)
}

///operator syntax for ProcessLink.chain
@discardableResult public func ^^<A,B,C>(left: ProcessLink<A,B>, right: @escaping (B) -> () -> C) -> ProcessLink<B, C> {
	return left.chain(right)
}

///operator syntax for ProcessLink.chain
@discardableResult public func ^-<A,B,C>(left: ProcessLink<A,B>, right: FunctionWithErrorHandler<() throws -> C,B>) -> ProcessLink<B, C> {
	return left.splice(right.function, right.errorHandler)
}

///operator syntax for ProcessLink.chain
@discardableResult public func ^^<A,B,C>(left: ProcessLink<A,B>, right: FunctionWithErrorHandler<(B) throws -> C,B>) -> ProcessLink<B, C> {
	return left.chain(right.function, right.errorHandler)
}

///operator syntax for ProcessLink.chain
@discardableResult public func ^^<A,B,C>(left: ProcessLink<A,B>, right: FunctionWithErrorHandler<(B) -> () throws -> C,B>) -> ProcessLink<B, C> {
	return left.chain(right.function, right.errorHandler)
}

///operator syntax for ProcessLink.chain
@discardableResult public func ^^<A,B,C>(left: ProcessLink<A,B>, right: @escaping (((C) -> Void)?) -> Void) -> ProcessLink<B, C> {
	return left.chain(right)
}

///operator syntax for ProcessLink.chain
@discardableResult public func ^^<A,B,C>(left: ProcessLink<A,B>, right: @escaping (B, ((C) -> Void)?) -> Void) -> ProcessLink<B, C> {
	return left.chain(right)
}

///operator syntax for ProcessLink.chain
@discardableResult public func ^^<A,B>(left: ProcessLink<A,B>, right: FunctionWithErrorHandler<(((Error?) -> Void)?) -> Void,B>) -> ProcessLink<B, B> {
	return left.chain(right.function, right.errorHandler)
}

///operator syntax for ProcessLink.chain
@discardableResult public func ^^<A,B,C>(left: ProcessLink<A,B>, right: @escaping (@escaping (C) -> Void) -> Void) -> ProcessLink<B, C> {
	return left.chain(right)
}

///operator syntax for ProcessLink.chain
@discardableResult public func ^^<A,B,C>(left: ProcessLink<A,B>, right: @escaping (B) -> (((C) -> Void)?) -> Void) -> ProcessLink<B, C> {
	return left.chain(right)
}

///operator syntax for ProcessLink.chain
@discardableResult public func ^^<A,B,C>(left: ProcessLink<A,B>, right: FunctionWithErrorHandler<(((C) -> Void)?) throws -> Void,B>) -> ProcessLink<B, C> {
	return left.chain(right.function, right.errorHandler)
}

///operator syntax for ProcessLink.chain
@discardableResult public func ^^<A,B>(left: ProcessLink<A,B>, right: FunctionWithErrorHandler<(B, ((Error?) -> Void)?) -> Void,B>) -> ProcessLink<B, B> {
	return left.chain(right.function, right.errorHandler)
}

///operator syntax for ProcessLink.chain
@discardableResult public func ^^<A,B,C>(left: ProcessLink<A,B>, right: FunctionWithErrorHandler<(((C?, Error?) -> Void)?) -> Void,B>) -> ProcessLink<B, C> {
	return left.chain(right.function, right.errorHandler)
}

///operator syntax for ProcessLink.chain
@discardableResult public func ^^<A,B,C>(left: ProcessLink<A,B>, right: @escaping (B, @escaping (C) -> Void) -> Void) -> ProcessLink<B, C> {
	return left.chain(right)
}

///operator syntax for ProcessLink.chain
@discardableResult public func ^^<A,B,C>(left: ProcessLink<A,B>, right: FunctionWithErrorHandler<(B, ((C) -> Void)?) throws -> Void,B>) -> ProcessLink<B, C> {
	return left.chain(right.function, right.errorHandler)
}

///operator syntax for ProcessLink.chain
@discardableResult public func ^^<A,B>(left: ProcessLink<A,B>, right: FunctionWithErrorHandler<(B) -> (((Error?) -> Void)?) -> Void,B>) -> ProcessLink<B, B> {
	return left.chain(right.function, right.errorHandler)
}

///operator syntax for ProcessLink.chain
@discardableResult public func ^^<A,B,C>(left: ProcessLink<A,B>, right: FunctionWithErrorHandler<(B, ((C?, Error?) -> Void)?) -> Void,B>) -> ProcessLink<B, C> {
	return left.chain(right.function, right.errorHandler)
}

///operator syntax for ProcessLink.chain
@discardableResult public func ^^<A,B>(left: ProcessLink<A,B>, right: FunctionWithErrorHandler<(@escaping (Error?) -> Void) -> Void,B>) -> ProcessLink<B, B> {
	return left.chain(right.function, right.errorHandler)
}

///operator syntax for ProcessLink.chain
@discardableResult public func ^^<A,B,C>(left: ProcessLink<A,B>, right: FunctionWithErrorHandler<(B) -> (((C) -> Void)?) throws -> Void,B>) -> ProcessLink<B, C> {
	return left.chain(right.function, right.errorHandler)
}

///operator syntax for ProcessLink.chain
@discardableResult public func ^^<A,B,C>(left: ProcessLink<A,B>, right: FunctionWithErrorHandler<(@escaping (C) -> Void) throws -> Void,B>) -> ProcessLink<B, C> {
	return left.chain(right.function, right.errorHandler)
}

///operator syntax for ProcessLink.chain
@discardableResult public func ^^<A,B,C>(left: ProcessLink<A,B>, right: @escaping (B) -> (@escaping (C) -> Void) -> Void) -> ProcessLink<B, C> {
	return left.chain(right)
}

///operator syntax for ProcessLink.chain
@discardableResult public func ^^<A,B>(left: ProcessLink<A,B>, right: FunctionWithErrorHandler<(B, @escaping (Error?) -> Void) -> Void,B>) -> ProcessLink<B, B> {
	return left.chain(right.function, right.errorHandler)
}

///operator syntax for ProcessLink.chain
@discardableResult public func ^^<A,B,C>(left: ProcessLink<A,B>, right: FunctionWithErrorHandler<(B) -> (((C?, Error?) -> Void)?) -> Void,B>) -> ProcessLink<B, C> {
	return left.chain(right.function, right.errorHandler)
}

///operator syntax for ProcessLink.chain
@discardableResult public func ^^<A,B,C>(left: ProcessLink<A,B>, right: FunctionWithErrorHandler<(@escaping (C?, Error?) -> Void) -> Void,B>) -> ProcessLink<B, C> {
	return left.chain(right.function, right.errorHandler)
}

///operator syntax for ProcessLink.chain
@discardableResult public func ^^<A,B,C>(left: ProcessLink<A,B>, right: FunctionWithErrorHandler<(B, @escaping (C) -> Void) throws -> Void,B>) -> ProcessLink<B, C> {
	return left.chain(right.function, right.errorHandler)
}

///operator syntax for ProcessLink.chain
@discardableResult public func ^^<A,B>(left: ProcessLink<A,B>, right: FunctionWithErrorHandler<(B) -> (@escaping (Error?) -> Void) -> Void,B>) -> ProcessLink<B, B> {
	return left.chain(right.function, right.errorHandler)
}

///operator syntax for ProcessLink.chain
@discardableResult public func ^^<A,B,C>(left: ProcessLink<A,B>, right: FunctionWithErrorHandler<(B, @escaping (C?, Error?) -> Void) -> Void,B>) -> ProcessLink<B, C> {
	return left.chain(right.function, right.errorHandler)
}

///operator syntax for ProcessLink.chain
@discardableResult public func ^^<A,B,C>(left: ProcessLink<A,B>, right: FunctionWithErrorHandler<(B) -> (@escaping (C) -> Void) throws -> Void,B>) -> ProcessLink<B, C> {
	return left.chain(right.function, right.errorHandler)
}

///operator syntax for ProcessLink.chain
@discardableResult public func ^^<A,B,C>(left: ProcessLink<A,B>, right: FunctionWithErrorHandler<(B) -> (@escaping (C?, Error?) -> Void) -> Void,B>) -> ProcessLink<B, C> {
	return left.chain(right.function, right.errorHandler)
}

