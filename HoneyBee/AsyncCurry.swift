//
//  AsyncCurry.swift
//  HoneyBee
//
//  Created by Alex Lynch on 4/23/19.
//  Copyright © 2019 IAM Apps. All rights reserved.
//

import Foundation

func async3<A, B, C, R, Performer: AsyncBlockPerformer>(_ function: @escaping (A, B, C, ((R?, Error?) -> Void)?) -> Void, on: Performer.Type, file: StaticString, line: UInt) -> TripleArgFunction<A, B, C, R, Performer> {
    TripleArgFunction(action: tname(function), file: file, line: line) { (a: Link<A, Performer>, b: Link<B, Performer>, c: Link<C, Performer>) -> Link<R, Performer> in
        (a+b+c).chain(file: file, line: line, functionDescription: tname(function)) { (unwrappedArgs: (a: A, b: B, c: C), completion: @escaping (R?, Error?) -> Void) -> Void in
            function(unwrappedArgs.a, unwrappedArgs.b, unwrappedArgs.c, completion)
        }
    }
}
	
func async2<A, B, R, Performer: AsyncBlockPerformer>(_ function: @escaping (A, B, ((R?, Error?) -> Void)?) -> Void, on: Performer.Type, file: StaticString, line: UInt) -> DoubleArgFunction<A, B, R, Performer> {
    DoubleArgFunction(action: tname(function), file: file, line: line) { (a: Link<A, Performer>, b: Link<B, Performer>) -> Link<R, Performer> in
        (a+b).chain(file: file, line: line, functionDescription: tname(function)) { (unwrappedArgs: (a: A, b: B), completion: @escaping (R?, Error?) -> Void) -> Void in
            function(unwrappedArgs.a, unwrappedArgs.b, completion)
        }
    }
}

func async1<A, R, Performer: AsyncBlockPerformer>(_ function: @escaping (A, ((R?, Error?) -> Void)?) -> Void, on: Performer.Type, file: StaticString, line: UInt) -> SingleArgFunction<A, R, Performer> {
    SingleArgFunction(action: tname(function), file: file, line: line) { (a: Link<A, Performer>) -> Link<R, Performer> in
        a.chain(file: file, line: line, functionDescription: tname(function), function)
    }
}
	
func async0<R, Performer: AsyncBlockPerformer>(_ function: @escaping (((R?, Error?) -> Void)?) -> Void, on: Performer.Type, file: StaticString, line: UInt) -> ZeroArgFunction<R, Performer> {
    ZeroArgFunction(action: tname(function), file: file, line: line) { (link: Link<Void, Performer>) -> Link<R, Performer> in
        link.chain(file: file, line: line, functionDescription: tname(function), function)
    }
}
	
func async3<A, B, C, Performer: AsyncBlockPerformer>(_ function: @escaping (A, B, C, ((Error?) -> Void)?) -> Void, on: Performer.Type, file: StaticString, line: UInt) -> TripleArgFunction<A, B, C, Void, Performer> {
    TripleArgFunction(action: tname(function), file: file, line: line) { (a: Link<A, Performer>, b: Link<B, Performer>, c: Link<C, Performer>) -> Link<Void, Performer> in
        (a+b+c).chain(file: file, line: line, functionDescription: tname(function)) { (unwrappedArgs: (a: A, b: B, c: C), completion: @escaping (Error?) -> Void) -> Void in
            function(unwrappedArgs.a, unwrappedArgs.b, unwrappedArgs.c, completion)
        }.drop
    }
}
	
func async1<A, Performer: AsyncBlockPerformer>(_ function: @escaping (A, ((Error?) -> Void)?) -> Void, on: Performer.Type, file: StaticString, line: UInt) -> SingleArgFunction<A, Void, Performer> {
    SingleArgFunction(action: tname(function), file: file, line: line) { (a: Link<A, Performer>) -> Link<Void, Performer> in
        a.chain(file: file, line: line, functionDescription: tname(function), function).drop
    }
}
	
