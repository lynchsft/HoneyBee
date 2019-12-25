//
//  MergeSortTest.swift
//  HoneyBeeTests
//
//  Created by Alex Lynch on 12/24/19.
//  Copyright © 2019 IAM Apps. All rights reserved.
//

import XCTest
import HoneyBee

class MergeSortTest: XCTestCase {


    private static var randomInts: [Int]!

    override class func setUp() {
       randomInts = (1...500_000).map { _ in Int.random(in: 1...100_000) }
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    ///https://github.com/raywenderlich/swift-algorithm-club/tree/master/Merge%20Sort
    func mergeSort0(_ array: [Int]) -> [Int] {
        guard array.count > 1 else { return array }    // 1

        let middleIndex = array.count / 2              // 2

        let leftArray = mergeSort0(Array(array[0..<middleIndex]))             // 3

        let rightArray = mergeSort0(Array(array[middleIndex..<array.count]))  // 4

        return merge(leftPile: leftArray, rightPile: rightArray)             // 5
    }

    ///https://github.com/raywenderlich/swift-algorithm-club/tree/master/Merge%20Sort
    func merge(leftPile: [Int], rightPile: [Int]) -> [Int] {
        // 1
        var leftIndex = 0
        var rightIndex = 0

        // 2
        var orderedPile = [Int]()
        orderedPile.reserveCapacity(leftPile.count + rightPile.count)

        // 3
        while leftIndex < leftPile.count && rightIndex < rightPile.count {
            if leftPile[leftIndex] < rightPile[rightIndex] {
                orderedPile.append(leftPile[leftIndex])
                leftIndex += 1
            } else if leftPile[leftIndex] > rightPile[rightIndex] {
                orderedPile.append(rightPile[rightIndex])
                rightIndex += 1
            } else {
                orderedPile.append(leftPile[leftIndex])
                leftIndex += 1
                orderedPile.append(rightPile[rightIndex])
                rightIndex += 1
            }
        }

        // 4
        while leftIndex < leftPile.count {
            orderedPile.append(leftPile[leftIndex])
            leftIndex += 1
        }

        while rightIndex < rightPile.count {
            orderedPile.append(rightPile[rightIndex])
            rightIndex += 1
        }

        return orderedPile
    }

    func testHoneyBee0() {
        let sorted = mergeSort0(MergeSortTest.randomInts)
        XCTAssertEqual(sorted.count, MergeSortTest.randomInts.count)
    }

    private lazy var mergeSort3 = async1(self.mergeSort3) as SingleArgFunction<[Int],[Int]>
    ///https://github.com/raywenderlich/swift-algorithm-club/tree/master/Merge%20Sort
    func mergeSort3(_ array: [Int], completion: @escaping ([Int])->Void) {
        guard array.count > 200 else {
            completion(array.sorted()) // 1
            return
        }

        let middleIndex = array.count / 2              // 2

        let hb = HoneyBee.start().handlingErrors(with: fail)

        let leftArray = mergeSort3(hb)(Array(array[0..<middleIndex]))             // 3

        let rightArray = mergeSort3(hb)(Array(array[middleIndex..<array.count]))  // 4

        let mergedArray = merge(hb)(leftPile: leftArray)(rightPile: rightArray)

        async1(completion)(mergedArray)
    }

    private lazy var merge = async2(self.merge)

    func testHoneyBee3() {
        let expect = self.expectation(description: "Completion")

        self.mergeSort3(MergeSortTest.randomInts) { sorted in
            XCTAssertEqual(sorted.count, MergeSortTest.randomInts.count)
            expect.fulfill()
        }

        self.waitForExpectations(timeout: 10)
    }

}

