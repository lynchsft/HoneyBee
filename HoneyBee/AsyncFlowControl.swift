//
//  AsyncFlowControl.swift
//  HoneyBee
//
//  Created by Alex Lynch on 12/24/19.
//  Copyright © 2019 IAM Apps. All rights reserved.
//

import Foundation

public func ==<E: Equatable, P: AsyncBlockPerformer>(lhs: Link<E,P>, rhs: Link<E,P>) -> Link<Bool, P> {
    (lhs+rhs).chain(==)
}

public func ==<E: Equatable, P: AsyncBlockPerformer>(lhs: Link<E,P>, rhs: E) -> Link<Bool, P> {
    lhs == lhs.insert(rhs)
}

public func ==<E: Equatable, P: AsyncBlockPerformer>(lhs: E, rhs: Link<E,P>) -> Link<Bool, P> {
    rhs.insert(lhs) == rhs
}


public func <<C: Comparable, P: AsyncBlockPerformer>(lhs: Link<C,P>, rhs: Link<C,P>) -> Link<Bool, P> {
    (lhs+rhs).chain(<)
}

public func <<C: Comparable, P: AsyncBlockPerformer>(lhs: Link<C,P>, rhs: C) -> Link<Bool, P> {
    lhs < lhs.insert(rhs)
}

public func <<C: Comparable, P: AsyncBlockPerformer>(lhs: C, rhs: Link<C,P>) -> Link<Bool, P> {
    rhs.insert(lhs) < rhs
}


public func ><C: Comparable, P: AsyncBlockPerformer>(lhs: Link<C,P>, rhs: Link<C,P>) -> Link<Bool, P> {
    (lhs+rhs).chain(>)
}

public func ><C: Comparable, P: AsyncBlockPerformer>(lhs: Link<C,P>, rhs: C) -> Link<Bool, P> {
    lhs > lhs.insert(rhs)
}

public func ><C: Comparable, P: AsyncBlockPerformer>(lhs: C, rhs: Link<C,P>) -> Link<Bool, P> {
    rhs.insert(lhs) > rhs
}


public func <=<C: Comparable, P: AsyncBlockPerformer>(lhs: Link<C,P>, rhs: Link<C,P>) -> Link<Bool, P> {
    (lhs+rhs).chain(<=)
}

public func <=<C: Comparable, P: AsyncBlockPerformer>(lhs: Link<C,P>, rhs: C) -> Link<Bool, P> {
    lhs <= lhs.insert(rhs)
}

public func <=<C: Comparable, P: AsyncBlockPerformer>(lhs: C, rhs: Link<C,P>) -> Link<Bool, P> {
    rhs.insert(lhs) <= rhs
}


public func >=<C: Comparable, P: AsyncBlockPerformer>(lhs: Link<C,P>, rhs: Link<C,P>) -> Link<Bool, P> {
    (lhs+rhs).chain(>=)
}

public func >=<C: Comparable, P: AsyncBlockPerformer>(lhs: Link<C,P>, rhs: C) -> Link<Bool, P> {
    lhs <= lhs.insert(rhs)
}

public func >=<C: Comparable, P: AsyncBlockPerformer>(lhs: C, rhs: Link<C,P>) -> Link<Bool, P> {
    rhs.insert(lhs) <= rhs
}

extension Link where B == Bool {
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

public class If<P: AsyncBlockPerformer> {
    let condition: Link<Bool,P>
    let action: () -> Void

    var nextElseContext = AtomicValue<ElseContext<P>?>(value: nil)
    var nextElseCallback: Optional<(ElseContext<P>?)->Void> = nil

    init(condition: Link<Bool,P>, action: @escaping () -> Void) {
        self.condition = condition
        self.action = action
    }

    public func `else`(_ action: @escaping () -> Void) {
        self.else_if(self.condition.insert(true), action)
    }


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

    func evaluate() {
        self.condition.if {
            self.action()
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
}

public class ElseContext<P: AsyncBlockPerformer>  {
    let trueCondition: Link<Bool, P>
    let conditionGenerator: ()->Link<Bool,P>
    var storedCondition = AtomicValue<Link<Bool,P>?>(value: nil)

    let action: () -> Void

    var nextElseContext = AtomicValue<ElseContext<P>?>(value: nil)
    var nextElseCallback: Optional<(ElseContext<P>?)->Void> = nil

    func getCondition() -> Link<Bool, P> {
        self.storedCondition.access { condition -> Link<Bool,P> in
            if let stored = condition {
                return stored
            } else {
                let fetched = self.conditionGenerator()
                condition = fetched
                return fetched
            }
        }
    }

    init(trueCondition: Link<Bool, P>, conditionGenerator: @escaping ()->Link<Bool,P>, action: @escaping () -> Void) {
        self.trueCondition = trueCondition
        self.conditionGenerator = conditionGenerator
        self.action = action
    }

    public func `else`(_ action: @escaping () -> Void) {
        self.else_if(self.trueCondition, action)
    }

    @discardableResult
    public func else_if(_ condition: @escaping @autoclosure () -> Link<Bool,P>, _ action: @escaping () -> Void) -> ElseContext<P> {
        let next = ElseContext<P>(trueCondition: self.trueCondition, conditionGenerator: condition, action: action)
        self.nextElseContext.access { elseContext in
            elseContext = next
            self.nextElseCallback?(next)
        }
        return next
    }

    func evaluate() {
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

@discardableResult
public func if_<P: AsyncBlockPerformer>(_ condition: Link<Bool,P>, _ action: @escaping () -> Void) -> If<P> {
    let context = If(condition: condition, action: action)
    context.evaluate()
    return context
}