func async3<A, B, C, R, Performer: AsyncBlockPerformer>(_ function: @escaping (A, B, C, ((R) -> Void)?) throws -> Void, on: Performer.Type, file: StaticString, line: UInt) -> TripleArgFunction<A, B, C, R, Performer> {
    TripleArgFunction(action: tname(function), file: file, line: line) { (a: Link<A, Performer>, b: Link<B, Performer>, c: Link<C, Performer>) -> Link<R, Performer> in
        (a+b+c).chain(file: file, line: line, functionDescription: tname(function)) { (unwrappedArgs: (a: A, b: B, c: C), completion: @escaping (R) -> Void) -> Void in
            try function(unwrappedArgs.a,unwrappedArgs.b, unwrappedArgs.c, completion)
        }
    }
}

func async3<A, B, C, R, Performer: AsyncBlockPerformer>(_ function: @escaping (A, B, C, @escaping (R) -> Void) throws -> Void, on: Performer.Type, file: StaticString, line: UInt) -> TripleArgFunction<A, B, C, R, Performer> {
    TripleArgFunction(action: tname(function), file: file, line: line) { (a: Link<A, Performer>, b: Link<B, Performer>, c: Link<C, Performer>) -> Link<R, Performer> in
        (a+b+c).chain(file: file, line: line, functionDescription: tname(function)) { (unwrappedArgs: (a: A, b: B, c: C), completion: @escaping (R) -> Void) -> Void in
            try function(unwrappedArgs.a,unwrappedArgs.b, unwrappedArgs.c, completion)
        }
    }
}
	
func async2<A, B, R, Performer: AsyncBlockPerformer>(_ function: @escaping (A, B, ((R) -> Void)?) throws -> Void, on: Performer.Type, file: StaticString, line: UInt) -> DoubleArgFunction<A, B, R, Performer> {
    DoubleArgFunction(action: tname(function), file: file, line: line) { (a: Link<A, Performer>, b: Link<B, Performer>) -> Link<R, Performer> in
        (a+b).chain(file: file, line: line, functionDescription: tname(function)) { (unwrappedArgs: (a: A, b: B), completion: @escaping (R) -> Void) -> Void in
            try function(unwrappedArgs.a, unwrappedArgs.b, completion)
        }
    }
}
	
func async2<A, B, R, Performer: AsyncBlockPerformer>(_ function: @escaping (A, B, @escaping (R) -> Void) throws -> Void, on: Performer.Type, file: StaticString, line: UInt) ->  DoubleArgFunction<A, B, R, Performer> {
    DoubleArgFunction(action: tname(function), file: file, line: line) { (a: Link<A, Performer>, b: Link<B, Performer>) -> Link<R, Performer> in
        (a+b).chain(file: file, line: line, functionDescription: tname(function)) { (unwrappedArgs: (a: A, b: B), completion: @escaping (R) -> Void) -> Void in
            try function(unwrappedArgs.a, unwrappedArgs.b, completion)
        }
    }
}
	
func async1<A, R, Performer: AsyncBlockPerformer>(_ function: @escaping (A, ((R) -> Void)?) throws -> Void, on: Performer.Type, file: StaticString, line: UInt) -> SingleArgFunction<A, R, Performer> {
    SingleArgFunction(action: tname(function), file: file, line: line) { (a: Link<A, Performer>) -> Link<R, Performer> in
        a.chain(file: file, line: line, functionDescription: tname(function), function)
    }
}
	
func async1<A, R, Performer: AsyncBlockPerformer>(_ function: @escaping (A, @escaping (R) -> Void) throws -> Void, on: Performer.Type, file: StaticString, line: UInt) -> SingleArgFunction<A, R, Performer> {
    SingleArgFunction(action: tname(function), file: file, line: line) { (a: Link<A, Performer>) -> Link<R, Performer> in
        a.chain(file: file, line: line, functionDescription: tname(function), function)
    }
}
	
func async0<R, Performer: AsyncBlockPerformer>(_ function: @escaping (@escaping (R) -> Void) throws -> Void, on: Performer.Type, file: StaticString, line: UInt) -> ZeroArgFunction<R, Performer> {
    ZeroArgFunction(action: tname(function), file: file, line: line) { (link: Link<Void, Performer>) -> Link<R, Performer> in
        link.chain(file: file, line: line, functionDescription: tname(function), function)
    }
}
	
