
/// Generated bind (partial apply) operator functions.

precedencegroup HoneyBeeBindPrecedence {
	associativity: left
	higherThan: LogicalConjunctionPrecedence
}

infix operator =<< : HoneyBeeBindPrecedence

/// bind argument to function. Type: 1 onto 1
public func =<< <A,R>(_ function: @escaping (A)->R, _ arg: A) -> ()-> R {
	return bind(function,arg)
}

/// bind argument to function. Type: 1 onto 2
public func =<< <A,B,R>(_ function: @escaping (A,B)->R, _ arg: A) -> (B)-> R {
	return bind(function,arg)
}

/// bind argument to function. Type: 2 onto 2
public func =<< <A,B,R>(_ function: @escaping (A,B)->R, _ arg: B) -> (A)-> R {
	return bind(function,arg)
}

/// bind argument to function. Type: 1 onto 2
public func =<< <A,R>(_ function: @escaping (A,A)->R, _ arg: A) -> (A)-> R {
	return bind(function,arg)
}

/// bind argument to function. Type: 1 onto 3
public func =<< <A,B,C,R>(_ function: @escaping (A,B,C)->R, _ arg: A) -> (B,C)-> R {
	return bind(function,arg)
}

/// bind argument to function. Type: 2 onto 3
public func =<< <A,B,C,R>(_ function: @escaping (A,B,C)->R, _ arg: B) -> (A,C)-> R {
	return bind(function,arg)
}

/// bind argument to function. Type: 3 onto 3
public func =<< <A,B,C,R>(_ function: @escaping (A,B,C)->R, _ arg: C) -> (A,B)-> R {
	return bind(function,arg)
}

/// bind argument to function. Type: 1 onto 4
public func =<< <A,B,C,D,R>(_ function: @escaping (A,B,C,D)->R, _ arg: A) -> (B,C,D)-> R {
	return bind(function,arg)
}

/// bind argument to function. Type: 2 onto 4
public func =<< <A,B,C,D,R>(_ function: @escaping (A,B,C,D)->R, _ arg: B) -> (A,C,D)-> R {
	return bind(function,arg)
}

/// bind argument to function. Type: 3 onto 4
public func =<< <A,B,C,D,R>(_ function: @escaping (A,B,C,D)->R, _ arg: C) -> (A,B,D)-> R {
	return bind(function,arg)
}

/// bind argument to function. Type: 4 onto 4
public func =<< <A,B,C,D,R>(_ function: @escaping (A,B,C,D)->R, _ arg: D) -> (A,B,C)-> R {
	return bind(function,arg)
}

