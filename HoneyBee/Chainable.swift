
/// Generated protocol declaring chain functions.
protocol Chainable {
	associatedtype B

///Creates a new ProcessLink which transforms argument of type B to type C and appends the link to the execution list of this ProcessLink
@discardableResult func chain<C>(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B) throws -> C ) -> ProcessLink<C>

///Creates a new ProcessLink which passes through argument of type B and appends the link to the execution list of this ProcessLink
@discardableResult func chain(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B) throws -> Void ) -> ProcessLink<B>

///Creates a new ProcessLink which transforms argument of type B to type C and appends the link to the execution list of this ProcessLink
@discardableResult func chain<C>(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B) -> () throws -> C ) -> ProcessLink<C>

///Creates a new ProcessLink which passes through argument of type B and appends the link to the execution list of this ProcessLink
@discardableResult func chain(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B) -> () throws -> Void ) -> ProcessLink<B>

///Creates a new ProcessLink which passes through argument of type B and appends the link to the execution list of this ProcessLink
@discardableResult func chain(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (((Error?) -> Void)?) -> Void ) -> ProcessLink<B>

///Creates a new ProcessLink which passes through argument of type B and appends the link to the execution list of this ProcessLink
@discardableResult func chain(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping ((() -> Void)?) throws -> Void ) -> ProcessLink<B>

///Creates a new ProcessLink which transforms argument of type B to type C and appends the link to the execution list of this ProcessLink
@discardableResult func chain<C>(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (((C) -> Void)?) throws -> Void ) -> ProcessLink<C>

///Creates a new ProcessLink which passes through argument of type B and appends the link to the execution list of this ProcessLink
@discardableResult func chain(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B, ((Error?) -> Void)?) -> Void ) -> ProcessLink<B>

///Creates a new ProcessLink which passes through argument of type B and appends the link to the execution list of this ProcessLink
@discardableResult func chain(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B, (() -> Void)?) throws -> Void ) -> ProcessLink<B>

///Creates a new ProcessLink which transforms argument of type B to type C and appends the link to the execution list of this ProcessLink
@discardableResult func chain<C>(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (((C?, Error?) -> Void)?) -> Void ) -> ProcessLink<C>

///Creates a new ProcessLink which transforms argument of type B to type C and appends the link to the execution list of this ProcessLink
@discardableResult func chain<C>(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B, ((C) -> Void)?) throws -> Void ) -> ProcessLink<C>

///Creates a new ProcessLink which passes through argument of type B and appends the link to the execution list of this ProcessLink
@discardableResult func chain(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (@escaping (Error?) -> Void) -> Void ) -> ProcessLink<B>

///Creates a new ProcessLink which transforms argument of type B to type C and appends the link to the execution list of this ProcessLink
@discardableResult func chain<C>(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B, ((C?, Error?) -> Void)?) -> Void ) -> ProcessLink<C>

///Creates a new ProcessLink which passes through argument of type B and appends the link to the execution list of this ProcessLink
@discardableResult func chain(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B) -> (((Error?) -> Void)?) -> Void ) -> ProcessLink<B>

///Creates a new ProcessLink which passes through argument of type B and appends the link to the execution list of this ProcessLink
@discardableResult func chain(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (@escaping () -> Void) throws -> Void ) -> ProcessLink<B>

///Creates a new ProcessLink which passes through argument of type B and appends the link to the execution list of this ProcessLink
@discardableResult func chain(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B) -> ((() -> Void)?) throws -> Void ) -> ProcessLink<B>

///Creates a new ProcessLink which transforms argument of type B to type C and appends the link to the execution list of this ProcessLink
@discardableResult func chain<C>(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (@escaping (C) -> Void) throws -> Void ) -> ProcessLink<C>

///Creates a new ProcessLink which transforms argument of type B to type C and appends the link to the execution list of this ProcessLink
@discardableResult func chain<C>(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B) -> (((C) -> Void)?) throws -> Void ) -> ProcessLink<C>

///Creates a new ProcessLink which passes through argument of type B and appends the link to the execution list of this ProcessLink
@discardableResult func chain(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B, @escaping (Error?) -> Void) -> Void ) -> ProcessLink<B>

///Creates a new ProcessLink which passes through argument of type B and appends the link to the execution list of this ProcessLink
@discardableResult func chain(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B, @escaping () -> Void) throws -> Void ) -> ProcessLink<B>

///Creates a new ProcessLink which transforms argument of type B to type C and appends the link to the execution list of this ProcessLink
@discardableResult func chain<C>(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B) -> (((C?, Error?) -> Void)?) -> Void ) -> ProcessLink<C>

///Creates a new ProcessLink which transforms argument of type B to type C and appends the link to the execution list of this ProcessLink
@discardableResult func chain<C>(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (@escaping (C?, Error?) -> Void) -> Void ) -> ProcessLink<C>

///Creates a new ProcessLink which transforms argument of type B to type C and appends the link to the execution list of this ProcessLink
@discardableResult func chain<C>(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B, @escaping (C) -> Void) throws -> Void ) -> ProcessLink<C>

///Creates a new ProcessLink which passes through argument of type B and appends the link to the execution list of this ProcessLink
@discardableResult func chain(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B) -> (@escaping (Error?) -> Void) -> Void ) -> ProcessLink<B>

///Creates a new ProcessLink which transforms argument of type B to type C and appends the link to the execution list of this ProcessLink
@discardableResult func chain<C>(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B, @escaping (C?, Error?) -> Void) -> Void ) -> ProcessLink<C>

///Creates a new ProcessLink which passes through argument of type B and appends the link to the execution list of this ProcessLink
@discardableResult func chain(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B) -> (@escaping () -> Void) throws -> Void ) -> ProcessLink<B>

///Creates a new ProcessLink which transforms argument of type B to type C and appends the link to the execution list of this ProcessLink
@discardableResult func chain<C>(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B) -> (@escaping (C) -> Void) throws -> Void ) -> ProcessLink<C>

///Creates a new ProcessLink which transforms argument of type B to type C and appends the link to the execution list of this ProcessLink
@discardableResult func chain<C>(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B) -> (@escaping (C?, Error?) -> Void) -> Void ) -> ProcessLink<C>

}