func async3<A, B, C, Performer: AsyncBlockPerformer>(_ function: @escaping (A, B, C, (() -> Void)?) throws -> Void, on: Performer.Type, file: StaticString, line: UInt) -> TripleArgFunction<A, B, C, Void, Performer> {
    TripleArgFunction(action: tname(function), file: file, line: line) { (a: Link<A, Performer>, b: Link<B, Performer>, c: Link<C, Performer>) -> Link<Void, Performer> in
        (a+b+c).chain(file: file, line: line, functionDescription: tname(function)) { (unwrappedArgs: (a: A, b: B, c: C), completion: @escaping () -> Void) -> Void in
            try function(unwrappedArgs.a, unwrappedArgs.b, unwrappedArgs.c, completion)
        }.drop
    }
}
	
func async3<A, B, C, Performer: AsyncBlockPerformer>(_ function: @escaping (A, B, C, @escaping () -> Void) throws -> Void, on: Performer.Type, file: StaticString, line: UInt) -> TripleArgFunction<A, B, C, Void, Performer> {
    TripleArgFunction(action: tname(function), file: file, line: line) { (a: Link<A, Performer>, b: Link<B, Performer>, c: Link<C, Performer>) -> Link<Void, Performer> in
        (a+b+c).chain(file: file, line: line, functionDescription: tname(function)) { (unwrappedArgs: (a: A, b: B, c: C), completion: @escaping () -> Void) -> Void in
            try function(unwrappedArgs.a, unwrappedArgs.b, unwrappedArgs.c, completion)
        }.drop
    }
}
	
func async2<A, B, Performer: AsyncBlockPerformer>(_ function: @escaping (A, B, (() -> Void)?) throws -> Void, on: Performer.Type, file: StaticString, line: UInt) -> DoubleArgFunction<A, B, Void, Performer> {
    DoubleArgFunction(action: tname(function), file: file, line: line) { (a: Link<A, Performer>, b: Link<B, Performer>) -> Link<Void, Performer> in
        (a+b).chain(file: file, line: line, functionDescription: tname(function)) { (unwrappedArgs: (a: A, b: B), completion: @escaping () -> Void) -> Void in
            try function(unwrappedArgs.a, unwrappedArgs.b, completion)
        }.drop
    }
}
	
func async2<A, B, Performer: AsyncBlockPerformer>(_ function: @escaping (A, B, @escaping () -> Void) throws -> Void, on: Performer.Type, file: StaticString, line: UInt) -> DoubleArgFunction<A, B, Void, Performer> {
    DoubleArgFunction(action: tname(function), file: file, line: line) { (a: Link<A, Performer>, b: Link<B, Performer>) -> Link<Void, Performer> in
        (a+b).chain(file: file, line: line, functionDescription: tname(function)) { (unwrappedArgs: (a: A, b: B), completion: @escaping () -> Void) -> Void in
            try function(unwrappedArgs.a, unwrappedArgs.b, completion)
        }.drop
    }
}
	
func async1<A, Performer: AsyncBlockPerformer>(_ function: @escaping (A, (() -> Void)?) throws -> Void, on: Performer.Type, file: StaticString, line: UInt) -> SingleArgFunction<A, Void, Performer> {
    SingleArgFunction(action: tname(function), file: file, line: line)  { (a: Link<A, Performer>) -> Link<Void, Performer> in
        a.chain(file: file, line: line, functionDescription: tname(function), function).drop
    }
}
	
func async1<A, Performer: AsyncBlockPerformer>(_ function: @escaping (A, @escaping () -> Void) throws -> Void, on: Performer.Type, file: StaticString, line: UInt) -> SingleArgFunction<A, Void, Performer> {
    SingleArgFunction(action: tname(function), file: file, line: line) { (a: Link<A, Performer>) -> Link<Void, Performer> in
        a.chain(file: file, line: line, functionDescription: tname(function), function).drop
    }
}
	
func async0<Performer: AsyncBlockPerformer>(_ function: @escaping ((() -> Void)?) throws -> Void, on: Performer.Type, file: StaticString, line: UInt) -> ZeroArgFunction<Void, Performer> {
    ZeroArgFunction(action: tname(function), file: file, line: line) { (link: Link<Void, Performer>) -> Link<Void, Performer> in
        link.chain(file: file, line: line, functionDescription: tname(function), function)
    }
}
	
