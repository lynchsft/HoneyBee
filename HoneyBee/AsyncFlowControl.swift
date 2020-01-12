//
//  AsyncFlowControl.swift
//  HoneyBee
//
//  Created by Alex Lynch on 12/24/19.
//  Copyright © 2019 IAM Apps. All rights reserved.
//

import Foundation

/// Returns a link containing a bool which is the result of evaluating the equatable results of two links
/// - Parameters:
///   - lhs: a link containing an equatable
///   - rhs: a link containing an equatable
public func ==<E: Equatable, P: AsyncBlockPerformer>(lhs: Link<E,P>, rhs: Link<E,P>) -> Link<Bool, P> {
    (lhs+rhs).chain(==)
}

/// Returns a link containing a bool which is the result of evaluating the equatable result of a link and a raw equatable
/// - Parameters:
///   - lhs: a link containing an equatable
///   - rhs: an equatable
public func ==<E: Equatable, P: AsyncBlockPerformer>(lhs: Link<E,P>, rhs: E) -> Link<Bool, P> {
    lhs == lhs.insert(rhs)
}

/// Returns a link containing a bool which is the result of evaluating the equatable result of a link and a raw equatable
/// - Parameters:
///   - lhs: an equatable
///   - rhs: a link containing an equatable
public func ==<E: Equatable, P: AsyncBlockPerformer>(lhs: E, rhs: Link<E,P>) -> Link<Bool, P> {
    rhs.insert(lhs) == rhs
}


/// Returns a link containing a bool which is the result of compairing the comparable results of two links
/// - Parameters:
///   - lhs: a link containing a comparable
///   - rhs: a link containing a comparable
public func <<C: Comparable, P: AsyncBlockPerformer>(lhs: Link<C,P>, rhs: Link<C,P>) -> Link<Bool, P> {
    (lhs+rhs).chain(<)
}

/// Returns a link containing a bool which is the result of compairing the comparable result of a link and a comparable
/// - Parameters:
///   - lhs: a link containing a comparable
///   - rhs: a comparable
public func <<C: Comparable, P: AsyncBlockPerformer>(lhs: Link<C,P>, rhs: C) -> Link<Bool, P> {
    lhs < lhs.insert(rhs)
}

/// Returns a link containing a bool which is the result of compairing the comparable result of a link and a comparable
/// - Parameters:
///   - lhs: a comparable
///   - rhs: a link containing a comparable
public func <<C: Comparable, P: AsyncBlockPerformer>(lhs: C, rhs: Link<C,P>) -> Link<Bool, P> {
    rhs.insert(lhs) < rhs
}

/// Returns a link containing a bool which is the result of compairing the comparable results of two links
/// - Parameters:
///   - lhs: a link containing a comparable
///   - rhs: a link containing a comparable
public func ><C: Comparable, P: AsyncBlockPerformer>(lhs: Link<C,P>, rhs: Link<C,P>) -> Link<Bool, P> {
    (lhs+rhs).chain(>)
}

/// Returns a link containing a bool which is the result of compairing the comparable result of a link and a comparable
/// - Parameters:
///   - lhs: a link containing a comparable
///   - rhs: a comparable
public func ><C: Comparable, P: AsyncBlockPerformer>(lhs: Link<C,P>, rhs: C) -> Link<Bool, P> {
    lhs > lhs.insert(rhs)
}

/// Returns a link containing a bool which is the result of compairing the comparable result of a link and a comparable
/// - Parameters:
///   - lhs: a comparable
///   - rhs: a link containing a comparable
public func ><C: Comparable, P: AsyncBlockPerformer>(lhs: C, rhs: Link<C,P>) -> Link<Bool, P> {
    rhs.insert(lhs) > rhs
}

/// Returns a link containing a bool which is the result of compairing the comparable results of two links
/// - Parameters:
///   - lhs: a link containing a comparable
///   - rhs: a link containing a comparable
public func <=<C: Comparable, P: AsyncBlockPerformer>(lhs: Link<C,P>, rhs: Link<C,P>) -> Link<Bool, P> {
    (lhs+rhs).chain(<=)
}

/// Returns a link containing a bool which is the result of compairing the comparable result of a link and a comparable
/// - Parameters:
///   - lhs: a link containing a comparable
///   - rhs: a comparable
public func <=<C: Comparable, P: AsyncBlockPerformer>(lhs: Link<C,P>, rhs: C) -> Link<Bool, P> {
    lhs <= lhs.insert(rhs)
}

