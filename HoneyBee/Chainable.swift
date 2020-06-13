
/// Generated protocol declaring safe chain functions.
protocol SafeChainable {
	associatedtype B
    associatedtype E: Error
	associatedtype P: AsyncBlockPerformer

///Creates a new Link which transforms argument of type B to type C and appends the link to the execution list of this Link
@discardableResult
func chain<C>(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B) -> C ) -> Link<C, E, P>

///Creates a new Link which passes through argument of type B and appends the link to the execution list of this Link
@discardableResult
func chain(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B) -> Void ) -> Link<B, E, P>

///Creates a new Link which transforms argument of type B to type C and appends the link to the execution list of this Link
@discardableResult
func chain<C>(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B) -> () -> C ) -> Link<C, E, P>

///Creates a new Link which passes through argument of type B and appends the link to the execution list of this Link
@discardableResult
func chain(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B) -> () -> Void ) -> Link<B, E, P>

///Creates a new Link which passes through argument of type B and appends the link to the execution list of this Link
@discardableResult
func chain(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping ((() -> Void)?) -> Void ) -> Link<B, E, P>

///Creates a new Link which transforms argument of type B to type C and appends the link to the execution list of this Link
@discardableResult
func chain<C>(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (((C) -> Void)?) -> Void ) -> Link<C, E, P>

///Creates a new Link which passes through argument of type B and appends the link to the execution list of this Link
@discardableResult
func chain(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B, (() -> Void)?) -> Void ) -> Link<B, E, P>

///Creates a new Link which transforms argument of type B to type C and appends the link to the execution list of this Link
@discardableResult
func chain<C>(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B, ((C) -> Void)?) -> Void ) -> Link<C, E, P>

///Creates a new Link which passes through argument of type B and appends the link to the execution list of this Link
@discardableResult
func chain(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B) -> ((() -> Void)?) -> Void ) -> Link<B, E, P>

///Creates a new Link which passes through argument of type B and appends the link to the execution list of this Link
@discardableResult
func chain(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (@escaping () -> Void) -> Void ) -> Link<B, E, P>

///Creates a new Link which transforms argument of type B to type C and appends the link to the execution list of this Link
@discardableResult
func chain<C>(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B) -> (((C) -> Void)?) -> Void ) -> Link<C, E, P>

///Creates a new Link which transforms argument of type B to type C and appends the link to the execution list of this Link
@discardableResult
func chain<C>(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (@escaping (C) -> Void) -> Void ) -> Link<C, E, P>

///Creates a new Link which passes through argument of type B and appends the link to the execution list of this Link
@discardableResult
func chain(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B, @escaping () -> Void) -> Void ) -> Link<B, E, P>

///Creates a new Link which transforms argument of type B to type C and appends the link to the execution list of this Link
@discardableResult
func chain<C>(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B, @escaping (C) -> Void) -> Void ) -> Link<C, E, P>

///Creates a new Link which passes through argument of type B and appends the link to the execution list of this Link
@discardableResult
func chain(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B) -> (@escaping () -> Void) -> Void ) -> Link<B, E, P>

///Creates a new Link which transforms argument of type B to type C and appends the link to the execution list of this Link
@discardableResult
func chain<C>(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B) -> (@escaping (C) -> Void) -> Void ) -> Link<C, E, P>

}

/// Generated protocol declaring erroring chain functions.
protocol ErroringChainable : SafeChainable {
	associatedtype B

///Creates a new Link which transforms argument of type B to type C and appends the link to the execution list of this Link
@discardableResult
func chain<C>(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B) throws -> C ) -> Link<C, Error, P>

///Creates a new Link which passes through argument of type B and appends the link to the execution list of this Link
@discardableResult
func chain(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B) throws -> Void ) -> Link<B, Error, P>

///Creates a new Link which transforms argument of type B to type C and appends the link to the execution list of this Link
@discardableResult
func chain<C>(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B) -> () throws -> C ) -> Link<C, Error, P>

///Creates a new Link which passes through argument of type B and appends the link to the execution list of this Link
@discardableResult
func chain(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B) -> () throws -> Void ) -> Link<B, Error, P>

///Creates a new Link which passes through argument of type B and appends the link to the execution list of this Link
@discardableResult
func chain<E>(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (((E?) -> Void)?) -> Void ) -> Link<B, E, P>

///Creates a new Link which passes through argument of type B and appends the link to the execution list of this Link
@discardableResult
func chain<E>(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B, ((E?) -> Void)?) -> Void ) -> Link<B, E, P>

///Creates a new Link which transforms argument of type B to type C and appends the link to the execution list of this Link
@discardableResult
func chain<C,E>(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (((C?, E?) -> Void)?) -> Void ) -> Link<C, E, P>

///Creates a new Link which passes through argument of type B and appends the link to the execution list of this Link
@discardableResult
func chain<E>(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B) -> (((E?) -> Void)?) -> Void ) -> Link<B, E, P>

///Creates a new Link which passes through argument of type B and appends the link to the execution list of this Link
@discardableResult
func chain<E>(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (@escaping (E?) -> Void) -> Void ) -> Link<B, E, P>

///Creates a new Link which transforms argument of type B to type C and appends the link to the execution list of this Link
@discardableResult
func chain<C,E>(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B, ((C?, E?) -> Void)?) -> Void ) -> Link<C, E, P>

///Creates a new Link which passes through argument of type B and appends the link to the execution list of this Link
@discardableResult
func chain<E>(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B, @escaping (E?) -> Void) -> Void ) -> Link<B, E, P>

///Creates a new Link which transforms argument of type B to type C and appends the link to the execution list of this Link
@discardableResult
func chain<C,E>(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B) -> (((C?, E?) -> Void)?) -> Void ) -> Link<C, E, P>

///Creates a new Link which transforms argument of type B to type C and appends the link to the execution list of this Link
@discardableResult
func chain<C,E>(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (@escaping (C?, E?) -> Void) -> Void ) -> Link<C, E, P>

///Creates a new Link which transforms argument of type B to type C and appends the link to the execution list of this Link
@discardableResult
func chain<C,E>(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B, @escaping (C?, E?) -> Void) -> Void ) -> Link<C, E, P>

///Creates a new Link which passes through argument of type B and appends the link to the execution list of this Link
@discardableResult
func chain<E>(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B) -> (@escaping (E?) -> Void) -> Void ) -> Link<B, E, P>

///Creates a new Link which transforms argument of type B to type C and appends the link to the execution list of this Link
@discardableResult
func chain<C,E>(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B) -> (@escaping (C?, E?) -> Void) -> Void ) -> Link<C, E, P>

}