func async0<Performer: AsyncBlockPerformer>(_ function: @escaping (@escaping () -> Void) throws -> Void, on: Performer.Type, file: StaticString, line: UInt) -> ZeroArgFunction<Void, Performer> {
    ZeroArgFunction(action: tname(function), file: file, line: line) { (link: Link<Void, Performer>) -> Link<Void, Performer> in
         link.chain(file: file, line: line, functionDescription: tname(function), function)
    }
}
	
public func async0<R, Performer: AsyncBlockPerformer>(_ function: @escaping () throws -> R, on: Performer.Type, file: StaticString = #file, line: UInt = #line) -> ZeroArgFunction<R, Performer>  {
    ZeroArgFunction(action: tname(function), file: file, line: line) { (link: Link<Void, Performer>) -> Link<R, Performer> in
        link.chain(file: file, line: line, functionDescription: tname(function), function)
    }
}

public func async1<A, R, Performer: AsyncBlockPerformer>(_ function: @escaping (A) throws -> R, on: Performer.Type, file: StaticString = #file, line: UInt = #line) -> SingleArgFunction<A, R, Performer> {
    SingleArgFunction(action: tname(function), file: file, line: line) { (a: Link<A, Performer>) -> Link<R, Performer> in
        a.chain(file: file, line: line, functionDescription: tname(function), function)
    }
}

public func async2<A, B, R, Performer: AsyncBlockPerformer>(_ function: @escaping (A,B) throws -> R, on: Performer.Type, file: StaticString = #file, line: UInt = #line) -> DoubleArgFunction<A, B, R, Performer> {
    DoubleArgFunction(action: tname(function), file: file, line: line) { (a: Link<A, Performer>, b: Link<B, Performer>) -> Link<R, Performer> in
        (a+b).chain(file: file, line: line, functionDescription: tname(function), function)
    }
}
	
public func async3<A, B, C, R, Performer: AsyncBlockPerformer>(_ function: @escaping (A,B,C) throws -> R, on: Performer.Type, file: StaticString = #file, line: UInt = #line) -> TripleArgFunction<A, B, C, R, Performer> {
    TripleArgFunction(action: tname(function), file: file, line: line) { (a: Link<A, Performer>, b: Link<B, Performer>, c: Link<C, Performer>) -> Link<R, Performer> in
        (a+b+c).chain(file: file, line: line, functionDescription: tname(function), function)
    }
}

public func async0<R, Performer: AsyncBlockPerformer>(_ function: @escaping (@escaping (R?, Error?) -> Void) -> Void, on: Performer.Type, file: StaticString = #file, line: UInt = #line) -> ZeroArgFunction<R, Performer> {
    ZeroArgFunction(action: tname(function), file: file, line: line) { (link: Link<Void, Performer>) -> Link<R, Performer> in
        link.chain(file: file, line: line, functionDescription: tname(function), function)
    }
}
	
public func async1<A, R, E: Error, Performer: AsyncBlockPerformer>(_ function: @escaping (A, @escaping (R?, E?) -> Void) -> Void, on: Performer.Type, file: StaticString = #file, line: UInt = #line) -> SingleArgFunction<A, R, Performer> {
    SingleArgFunction(action: tname(function), file: file, line: line) { (a: Link<A, Performer>) -> Link<R, Performer> in
        a.chain(file: file, line: line, functionDescription: tname(function), function)
    }
}
	
public func async2<A, B, R, Performer: AsyncBlockPerformer>(_ function: @escaping (A,B, @escaping (R?, Error?) -> Void) -> Void, on: Performer.Type, file: StaticString = #file, line: UInt = #line) -> DoubleArgFunction<A, B, R, Performer> {
    DoubleArgFunction(action: tname(function), file: file, line: line) { (a: Link<A, Performer>, b: Link<B, Performer>) -> Link<R, Performer> in
        (a+b).chain(file: file, line: line, functionDescription: tname(function)) { (unwrappedArgs: (a: A, b: B), completion: @escaping (R?, Error?) -> Void) -> Void in
            function(unwrappedArgs.a,unwrappedArgs.b,completion)
        }
    }
}

