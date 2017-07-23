
/// Generated protocol declaring chain functions.
protocol Chainable {
	associatedtype B

///Creates a new ProcessLink which transforms argument of type B to type C and appends the link to the execution list of this ProcessLink
@discardableResult func splice<C>(file: StaticString, line: UInt, _ function: @escaping () throws -> C ) -> ProcessLink<B,C>

///Creates a new ProcessLink which transforms argument of type B to type C and appends the link to the execution list of this ProcessLink
@discardableResult func chain<C>(file: StaticString, line: UInt, _ function: @escaping (B) throws -> C ) -> ProcessLink<B,C>

///Creates a new ProcessLink which transforms argument of type B to type C and appends the link to the execution list of this ProcessLink
@discardableResult func chain<C>(file: StaticString, line: UInt, _ function: @escaping (B) -> () throws -> C ) -> ProcessLink<B,C>

///Creates a new ProcessLink which passes through argument of type B and appends the link to the execution list of this ProcessLink
@discardableResult func chain(file: StaticString, line: UInt, _ function: @escaping (((Error?) -> Void)?) -> Void ) -> ProcessLink<B,B>

///Creates a new ProcessLink which transforms argument of type B to type C and appends the link to the execution list of this ProcessLink
@discardableResult func chain<C>(file: StaticString, line: UInt, _ function: @escaping (((C) -> Void)?) throws -> Void ) -> ProcessLink<B,C>

///Creates a new ProcessLink which passes through argument of type B and appends the link to the execution list of this ProcessLink
@discardableResult func chain(file: StaticString, line: UInt, _ function: @escaping (B, ((Error?) -> Void)?) -> Void ) -> ProcessLink<B,B>

///Creates a new ProcessLink which transforms argument of type B to type C and appends the link to the execution list of this ProcessLink
@discardableResult func chain<C>(file: StaticString, line: UInt, _ function: @escaping (((C?, Error?) -> Void)?) -> Void ) -> ProcessLink<B,C>

///Creates a new ProcessLink which transforms argument of type B to type C and appends the link to the execution list of this ProcessLink
@discardableResult func chain<C>(file: StaticString, line: UInt, _ function: @escaping (B, ((C) -> Void)?) throws -> Void ) -> ProcessLink<B,C>

///Creates a new ProcessLink which transforms argument of type B to type C and appends the link to the execution list of this ProcessLink
@discardableResult func chain<C>(file: StaticString, line: UInt, _ function: @escaping (B, ((C?, Error?) -> Void)?) -> Void ) -> ProcessLink<B,C>

///Creates a new ProcessLink which passes through argument of type B and appends the link to the execution list of this ProcessLink
@discardableResult func chain(file: StaticString, line: UInt, _ function: @escaping (B) -> (((Error?) -> Void)?) -> Void ) -> ProcessLink<B,B>

///Creates a new ProcessLink which passes through argument of type B and appends the link to the execution list of this ProcessLink
@discardableResult func chain(file: StaticString, line: UInt, _ function: @escaping (@escaping (Error?) -> Void) -> Void ) -> ProcessLink<B,B>

///Creates a new ProcessLink which transforms argument of type B to type C and appends the link to the execution list of this ProcessLink
@discardableResult func chain<C>(file: StaticString, line: UInt, _ function: @escaping (B) -> (((C) -> Void)?) throws -> Void ) -> ProcessLink<B,C>

///Creates a new ProcessLink which transforms argument of type B to type C and appends the link to the execution list of this ProcessLink
@discardableResult func chain<C>(file: StaticString, line: UInt, _ function: @escaping (@escaping (C) -> Void) throws -> Void ) -> ProcessLink<B,C>

///Creates a new ProcessLink which passes through argument of type B and appends the link to the execution list of this ProcessLink
@discardableResult func chain(file: StaticString, line: UInt, _ function: @escaping (B, @escaping (Error?) -> Void) -> Void ) -> ProcessLink<B,B>

///Creates a new ProcessLink which transforms argument of type B to type C and appends the link to the execution list of this ProcessLink
@discardableResult func chain<C>(file: StaticString, line: UInt, _ function: @escaping (@escaping (C?, Error?) -> Void) -> Void ) -> ProcessLink<B,C>

///Creates a new ProcessLink which transforms argument of type B to type C and appends the link to the execution list of this ProcessLink
@discardableResult func chain<C>(file: StaticString, line: UInt, _ function: @escaping (B) -> (((C?, Error?) -> Void)?) -> Void ) -> ProcessLink<B,C>

///Creates a new ProcessLink which transforms argument of type B to type C and appends the link to the execution list of this ProcessLink
@discardableResult func chain<C>(file: StaticString, line: UInt, _ function: @escaping (B, @escaping (C) -> Void) throws -> Void ) -> ProcessLink<B,C>

///Creates a new ProcessLink which passes through argument of type B and appends the link to the execution list of this ProcessLink
@discardableResult func chain(file: StaticString, line: UInt, _ function: @escaping (B) -> (@escaping (Error?) -> Void) -> Void ) -> ProcessLink<B,B>

///Creates a new ProcessLink which transforms argument of type B to type C and appends the link to the execution list of this ProcessLink
@discardableResult func chain<C>(file: StaticString, line: UInt, _ function: @escaping (B, @escaping (C?, Error?) -> Void) -> Void ) -> ProcessLink<B,C>

///Creates a new ProcessLink which transforms argument of type B to type C and appends the link to the execution list of this ProcessLink
@discardableResult func chain<C>(file: StaticString, line: UInt, _ function: @escaping (B) -> (@escaping (C) -> Void) throws -> Void ) -> ProcessLink<B,C>

///Creates a new ProcessLink which transforms argument of type B to type C and appends the link to the execution list of this ProcessLink
@discardableResult func chain<C>(file: StaticString, line: UInt, _ function: @escaping (B) -> (@escaping (C?, Error?) -> Void) -> Void ) -> ProcessLink<B,C>

}
