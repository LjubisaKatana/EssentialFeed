//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Ljubisa Katana on 21.3.23..
//

import XCTest

class RemoteFeedLoader {
    
    func load() {
        HTTPClient.shared.get(from: URL(string: "https://a-url.com")!)
    }
}

class HTTPClient {
    static var shared = HTTPClient() // this is not singleton anymore it's global shared instance
    
    private init() {}
    
    func get(from url: URL) {
        requestURL = url
    }
    
    var requestURL: URL?
}

final class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        // arrange
        let client = HTTPClient.shared
        _ = RemoteFeedLoader()
        
        XCTAssertNil(client.requestURL)
    }
    
    func test_load_requestDataFromURL() {
        // arrange
        let client = HTTPClient.shared
        let sut = RemoteFeedLoader()
        
        // act
        sut.load()
        
        // assert
        XCTAssertNotNil(client.requestURL)
    }
}

/*
 - Start from minimum requirements --> init
 - Think about what I have in order to provide url but use some kind of collaborator URLSession for example (HTTP client)
 - But I don't have URL yet so, maybe need to go from other direction(different angle) -->
 - We can provide client trough constructor, property, method injection, but there is another ways
 - And we want to get rid of singleton --> global shared instance
 */
