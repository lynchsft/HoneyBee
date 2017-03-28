
/// Generated chain operator functions.

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

///operator syntax for ProcessLink.chain
@discardableResult public func ^^<A,B>(left: ProcessLink<A,B>, right: @escaping () -> Void) -> ProcessLink<B, B> {
	return left.chain(right)
}

///operator syntax for ProcessLink.chain
@discardableResult public func ^^<A,B>(left: ProcessLink<A,B>, right: FunctionWithErrorHandler<(@escaping (Error?) -> Void) -> Void>) -> ProcessLink<B, B> {
	return left.chain(right.function, right.errorHandler)
}

///operator syntax for ProcessLink.chain
@discardableResult public func ^^<A,B,C>(left: ProcessLink<A,B>, right: @escaping (((C) -> Void)?) -> Void) -> ProcessLink<B, C> {
	return left.chain(right)
}

///operator syntax for ProcessLink.chain
@discardableResult public func ^^<A,B,C>(left: ProcessLink<A,B>, right: @escaping (B) -> (C)) -> ProcessLink<B, C> {
	return left.chain(right)
}

///operator syntax for ProcessLink.chain
@discardableResult public func ^^<A,B,C>(left: ProcessLink<A,B>, right: FunctionWithErrorHandler<(B) throws -> (C)>) -> ProcessLink<B, C> {
	return left.chain(right.function, right.errorHandler)
}

///operator syntax for ProcessLink.chain
@discardableResult public func ^^<A,B,C>(left: ProcessLink<A,B>, right: @escaping (B) -> (() -> C)) -> ProcessLink<B, C> {
	return left.chain(right)
}

///operator syntax for ProcessLink.chain
@discardableResult public func ^^<A,B,C>(left: ProcessLink<A,B>, right: @escaping (B, ((C) -> Void)?) -> Void) -> ProcessLink<B, C> {
	return left.chain(right)
}

///operator syntax for ProcessLink.chain
@discardableResult public func ^^<A,B,C>(left: ProcessLink<A,B>, right: @escaping (B) -> (((C) -> Void)?) -> Void) -> ProcessLink<B, C> {
	return left.chain(right)
}

///operator syntax for ProcessLink.chain
@discardableResult public func ^^<A,B,C>(left: ProcessLink<A,B>, right: FunctionWithErrorHandler<(B, ((C) -> Void)?) throws -> Void>) -> ProcessLink<B, C> {
	return left.chain(right.function, right.errorHandler)
}

///operator syntax for ProcessLink.chain
@discardableResult public func ^^<A,B,C>(left: ProcessLink<A,B>, right: @escaping (B, @escaping (C) -> Void) -> Void) -> ProcessLink<B, C> {
	return left.chain(right)
}

///operator syntax for ProcessLink.chain
@discardableResult public func ^^<A,B,C>(left: ProcessLink<A,B>, right: FunctionWithErrorHandler<(B, ((C?, Error?) -> Void)?) -> Void>) -> ProcessLink<B, C> {
	return left.chain(right.function, right.errorHandler)
}

///operator syntax for ProcessLink.chain
@discardableResult public func ^^<A,B,C>(left: ProcessLink<A,B>, right: @escaping (B) -> (@escaping (C) -> Void) -> Void) -> ProcessLink<B, C> {
	return left.chain(right)
}

///operator syntax for ProcessLink.chain
@discardableResult public func ^^<A,B,C>(left: ProcessLink<A,B>, right: FunctionWithErrorHandler<(B, @escaping (C) -> Void) throws -> Void>) -> ProcessLink<B, C> {
	return left.chain(right.function, right.errorHandler)
}

///operator syntax for ProcessLink.chain
@discardableResult public func ^^<A,B,C>(left: ProcessLink<A,B>, right: FunctionWithErrorHandler<(B, @escaping (C?, Error?) -> Void) -> Void>) -> ProcessLink<B, C> {
	return left.chain(right.function, right.errorHandler)
}

///operator syntax for ProcessLink.chain
@discardableResult public func ^^<A,B>(left: ProcessLink<A,B>, right: @escaping (B) -> (() -> Void)) -> ProcessLink<B, B> {
	return left.chain(right)
}

///operator syntax for ProcessLink.chain
@discardableResult public func ^^<A,B>(left: ProcessLink<A,B>, right: FunctionWithErrorHandler<(B, ((Error?) -> Void)?) -> Void>) -> ProcessLink<B, B> {
	return left.chain(right.function, right.errorHandler)
}

///operator syntax for ProcessLink.chain
@discardableResult public func ^^<A,B>(left: ProcessLink<A,B>, right: FunctionWithErrorHandler<(B) -> (((Error?) -> Void)?) -> Void>) -> ProcessLink<B, B> {
	return left.chain(right.function, right.errorHandler)
}

///operator syntax for ProcessLink.chain
@discardableResult public func ^^<A,B>(left: ProcessLink<A,B>, right: FunctionWithErrorHandler<(B, @escaping (Error?) -> Void) -> Void>) -> ProcessLink<B, B> {
	return left.chain(right.function, right.errorHandler)
}

///operator syntax for ProcessLink.chain
@discardableResult public func ^^<A,B>(left: ProcessLink<A,B>, right: FunctionWithErrorHandler<(B) -> (@escaping (Error?) -> Void) -> Void>) -> ProcessLink<B, B> {
	return left.chain(right.function, right.errorHandler)
}

