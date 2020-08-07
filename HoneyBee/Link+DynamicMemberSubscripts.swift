//
//  Link+DynamicMemberSubscripts.swift
//  HoneyBee
//
//  Created by Alex Lynch on 8/6/20.
//  Copyright © 2020 IAM Apps. All rights reserved.
//

import Foundation

extension Link {

    public subscript<X,Y,Z,R>(dynamicMember keyPath: KeyPath<B, TripleArgFunction<X,Y,Z,R,E>>) -> AsyncTripleArgFunction<X,Y,Z,R,E,P> {
        AsyncTripleArgFunction(action: nil, root: self.drop) { (x: Link<X, E, P>, y: Link<Y, E, P>, z: Link<Z, E, P>) -> Link<R, E, P> in
            self[dynamicMember: keyPath].chain { (triple: TripleArgFunction<X,Y,Z,R,E>, completion: @escaping FunctionWrapperCompletion<R,E>) in
                triple(x)(y)(self +> z).onResult(completion)
            }
        }
    }

    public subscript<Y,Z,R>(dynamicMember keyPath: KeyPath<B, DoubleArgFunction<Y,Z,R,E>>) -> AsyncDoubleArgFunction<Y,Z,R,E,P> {
        AsyncDoubleArgFunction(action: nil, root: self.drop) { (y: Link<Y, E, P>, z: Link<Z, E, P>) -> Link<R, E, P> in
            self[dynamicMember: keyPath].chain { (double: DoubleArgFunction<Y,Z,R,E>, completion: @escaping FunctionWrapperCompletion<R,E>) in
                double(y)(self +> z).onResult(completion)
            }
        }
    }

    public subscript<Z,R>(dynamicMember keyPath: KeyPath<B, SingleArgFunction<Z,R,E>>) -> AsyncSingleArgFunction<Z,R,E,P> {
        AsyncSingleArgFunction(action: nil, root: self.drop) { (z: Link<Z, E, P>) -> Link<R, E, P> in
            self[dynamicMember: keyPath].chain { (single: SingleArgFunction<Z,R,E>, completion: @escaping FunctionWrapperCompletion<R,E>) in
                single(self +> z).onResult(completion)
            }
        }
    }

    public subscript<R>(dynamicMember keyPath: KeyPath<B, ZeroArgFunction<R, E>>) -> AsyncZeroArgFunction<R,E,P> {
        AsyncZeroArgFunction(action: nil, root: self.drop) { () -> Link<R, E, P> in
            self[dynamicMember: keyPath].chain { (zero: ZeroArgFunction<R, E>, completion: @escaping FunctionWrapperCompletion<R,E>) in
                zero(self.drop).onResult(completion)
            }
        }
    }

    public subscript<X,Y,Z,R>(dynamicMember keyPath: KeyPath<B, BoundTripleArgFunction<X,Y,Z,R,E,P>>) -> AsyncTripleArgFunction<X,Y,Z,R,E,P> {
        AsyncTripleArgFunction(action: nil, root: self.drop) { (x: Link<X, E, P>, y: Link<Y, E, P>, z: Link<Z, E, P>) -> Link<R, E, P> in
            self[dynamicMember: keyPath].chain { (triple: BoundTripleArgFunction<X,Y,Z,R,E,P>, completion: @escaping FunctionWrapperCompletion<R,E>) in
                triple(x)(y)(self +> z).onResult(completion)
            }
        }
    }

    public subscript<Y,Z,R>(dynamicMember keyPath: KeyPath<B, BoundDoubleArgFunction<Y,Z,R,E,P>>) -> AsyncDoubleArgFunction<Y,Z,R,E,P> {
        AsyncDoubleArgFunction(action: nil, root: self.drop) { (y: Link<Y, E, P>, z: Link<Z, E, P>) -> Link<R, E, P> in
            self[dynamicMember: keyPath].chain { (double: BoundDoubleArgFunction<Y,Z,R,E,P>, completion: @escaping FunctionWrapperCompletion<R,E>) in
                double(y)(self +> z).onResult(completion)
            }
        }
    }

    public subscript<Z,R>(dynamicMember keyPath: KeyPath<B, BoundSingleArgFunction<Z,R,E,P>>) -> AsyncSingleArgFunction<Z,R,E,P> {
        AsyncSingleArgFunction(action: nil, root: self.drop) { (z: Link<Z, E, P>) -> Link<R, E, P> in
            self[dynamicMember: keyPath].chain { (single: BoundSingleArgFunction<Z,R,E,P>, completion: @escaping FunctionWrapperCompletion<R,E>) in
                single(self +> z).onResult(completion)
            }
        }
    }

