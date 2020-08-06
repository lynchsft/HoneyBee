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
        
        func completion(_ result: Result<Image, Error>) {
            switch result {
            case .failure(let error):
                fail(on: error)
            case .success(_):
                expect1.fulfill()
            }
        }


        HoneyBee.async(completion: completion) { (async: Link<Void, Never, DefaultDispatchQueue>) in

            let dataProfile = loadWebResource("dataprofile.txt")(async)
            let imageData = loadWebResource("imagedata.dat" >> async)

            let image = decodeImage(dataProfile)(imageData)
            let cleanedImage = dewarpAndCleanupImage(image)

            return cleanedImage
        }
        
        waitForExpectations(timeout: 3)
    }
    
    func testAwaitCurry() {
        let expect1 = expectation(description: "Chain 1 should complete")
        let expect2 = expectation(description: "Chain 2 should complete")

        let hb = HoneyBee.start()

        let user = User() >> hb

        user.reset(5 >> hb)

        let result1 = User.login("Fred")(17)(hb)
        expect1.fulfill(result1)

        addTogether(1)(3.5)(hb)

        let r1 = increment(3 >> hb)
        let r2 = increment(r1)
        let r3 = increment(r2)

        let b = increment(r3)[{
            XCTAssertEqual($0, 7)
        }]
        let c = expect2.fulfill(b)


        c.onResult { (result: Result<Void, Never>) in
            failIfError(result)
        }

        waitForExpectations(timeout: 3)
    }
}
