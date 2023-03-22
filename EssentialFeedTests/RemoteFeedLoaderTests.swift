//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Ljubisa Katana on 21.3.23..
//

import XCTest

class RemoteFeedLoader {
    let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func load() {
        client.get(from: URL(string: "https://a-url.com")!)
    }
}

class HTTPClient { // This is the abstract class, check the get method it's just a signature
    // with shared instance we're mixing responsibilities. Responsibility of invoking a method in an object and locating this object
    // So if we inject our client we have more control
//    static var shared = HTTPClient() // this is not singleton anymore it's global shared instance
    
    func get(from url: URL) {}
}

class HTTPClientSpy: HTTPClient {
    override func get(from url: URL) {
        requestURL = url
    }
    
    internal private(set) var requestURL: URL?
}

final class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        // arrange
        let client = HTTPClientSpy()
        _ = RemoteFeedLoader(client: client)
        
        XCTAssertNil(client.requestURL)
    }
    
    func test_load_requestDataFromURL() {
        // arrange
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client)
        
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
 - The smell is that we have a subclassing and we can use composition instead of the inheritance
 */