/// Returns a link containing a bool which is the result of compairing the comparable result of a link and a comparable
/// - Parameters:
///   - lhs: a comparable
///   - rhs: a link containing a comparable
public func <=<C: Comparable, P: AsyncBlockPerformer>(lhs: C, rhs: Link<C,P>) -> Link<Bool, P> {
    rhs.insert(lhs) <= rhs
}

/// Returns a link containing a bool which is the result of compairing the comparable results of two links
/// - Parameters:
///   - lhs: a link containing a comparable
///   - rhs: a link containing a comparable
public func >=<C: Comparable, P: AsyncBlockPerformer>(lhs: Link<C,P>, rhs: Link<C,P>) -> Link<Bool, P> {
    (lhs+rhs).chain(>=)
}

/// Returns a link containing a bool which is the result of compairing the comparable result of a link and a comparable
/// - Parameters:
///   - lhs: a link containing a comparable
///   - rhs: a comparable
public func >=<C: Comparable, P: AsyncBlockPerformer>(lhs: Link<C,P>, rhs: C) -> Link<Bool, P> {
    lhs <= lhs.insert(rhs)
}

/// Returns a link containing a bool which is the result of compairing the comparable result of a link and a comparable
/// - Parameters:
///   - lhs: a comparable
///   - rhs: a link containing a comparable
public func >=<C: Comparable, P: AsyncBlockPerformer>(lhs: C, rhs: Link<C,P>) -> Link<Bool, P> {
    rhs.insert(lhs) <= rhs
}

fileprivate extension Link where B == Bool {
    func `if`(_ block: @escaping ()->Void) {
        self.chain { (bool:Bool)->Void in
            if bool {
                block()
            }
        }
    }

    func unless(_ block: @escaping ()->Void) {
        self.chain { (bool:Bool)->Void in
            if !bool {
                block()
            }
        }
    }
}

/// A construct to build if/else-if/else statements predicated on a Link containing bool
public class If<P: AsyncBlockPerformer> {
    private let condition: Link<Bool,P>

    private var nextElseContext = AtomicValue<ElseContext<P>?>(value: nil)
    private var nextElseCallback: Optional<(ElseContext<P>?)->Void> = nil

    fileprivate init(condition: Link<Bool,P>, action: @escaping () -> Void) {
        self.condition = condition

        self.condition.if {
            action()
        }
        self.condition.unless {
            self.nextElseContext.access { nextElse in
                if let nextElse = nextElse {
                    nextElse.evaluate()
                } else {
                    self.nextElseCallback = { nextElse in
                        nextElse?.evaluate()
                    }
                }
            }
        }
    }

    /// Adds an async else clause to an existing if_
    /// Example usage:
    ///
    /// let hb = HoneyBee.start().handlingErrors(with: someErrorHandler)
    ///
    /// let testAPassed = testAAsyncFunc(hb) // a Link<Bool, DefaultDispatchQueue>
    /// let testBPassed = testBAsyncFunc(hb) // a Link<Bool, DefaultDispatchQueue>
    /// if_ (testAPassed) {
    ///     someAsyncNextStep(hb)(.nextStep)
    /// }.else_if (testBPassed) {
    ///     someSuboptimalStep(hb)(.disappointed)
    /// }.else {
    ///     someAsyncRemediationFunc(hb)
    /// }
    public func `else`(_ action: @escaping () -> Void) {
        self.else_if(self.condition.insert(true), action)
    }

    /// Adds an async else if clause to an existing if_
    /// Example usage:
    ///
    /// let hb = HoneyBee.start().handlingErrors(with: someErrorHandler)
    ///
    /// let testAPassed = testAAsyncFunc(hb) // a Link<Bool, DefaultDispatchQueue>
    /// let testBPassed = testBAsyncFunc(hb) // a Link<Bool, DefaultDispatchQueue>
    /// if_ (testAPassed) {
    ///     someAsyncNextStep(hb)(.nextStep)
    /// }.else_if (testBPassed) {
    ///     someSuboptimalStep(hb)(.disappointed)
    /// }.else {
    ///     someAsyncRemediationFunc(hb)
    /// }
    @discardableResult
    public func else_if(_ condition: @escaping @autoclosure () -> Link<Bool,P>, _ action: @escaping () -> Void) -> ElseContext<P> {
        let next = ElseContext<P>(trueCondition: self.condition.insert(true),
                                  conditionGenerator: condition,
                                  action: action)
        self.nextElseContext.access { elseContext in
            elseContext = next
            self.nextElseCallback?(next)
        }
        return next
    }
}