    public subscript<R>(dynamicMember keyPath: KeyPath<B, BoundZeroArgFunction<R,E,P>>) -> AsyncZeroArgFunction<R,E,P> {
        AsyncZeroArgFunction(action: nil, root: self.drop) { () -> Link<R, E, P> in
            self[dynamicMember: keyPath].chain { (zero: BoundZeroArgFunction<R,E,P>, completion: @escaping FunctionWrapperCompletion<R,E>) in
                zero(self.drop).onResult(completion)
            }
        }
    }
}

extension Link {
    public subscript<X,Y,Z,R>(dynamicMember keyPath: KeyPath<B, TripleArgFunction<X,Y,Z,R,Never>>) -> AsyncTripleArgFunction<X,Y,Z,R,E,P> {
        AsyncTripleArgFunction(action: nil, root: self.drop) { (x: Link<X, E, P>, y: Link<Y, E, P>, z: Link<Z, E, P>) -> Link<R, E, P> in
            self[dynamicMember: keyPath].chain { (triple: TripleArgFunction<X,Y,Z,R,Never>, completion: @escaping FunctionWrapperCompletion<R,E>) in
                triple(x)(y)(self +> z).onResult(completion)
            }
        }
    }

    public subscript<Y,Z,R>(dynamicMember keyPath: KeyPath<B, DoubleArgFunction<Y,Z,R,Never>>) -> AsyncDoubleArgFunction<Y,Z,R,E,P> {
        AsyncDoubleArgFunction(action: nil, root: self.drop) { (y: Link<Y, E, P>, z: Link<Z, E, P>) -> Link<R, E, P> in
            self[dynamicMember: keyPath].chain { (double: DoubleArgFunction<Y,Z,R,Never>, completion: @escaping FunctionWrapperCompletion<R,E>) in
                double(y)(self +> z).onResult(completion)
            }
        }
    }

    public subscript<Z,R>(dynamicMember keyPath: KeyPath<B, SingleArgFunction<Z,R,Never>>) -> AsyncSingleArgFunction<Z,R,E,P> {
        AsyncSingleArgFunction(action: nil, root: self.drop) { (z: Link<Z, E, P>) -> Link<R, E, P> in
            self[dynamicMember: keyPath].chain { (single: SingleArgFunction<Z,R,Never>, completion: @escaping FunctionWrapperCompletion<R,E>) in
                single(self +> z).onResult(completion)
            }
        }
    }

    public subscript<R>(dynamicMember keyPath: KeyPath<B, ZeroArgFunction<R, Never>>) -> AsyncZeroArgFunction<R,E,P> {
        AsyncZeroArgFunction(action: nil, root: self.drop) { () -> Link<R, E, P> in
            self[dynamicMember: keyPath].chain { (zero: ZeroArgFunction<R, Never>, completion: @escaping FunctionWrapperCompletion<R,E>) in
                zero(self.drop).onResult(completion)
            }
        }
    }

    public subscript<X,Y,Z,R>(dynamicMember keyPath: KeyPath<B, BoundTripleArgFunction<X,Y,Z,R,Never,P>>) -> AsyncTripleArgFunction<X,Y,Z,R,E,P> {
        AsyncTripleArgFunction(action: nil, root: self.drop) { (x: Link<X, E, P>, y: Link<Y, E, P>, z: Link<Z, E, P>) -> Link<R, E, P> in
            self[dynamicMember: keyPath].chain { (triple: BoundTripleArgFunction<X,Y,Z,R,Never,P>, completion: @escaping FunctionWrapperCompletion<R,E>) in
                triple(x)(y)(self +> z).onResult(completion)
            }
        }
    }

    public subscript<Y,Z,R>(dynamicMember keyPath: KeyPath<B, BoundDoubleArgFunction<Y,Z,R,Never,P>>) -> AsyncDoubleArgFunction<Y,Z,R,E,P> {
        AsyncDoubleArgFunction(action: nil, root: self.drop) { (y: Link<Y, E, P>, z: Link<Z, E, P>) -> Link<R, E, P> in
            self[dynamicMember: keyPath].chain { (double: BoundDoubleArgFunction<Y,Z,R,Never,P>, completion: @escaping FunctionWrapperCompletion<R,E>) in
                double(y)(self +> z).onResult(completion)
            }
        }
    }

