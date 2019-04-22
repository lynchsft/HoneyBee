
/// Generated protocol declaring safe chain functions.
protocol SafeChainable {
	associatedtype B
	associatedtype Performer: AsyncBlockPerformer

///Creates a new Link which transforms argument of type B to type C and appends the link to the execution list of this Link
@discardableResult
func chain<C>(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B) -> C ) -> SafeLink<C, Performer>

///Creates a new Link which passes through argument of type B and appends the link to the execution list of this Link
@discardableResult
func chain(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B) -> Void ) -> SafeLink<B, Performer>

///Creates a new Link which transforms argument of type B to type C and appends the link to the execution list of this Link
@discardableResult
func chain<C>(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B) -> () -> C ) -> SafeLink<C, Performer>

///Creates a new Link which passes through argument of type B and appends the link to the execution list of this Link
@discardableResult
func chain(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B) -> () -> Void ) -> SafeLink<B, Performer>

///Creates a new Link which passes through argument of type B and appends the link to the execution list of this Link
@discardableResult
func chain(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping ((() -> Void)?) -> Void ) -> SafeLink<B, Performer>

///Creates a new Link which transforms argument of type B to type C and appends the link to the execution list of this Link
@discardableResult
func chain<C>(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (((C) -> Void)?) -> Void ) -> SafeLink<C, Performer>

///Creates a new Link which passes through argument of type B and appends the link to the execution list of this Link
@discardableResult
func chain(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B, (() -> Void)?) -> Void ) -> SafeLink<B, Performer>

///Creates a new Link which transforms argument of type B to type C and appends the link to the execution list of this Link
@discardableResult
func chain<C>(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B, ((C) -> Void)?) -> Void ) -> SafeLink<C, Performer>

///Creates a new Link which passes through argument of type B and appends the link to the execution list of this Link
@discardableResult
func chain(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B) -> ((() -> Void)?) -> Void ) -> SafeLink<B, Performer>

///Creates a new Link which passes through argument of type B and appends the link to the execution list of this Link
@discardableResult
func chain(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (@escaping () -> Void) -> Void ) -> SafeLink<B, Performer>

///Creates a new Link which transforms argument of type B to type C and appends the link to the execution list of this Link
@discardableResult
func chain<C>(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B) -> (((C) -> Void)?) -> Void ) -> SafeLink<C, Performer>

///Creates a new Link which transforms argument of type B to type C and appends the link to the execution list of this Link
@discardableResult
func chain<C>(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (@escaping (C) -> Void) -> Void ) -> SafeLink<C, Performer>

///Creates a new Link which passes through argument of type B and appends the link to the execution list of this Link
@discardableResult
func chain(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B, @escaping () -> Void) -> Void ) -> SafeLink<B, Performer>

///Creates a new Link which transforms argument of type B to type C and appends the link to the execution list of this Link
@discardableResult
func chain<C>(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B, @escaping (C) -> Void) -> Void ) -> SafeLink<C, Performer>

///Creates a new Link which passes through argument of type B and appends the link to the execution list of this Link
@discardableResult
func chain(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B) -> (@escaping () -> Void) -> Void ) -> SafeLink<B, Performer>

///Creates a new Link which transforms argument of type B to type C and appends the link to the execution list of this Link
@discardableResult
func chain<C>(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B) -> (@escaping (C) -> Void) -> Void ) -> SafeLink<C, Performer>

}

/// Generated protocol declaring erroring chain functions.
protocol ErroringChainable  {
	associatedtype B
	associatedtype Performer: AsyncBlockPerformer

///Creates a new Link which transforms argument of type B to type C and appends the link to the execution list of this Link
@discardableResult
func chain<C>(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B) throws -> C ) -> Link<C, Performer>

///Creates a new Link which passes through argument of type B and appends the link to the execution list of this Link
@discardableResult
func chain(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B) throws -> Void ) -> Link<B, Performer>

///Creates a new Link which transforms argument of type B to type C and appends the link to the execution list of this Link
@discardableResult
func chain<C>(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B) -> () throws -> C ) -> Link<C, Performer>

///Creates a new Link which passes through argument of type B and appends the link to the execution list of this Link
@discardableResult
func chain(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B) -> () throws -> Void ) -> Link<B, Performer>

///Creates a new Link which passes through argument of type B and appends the link to the execution list of this Link
@discardableResult
func chain(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (((Error?) -> Void)?) -> Void ) -> Link<B, Performer>

///Creates a new Link which passes through argument of type B and appends the link to the execution list of this Link
@discardableResult
func chain(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping ((() -> Void)?) throws -> Void ) -> Link<B, Performer>

