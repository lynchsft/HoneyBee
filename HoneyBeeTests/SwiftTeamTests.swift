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
        
        struct NaturalFunctions {
            static func loadWebResource(named name: String, completion: (Data?, Error?) -> Void) { completion(Data(), nil)}
            static func decodeImage(dataProfile: Data, image: Data) throws -> Image { return Image() }
            static func dewarpAndCleanupImage(_ image: Image, completion: (Image?, Error?) -> Void) { completion(Image(), nil)}
        }
        
        
        let loadWebResource = async1(NaturalFunctions.loadWebResource)
        let decodeImage = async2(NaturalFunctions.decodeImage)
        let dewarpAndCleanupImage = async1(NaturalFunctions.dewarpAndCleanupImage)
        
        let expect1 = expectation(description: "Async process should complete")
        
        func completion(_ result: Result<Image, ErrorContext>) {
            switch result {
            case .failure(let context):
                fail(on: context.error)
            case .success(_):
                expect1.fulfill()
            }
        }
        
        HoneyBee.async(completion: completion) { async in
        
            let dataProfile = loadWebResource(async)(named: "dataprofile.txt")
            let imageData = loadWebResource(async)(named: "imagedata.dat")
            
            let image = decodeImage(dataProfile: dataProfile)(image: imageData)
            let cleanedImage = dewarpAndCleanupImage(image)
            
            return cleanedImage
        }
        
        waitForExpectations(timeout: 3) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testAwaitCurry() {
        let expect1 = expectation(description: "Chain 1 should complete")
        let expect2 = expectation(description: "Chain 2 should complete")
        
        func handleError(_ context: ErrorContext) {
            fail(on: context.error)
        }
        
        let hb = HoneyBee.start().handlingErrors(with: handleError)
        
        let user = hb.insert(User())
        
        user.reset(5)({
            print($0)
        })
        
        User.login(hb)("Fred")(17)({ _ in
            expect1.fulfill()
        })
        
        addTogether(hb)(one: 1)(two: 3.5)
        
        let r1 = increment(hb)(3)
        let r2 = increment(val: r1)
        let r3 = increment(val: r2)({
            $0/2
        })
        
        let b = increment(fox: r3)({
            XCTAssertEqual($0, 4)
        })
        b({ _ in expect2.fulfill() })
        
        waitForExpectations(timeout: 3) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
}