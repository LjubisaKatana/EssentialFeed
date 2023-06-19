//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Ljubisa Katana on 21.3.23..
//

import XCTest
import EssentialFeed

final class LoadFeedFromRemoteUseCaseTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        // arrange
        let (_, client) = makeSUT()
        
        // assert
        XCTAssertTrue(client.requestURLs.isEmpty)
    }
    
    func test_load_requestsDataFromURL() {
        // arrange
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        // act
        sut.load { _ in }
        
        // assert
        XCTAssertEqual(client.requestURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        // arrange
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        // act
        sut.load { _ in }
        sut.load { _ in }
        
        // assert
        XCTAssertEqual(client.requestURLs, [url, url]) // we can assert order, equality and count. This is more better way to have good test
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: failure(.connectivity), when: {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError, at: 0)
        })
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        let samples = [199, 201, 300, 400, 500]
        
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: failure(.invalidData), when: {
                let json = makeItemsJSON(items: [])
                client.complete(withStatusCode: code, data: json, at: index)
            })
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: failure(.invalidData)) {
            let invalidJSON = Data("invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        }
    }
    
    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyList() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: .success([])) {
            let emptyListJSON = makeItemsJSON(items: [])
            client.complete(withStatusCode: 200, data: emptyListJSON)
        }
    }
    
    func test_load_deliversNoItemsOn200HTTPResponseWithJSONItems() {
        let (sut, client) = makeSUT()
        
        let item1 = makeItem(id: UUID(),
                             imageURL: URL(string: "https://a-url.com")!)
        
        let item2 = makeItem(id: UUID(),
                             description: "a description",
                             location: "a location",
                             imageURL: URL(string: "https://another-url.com")!)
        
        let items = [item1.model, item2.model]
        
        expect(sut, toCompleteWith: .success(items)) {
            let json = makeItemsJSON(items: [item1.json, item2.json])
            client.complete(withStatusCode: 200, data: json)
        }
    }
    
    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let url = URL(string: "http://any-url.com")!
        let client = HTTPClientSpy()
        var sut: RemoteFeedLoader? = RemoteFeedLoader(url: url, client: client)
        
        var capturedResults = [RemoteFeedLoader.Result]()
        sut?.load { capturedResults.append($0) }
        
        sut = nil
        client.complete(withStatusCode: 200, data: makeItemsJSON(items: []))
        
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!,
                         file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: RemoteFeedLoader,
                                                                           client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        
        trackForMemoryLeaks(instance: client, file: file, line: line)
        trackForMemoryLeaks(instance: sut, file: file, line: line)
        
        return (sut, client)
    }
    
    private func failure(_ error: RemoteFeedLoader.Error) -> RemoteFeedLoader.Result {
        return .failure(error)
    }
    
    private func makeItem(id: UUID, description: String? = nil, location: String? = nil, imageURL: URL) -> (model: FeedItem, json: [String: Any]) {
        
        let item = FeedItem(id: id, description: description, location: location, imageURL: imageURL)
        
        let json = [
            "id": id.uuidString,
            "description": description,
            "location": location,
            "image": imageURL.absoluteString
        ].compactMapValues { $0 }

        return (item, json)
    }
    
    private func makeItemsJSON(items: [[String: Any]]) -> Data {
        let json = ["items": items]
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    private func expect(_ sut: RemoteFeedLoader,
                        toCompleteWith expectedResults: RemoteFeedLoader.Result,
                        when action: () -> Void,
                        file: StaticString = #filePath,
                        line: UInt = #line) {
        
        let exp = expectation(description: "Wait for load completion")
        
        sut.load { receivedResult in
            switch (receivedResult, expectedResults) { // pattern matching language feature
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
                
            case let (.failure(receivedError as RemoteFeedLoader.Error), .failure(expectedError as RemoteFeedLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected result \(expectedResults) got \(receivedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
//    @available(swift, deprecated: 5, message: "use `init(_:)` instead")
    private class HTTPClientSpy: HTTPClient {
        private var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()
        
        var requestURLs: [URL] {
            return messages.map { $0.url }
        }
        
        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(url: requestURLs[index],
                                           statusCode: code,
                                           httpVersion: nil,
                                           headerFields: nil)!
            messages[index].completion(.success(data, response))
        }
    }
}

/* We start implementing the RemoteFeedLoader (API) module by following the Load Feed Use Case requirements.
 Learning Outcomes:
 #1
 - How to test-drive an API layer implementation
 - Modular Design
 - Singletons: When and Why
 - Singletons: Better alternatives
 - Singletons: Refactoring steps to gradually remove tight coupling created by singletons
 - Controlling your dependencies: Locating globally shared instances (Implicit) vs. Injecting dependencies (Explicit)
 - Controlling your dependencies: Dependency injection
 
 #2
 - Understand the trade-offs of access control for testing purposes
 - Expand behaviour checking (and coverage) using test spy objects
 
 #3
 - Handling network errors
 - Differences between stubbing and spying when unit testing
 - How to extend code coverage by using samples of values to test specific test cases
 - Design better code with enums to make invalid paths unrepresentable
 
 #4
 - Differences and trade-offs between mocking vs. testing collaborators in integration
 - Mapping JSON data to native models using the Decodable protocol
 - How to protect your architecture abstractions by working with domain-specific models
 - How to simplify tests leveraging factory methods and test helper functions
 
 #5
 - Automating memory leak detection with tests
 - Preventing a common async bug
 - More refactor techniques
 
 #6
 - Protecting the production code from test details
 - Maintain modularity by protecting high-level abstractions from low-level implementation details
 - Dealing with potential issues when using the Swift.Error protocol
 - Pattern matching using Swift enums
 - Assert asynchronous behavior with XCTestCase expectations
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
 - Add property that hold array of URLs to have better test
 - It's time to add some response from load method
 - We can start with connectivity error --> domain error
 - Again we check capturedErrors so we can guarantee number of errors in this case we want to have one error.
 - We can have messages array of signature of the get method and return instead of requestedURLs and completions
 - It's time to delivers invalidData for non 200 HTTP responses
 - The logical question is, what about the rest of the status codes?
 - So how munch is enough?
 - We can provide some basic status codes
 - Replace with enum optional types to have success/failure cases
 - Now it's time to have a test with response ok 200 but with InvalidJSON
 - We extend our success case with Data so we can provide json data from response
 - We can refactor code a bit by adding `expect` helper method and remove duplication
 - And now happy path --> response 200 with empty list
 - Refactor to return `Result` instead of error
 - Add test with HTTP response 200 and valid json data
 - It's time to add decodable
 - Since description and location are optional the type is not match as a json: [String: Any]) so we can `reduce` it into a dictionary.
 - With Swift 5 we can switch `reduce` to `compactMapValues` so we can have more readable syntax, where we remove nil values from Dictionary
 let json = [
   "id": id.uuidString,
   "description": description,
   "location": location,
   "image": imageURL.absoluteString
 ].compactMapValues { $0 }
 - We can decouple the Feed Feature module from API implementation details by adding `Item` struct
 - We can map result and data by using mapper
 - Move related inside of Mapper scope
 - We can switch if/else statements to do/catch, it's about preferences
 - We can move HTTPClient to own file and RemoteItemMapper as well
 - We extract logic from load function to map itself and capturing self which means we can encounter retain cycle, where we have to add some safeties, and protect it from memory leak.
 - We add memory leak checker
 - Now we can call map function, but it's better to have it as a static func to remove self
 - Move mapping logic to the FeedItemsMapper
 - Important thing is that we should somehow test if we can invoke the function load after RemoteFeedLoader instance is deallocated
 - RemoteFeedLoader conforms to FeedLoader, but we have constraints with Equatable for the LoadFeedResult
 */



//#1 There are many reasons to have different implementations of an HTTPClient. For example, you can create test-double implementations for testing purposes. You can also change between frameworks such as Moya, Alamofire, and URLSession without breaking other modules. You may also want to provide an implementation with hardcoded behaviour for demoing purposes. And so on!

// #2 Test visibility: public vs @testable (internal) We start by moving the RemoteFeedLoader class and the HTTPClient protocol to a new production file to facilitate our development workflow. By doing so, our test target doesn’t have access to our internal types anymore; thus we need to decide whether we will make our types public or leave them as internal and add the @testable attribute when importing our production module in the tests. We decided the former as we can test the Feed API module through the public interfaces it contains so that we can test the expected behaviour as a client of the module. Another benefit of this approach is that we can now make changes to any internal or private implementation details without breaking our tests.

// #2 Enhancing test assertions Our previous HTTPClientSpy was capturing the URL passed to the HTTPClient in its requestedURL property, which we then used to assert that the RemoteFeedLoader was giving the correct value to the client. Although this approach (capturing the received URL in a property) checks the desired behaviours correctly, it won’t notify us in the case we mistakenly execute a request more than once. To make sure we cover every case, we introduce a new array of URLs named requestedURLs in the HTTPClientSpy where we append all received URLs when get(from:) is invoked. We now still can check that we capture the appropriate URL values, but we can also assert how many times get(from:) was invoked as well.

// #3 Spies are usually test-helpers with a single responsibility of capturing the received messages. To remove the stubbed behaviour and give our spy a sole responsibility again, we altered its implementation to keep track of all the completions passed through the HTTPClient's get(from:completion:).


/* #4
Inline JSON vs external files
Another decision we made while dealing with the JSON data was to create them inline in the tests (hardcoded in code, matching the backend payload contract) and then extract their creation into helper functions. Oppositely, we could have formed an external text file containing “mocked” JSON matching the payload and load its contents every time the test ran. Although a valid and common approach, we deemed such an activity an overkill for now since the JSON representation is simple enough (and readable) to be represented in code. If we keep the JSON in external text files, we would have to read those files from the disk which seemed like an overhead (slowing down our tests) and unnecessary expense at the moment (those tiny slowdowns build up over time and can become a problem). Additionally, such solutions can make debugging more difficult as the JSON values live “far away” from the tests (external files) which can complicate our research in the case of a test failure.
*/


/*
 #5 - nn
 */

/*
 #6
 The case against a reusable/generic Result
 “Why haven’t you made the Result a generic type yet?!”

 Initially, the way we chose to structure and represent the output of the Feed API and the Feed Feature module is through domain-specific result types: the RemoteFeedLoader.Result, the HTTPClientResult, and the LoadFeedResult enums. Although it’s a good idea to delay the abstraction and reuse of types unless required, the multiple representations of a result are starting to look like a DRY (Don’t Repeat Yourself) violation.

 Instead of multiple result types, we could have created a generic version of a shared Result<Value, Error> and reuse it instead of all the domain-specific ones. Although this approach would solve the DRY violation, another potential issue could appear: “In which module should the reusable Result type live?” A possible solution would be to create and declare the generic Result type in a new Shared or Common module which all other modules could import/depend upon. However, such a solution could easily complicate or potentially compromise our system’s modularity as our modules would have a new dependency to handle and maintain. We could also choose at this time to leave the reusable Result type in the Feed Feature module since all other modules seem to depend on it already (although that’s a huge assumption to make so early in the development cycle).

 None of those solutions seem ideal, so we can defer making a decision until we learn more about our system’s needs.

 If you’re using Swift 5 or above, you can use the Swift.Result type from the standard library to solve this problem! Better yet, since the generic Swift.Result is a Swift standard library type, we can more easily compose our solutions with external frameworks (including 3rd-party) in the future. Later on in the course, you’ll learn how to take advantage of the standard  Swift.Result type.

 The case against a domain-specific Feed Feature Error type (for now)
 A common modularity challenge is how to protect our high-level abstractions from low-level implementation details. Typed errors are one of those problems and one of the reasons why the Swift (a strongly typed language) team decided to go with untyped errors (relying on the empty Swift.Error protocol that must be cast in runtime) in its native error handling features: they don’t want errors to break modularity/source code compatibility over time.

 We faced the same dilemma. By making the RemoteFeedLoader class (lower-level Feed API module) conform to the FeedLoader protocol (higher-level Feed Feature module), we need to think about the incompatibility of errors that the corresponding modules hold. We decided that the LoadFeedResult enum, the general purpose result of the Feed Feature (high-level module), should have a failure case holding an associated value of the standard Swift.Error protocol to hide the low-level details from the high-level module. Then, the RemoteFeedLoader from the Feed API (lower-level module) implements the high-level protocol and, in the case of a failure, completes with its domain-specific typed error (enum) which conforms to the Swift.Error protocol.

 We chose to structure our types as such because the RemoteFeedLoader’s domain-specific Error enum type is a lower-level implementation detail of the Feed API module. Thus, we don't want to expose it in the higher-level Feed Feature module (at least yet–we might do it in the future). If we did so then, the Feed Feature would be coupled with implementation details of other lower-level modules and would break the system’s modular nature.
 */