/// A construct to build if/else-if/else statements predicated on a Link containing bool
public class ElseContext<P: AsyncBlockPerformer>  {
    private let trueCondition: Link<Bool, P>
    private let conditionGenerator: ()->Link<Bool,P>
    private var storedCondition = AtomicValue<Link<Bool,P>?>(value: nil)

    private let action: () -> Void

    private var nextElseContext = AtomicValue<ElseContext<P>?>(value: nil)
    private var nextElseCallback: Optional<(ElseContext<P>?)->Void> = nil

    fileprivate init(trueCondition: Link<Bool, P>, conditionGenerator: @escaping ()->Link<Bool,P>, action: @escaping () -> Void) {
        self.trueCondition = trueCondition
        self.conditionGenerator = conditionGenerator
        self.action = action
    }

    /// Adds an async else clause to an existing .else_if
    /// Example usage:
    ///
    /// let hb = HoneyBee.start().handlingErrors(with: someErrorHandler)
    ///
    /// let testAPassed = testAAsyncFunc(hb) // a Link<Bool, DefaultDispatchQueue>
    /// let testBPassed = testBAsyncFunc(hb) // a Link<Bool, DefaultDispatchQueue>
    /// if_ (testAPassed) {
    ///     someAsyncNextStep(hb)(.nextStep)
    /// }.else_if (testBPassed) {
    ///     someSuboptimalStep(hb)(.disappointed)
    /// }.else {
    ///     someAsyncRemediationFunc(hb)
    /// }
    public func `else`(_ action: @escaping () -> Void) {
        self.else_if(self.trueCondition, action)
    }

    /// Adds an async else if clause to an existing .else_if
    /// Example usage:
    ///
    /// let hb = HoneyBee.start().handlingErrors(with: someErrorHandler)
    ///
    /// let testAPassed = testAAsyncFunc(hb) // a Link<Bool, DefaultDispatchQueue>
    /// let testBPassed = testBAsyncFunc(hb) // a Link<Bool, DefaultDispatchQueue>
    /// if_ (testAPassed) {
    ///     someAsyncNextStep(hb)(.nextStep)
    /// }.else_if (testBPassed) {
    ///     someSuboptimalStep(hb)(.disappointed)
    /// }.else {
    ///     someAsyncRemediationFunc(hb)
    /// }
    @discardableResult
    public func else_if(_ condition: @escaping @autoclosure () -> Link<Bool,P>, _ action: @escaping () -> Void) -> ElseContext<P> {
        let next = ElseContext<P>(trueCondition: self.trueCondition, conditionGenerator: condition, action: action)
        self.nextElseContext.access { elseContext in
            elseContext = next
            self.nextElseCallback?(next)
        }
        return next
    }

    fileprivate func evaluate() {
        self.conditionGenerator().if {
            self.action()
        }
        self.conditionGenerator().unless {
            self.nextElseContext.access { nextElse in
                if let nextElse = nextElse {
                    nextElse.evaluate()
                } else {
                    self.nextElseCallback = { nextElse in
                        nextElse?.evaluate()
                    }
                }
            }
        }
    }
}

/// A free-func to begin a async flow control statement
/// Example usage:
///
/// let hb = HoneyBee.start().handlingErrors(with: someErrorHandler)
///
/// let testAPassed = testAAsyncFunc(hb) // a Link<Bool, DefaultDispatchQueue>
/// let testBPassed = testBAsyncFunc(hb) // a Link<Bool, DefaultDispatchQueue>
/// if_ (testAPassed) {
///     someAsyncNextStep(hb)(.nextStep)
/// }.else_if (testBPassed) {
///     someSuboptimalStep(hb)(.disappointed)
/// }.else {
///     someAsyncRemediationFunc(hb)
/// }
@discardableResult
public func if_<P: AsyncBlockPerformer>(_ condition: Link<Bool,P>, _ action: @escaping () -> Void) -> If<P> {
    return If(condition: condition, action: action)
}
