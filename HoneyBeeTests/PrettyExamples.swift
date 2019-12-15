//
//  PrettyExamples.swift
//  HoneyBeeTests
//
//  Created by Alex Lynch on 1/7/18.
//  Copyright © 2018 IAM Apps. All rights reserved.
//

import Foundation
import HoneyBee

struct PrettyExamples {
	
	func example1() {
		func handleError(_ error: Error) {}
		func fetchNewMovieTitle(completion: (String?, Error?) -> Void) {}
		func fetchReviews(for movieTitle: String, completion: (FailableResult<[String]>) -> Void) {}
		func averageReviews(_ reviews: [String]) throws -> Int { return reviews.count }
		func fetchComments(for movieTitle: String, completion: (([String]?, Error?) -> Void)?) {}
		func countComments(_ comments: [String]) -> Int { return comments.count }
		func updateUI(withAverageReview: Int, commentsCount: Int) {}
		
		HoneyBee.start()
				.handlingErrors(with: handleError)
				.chain(fetchNewMovieTitle)
				.branch { stem in
					stem.chain(fetchReviews)
						.chain(averageReviews)
					+
					stem.chain(fetchComments)
						.chain(countComments)
				}
				.move(to: DispatchQueue.main)
				.chain(updateUI)
	}
	
	func example2() {
		func handleError(_ error: Error) {}
		func fetchNewMovieTitle(completion: (String?, Error?) -> Void) {}
		func fetchReviews(for movieTitle: String, completion: (FailableResult<[String]>) -> Void) {}
		func isNonTrivial(_ int: Int, completion: (Bool) -> Void) {}
		func updateUI(withTotalWordsInNonTrivialReviews: Int) {}
		
		HoneyBee.start(on: DispatchQueue.main)
				.handlingErrors(with:handleError)
				.chain(fetchNewMovieTitle)
				.chain(fetchReviews)
				.map { elem in // parallel map
					elem.chain(\.count)	// Keypath access
				}
				.filter { elem in // parallel filtering
					elem.chain(isNonTrivial)
				}
				.reduce { pair in // parallel "pyramid" reduce
					pair.chain(+) // operator acess
				}
				.chain(updateUI)
	}
	
	struct Image {}
	func processImageData(completionBlock: @escaping (Image?, Error?) -> Void) {
		func loadWebResource(named name: String, completion: (Data?, Error?) -> Void) {}
		func decodeImage(dataProfile: Data, image: Data) throws -> Image { return Image() }
		func dewarpAndCleanupImage(_ image: Image, completion: (Image?, Error?) -> Void) {}
		
		let a = HoneyBee.start()
				.handlingErrors { completionBlock(nil, $0) }
				
		let b = a.branch { stem -> Link<(Data,Data), DefaultDispatchQueue> in
					stem.chain(loadWebResource =<< "dataprofile.txt")
					+
					stem.chain(loadWebResource =<< "imagedata.dat")
				}
			
				b.chain(decodeImage)
				.chain(dewarpAndCleanupImage)
				.chain{ completionBlock($0, nil) }
	}
	
	func processImageDataCurried(completionBlock: @escaping (Image?, Error?) -> Void) {
        struct NaturalFunctions {
            static func loadWebResource(named name: String, completion: (Data?, Error?) -> Void) {}
            static func decodeImage(dataProfile: Data, image: Data) throws -> Image { return Image() }
            static func dewarpAndCleanupImage(_ image: Image, completion: (Image?, Error?) -> Void) {}
        }
        
        
        let loadWebResource = async1(NaturalFunctions.loadWebResource)
        let decodeImage = async2(NaturalFunctions.decodeImage)
        let dewarpAndCleanupImage = async1(NaturalFunctions.dewarpAndCleanupImage)
		
		func completionWrapper(_ result: Result<Image, ErrorContext>) {
			switch result {
			case .failure(let context):
				completionBlock(nil, context.error)
			case .success(let image):
				completionBlock(image, nil)
			}
		}
		
		HoneyBee.async(completion: completionWrapper) { async in
            let dataProfile = loadWebResource(async)(named: "dataprofile.txt")
            let imageData = loadWebResource(async)(named: "imagedata.dat")
			
            let image = decodeImage(dataProfile: dataProfile)(image: imageData)
			let cleanedImage = dewarpAndCleanupImage(image)
			
			return cleanedImage
		}
	}
}

