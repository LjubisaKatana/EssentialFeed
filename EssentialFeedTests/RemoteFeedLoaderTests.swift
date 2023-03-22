//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Ljubisa Katana on 21.3.23..
//

import XCTest

class RemoteFeedLoader {
    let url: URL
    let client: HTTPClient
    
    init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    func load() {
        client.get(from: url)
    }
}

protocol HTTPClient {
    func get(from url: URL)
}

class HTTPClientSpy: HTTPClient {
    func get(from url: URL) {
        requestURL = url
    }
    
    internal private(set) var requestURL: URL?
}

final class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        // arrange
        let url = URL(string: "https://a-url.com")!
        let client = HTTPClientSpy()
        _ = RemoteFeedLoader(url: url, client: client)
        
        XCTAssertNil(client.requestURL)
    }
    
    func test_load_requestDataFromURL() {
        // arrange
        let url = URL(string: "https://a-given-url.com")!
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        
        // act
        sut.load()
        
        // assert
        XCTAssertEqual(client.requestURL, url)
    }
}

/*
 - Start from minimum requirements --> init
 - Think about what I have in order to provide url but use some kind of collaborator URLSession for example (HTTP client)
 - But I don't have URL yet so, maybe need to go from other direction(different angle) -->
 - We can provide client trough constructor, property, method injection, but there is another ways
 - And we want to get rid of singleton --> global shared instance
 - The smell is that we have a subclassing and we can use composition instead of the inheritance
 - We can remove shared instance and have abstract class
 - Since the protocol is better as abstraction, we can remove class keyword
 - When we load we can loading from multiple locations, so URL is the detail of the implementation of RemoteFeedLoader, it should not be in the public interface
 */
