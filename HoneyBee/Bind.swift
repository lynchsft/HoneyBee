
/// Generated bind (partial apply) functions.

/// bind argument to function. Type: 1 onto 1
public func bind<A,R>(_ function: @escaping (A) throws -> R, _ arg: A) -> () throws -> R {
	return { () in
		return try function(arg)
	}
}

/// bind argument to function. Type: 1 onto 1
public func bind<A,R>(_ function: @escaping (A) -> R, _ arg: A) -> () -> R {
	return { () in
		return  function(arg)
	}
}

/// bind argument to function. Type: 1 onto 2
public func bind<A,B,R>(_ function: @escaping (A,B) throws -> R, _ arg: A) -> (B) throws -> R {
	return { (b: B) in
		return try function(arg, b)
	}
}

/// bind argument to function. Type: 1 onto 2
public func bind<A,B,R>(_ function: @escaping (A,B) -> R, _ arg: A) -> (B) -> R {
	return { (b: B) in
		return  function(arg, b)
	}
}

/// bind argument to function. Type: 2 onto 2
public func bind<A,B,R>(_ function: @escaping (A,B) throws -> R, _ arg: B) -> (A) throws -> R {
	return { (a: A) in
		return try function(a, arg)
	}
}

/// bind argument to function. Type: 2 onto 2
public func bind<A,B,R>(_ function: @escaping (A,B) -> R, _ arg: B) -> (A) -> R {
	return { (a: A) in
		return  function(a, arg)
	}
}

/// bind argument to function. Type: instance curried 1 onto 2
public func bind<A,B,R>(_ function: @escaping (A)->(B) throws -> R, _ arg: B) -> (A) throws -> R {
	return { (a: A) in
		return try function(a)(arg)
	}
}

/// bind argument to function. Type: instance curried 1 onto 2
public func bind<A,B,R>(_ function: @escaping (A)->(B) -> R, _ arg: B) -> (A) -> R {
	return { (a: A) in
		return  function(a)(arg)
	}
}

/// bind argument to function. Type: 1 onto 2
public func bind<A,R>(_ function: @escaping (A,A) throws -> R, _ arg: A) -> (A) throws -> R {
	return { (a: A) in
		return try function(arg, a)
	}
}

/// bind argument to function. Type: 1 onto 2
public func bind<A,R>(_ function: @escaping (A,A) -> R, _ arg: A) -> (A) -> R {
	return { (a: A) in
		return  function(arg, a)
	}
}

/// bind argument to function. Type: 1 onto 3
public func bind<A,B,C,R>(_ function: @escaping (A,B,C) throws -> R, _ arg: A) -> (B,C) throws -> R {
	return { (b: B, c: C) in
		return try function(arg, b, c)
	}
}

/// bind argument to function. Type: 1 onto 3
public func bind<A,B,C,R>(_ function: @escaping (A,B,C) -> R, _ arg: A) -> (B,C) -> R {
	return { (b: B, c: C) in
		return  function(arg, b, c)
	}
}

/// bind argument to function. Type: 2 onto 3
public func bind<A,B,C,R>(_ function: @escaping (A,B,C) throws -> R, _ arg: B) -> (A,C) throws -> R {
	return { (a: A, c: C) in
		return try function(a, arg, c)
	}
}

/// bind argument to function. Type: 2 onto 3
public func bind<A,B,C,R>(_ function: @escaping (A,B,C) -> R, _ arg: B) -> (A,C) -> R {
	return { (a: A, c: C) in
		return  function(a, arg, c)
	}
}

/// bind argument to function. Type: instance curried 1 onto 3
public func bind<A,B,C,R>(_ function: @escaping (A)->(B,C) throws -> R, _ arg: B) -> (A,C) throws -> R {
	return { (a: A, c: C) in
		return try function(a)(arg, c)
	}
}

/// bind argument to function. Type: instance curried 1 onto 3
public func bind<A,B,C,R>(_ function: @escaping (A)->(B,C) -> R, _ arg: B) -> (A,C) -> R {
	return { (a: A, c: C) in
		return  function(a)(arg, c)
	}
}

/// bind argument to function. Type: 3 onto 3
public func bind<A,B,C,R>(_ function: @escaping (A,B,C) throws -> R, _ arg: C) -> (A,B) throws -> R {
	return { (a: A, b: B) in
		return try function(a, b, arg)
	}
}

/// bind argument to function. Type: 3 onto 3
public func bind<A,B,C,R>(_ function: @escaping (A,B,C) -> R, _ arg: C) -> (A,B) -> R {
	return { (a: A, b: B) in
		return  function(a, b, arg)
	}
}

