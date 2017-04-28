
/// Generated protocol declaring chain functions.
protocol Chainable {
	associatedtype B

///Creates a new ProcessLink which transforms argument of type B to type C and appends the link to the execution list of this ProcessLink
@discardableResult func splice<C>(_ function: @escaping () -> C ) -> ProcessLink<B,C>

///Creates a new ProcessLink which transforms argument of type B to type C and appends the link to the execution list of this ProcessLink
@discardableResult func chain<C>(_ function: @escaping (B) -> C ) -> ProcessLink<B,C>

///Creates a new ProcessLink which transforms argument of type B to type C and appends the link to the execution list of this ProcessLink
@discardableResult func chain<C>(_ function: @escaping (B) -> () -> C ) -> ProcessLink<B,C>

///Creates a new ProcessLink which transforms argument of type B to type C and appends the link to the execution list of this ProcessLink
@discardableResult func splice<C>(_ function: @escaping () throws -> C, _ errorHandler: @escaping (Error) -> Void ) -> ProcessLink<B,C>

///Creates a new ProcessLink which transforms argument of type B to type C and appends the link to the execution list of this ProcessLink
@discardableResult func chain<C>(_ function: @escaping (B) throws -> C, _ errorHandler: @escaping (Error) -> Void ) -> ProcessLink<B,C>

///Creates a new ProcessLink which transforms argument of type B to type C and appends the link to the execution list of this ProcessLink
@discardableResult func chain<C>(_ function: @escaping (B) -> () throws -> C, _ errorHandler: @escaping (Error) -> Void ) -> ProcessLink<B,C>

///Creates a new ProcessLink which transforms argument of type B to type C and appends the link to the execution list of this ProcessLink
@discardableResult func chain<C>(_ function: @escaping (((C) -> Void)?) -> Void ) -> ProcessLink<B,C>

///Creates a new ProcessLink which transforms argument of type B to type C and appends the link to the execution list of this ProcessLink
@discardableResult func chain<C>(_ function: @escaping (B, ((C) -> Void)?) -> Void ) -> ProcessLink<B,C>

///Creates a new ProcessLink which passes through argument of type B and appends the link to the execution list of this ProcessLink
@discardableResult func chain(_ function: @escaping (((Error?) -> Void)?) -> Void, _ errorHandler: @escaping (Error) -> Void ) -> ProcessLink<B,B>

///Creates a new ProcessLink which transforms argument of type B to type C and appends the link to the execution list of this ProcessLink
@discardableResult func chain<C>(_ function: @escaping (@escaping (C) -> Void) -> Void ) -> ProcessLink<B,C>

///Creates a new ProcessLink which transforms argument of type B to type C and appends the link to the execution list of this ProcessLink
@discardableResult func chain<C>(_ function: @escaping (B) -> (((C) -> Void)?) -> Void ) -> ProcessLink<B,C>

///Creates a new ProcessLink which transforms argument of type B to type C and appends the link to the execution list of this ProcessLink
@discardableResult func chain<C>(_ function: @escaping (((C) -> Void)?) throws -> Void, _ errorHandler: @escaping (Error) -> Void ) -> ProcessLink<B,C>

///Creates a new ProcessLink which passes through argument of type B and appends the link to the execution list of this ProcessLink
@discardableResult func chain(_ function: @escaping (B, ((Error?) -> Void)?) -> Void, _ errorHandler: @escaping (Error) -> Void ) -> ProcessLink<B,B>

///Creates a new ProcessLink which transforms argument of type B to type C and appends the link to the execution list of this ProcessLink
@discardableResult func chain<C>(_ function: @escaping (((C?, Error?) -> Void)?) -> Void, _ errorHandler: @escaping (Error) -> Void ) -> ProcessLink<B,C>

///Creates a new ProcessLink which transforms argument of type B to type C and appends the link to the execution list of this ProcessLink
@discardableResult func chain<C>(_ function: @escaping (B, @escaping (C) -> Void) -> Void ) -> ProcessLink<B,C>

///Creates a new ProcessLink which transforms argument of type B to type C and appends the link to the execution list of this ProcessLink
@discardableResult func chain<C>(_ function: @escaping (B, ((C) -> Void)?) throws -> Void, _ errorHandler: @escaping (Error) -> Void ) -> ProcessLink<B,C>

///Creates a new ProcessLink which passes through argument of type B and appends the link to the execution list of this ProcessLink
@discardableResult func chain(_ function: @escaping (B) -> (((Error?) -> Void)?) -> Void, _ errorHandler: @escaping (Error) -> Void ) -> ProcessLink<B,B>

///Creates a new ProcessLink which transforms argument of type B to type C and appends the link to the execution list of this ProcessLink
@discardableResult func chain<C>(_ function: @escaping (B, ((C?, Error?) -> Void)?) -> Void, _ errorHandler: @escaping (Error) -> Void ) -> ProcessLink<B,C>

///Creates a new ProcessLink which passes through argument of type B and appends the link to the execution list of this ProcessLink
@discardableResult func chain(_ function: @escaping (@escaping (Error?) -> Void) -> Void, _ errorHandler: @escaping (Error) -> Void ) -> ProcessLink<B,B>

///Creates a new ProcessLink which transforms argument of type B to type C and appends the link to the execution list of this ProcessLink
@discardableResult func chain<C>(_ function: @escaping (B) -> (((C) -> Void)?) throws -> Void, _ errorHandler: @escaping (Error) -> Void ) -> ProcessLink<B,C>

///Creates a new ProcessLink which transforms argument of type B to type C and appends the link to the execution list of this ProcessLink
@discardableResult func chain<C>(_ function: @escaping (@escaping (C) -> Void) throws -> Void, _ errorHandler: @escaping (Error) -> Void ) -> ProcessLink<B,C>

///Creates a new ProcessLink which transforms argument of type B to type C and appends the link to the execution list of this ProcessLink
@discardableResult func chain<C>(_ function: @escaping (B) -> (@escaping (C) -> Void) -> Void ) -> ProcessLink<B,C>

///Creates a new ProcessLink which passes through argument of type B and appends the link to the execution list of this ProcessLink
@discardableResult func chain(_ function: @escaping (B, @escaping (Error?) -> Void) -> Void, _ errorHandler: @escaping (Error) -> Void ) -> ProcessLink<B,B>

///Creates a new ProcessLink which transforms argument of type B to type C and appends the link to the execution list of this ProcessLink
@discardableResult func chain<C>(_ function: @escaping (B) -> (((C?, Error?) -> Void)?) -> Void, _ errorHandler: @escaping (Error) -> Void ) -> ProcessLink<B,C>

///Creates a new ProcessLink which transforms argument of type B to type C and appends the link to the execution list of this ProcessLink
@discardableResult func chain<C>(_ function: @escaping (@escaping (C?, Error?) -> Void) -> Void, _ errorHandler: @escaping (Error) -> Void ) -> ProcessLink<B,C>

///Creates a new ProcessLink which transforms argument of type B to type C and appends the link to the execution list of this ProcessLink
@discardableResult func chain<C>(_ function: @escaping (B, @escaping (C) -> Void) throws -> Void, _ errorHandler: @escaping (Error) -> Void ) -> ProcessLink<B,C>

///Creates a new ProcessLink which passes through argument of type B and appends the link to the execution list of this ProcessLink
@discardableResult func chain(_ function: @escaping (B) -> (@escaping (Error?) -> Void) -> Void, _ errorHandler: @escaping (Error) -> Void ) -> ProcessLink<B,B>

///Creates a new ProcessLink which transforms argument of type B to type C and appends the link to the execution list of this ProcessLink
@discardableResult func chain<C>(_ function: @escaping (B, @escaping (C?, Error?) -> Void) -> Void, _ errorHandler: @escaping (Error) -> Void ) -> ProcessLink<B,C>

///Creates a new ProcessLink which transforms argument of type B to type C and appends the link to the execution list of this ProcessLink
@discardableResult func chain<C>(_ function: @escaping (B) -> (@escaping (C) -> Void) throws -> Void, _ errorHandler: @escaping (Error) -> Void ) -> ProcessLink<B,C>

///Creates a new ProcessLink which transforms argument of type B to type C and appends the link to the execution list of this ProcessLink
@discardableResult func chain<C>(_ function: @escaping (B) -> (@escaping (C?, Error?) -> Void) -> Void, _ errorHandler: @escaping (Error) -> Void ) -> ProcessLink<B,C>

}
