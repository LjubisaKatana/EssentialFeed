//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Ljubisa Katana on 21.3.23..
//

import XCTest

class RemoteFeedLoader {
    
    var client: HTTPClient?
    
    func load() {
        
    }
}

class HTTPClient {
    var requestURL: URL?
}

final class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClient()
        let sut = RemoteFeedLoader()
        sut.client = client
        
        XCTAssertNil(client.requestURL)
    }
    
    func test_load_requestDataFromURL() {
        // arrange
        let client = HTTPClient()
        client.requestURL = URL(string: "test")
        let sut = RemoteFeedLoader()
        sut.client = client
        
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
 */