    public subscript<Z,R>(dynamicMember keyPath: KeyPath<B, BoundSingleArgFunction<Z,R,Never,P>>) -> AsyncSingleArgFunction<Z,R,E,P> {
        AsyncSingleArgFunction(action: nil, root: self.drop) { (z: Link<Z, E, P>) -> Link<R, E, P> in
            self[dynamicMember: keyPath].chain { (single: BoundSingleArgFunction<Z,R,Never,P>, completion: @escaping FunctionWrapperCompletion<R,E>) in
                single(self +> z).onResult(completion)
            }
        }
    }

    public subscript<R>(dynamicMember keyPath: KeyPath<B, BoundZeroArgFunction<R,Never,P>>) -> AsyncZeroArgFunction<R,E,P> {
        AsyncZeroArgFunction(action: nil, root: self.drop) { () -> Link<R, E, P> in
            self[dynamicMember: keyPath].chain { (zero: BoundZeroArgFunction<R,Never,P>, completion: @escaping FunctionWrapperCompletion<R,E>) in
                zero(self.drop).onResult(completion)
            }
        }
    }
}

extension Link {
    public subscript<X,Y,Z,R,OtherE: Error>(dynamicMember keyPath: KeyPath<B, TripleArgFunction<X,Y,Z,R,OtherE>>) -> AsyncTripleArgFunction<X,Y,Z,R,Error,P> {
        AsyncTripleArgFunction(action: nil, root: self.drop.expect(Error.self)) { (x: Link<X, Error, P>, y: Link<Y, Error, P>, z: Link<Z, Error, P>) -> Link<R, Error, P> in
            self[dynamicMember: keyPath].chain { (triple: TripleArgFunction<X,Y,Z,R,OtherE>, completion: @escaping FunctionWrapperCompletion<R,Error>) in
                triple(x)(y)(self +> z).onResult(completion)
            }
        }
    }

    public subscript<Y,Z,R,OtherE: Error>(dynamicMember keyPath: KeyPath<B, DoubleArgFunction<Y,Z,R,OtherE>>) -> AsyncDoubleArgFunction<Y,Z,R,Error,P> {
        AsyncDoubleArgFunction(action: nil, root: self.drop.expect(Error.self)) { (y: Link<Y, Error, P>, z: Link<Z, Error, P>) -> Link<R, Error, P> in
            self[dynamicMember: keyPath].chain { (double: DoubleArgFunction<Y,Z,R,OtherE>, completion: @escaping FunctionWrapperCompletion<R,Error>) in
                double(y)(self +> z).onResult(completion)
            }
        }
    }

    public subscript<Z,R,OtherE: Error>(dynamicMember keyPath: KeyPath<B, SingleArgFunction<Z,R,OtherE>>) -> AsyncSingleArgFunction<Z,R,Error,P> {
        AsyncSingleArgFunction(action: nil, root: self.drop.expect(Error.self)) { (z: Link<Z, Error, P>) -> Link<R, Error, P> in
            self[dynamicMember: keyPath].chain { (single: SingleArgFunction<Z,R,OtherE>, completion: @escaping FunctionWrapperCompletion<R,Error>) in
                single(self +> z).onResult(completion)
            }
        }
    }

    public subscript<R,OtherE: Error>(dynamicMember keyPath: KeyPath<B, ZeroArgFunction<R, OtherE>>) -> AsyncZeroArgFunction<R,Error,P> {
        AsyncZeroArgFunction(action: nil, root: self.drop.expect(Error.self)) { () -> Link<R, Error, P> in
            self[dynamicMember: keyPath].chain { (zero: ZeroArgFunction<R,OtherE>, completion: @escaping FunctionWrapperCompletion<R,Error>) in
                zero(self.drop.expect(Error.self)).onResult(completion)
            }
        }
    }


    public subscript<X,Y,Z,R,OtherE: Error>(dynamicMember keyPath: KeyPath<B, BoundTripleArgFunction<X,Y,Z,R,OtherE,P>>) -> AsyncTripleArgFunction<X,Y,Z,R,Error,P> {
        AsyncTripleArgFunction(action: nil, root: self.drop.expect(Error.self)) { (x: Link<X, Error, P>, y: Link<Y, Error, P>, z: Link<Z, Error, P>) -> Link<R, Error, P> in
            self[dynamicMember: keyPath].chain { (triple: BoundTripleArgFunction<X,Y,Z,R,OtherE,P>, completion: @escaping FunctionWrapperCompletion<R,Error>) in
                triple(x)(y)(self +> z).onResult(completion)
            }
        }
    }