///Creates a new Link which transforms argument of type B to type C and appends the link to the execution list of this Link
@discardableResult
func chain<C>(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (((C) -> Void)?) throws -> Void ) -> Link<C, Performer>

///Creates a new Link which passes through argument of type B and appends the link to the execution list of this Link
@discardableResult
func chain(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B, ((Error?) -> Void)?) -> Void ) -> Link<B, Performer>

///Creates a new Link which passes through argument of type B and appends the link to the execution list of this Link
@discardableResult
func chain(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B, (() -> Void)?) throws -> Void ) -> Link<B, Performer>

///Creates a new Link which transforms argument of type B to type C and appends the link to the execution list of this Link
@discardableResult
func chain<C>(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (((C?, Error?) -> Void)?) -> Void ) -> Link<C, Performer>

///Creates a new Link which transforms argument of type B to type C and appends the link to the execution list of this Link
@discardableResult
func chain<C>(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B, ((C) -> Void)?) throws -> Void ) -> Link<C, Performer>

///Creates a new Link which passes through argument of type B and appends the link to the execution list of this Link
@discardableResult
func chain(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B) -> (((Error?) -> Void)?) -> Void ) -> Link<B, Performer>

///Creates a new Link which passes through argument of type B and appends the link to the execution list of this Link
@discardableResult
func chain(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (@escaping (Error?) -> Void) -> Void ) -> Link<B, Performer>

///Creates a new Link which transforms argument of type B to type C and appends the link to the execution list of this Link
@discardableResult
func chain<C>(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B, ((C?, Error?) -> Void)?) -> Void ) -> Link<C, Performer>

///Creates a new Link which passes through argument of type B and appends the link to the execution list of this Link
@discardableResult
func chain(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B) -> ((() -> Void)?) throws -> Void ) -> Link<B, Performer>

///Creates a new Link which passes through argument of type B and appends the link to the execution list of this Link
@discardableResult
func chain(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (@escaping () -> Void) throws -> Void ) -> Link<B, Performer>

///Creates a new Link which transforms argument of type B to type C and appends the link to the execution list of this Link
@discardableResult
func chain<C>(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (@escaping (C) -> Void) throws -> Void ) -> Link<C, Performer>

///Creates a new Link which transforms argument of type B to type C and appends the link to the execution list of this Link
@discardableResult
func chain<C>(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B) -> (((C) -> Void)?) throws -> Void ) -> Link<C, Performer>

///Creates a new Link which passes through argument of type B and appends the link to the execution list of this Link
@discardableResult
func chain(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B, @escaping (Error?) -> Void) -> Void ) -> Link<B, Performer>

///Creates a new Link which transforms argument of type B to type C and appends the link to the execution list of this Link
@discardableResult
func chain<C>(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B) -> (((C?, Error?) -> Void)?) -> Void ) -> Link<C, Performer>

///Creates a new Link which passes through argument of type B and appends the link to the execution list of this Link
@discardableResult
func chain(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B, @escaping () -> Void) throws -> Void ) -> Link<B, Performer>

///Creates a new Link which transforms argument of type B to type C and appends the link to the execution list of this Link
@discardableResult
func chain<C>(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (@escaping (C?, Error?) -> Void) -> Void ) -> Link<C, Performer>

///Creates a new Link which transforms argument of type B to type C and appends the link to the execution list of this Link
@discardableResult
func chain<C>(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B, @escaping (C) -> Void) throws -> Void ) -> Link<C, Performer>

///Creates a new Link which transforms argument of type B to type C and appends the link to the execution list of this Link
@discardableResult
func chain<C>(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B, @escaping (C?, Error?) -> Void) -> Void ) -> Link<C, Performer>

///Creates a new Link which passes through argument of type B and appends the link to the execution list of this Link
@discardableResult
func chain(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B) -> (@escaping (Error?) -> Void) -> Void ) -> Link<B, Performer>

///Creates a new Link which passes through argument of type B and appends the link to the execution list of this Link
@discardableResult
func chain(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B) -> (@escaping () -> Void) throws -> Void ) -> Link<B, Performer>

///Creates a new Link which transforms argument of type B to type C and appends the link to the execution list of this Link
@discardableResult
func chain<C>(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B) -> (@escaping (C) -> Void) throws -> Void ) -> Link<C, Performer>

///Creates a new Link which transforms argument of type B to type C and appends the link to the execution list of this Link
@discardableResult
func chain<C>(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B) -> (@escaping (C?, Error?) -> Void) -> Void ) -> Link<C, Performer>

}