public func async3<A, B, C, R, Performer: AsyncBlockPerformer>(_ function: @escaping (A,B,C, @escaping (R?, Error?) -> Void) -> Void, on: Performer.Type, file: StaticString = #file, line: UInt = #line) -> TripleArgFunction<A, B, C, R, Performer> {
    TripleArgFunction(action: tname(function), file: file, line: line) { (a: Link<A, Performer>, b: Link<B, Performer>, c: Link<C, Performer>) -> Link<R, Performer> in
        (a+b+c).chain(file: file, line: line, functionDescription: tname(function)) { (unwrappedArgs: (a: A, b: B, c: C), completion: @escaping (R?, Error?) -> Void) -> Void in
            function(unwrappedArgs.a,unwrappedArgs.b,unwrappedArgs.c,completion)
        }
    }
}

public func async0<R, Performer: AsyncBlockPerformer>(_ function: @escaping (@escaping (Error?, R?) -> Void) -> Void, on: Performer.Type, file: StaticString = #file, line: UInt = #line) -> ZeroArgFunction<R, Performer> {
    ZeroArgFunction(action: tname(function), file: file, line: line) { (link: Link<Void, Performer>) -> Link<R, Performer> in
        link.chain { (completion: @escaping (R?, Error?) -> Void) -> Void in
            function() { error, r in
                completion(r, error)
            }
        }
    }
}

public func async1<A, R, Performer: AsyncBlockPerformer>(_ function: @escaping (A, @escaping (Error?, R?) -> Void) -> Void, on: Performer.Type, file: StaticString = #file, line: UInt = #line) -> SingleArgFunction<A, R, Performer> {
    SingleArgFunction(action: tname(function), file: file, line: line) { (a: Link<A, Performer>) -> Link<R, Performer> in
        a.chain(file: file, line: line, functionDescription: tname(function)) { (aa: A, completion: @escaping (R?, Error?) -> Void) in
            function(aa) { error, r in
                completion(r, error)
            }
        }
    }
}

public func async2<A, B, R, Performer: AsyncBlockPerformer>(_ function: @escaping (A,B, @escaping (Error?, R?) -> Void) -> Void, on: Performer.Type, file: StaticString = #file, line: UInt = #line) -> DoubleArgFunction<A, B, R, Performer> {
	DoubleArgFunction(action: tname(function), file: file, line: line) { (a: Link<A, Performer>, b: Link<B, Performer>) -> Link<R, Performer> in
        (a+b).chain(file: file, line: line, functionDescription: tname(function)) { ( ab:(A, B), completion: @escaping (R?, Error?) -> Void) in
            function(ab.0, ab.1) { error, r in
                completion(r, error)
            }
        }
    }
}

public func async3<A, B, C, R, Performer: AsyncBlockPerformer>(_ function: @escaping (A,B,C, @escaping (Error?, R?) -> Void) -> Void, on: Performer.Type, file: StaticString = #file, line: UInt = #line) -> TripleArgFunction<A, B, C, R, Performer> {
	TripleArgFunction(action: tname(function), file: file, line: line) { (a: Link<A, Performer>, b: Link<B, Performer>, c: Link<C, Performer>) -> Link<R, Performer> in
        (a+b+c).chain(file: file, line: line, functionDescription: tname(function)) { ( abc:(A, B, C), completion: @escaping (R?, Error?) -> Void) in
            function(abc.0, abc.1, abc.2) { error, r in
                completion(r, error)
            }
        }
    }
}

public func async<Performer: AsyncBlockPerformer>(_ function: @escaping (((Error?) -> Void)?) -> Void, on: Performer.Type, file: StaticString = #file, line: UInt = #line) -> ZeroArgFunction<Void, Performer> {
    ZeroArgFunction(action: tname(function), file: file, line: line) { (link: Link<Void, Performer>) -> Link<Void, Performer> in
        link.chain(file: file, line: line, functionDescription: tname(function), function)
    }
}

public func async<Performer: AsyncBlockPerformer>(_ function: @escaping (@escaping (Error?) -> Void) -> Void, on: Performer.Type, file: StaticString = #file, line: UInt = #line) -> ZeroArgFunction<Void, Performer> {
    ZeroArgFunction(action: tname(function), file: file, line: line) { (link: Link<Void, Performer>) -> Link<Void, Performer> in
        link.chain(file: file, line: line, functionDescription: tname(function), function)
    }
}

public func async1<A, Performer: AsyncBlockPerformer>(_ function: @escaping (A, @escaping (Error?) -> Void) -> Void, on: Performer.Type, file: StaticString = #file, line: UInt = #line) -> SingleArgFunction<A,Void, Performer> {
    SingleArgFunction(action: tname(function), file: file, line: line) { (a: Link<A, Performer>) -> Link<Void, Performer> in
        a.chain(file: file, line: line, functionDescription: tname(function), function).drop
    }
}

