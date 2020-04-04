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
				.setErrorHandler(handleError)
				.chain(fetchNewMovieTitle)
				.branch { stem in
					stem.chain(fetchReviews)
						.chain(averageReviews)
					+
					stem.chain(fetchComments)
						.chain(countComments)
				}
				.setBlockPerformer(DispatchQueue.main)
				.chain(updateUI)
	}
	
	func example2() {
		func handleError(_ error: Error) {}
		func fetchNewMovieTitle(completion: (String?, Error?) -> Void) {}
		func fetchReviews(for movieTitle: String, completion: (FailableResult<[String]>) -> Void) {}
		func isNonTrivial(_ int: Int, completion: (Bool) -> Void) {}
		func updateUI(withTotalWordsInNonTrivialReviews: Int) {}
		
		HoneyBee.start(on: DispatchQueue.main)
				.setErrorHandler(handleError)
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
		
		HoneyBee.start()
				.setErrorHandler { completionBlock(nil, $0) }
				.branch { stem -> Link<(Data,Data)> in
					stem.chain(loadWebResource =<< "dataprofile.txt")
					+
					stem.chain(loadWebResource =<< "imagedata.dat")
				}
				.chain(decodeImage)
				.chain(dewarpAndCleanupImage)
				.chain{ completionBlock($0, nil) }
	}
}