    public subscript<Y,Z,R,OtherE: Error>(dynamicMember keyPath: KeyPath<B, BoundDoubleArgFunction<Y,Z,R,OtherE,P>>) -> AsyncDoubleArgFunction<Y,Z,R,Error,P> {
        AsyncDoubleArgFunction(action: nil, root: self.drop.expect(Error.self)) { (y: Link<Y, Error, P>, z: Link<Z, Error, P>) -> Link<R, Error, P> in
            self[dynamicMember: keyPath].chain { (double: BoundDoubleArgFunction<Y,Z,R,OtherE,P>, completion: @escaping FunctionWrapperCompletion<R,Error>) in
                double(y)(self +> z).onResult(completion)
            }
        }
    }

    public subscript<Z,R,OtherE: Error>(dynamicMember keyPath: KeyPath<B, BoundSingleArgFunction<Z,R,OtherE,P>>) -> AsyncSingleArgFunction<Z,R,Error,P> {
        AsyncSingleArgFunction(action: nil, root: self.drop.expect(Error.self)) { (z: Link<Z, Error, P>) -> Link<R, Error, P> in
            self[dynamicMember: keyPath].chain { (single: BoundSingleArgFunction<Z,R,OtherE,P>, completion: @escaping FunctionWrapperCompletion<R,Error>) in
                single(self +> z).onResult(completion)
            }
        }
    }

    public subscript<R,OtherE: Error>(dynamicMember keyPath: KeyPath<B, BoundZeroArgFunction<R,OtherE,P>>) -> AsyncZeroArgFunction<R,Error,P> {
        AsyncZeroArgFunction(action: nil, root: self.drop.expect(Error.self)) { () -> Link<R, Error, P> in
            self[dynamicMember: keyPath].chain { (zero: BoundZeroArgFunction<R,OtherE,P>, completion: @escaping FunctionWrapperCompletion<R,Error>) in
                zero(self.drop.expect(Error.self)).onResult(completion)
            }
        }
    }
}

extension Link where E == Never {

    public subscript<X,Y,Z,R,OtherE: Error>(dynamicMember keyPath: KeyPath<B, TripleArgFunction<X,Y,Z,R,OtherE>>) -> AsyncTripleArgFunction<X,Y,Z,R,OtherE,P> {
        self.expect(OtherE.self)[dynamicMember: keyPath]
    }

    public subscript<Y,Z,R,OtherE: Error>(dynamicMember keyPath: KeyPath<B, DoubleArgFunction<Y,Z,R,OtherE>>) -> AsyncDoubleArgFunction<Y,Z,R,OtherE,P> {
        self.expect(OtherE.self)[dynamicMember: keyPath]
    }

    public subscript<Z,R,OtherE: Error>(dynamicMember keyPath: KeyPath<B, SingleArgFunction<Z,R,OtherE>>) -> AsyncSingleArgFunction<Z,R,OtherE,P> {
        self.expect(OtherE.self)[dynamicMember: keyPath]
    }

    public subscript<R,OtherE: Error>(dynamicMember keyPath: KeyPath<B, ZeroArgFunction<R, OtherE>>) -> AsyncZeroArgFunction<R,OtherE,P> {
        self.expect(OtherE.self)[dynamicMember: keyPath]
    }


    public subscript<X,Y,Z,R,OtherE: Error>(dynamicMember keyPath: KeyPath<B, BoundTripleArgFunction<X,Y,Z,R,OtherE,P>>) -> AsyncTripleArgFunction<X,Y,Z,R,OtherE,P> {
        self.expect(OtherE.self)[dynamicMember: keyPath]
    }

    public subscript<Y,Z,R,OtherE: Error>(dynamicMember keyPath: KeyPath<B, BoundDoubleArgFunction<Y,Z,R,OtherE,P>>) -> AsyncDoubleArgFunction<Y,Z,R,OtherE,P> {
        self.expect(OtherE.self)[dynamicMember: keyPath]
    }

    public subscript<Z,R,OtherE: Error>(dynamicMember keyPath: KeyPath<B, BoundSingleArgFunction<Z,R,OtherE,P>>) -> AsyncSingleArgFunction<Z,R,OtherE,P> {
        self.expect(OtherE.self)[dynamicMember: keyPath]
    }

    public subscript<R,OtherE: Error>(dynamicMember keyPath: KeyPath<B, BoundZeroArgFunction<R,OtherE,P>>) -> AsyncZeroArgFunction<R,OtherE,P> {
        self.expect(OtherE.self)[dynamicMember: keyPath]
    }


