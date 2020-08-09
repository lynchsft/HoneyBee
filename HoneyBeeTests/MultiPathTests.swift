//
//  MultiPathTests.swift
//  HoneyBeeTests
//
//  Created by Alex Lynch on 10/22/17.
//  Copyright © 2017 IAM Apps. All rights reserved.
//

import XCTest
@testable import HoneyBee

fileprivate extension Link {
    func wait(seconds: UInt32) -> Link<B, E, P> {
        self.tunnel { (link: Link<B, E, P>) in
            link.drop.chain(sleep =<< seconds)
        }
    }
}

class MultiPathTests: XCTestCase {
	let funcContainer = TestingFunctions()
	
	override func setUp() {
		super.setUp()
		
		HoneyBee.functionOvercallResponse = .fail
		HoneyBee.functionUndercallResponse = .fail
		HoneyBee.internalFailureResponse = .fail
		HoneyBee.mismatchedConjoinResponse = .fail
	}
	
	override func tearDown() {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
		super.tearDown()
	}
	
	func testBranch() {
		let expect1 = expectation(description: "First branch should be reached")
		let expect2 = expectation(description: "Second branch should be reached")
		
        let assertEquals = async2(assertEquals(t1: t2:)) as DoubleArgFunction<Int, Int, Void, Never>
		
		let async = HoneyBee.start()
            
        let string = self.funcContainer.intToString(10)(async)
        let int = self.funcContainer.stringToInt(string)
        
        let eq1 = assertEquals(int)(10)
        expect1.fulfill(eq1)
            
        let doubleInt = self.funcContainer.multiplyInt(int)
        let eq2 = assertEquals(doubleInt)(20)
        expect2.fulfill(eq2)

        eq2.onError{ (error: NSError) in fail(on: error) }
        
		waitForExpectations(timeout: 1)
	}
	
