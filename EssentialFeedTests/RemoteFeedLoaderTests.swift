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

final class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        // arrange
        let (_, client) = makeSUT()
        
        // assert
        XCTAssertNil(client.requestURL)
    }
    
    func test_load_requestDataFromURL() {
        // arrange
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        // act
        sut.load()
        
        // assert
        XCTAssertEqual(client.requestURL, url)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var requestURL: URL?
        
        func get(from url: URL) {
            requestURL = url
        }
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
 Since there is a code duplication, it can be refactored --> factory method to have makeSUT() -> RemoteFeedLoader
 - Spy class is not production code, so we can move it to test class scope
 */
