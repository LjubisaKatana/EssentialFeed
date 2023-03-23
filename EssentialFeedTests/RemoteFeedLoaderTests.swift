//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Ljubisa Katana on 21.3.23..
//

import XCTest
import EssentialFeed

final class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        // arrange
        let (_, client) = makeSUT()
        
        // assert
        XCTAssertNil(client.requestURL)
    }
    
    func test_load_requestsDataFromURL() {
        // arrange
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        // act
        sut.load()
        
        // assert
        XCTAssertEqual(client.requestURL, url)
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        // arrange
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        // act
        sut.load()
        sut.load()
        
        // assert
        XCTAssertEqual(client.requestURLs, [url, url]) // we can assert order, equality and count. This is more better way to have good test
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var requestURLs = [URL]()
        var requestURL: URL?
        
        func get(from url: URL) {
            requestURL = url
            requestURLs.append(url)
        }
    }
}

/* We start implementing the RemoteFeedLoader (API) module by following the Load Feed Use Case requirements.
 Learning Outcomes:
 - How to test-drive an API layer implementation
 - Modular Design
 - Singletons: When and Why
 - Singletons: Better alternatives
 - Singletons: Refactoring steps to gradually remove tight coupling created by singletons
 - Controlling your dependencies: Locating globally shared instances (Implicit) vs. Injecting dependencies (Explicit)
 - Controlling your dependencies: Dependency injection
 */


// Even though the RemoteFeedLoader will be a <FeedLoader> implementation, we don't start by conforming to the <FeedLoader> protocol, as it would require us to think too much ahead. Instead, we can take smaller (and safer) steps by test-driving the RemoteFeedLoader implementation. The <FeedLoader> protocol is just a guideline at this time (part of the feature interfaces), so we can conform to it at the end.

/* Global shared instances vs. Dependency Injection
We go on to demonstrate an evolutionary design for the RemoteFeedLoader's collaborator, the HTTPClient. We show how such a collaborator can start as a concrete singleton and how we can follow a detailed process, backed up by unit tests, to ensure the behaviour of the system won't change when we refactor to a more modular (protocol based) solution.

HTTP clients are often implemented as singletons just because it may be more "convenient" to locate the shared instance. However, in our opinion, such an approach may be considered an anti-pattern as it can introduce tight coupling between the modules. In our case, the HTTPClient has no reason to be a singleton, so a more suitable solution to be able to communicate with collaborators is using dependency injection instead. Then we can move the responsibility of locating and injecting the collaborator to a composer module (e.g., Main), so we can focus only on passing messages between the other components.
 */

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
 - I choose to net having a Singleton for the HTTPClient because of that there is no reason to be a Singleton, We don't want to have one instance per application here. And with a dependency injection we keep our code modular. By using the Singleton or shared instance we may introduce tight coupling between modules
 - HTTPClient become the abstract class, and does it have to be AC? It's just contract, defining which external functionality the RemoteFeedLoader needs, so protocol is more convenient to define a contract
 - Extract production component to production folder and add access level
 - We have to guarantee to have last passed value when calling `load` method twice
 */


//There are many reasons to have different implementations of an HTTPClient. For example, you can create test-double implementations for testing purposes. You can also change between frameworks such as Moya, Alamofire, and URLSession without breaking other modules. You may also want to provide an implementation with hardcoded behaviour for demoing purposes. And so on!