public func async2<A, B, Performer: AsyncBlockPerformer>(_ function: @escaping (A,B, @escaping (Error?) -> Void) -> Void, on: Performer.Type, file: StaticString = #file, line: UInt = #line) -> DoubleArgFunction<A,B,Void, Performer> {
    DoubleArgFunction(action: tname(function), file: file, line: line) { (a: Link<A, Performer>, b: Link<B, Performer>) -> Link<Void, Performer> in
        (a+b).chain(file: file, line: line, functionDescription: tname(function)) { (unwrappedArgs: (a: A, b: B), completion: @escaping (Error?) -> Void) -> Void in
            function(unwrappedArgs.a, unwrappedArgs.b, completion)
        }.drop
    }
}

public func async3<A, B, C, Performer: AsyncBlockPerformer>(_ function: @escaping (A,B,C, @escaping (Error?) -> Void) -> Void, on: Performer.Type, file: StaticString = #file, line: UInt = #line) -> TripleArgFunction<A,B,C,Void, Performer> {
    TripleArgFunction(action: tname(function), file: file, line: line) { (a: Link<A, Performer>, b: Link<B, Performer>, c: Link<C, Performer>) -> Link<Void, Performer> in
        (a+b+c).chain(file: file, line: line, functionDescription: tname(function)) { (unwrappedArgs: (a: A, b: B, c:C), completion: @escaping (Error?) -> Void) -> Void in
            function(unwrappedArgs.a, unwrappedArgs.b, unwrappedArgs.c, completion)
        }.drop
    }
}

public func async1<A,B,E: Error, Performer: AsyncBlockPerformer>(_ function: @escaping (A,B, ((E?) -> Void)?) -> Void, on: Performer.Type, file: StaticString = #file, line: UInt = #line) -> DoubleArgFunction<A,B,Void, Performer> {
    DoubleArgFunction(action: tname(function), file: file, line: line) { (a: Link<A, Performer>, b: Link<B, Performer>) -> Link<Void, Performer> in
        (a+b).chain(file: file, line: line, functionDescription: tname(function)) { (unwrappedArgs: (a: A, b: B), completion: @escaping (Error?) -> Void) -> Void in
            function(unwrappedArgs.a, unwrappedArgs.b, completion)
        }.drop
    }
}

public func async0<R,Failable, Performer: AsyncBlockPerformer>(_ function: @escaping (@escaping (Failable) -> Void) -> Void, on: Performer.Type, file: StaticString = #file, line: UInt = #line) -> ZeroArgFunction<R, Performer> where Failable : FailableResultProtocol, Failable.Wrapped == R {
    ZeroArgFunction(action: tname(function), file: file, line: line) { (link: Link<Void, Performer>) -> Link<R, Performer> in
        link.chain(file: file, line: line, functionDescription: tname(function), function)
    }
}

public func async1<A,R,Failable, Performer: AsyncBlockPerformer>(_ function: @escaping (A, @escaping (Failable) -> Void) -> Void, on: Performer.Type, file: StaticString = #file, line: UInt = #line) -> SingleArgFunction<A, R, Performer>  where Failable : FailableResultProtocol, Failable.Wrapped == R {
    SingleArgFunction(action: tname(function), file: file, line: line) { (a: Link<A, Performer>) -> Link<R, Performer> in
        a.chain(file: file, line: line, functionDescription: tname(function), function)
    }
}

public func async1<A,B,R,Failable, Performer: AsyncBlockPerformer>(_ function: @escaping (A,B, @escaping (Failable) -> Void) -> Void, on: Performer.Type, file: StaticString = #file, line: UInt = #line) -> DoubleArgFunction<A, B, R, Performer> where Failable : FailableResultProtocol, Failable.Wrapped == R {
    DoubleArgFunction(action: tname(function), file: file, line: line) { (a: Link<A, Performer>, b: Link<B, Performer>) -> Link<R, Performer> in
        (a+b).chain(file: file, line: line, functionDescription: tname(function)) { (unwrappedArgs: (a: A, b: B), completion: @escaping (Failable) -> Void) -> Void in
            function(unwrappedArgs.a, unwrappedArgs.b, completion)
        }
    }
}