    public subscript<X,Y,Z,R>(dynamicMember keyPath: KeyPath<B, TripleArgFunction<X,Y,Z,R,Never>>) -> AsyncTripleArgFunction<X,Y,Z,R,Never,P> {
        AsyncTripleArgFunction(action: nil, root: self.drop) { (x: Link<X, E, P>, y: Link<Y, E, P>, z: Link<Z, E, P>) -> Link<R, E, P> in
            self[dynamicMember: keyPath].chain { (triple: TripleArgFunction<X,Y,Z,R,Never>, completion: @escaping FunctionWrapperCompletion<R,E>) in
                triple(x)(y)(z).onResult(completion)
            }
        }
    }

    public subscript<Y,Z,R>(dynamicMember keyPath: KeyPath<B, DoubleArgFunction<Y,Z,R,Never>>) -> AsyncDoubleArgFunction<Y,Z,R,Never,P> {
        AsyncDoubleArgFunction(action: nil, root: self.drop) { (y: Link<Y, E, P>, z: Link<Z, E, P>) -> Link<R, E, P> in
            self[dynamicMember: keyPath].chain { (double: DoubleArgFunction<Y,Z,R,Never>, completion: @escaping FunctionWrapperCompletion<R,E>) in
                double(y)(z).onResult(completion)
            }
        }
    }

    public subscript<Z,R>(dynamicMember keyPath: KeyPath<B, SingleArgFunction<Z,R,Never>>) -> AsyncSingleArgFunction<Z,R,Never,P> {
        AsyncSingleArgFunction(action: nil, root: self.drop) { (z: Link<Z, E, P>) -> Link<R, E, P> in
            self[dynamicMember: keyPath].chain { (single: SingleArgFunction<Z,R,Never>, completion: @escaping FunctionWrapperCompletion<R,E>) in
                single(z).onResult(completion)
            }
        }
    }

    public subscript<R>(dynamicMember keyPath: KeyPath<B, ZeroArgFunction<R, Never>>) -> AsyncZeroArgFunction<R,Never,P> {
        AsyncZeroArgFunction(action: nil, root: self.drop) { () -> Link<R, E, P> in
            self[dynamicMember: keyPath].chain { (zero: ZeroArgFunction<R, Never>, completion: @escaping FunctionWrapperCompletion<R,E>) in
                zero(self.drop).onResult(completion)
            }
        }
    }


    public subscript<X,Y,Z,R>(dynamicMember keyPath: KeyPath<B, BoundTripleArgFunction<X,Y,Z,R,Never,P>>) -> AsyncTripleArgFunction<X,Y,Z,R,Never,P> {
        AsyncTripleArgFunction(action: nil, root: self.drop) { (x: Link<X, E, P>, y: Link<Y, E, P>, z: Link<Z, E, P>) -> Link<R, E, P> in
            self[dynamicMember: keyPath].chain { (triple: BoundTripleArgFunction<X,Y,Z,R,Never,P>, completion: @escaping FunctionWrapperCompletion<R,E>) in
                triple(x)(y)(z).onResult(completion)
            }
        }
    }

    public subscript<Y,Z,R>(dynamicMember keyPath: KeyPath<B, BoundDoubleArgFunction<Y,Z,R,Never,P>>) -> AsyncDoubleArgFunction<Y,Z,R,Never,P> {
        AsyncDoubleArgFunction(action: nil, root: self.drop) { (y: Link<Y, E, P>, z: Link<Z, E, P>) -> Link<R, E, P> in
            self[dynamicMember: keyPath].chain { (double: BoundDoubleArgFunction<Y,Z,R,Never,P>, completion: @escaping FunctionWrapperCompletion<R,E>) in
                double(y)(z).onResult(completion)
            }
        }
    }

    public subscript<Z,R>(dynamicMember keyPath: KeyPath<B, BoundSingleArgFunction<Z,R,Never,P>>) -> AsyncSingleArgFunction<Z,R,Never,P> {
        AsyncSingleArgFunction(action: nil, root: self.drop) { (z: Link<Z, E, P>) -> Link<R, E, P> in
            self[dynamicMember: keyPath].chain { (single: BoundSingleArgFunction<Z,R,Never,P>, completion: @escaping FunctionWrapperCompletion<R,E>) in
                single(z).onResult(completion)
            }
        }
    }

    public subscript<R>(dynamicMember keyPath: KeyPath<B, BoundZeroArgFunction<R,Never,P>>) -> AsyncZeroArgFunction<R,Never,P> {
        AsyncZeroArgFunction(action: nil, root: self.drop) { () -> Link<R, E, P> in
            self[dynamicMember: keyPath].chain { (zero: BoundZeroArgFunction<R,Never,P>, completion: @escaping FunctionWrapperCompletion<R,E>) in
                zero(self.drop).onResult(completion)
            }
        }
    }
}
