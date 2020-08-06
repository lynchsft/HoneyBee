//
//  HoneyBeeTests.swift
//  HoneyBeeTests
//
//  Created by Alex Lynch on 4/11/17.
//  Copyright © 2017 IAM Apps. All rights reserved.
//

import XCTest
import HoneyBee

class SinglePathTests: XCTestCase {
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
	
	func testCompletionHandler() {
		let expect1 = expectation(description: "Chain 1 should complete")

		func completionHandler(_ result: Result<Void,NSError>) {
            switch result {
            case let .failure(error):
                fail(on: error)
            case .success(_):
                XCTAssert(!Thread.current.isMainThread)
                expect1.fulfill()
            }
		}

        HoneyBee.async(completion: completionHandler) { (hb) in
            let hb = hb >> NSError.self
            let subject = self.funcContainer >> hb

            let string = subject.intToStringA(4 >> hb)

            let intAgain = subject.stringToIntA(string)
            let multiplied = subject.multiplyIntA(intAgain)

            return XCTAssertEqual(multiplied, 8 >> hb)
        }
		
		let expect2 = expectation(description: "Simple chain 2 should complete")

		func completionHandler2(_ result: Result<Void,Error>) {
            switch result {
            case let .failure(error):
                fail(on: error)
            case .success(_):
                XCTAssert(Thread.current.isMainThread)
                expect2.fulfill()
            }
		}

        HoneyBee.async(on: MainDispatchQueue(), completion: completionHandler2) { (hb) in
            let mainQ = hb.expect(Error.self)

            let funcContainer = self.funcContainer >> mainQ

            let result = funcContainer.voidFuncA()

            return result
        }

		waitForExpectations(timeout: 3)
	}

//	func testOptionally() {
//		let expect = expectation(description: "Expect should be reached")
//		let optionalExpect = expectation(description: "Optional expect should be reached")
//
//		var optionallyCompleted = false
//
//		HoneyBee.start(on: MainDispatchQueue())
//				.insert(Optional(7))
//				.optionally { link in
//					link.chain(assertEquals =<< 7)
//						.chain(optionalExpect.fulfill)
//						.chain{ optionallyCompleted = true }
//				}
//				.drop
//				.chain{ XCTAssert(optionallyCompleted, "Optionally chain should have completed by now") }
//				.chain(expect.fulfill)
//
//		waitForExpectations(timeout: 1) { error in
//			if let error = error {
//				XCTFail("waitForExpectationsWithTimeout errored: \(error)")
//			}
//		}
//	}
//
//	func testOptionallylNegative() {
//		let expect = expectation(description: "Expect should be reached")
//		let optionalExpect = expectation(description: "Optional expect should not be reached")
//		optionalExpect.isInverted = true
//
//		HoneyBee.start(on: DispatchQueue.main)
//				.insert(Optional<Int>.none)
//				.optionally { link in
//					link.drop
//						.chain(optionalExpect.fulfill)
//				}
//				.drop
//				.chain(expect.fulfill)
//
//		waitForExpectations(timeout: 1) { error in
//			if let error = error {
//				XCTFail("waitForExpectationsWithTimeout errored: \(error)")
//			}
//		}
//	}
//
	func testMultipleCallback() {
		let overcallExpectation = expectation(description: "Should finish chain")
        overcallExpectation.expectedFulfillmentCount = 3

		HoneyBee.functionOvercallResponse = .custom(handler: { (message) in
            overcallExpectation.fulfill()
		})

        let hb = HoneyBee.start()

        hb.chain{ (_: Void, callback: (Result<Int, Error>) -> Void) in
					callback(.success(1))
					callback(.success(2))
					callback(.failure(NSError(domain: "Purposeful error", code: 3, userInfo: nil)))
					callback(.failure(NSError(domain: "Purposeful error", code: 4, userInfo: nil)))
        }
        .chain(assertEquals =<< 1)
                .onError(fail)

		waitForExpectations(timeout: 3) { _ in
            HoneyBee.functionOvercallResponse = .fail
		}
	}

	func testQueueChange() {
		let expect = expectation(description: "Simple chain should complete")

		func assertThreadIsMain(_ isMain: Bool){
			XCTAssert(Thread.isMainThread == isMain, "Thead-mainness expected to be \(isMain) but is \(Thread.isMainThread)")
		}

		let a = HoneyBee.start(on: DispatchQueue.main)
				.chain(assertThreadIsMain =<< true)
				.move(to: DispatchQueue.global())
				.chain(assertThreadIsMain =<< false)

				a.move(to: DispatchQueue.main)
				.chain(assertThreadIsMain =<< true)
				.chain(expect.fulfill)

		waitForExpectations(timeout: 1) { error in
			if let error = error {
				XCTFail("waitForExpectationsWithTimeout errored: \(error)")
			}
		}
	}

	func testTunnel() {
		let expectFinal = expectation(description: "Chain should complete")
		let expectTunnel = expectation(description: "Tunnel chain should complete")

        let hb = HoneyBee.start()
		let a = hb
				.insert(4)
				.tunnel { link in
                    (self.funcContainer >> hb).intToStringA(link)
						.chain(assertEquals =<< "4")
						.chain(expectTunnel.fulfill)
				}

               a.chain(self.funcContainer.multiplyInt)
				.chain(assertEquals =<< 8)
				.chain(expectFinal.fulfill)

		waitForExpectations(timeout: 1) { error in
			if let error = error {
				XCTFail("waitForExpectationsWithTimeout errored: \(error)")
			}
		}
	}

	func testKeyPath() {
		let expect1 = expectation(description: "KeyPath chain should complete")

		let hb = HoneyBee.start()
        let string = "catdog" >> hb
        let count = string.utf16.count

        count.chain(assertEquals =<< 6)
            .chain(expect1.fulfill)

		waitForExpectations(timeout: 1) { error in
			if let error = error {
				XCTFail("waitForExpectationsWithTimeout errored: \(error)")
			}
		}
	}

	func testGetBlockPerformer() {
		let expect1 = expectation(description: "KeyPath chain should complete")

        let hb = HoneyBee.start(on: DispatchQueue.main)
        let link1 = hb.drop

		XCTAssertEqual(HoneyBee.getBlockPerformer(of: link1), DispatchQueue.main)

		let link2 = link1.move(to: DispatchQueue.global())

		XCTAssertEqual(HoneyBee.getBlockPerformer(of: link1), DispatchQueue.main)
		XCTAssertEqual(HoneyBee.getBlockPerformer(of: link2), DispatchQueue.global())

        let string = "catdog" >> hb
        let count = string.utf16.count

		count.chain(assertEquals =<< 6)
             .chain(expect1.fulfill)

		waitForExpectations(timeout: 1) { error in
			if let error = error {
				XCTFail("waitForExpectationsWithTimeout errored: \(error)")
			}
		}
	}

}