public func async1<A,B,C,R,Failable, Performer: AsyncBlockPerformer>(_ function: @escaping (A,B,C, @escaping (Failable) -> Void) -> Void, on: Performer.Type, file: StaticString = #file, line: UInt = #line) -> TripleArgFunction<A, B, C, R, Performer> where Failable : FailableResultProtocol, Failable.Wrapped == R {
    TripleArgFunction(action: tname(function), file: file, line: line) { (a: Link<A, Performer>, b: Link<B, Performer>, c: Link<C, Performer>) -> Link<R, Performer> in
        (a+b+c).chain(file: file, line: line, functionDescription: tname(function)) { (unwrappedArgs: (a: A, b: B, c: C), completion: @escaping (Failable) -> Void) -> Void in
            function(unwrappedArgs.a, unwrappedArgs.b, unwrappedArgs.c, completion)
        }
    }
}

public func async0<R, Performer: AsyncBlockPerformer>(_ function: @escaping (((R) -> Void)?) throws -> Void, on: Performer.Type, file: StaticString = #file, line: UInt = #line) -> ZeroArgFunction<R, Performer> {
    ZeroArgFunction(action: tname(function), file: file, line: line) { (link: Link<Void, Performer>) -> Link<R, Performer> in
        link.chain(file: file, line: line, functionDescription: tname(function), function)
    }
}

public func async0<R, Performer: AsyncBlockPerformer>(_ function: @escaping (@escaping (R) -> Void) -> Void, on: Performer.Type, file: StaticString = #file, line: UInt = #line) -> ZeroArgFunction<R, Performer> {
    ZeroArgFunction(action: tname(function), file: file, line: line) { (link: Link<Void, Performer>) -> Link<R, Performer> in
        link.chain(file: file, line: line, functionDescription: tname(function), function)
    }
}

public func async0<Performer: AsyncBlockPerformer>(_ function: @escaping (@escaping (Error?) -> Void) -> Void, on: Performer.Type, file: StaticString = #file, line: UInt = #line) -> ZeroArgFunction<Void, Performer> {
    ZeroArgFunction(action: tname(function), file: file, line: line) { (link: Link<Void, Performer>) -> Link<Void, Performer> in
        link.chain(file: file, line: line, functionDescription: tname(function), function)
    }
}

public func async1<A, R, Performer: AsyncBlockPerformer>(_ function: @escaping (A, @escaping (R) -> Void) -> Void, on: Performer.Type, file: StaticString = #file, line: UInt = #line) -> SingleArgFunction<A, R, Performer> {
    SingleArgFunction(action: tname(function), file: file, line: line) { (a: Link<A, Performer>) -> Link<R, Performer> in
        a.chain(file: file, line: line, functionDescription: tname(function), function)
    }
}

public func async2<A, B, R, Performer: AsyncBlockPerformer>(_ function: @escaping (A,B, @escaping (R) -> Void) -> Void, on: Performer.Type, file: StaticString = #file, line: UInt = #line) -> DoubleArgFunction<A, B, R, Performer> {
    DoubleArgFunction(action: tname(function), file: file, line: line) { (a: Link<A, Performer>, b: Link<B, Performer>) -> Link<R, Performer> in
        (a+b).chain(file: file, line: line, functionDescription: tname(function)) { (unwrappedArgs: (a: A, b: B), completion: @escaping (R) -> Void) -> Void in
            function(unwrappedArgs.a,unwrappedArgs.b,completion)
        }
    }
}

public func async3<A, B, C, R, Performer: AsyncBlockPerformer>(_ function: @escaping (A,B,C, @escaping (R) -> Void) -> Void, on: Performer.Type, file: StaticString = #file, line: UInt = #line) -> TripleArgFunction<A, B, C, R, Performer> {
    TripleArgFunction(action: tname(function), file: file, line: line) { (a: Link<A, Performer>, b: Link<B, Performer>, c: Link<C, Performer>) -> Link<R, Performer> in
        (a+b+c).chain(file: file, line: line, functionDescription: tname(function)) { (unwrappedArgs: (a: A, b: B, c: C), completion: @escaping (R) -> Void) -> Void in
            function(unwrappedArgs.a,unwrappedArgs.b,unwrappedArgs.c,completion)
        }
    }
}
