//
//  SwiftTeamTests.swift
//  HoneyBeeTests
//
//  Created by Alex Lynch on 5/26/19.
//  Copyright © 2019 IAM Apps. All rights reserved.
//

import XCTest
import HoneyBee


class SwiftTeamTests: XCTestCase {
	
	private struct Image {}
	
	func testSwiftTeamsConcurencyIdeas() {
		func loadWebResource(named name: String, completion: (Data?, Error?) -> Void) { completion(Data(), nil) }
		func decodeImage(dataProfile: Data, image: Data) throws -> Image { return Image() }
		func dewarpAndCleanupImage(_ image: Image, completion: (Image?, Error?) -> Void) { completion(image, nil) }
		
		let expect1 = expectation(description: "Async process should complete")
		
		func completion(_ result: Result<Image, ErrorContext>) {
			switch result {
			case .failure(let context):
				fail(on: context.error)
			case .success(_):
				expect1.fulfill()
			}
		}
		
		HoneyBee.async(completion: completion) { a in
			
			let dataProfile = a.await(loadWebResource)(named: "dataprofile.txt")
			let imageData = a.await(loadWebResource)(named: "imagedata.dat")
			
			let image = a.await(decodeImage)(dataProfile: dataProfile)(image: imageData)
			let cleanedImage = a.await(dewarpAndCleanupImage)(image)
			
			return cleanedImage
		}
		
		waitForExpectations(timeout: 3) { error in
			if let error = error {
				XCTFail("waitForExpectationsWithTimeout errored: \(error)")
			}
		}
	}
	
	func testAwaitCurry_SEGFAULT() {
		// Every square bracket in this function wants to be a parenthesis.
		// There's a bug in the compilation of generic @dynamicCallable functions...
		// The below code is not intended to be highly semantic; it's a lexical feature test.
		let expect1 = expectation(description: "Chain 1 should complete")
		let expect2 = expectation(description: "Chain 2 should complete")
		
		func handleError(_ context: ErrorContext) {
			fail(on: context.error)
		}
		
		let a = HoneyBee.start().handlingErrors(with: handleError)
		
		a.await(User.reset)[.any][5][{
			print($0)
		}]
		//		a.await(User.reset)[.any](5) // segfault
		//		a.await(User.reset)(.any)(5) // segfault
		//		a.await(User.reset)(.any)[5] // segfault
		// Why u no like? (╯°□°）╯
		
		a.await(User.login)["Fred"][17].mute
		
		a.await(User.login)["Fred"][17]
			.await(expect1.fulfill)
		
		a.await(addTogether)(one: 1)(two: 3.5)
			.await(addTogether)(1)(3.5)
			.await(addTogether)(1)(3.5)
		
		let r1 = a.await(increment)(3)
		let r2 = a.await(increment)(val: r1)
		let r3 = a.await(increment(val:))(val: r2)({
			$0/2
		})
		a.await(increment)(fox: r3)({
			XCTAssertEqual($0, 4)
		}).await(expect2.fulfill)
		
		waitForExpectations(timeout: 3) { error in
			if let error = error {
				XCTFail("waitForExpectationsWithTimeout errored: \(error)")
			}
		}
	}
}