/// bind argument to function. Type: instance curried 2 onto 3
public func bind<A,B,C,R>(_ function: @escaping (A)->(B,C) throws -> R, _ arg: C) -> (A,B) throws -> R {
	return { (a: A, b: B) in
		return try function(a)(b, arg)
	}
}

/// bind argument to function. Type: instance curried 2 onto 3
public func bind<A,B,C,R>(_ function: @escaping (A)->(B,C) -> R, _ arg: C) -> (A,B) -> R {
	return { (a: A, b: B) in
		return  function(a)(b, arg)
	}
}

/// bind argument to function. Type: 1 onto 4
public func bind<A,B,C,D,R>(_ function: @escaping (A,B,C,D) throws -> R, _ arg: A) -> (B,C,D) throws -> R {
	return { (b: B, c: C, d: D) in
		return try function(arg, b, c, d)
	}
}

/// bind argument to function. Type: 1 onto 4
public func bind<A,B,C,D,R>(_ function: @escaping (A,B,C,D) -> R, _ arg: A) -> (B,C,D) -> R {
	return { (b: B, c: C, d: D) in
		return  function(arg, b, c, d)
	}
}

/// bind argument to function. Type: 2 onto 4
public func bind<A,B,C,D,R>(_ function: @escaping (A,B,C,D) throws -> R, _ arg: B) -> (A,C,D) throws -> R {
	return { (a: A, c: C, d: D) in
		return try function(a, arg, c, d)
	}
}

/// bind argument to function. Type: 2 onto 4
public func bind<A,B,C,D,R>(_ function: @escaping (A,B,C,D) -> R, _ arg: B) -> (A,C,D) -> R {
	return { (a: A, c: C, d: D) in
		return  function(a, arg, c, d)
	}
}

/// bind argument to function. Type: instance curried 1 onto 4
public func bind<A,B,C,D,R>(_ function: @escaping (A)->(B,C,D) throws -> R, _ arg: B) -> (A,C,D) throws -> R {
	return { (a: A, c: C, d: D) in
		return try function(a)(arg, c, d)
	}
}

/// bind argument to function. Type: instance curried 1 onto 4
public func bind<A,B,C,D,R>(_ function: @escaping (A)->(B,C,D) -> R, _ arg: B) -> (A,C,D) -> R {
	return { (a: A, c: C, d: D) in
		return  function(a)(arg, c, d)
	}
}

/// bind argument to function. Type: 3 onto 4
public func bind<A,B,C,D,R>(_ function: @escaping (A,B,C,D) throws -> R, _ arg: C) -> (A,B,D) throws -> R {
	return { (a: A, b: B, d: D) in
		return try function(a, b, arg, d)
	}
}

/// bind argument to function. Type: 3 onto 4
public func bind<A,B,C,D,R>(_ function: @escaping (A,B,C,D) -> R, _ arg: C) -> (A,B,D) -> R {
	return { (a: A, b: B, d: D) in
		return  function(a, b, arg, d)
	}
}

/// bind argument to function. Type: instance curried 2 onto 4
public func bind<A,B,C,D,R>(_ function: @escaping (A)->(B,C,D) throws -> R, _ arg: C) -> (A,B,D) throws -> R {
	return { (a: A, b: B, d: D) in
		return try function(a)(b, arg, d)
	}
}

/// bind argument to function. Type: instance curried 2 onto 4
public func bind<A,B,C,D,R>(_ function: @escaping (A)->(B,C,D) -> R, _ arg: C) -> (A,B,D) -> R {
	return { (a: A, b: B, d: D) in
		return  function(a)(b, arg, d)
	}
}

/// bind argument to function. Type: 4 onto 4
public func bind<A,B,C,D,R>(_ function: @escaping (A,B,C,D) throws -> R, _ arg: D) -> (A,B,C) throws -> R {
	return { (a: A, b: B, c: C) in
		return try function(a, b, c, arg)
	}
}

/// bind argument to function. Type: 4 onto 4
public func bind<A,B,C,D,R>(_ function: @escaping (A,B,C,D) -> R, _ arg: D) -> (A,B,C) -> R {
	return { (a: A, b: B, c: C) in
		return  function(a, b, c, arg)
	}
}

/// bind argument to function. Type: instance curried 3 onto 4
public func bind<A,B,C,D,R>(_ function: @escaping (A)->(B,C,D) throws -> R, _ arg: D) -> (A,B,C) throws -> R {
	return { (a: A, b: B, c: C) in
		return try function(a)(b, c, arg)
	}
}

/// bind argument to function. Type: instance curried 3 onto 4
public func bind<A,B,C,D,R>(_ function: @escaping (A)->(B,C,D) -> R, _ arg: D) -> (A,B,C) -> R {
	return { (a: A, b: B, c: C) in
		return  function(a)(b, c, arg)
	}
}