    func testBranchWithInsert() {
        let expect1 = expectation(description: "First branch should be reached")
        let expect2 = expectation(description: "Second branch should be reached")
        
        let assertEquals = async2(assertEquals(t1: t2:)) as DoubleArgFunction<Int, Int, Void, Never>
        
        let async = HoneyBee.start()
        let asynFuncs = async.insert(self.funcContainer)
            
        let string = asynFuncs.intToString(10)
        let int = asynFuncs.stringToInt(string)
        
        let eq1 = assertEquals(int)(10)
        expect1.fulfill(eq1)
            
        let doubleInt = asynFuncs.multiplyInt(int)
        let eq2 = assertEquals(doubleInt)(20)
        expect2.fulfill(eq2)

        eq2.onError{ (error: NSError) in fail(on: error) }
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
	func testCompoundJoin() {
		let expectA = expectation(description: "Join should be reached, path A")
		
		func compoundMethod(int: Int, string: String, int2: Int) {
			expectA.fulfill()
		}
		
		let async = HoneyBee.start()
        
        async.branch { stem in
            self.funcContainer.constantInt(stem)
            +
            self.funcContainer.constantString(stem)
            +
            self.funcContainer.constantInt(stem)
        }
        .chain(compoundMethod)
        .onError(fail)
			
		waitForExpectations(timeout: 1)
	}
	
	func testJoin() {
        
		let expectA = expectation(description: "Join should be reached, path A")
		let expectB = expectation(description: "Join should be reached, path B")
		
        func assertEquals<T: Equatable>() -> DoubleArgFunction<T, T, Void, Never> {
            async2(assertEquals(t1: t2:)) as DoubleArgFunction<T, T, Void, Never>
        }
        
		let sleepTime:UInt32 = 1
		
        do {
            let async = HoneyBee.start()
            let asyncFuncs = async.insert(self.funcContainer)
            
            let int = asyncFuncs.constantInt()
            
            let wait = asyncFuncs.wait(seconds: sleepTime)
            let string = wait.constantString()
            
            let multipled = asyncFuncs.multiplyString(string)(int)
            let catted = asyncFuncs.stringCat(multipled)

            #warning("Watch this")
            assertEquals()(catted)("lamblamblamblamblamblamblamblambcat")
                .chain(expectA.fulfill)
                .onError(fail)
        }

        do {
            let async = HoneyBee.start()
            let asyncFuncs = async.insert(self.funcContainer)
                    
            let int = asyncFuncs.constantInt()
            
            let wait = asyncFuncs.wait(seconds: sleepTime)
            let string = wait.constantString()
            
            let bool = asyncFuncs.stringLengthEquals(int)(string)
            assertEquals()(bool)(false)
                .chain(expectB.fulfill)
                .onError(fail)
        }
        
		waitForExpectations(timeout: 3)
	}
	
	func testJoinLeftAndJoinRight() {
		let expectA = expectation(description: "Join should be reached, path A")
		let expectB = expectation(description: "Join should be reached, path B")
		
		let sleepTime:UInt32 = 1

        do {
            let stem = HoneyBee.start()

            let result1 = self.funcContainer.constantInt(stem)

            let wait = stem.chain(sleep =<< sleepTime).drop
            let result2 = self.funcContainer.constantString(wait)

            self.funcContainer.stringCat(result2 <+ result1)
                    .chain(assertEquals =<< "lambcat")
                    .chain(expectA.fulfill)
                    .onError(fail)
        }

        do {
            let stem = HoneyBee.start()

            let result1 = self.funcContainer.constantInt(stem)

            let wait = stem.chain(sleep =<< sleepTime).drop
            let funcContainer = self.funcContainer >> wait
            let result2 = funcContainer.constantString()

            (result1 +> result2)
                    .chain(assertEquals =<< "lamb")
                    .chain(expectB.fulfill)
                    .onError(fail)
        }

		waitForExpectations(timeout: 3)
	}
	
	func testMap() {
		var intsToExpectations:[Int:XCTestExpectation] = [:]
		
		let source = Array(0..<10)
		for int in source {
			intsToExpectations[int] = expectation(description: "Expected to map value for \(int)")
		}
		
		let finishExpectation = expectation(description: "Should reach the end of the chain")
		
		HoneyBee.start()
                .insert(source)
				.map { elem in
					elem.chain(self.funcContainer.multiplyInt)
				}
				.each { elem in
					elem.chain { (int:Int) -> Void in
						let sourceValue = int/2
						if let exepct = intsToExpectations[sourceValue]  {
							exepct.fulfill()
						} else {
							XCTFail("Map source value not found \(sourceValue)")
						}
					}
				}
				.drop
				.chain(finishExpectation.fulfill)
                .onError(fail)
		
		waitForExpectations(timeout: 3)
	}
	
	func testMapWithLimit() {
		var intsToExpectations:[Int:XCTestExpectation] = [:]
		
		let source = Array(0..<10)
		for int in source {
			intsToExpectations[int] = expectation(description: "Expected to map value for \(int)")
		}
		
		let sleepSeconds = 0.1
		
		let accessCounter: AtomicInt = 0
		accessCounter.guaranteeValueAtDeinit(0)
		
		func asynchronouslyHoldLock(iteration: Int, completion: @escaping (Result<Int, Never>)->Void) {
			if accessCounter.increment() != 1 {
				XCTFail("Countered should never != 1 at this point. Implies parallel execution. Iteration: \(iteration)")
			}
			
			DispatchQueue.global(qos: .background).async {
				sleep(UInt32(sleepSeconds))
				accessCounter.decrement()
                completion(.success(iteration))
			}
		}
		
		
		let finishExpectation = expectation(description: "Should reach the end of the chain")
		let elementExpectation = expectation(description: "Element should finish \(source.count) times")
		elementExpectation.expectedFulfillmentCount = source.count
		
		HoneyBee.start()
                .insert(source)
				.map(limit: 1) { elem in
					elem.tunnel { link in
						link.chain(asynchronouslyHoldLock).drop
							.chain(elementExpectation.fulfill)
					}
					.chain(self.funcContainer.multiplyInt)
				}
				.each { elem in
					elem.chain { (int:Int) -> Void in
						let sourceValue = int/2
						if let exepct = intsToExpectations[sourceValue]  {
							exepct.fulfill()
						} else {
							XCTFail("Map source value not found \(sourceValue)")
						}
					}
				}
				.drop
				.chain(finishExpectation.fulfill)
                .onError(fail)
		
		waitForExpectations(timeout: TimeInterval(Double(source.count) * sleepSeconds + 2.0))
	}
	
	func testMapQueue() {
		let source = Array(0...10)
		
		let finishExpectation = expectation(description: "Should reach the end of the chain")
		
		let async = HoneyBee.start(on: MainDispatchQueue())
            
        let asyncSource = async.insert(source)
            
        asyncSource.map { (elem: Link<Int, Never, MainDispatchQueue>) -> Link<Int, Never, MainDispatchQueue> in
            elem.chain{ (_:Int) -> Void in
                XCTAssert(Thread.current.isMainThread, "Not main thread")
            }
            return self.funcContainer.multiplyInt(elem)
        }
        .drop
        .chain(finishExpectation.fulfill)
        .onError(fail)
		
		waitForExpectations(timeout: 3)
	}
	
	func testFilter() {
		let source = Array(0...10)
		let result = [0,2,4,6,8,10]
		
		let finishExpectation = expectation(description: "Should reach the end of the chain")
		
		HoneyBee.start()
                .insert(source)
				.filter { elem in
					self.funcContainer.isEven(elem)
				}
				.chain{ XCTAssert($0 == result, "Filter failed. expected: \(result). Received: \($0).") }
				.chain(finishExpectation.fulfill)
                .onError(fail)
		
		waitForExpectations(timeout: 3)
	}
	
	func testFilterWithLimit() {
		let source = Array(0...10)
		let result = [0,2,4,6,8,10]
		
		let sleepSeconds = 0.1
		
		let accessCounter: AtomicInt = 0
		accessCounter.guaranteeValueAtDeinit(0)
		
		func asynchronouslyHoldLock(iteration: Int, completion: @escaping (Result<Int, Never>)->Void) {
			if accessCounter.increment() != 1 {
				XCTFail("Counter should never != 1 at this point. Implies parallel execution. Iteration: \(iteration)")
			}
			
			DispatchQueue.global(qos: .background).async {
				sleep(UInt32(sleepSeconds))
				accessCounter.decrement()
                completion(.success(iteration))
			}
		}

		
		let finishExpectation = expectation(description: "Should reach the end of the chain")
		let elementExpectation = expectation(description: "Element should finish \(source.count) times")
		elementExpectation.expectedFulfillmentCount = source.count
		
		let hb = HoneyBee.start()
        let asyncSource = source >> hb

		let filtered = asyncSource.filter(limit: 1) { elem in
					elem.tunnel { link in
						link.chain(asynchronouslyHoldLock).drop
							.chain(elementExpectation.fulfill)
						}
                        +>
						self.funcContainer.isEven(elem)
				}

        filtered.chain{ XCTAssert($0 == result, "Filter failed. expected: \(result). Received: \($0).") }
				.chain(finishExpectation.fulfill)
                .onError(fail)
		
		waitForExpectations(timeout: TimeInterval(Double(source.count) * sleepSeconds + 2.0))
	}
	
	func testEach() {
		var expectations:[XCTestExpectation] = []
		var filledExpectationCount:AtomicInt = 0
		
		for int in 0..<10 {
			expectations.append(expectation(description: "Expected to evaluate \(int)"))
		}
		
		func incrementFullfilledExpectCount() {
			filledExpectationCount.increment()
		}
		
		let finishExpectation = expectation(description: "Should reach the end of the chain")
		
		HoneyBee.start()
				.insert(expectations)
				.each { expectation in
					expectation.fulfill()
                        .chain{ _ in incrementFullfilledExpectCount() }
				}
				.drop
				.chain {
					XCTAssert(filledExpectationCount.get() == expectations.count, "All expectations should be filled by now, but was actually \(filledExpectationCount.get()) != \(expectations.count)")
				}
				.chain(finishExpectation.fulfill)
                .onError(fail)
		
		waitForExpectations(timeout: 3)
	}
	
	func testEachWithRateLimiter() {
		var expectations:[XCTestExpectation] = []
		var filledExpectationCount: AtomicInt = 0
		
		for int in 0..<10 {
			expectations.append(expectation(description: "Expected to evaluate \(int)"))
		}
		
		let finishExpectation = expectation(description: "Should reach the end of the chain")
		
		func incrementFullfilledExpectCount() {
			filledExpectationCount.increment()
		}
		
		func assertAllExpectationsFullfilled() {
			XCTAssert(filledExpectationCount.get() == expectations.count, "All expectations should be filled by now, but was actually \(filledExpectationCount) != \(expectations.count)")
		}

        do {
		HoneyBee.start()
				.insert(expectations)
				.each { elem in
					elem.limit(3) { expectation in
                        expectation.fulfill()
                            .chain(incrementFullfilledExpectCount)
					}
				}
				.drop
				.chain(assertAllExpectationsFullfilled)
				.chain(finishExpectation.fulfill)
                .onError(fail)
        }
		
		waitForExpectations(timeout: 3)
	}
	
	func testEachWithLimit() {
		let source = Array(0..<3)
		let sleepSeconds = 0.1
		
		let accessCounter: AtomicInt = 0
		accessCounter.guaranteeValueAtDeinit(0)
		
		func asynchronouslyHoldLock(iteration: Int, completion: @escaping (Result<Int, Never>)->Void) {
			if accessCounter.increment() != 1 {
				XCTFail("Counter should never be != 1 at this point. Implies parallel execution. Iteration: \(iteration)")
			}
			
			DispatchQueue.global(qos: .background).async {
				sleep(UInt32(sleepSeconds))
				accessCounter.decrement()
                completion(.success(iteration))
			}
		}
		
		let finishExpectation = expectation(description: "Should reach the end of the chain")
		let elementExpectation = expectation(description: "Element should finish \(source.count) times")
		elementExpectation.expectedFulfillmentCount = source.count
		
		HoneyBee.start()
                .insert(source)
				.each(limit: 1) { elem in
					elem.chain(asynchronouslyHoldLock).drop
						.chain(elementExpectation.fulfill)
				}
				.drop
				.chain(finishExpectation.fulfill)
                .onError(fail)
		
		waitForExpectations(timeout: TimeInterval(Double(source.count) * sleepSeconds + 2.0))
	}
	
	func testLimit() {
		let source = Array(0..<3)
		let sleepNanoSeconds:UInt32 = 100
		
		let accessCounter: AtomicInt = 0
		
		func asynchronouslyHoldLock(iteration: Int, completion: @escaping (Result<Int, Never>)->Void) {
			if accessCounter.increment() != 1 {
				XCTFail("Counter should never be != 1 at this point. Implies parallel execution. Iteration: \(iteration)")
			}
			
			DispatchQueue.global(qos: .background).async {
				usleep(sleepNanoSeconds)
				accessCounter.decrement()
                completion(.success(iteration))
			}
		}
		
		let finishExpectation = expectation(description: "Should reach the end of the chain")
		let startParalleCodeExpectation = expectation(description: "Should start parallel code")
		startParalleCodeExpectation.expectedFulfillmentCount = source.count
		let finishParalleCodeExpectation = expectation(description: "Should finish parallel code")
		finishParalleCodeExpectation.expectedFulfillmentCount = source.count
		var parallelCodeFinished = false
		let parallelCodeFinishedLock = NSLock()
		
		HoneyBee.start()
                .insert(source)
				.each() { elem in
					elem.limit(1) { link in
						link.chain(asynchronouslyHoldLock)
							.chain(asynchronouslyHoldLock)
							.chain(asynchronouslyHoldLock)
						}
						.drop
						.chain(startParalleCodeExpectation.fulfill)
						// parallelize
						.chain{ _ in usleep(sleepNanoSeconds * 3) }
						.drop
						.chain(finishParalleCodeExpectation.fulfill)
						.chain({ () -> Void in
							parallelCodeFinishedLock.lock()
							parallelCodeFinished = true
							parallelCodeFinishedLock.unlock()
						})
				}
				.drop
				.chain{ XCTAssert(parallelCodeFinished, "the parallel code should have finished before this") }
				.chain(finishExpectation.fulfill)
                .onError(fail)
		
		let sleepSeconds = (Double(sleepNanoSeconds)/1000.0)
		waitForExpectations(timeout: TimeInterval(Double(source.count) * sleepSeconds * 4.0 + 2.0))
	}
	
	func testLimitReturnChain() {
		let intermediateExpectation = expectation(description: "Should reach the intermediate end")
		let finishExpectation = expectation(description: "Should reach the end of the chain")
		
		var intermediateFullfilled = false
		
		HoneyBee.start()
                .limit(29) { link in
                    self.funcContainer.stringCat("Right" >> link).drop
						.chain(intermediateExpectation.fulfill)
						.chain{ intermediateFullfilled = true }
				}
				.chain{ XCTAssert(intermediateFullfilled, "Intermediate expectation not fullfilled") }
				.chain(finishExpectation.fulfill)
                .onError(fail)
		
		waitForExpectations(timeout: 3)
	}
	
	func testParallelReduce() {
	
		let source = Array(0...10)
		let result = 55
		
		let finishExpectation = expectation(description: "Should reach the end of the chain")

        HoneyBee.start()
                .insert(source)
                .reduce { pair in
                    pair.chain { (arg: (Int, Int)) -> Int in
                        print("\(arg.0)+\(arg.1)")
                        return arg.0+arg.1
                    }
                }
                .chain{ XCTAssert($0 == result, "Reduce failed. Expected: \(result). Received: \($0).") }
                .chain(finishExpectation.fulfill)


		waitForExpectations(timeout: 3)
	}
	
	func testMismatchedJoin() {
		let expectA = expectation(description: "Join should casuse a failure")
		
		HoneyBee.mismatchedConjoinResponse = .custom(handler: { (message) in
			expectA.fulfill()
		})
		
		let hb = HoneyBee.start()

        let int = self.funcContainer.constantInt(hb >> DispatchQueue.main)
        let string = self.funcContainer.constantString(hb >> DispatchQueue.global())

        (int+string).onError(fail)
		
		waitForExpectations(timeout: 3)
	}
}
