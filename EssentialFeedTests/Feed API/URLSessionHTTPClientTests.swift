//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Ljubisa Katana on 4.4.23..
//

import XCTest
import EssentialFeed

class URLSessionHTTPClient {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { _, _, error in
            if let error = error {
                completion(.failure(error))
            }
        }.resume()
    }
}

final class URLSessionHTTPClientTests: XCTestCase {
    
    override class func setUp() {
        super.setUp()
        URLProtocolStub.startInterceptingRequests()
    }
    
    override class func tearDown() {
        super.tearDown()
        URLProtocolStub.stopInterceptingRequests()
    }
    
    func test_getFromURL_performsGETRequestWithURL() {
        let url = URL(string: "http://any-url.com")!
        let exp = expectation(description: "Wait for request")
        
        URLProtocolStub.observeRequest { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        
        makeSUT().get(from: url) { _ in }
        
        wait(for: [exp], timeout: 1)
    }

    func test_getFromURL_failsOnRequestError() {
        let url = URL(string: "http://any-url.com")!
        let requestError = NSError(domain: "any error", code: 1)
        URLProtocolStub.stub(data: nil, response: nil, error: requestError)
        
        let exp = expectation(description: "Wait for completion")
        
        makeSUT().get(from: url) { result in
            switch result {
            case let .failure(receivedError as NSError):
//                XCTAssertEqual(receivedError, error)
                // iOS 14 +
                XCTAssertEqual(receivedError.domain, requestError.domain)
//                XCTAssertEqual(receivedError.code, requestError.code)
                
                // Or if you don’t care about the specific error values, you can just make sure it’s not nil:
//                XCTAssertNotNil(receivedError)
            default:
                XCTFail("Expected failure with error \(requestError), got \(result) instead")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }

    // MARK: - Helpers
    
    // TODO: - We should return abstraction instead of concrete implementation!
    private func makeSUT(file: StaticString = #filePath,
                         line: UInt = #line) -> URLSessionHTTPClient { // Protect our test and API changes by using factory method
        let sut = URLSessionHTTPClient()
        trackForMemoryLeaks(instance: sut, file: file, line: line)
        return sut
    }
    
    private class URLProtocolStub: URLProtocol {
        private static var stub:  Stub?
        private static var requestObserver: ((URLRequest) -> Void)?
        
        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
        
        static func stub(data: Data?, response: URLResponse?, error: Error?) {
            stub = Stub(data: data, response: response, error: error)
        }
        
        static func observeRequest(observer: @escaping (URLRequest) -> Void) {
            requestObserver = observer
        }
        
        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
            stub = nil
            requestObserver = nil
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            requestObserver?(request)
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            if let data = URLProtocolStub.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = URLProtocolStub.stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let error = URLProtocolStub.stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {}
    }
}

/* Documentation
 - We can have end to end approach but it can be unreliable sync hitting the backend
 - Beside that it can be flaky
 - Also we don't have backend side in this moment
 
 - First we want to capture URL and we can do that by adding Spy again
 - We override dataTask method and append urls but function returns URLSessionDataTask and we need some mock implementation where we can provide Fake one as return (FakeURLSessionsDataTask)
 - By mocking our tests are tide with implementation. We should avoid this by testing behaviour, if possible. And in this case is possible
 
 - Expected error when enter url, but we don't know what exact error we should expect! So we have to prepare our test to have more information value
 - We can observe HTTP request
 - And on the same way we can test POST, ...
 - By using factory method we protect our test and API changes
 */

/*
 Learning Outcomes:
 - Learn various testing strategies for network requests and their trade-offs
 - Subclass and protocol-based mocking of classes we don’t own (e.g., the Foundation URLSession class)
 - The (little-known) URL Loading System
 - Intercepting and handling URL requests with URLProtocol
 */

/*
Proposed testing strategies for network requests
End-to-end testing
End-to-end testing of network requests refers to a testing strategy that checks the integration between the client and server communication, by performing real HTTP requests.

A downside to end-to-end tests for us is that we don’t have a backend to talk to yet (and we don’t want to use it as an excuse to be “blocked”). Also, because of hitting the network, other downsides to this type of tests are: they require a network connection to run, they can be flaky (as network requests may fail, the tests may sometimes fail unexpectedly), and they can be slow (depending on network performance).

Although a valid solution, there are faster and more reliable alternatives to testing the network requests at the component level. We believe it would be much more beneficial at this stage of development to test URLSessionHTTPClient in isolation. Later on, we can add some end-to-end tests to guarantee correct communication with our backend.

Mocking with Subclasses
Testing the URLSession implementation by subclassing and spying/stubbing its methods is a testing strategy that targets the component level without hitting a real HTTP request. It can be faster and more reliable, but we should keep in mind that subclass mocking can be dangerous when we subclass types we don’t own. From our point of view, URLSession is a 3rd-party class (a class we don’t own) which we don’t have access to its implementation. We believe that by not owning the mocked class, we inherently increase the risk in our codebase because of the possible wrongful assumptions we make about it’s mocked behavior. For example, we were surprised when a crash occurred in a test because the FakeURLSessionDataTask subclass didn't override the URLSessionDataTask.resume() instance method. Additionally, URLSession and its collaborators (e.g., URLSessionTask) expose a plethora of methods that we are not overriding in our mock, increasing the risk of wrongful assumptions and future runtime crashes.

Another downside to subclass mocking is the tight coupling between the tests with the production code. For example, when mocking, the tests end up asserting precise method calls (first we assert that we’ve created a data task with a given URL using a specific API, then we assert that we’ve called resume to start the request, and only then we can assert the behavior we expect).

When possible, we strive to find strategies that decouple the tests from the production implementation. Doing so allows us to assert only the expected behavior instead of precise method calls. When we decouple the test from the implementation, the production code can be more easily refactored/changed without breaking the tests (as long as we keep the same behavior).

Mocking with Protocols
Another approach for testing the URLSession-based solution is to use protocols that mimic the desired interfaces we’d like to spy on. For example, in the episode, we created a <HTTPSession> protocol with only the specific URLSession method we care about. The URLSessionHTTPClient then collaborates with the <HTTPSession> protocol instead of the concrete URLSession type. By doing so, we believe we improved the test code by hiding unnecessary details about the URLSession APIs. Also, we avoid overriding any methods, oppositely to the mocking by subclassing testing strategy, as we only have to implement and maintain specific methods we care about.

With the protocol-based mocking strategy we may have solved the mocked assumptions problem of the subclass-based strategy, but we still haven’t solved the tight coupling with the URLSession APIs since the protocols are mimicking its method signatures.

Additionally, by adding a set of protocols for testing the URLSession-based implementation, we introduce a lot of noise in our production code, as the protocols are created solely for testing purposes.

URLProtocol stubbing
The last (and our preferred) presented approach for testing network requested is to use the little-known URL Loading System to intercept and handle requests with URLProtocol stubs.

It’s our preferred approach since it solves the shortcomings of the other popular strategies.

It’s fast and reliable.
It’s a documented and recommended API by Apple to test network requests, so it should not have any unexpected mocking behavior.
It helps us to decouple the tests from production implementation.
It helps us to hide test details from production code.
 */

/*
 URLProtocol
 URLProtocol is an abstract class that defines an abstract interface that can be implemented by subclasses to handle the loading of protocol-specific URL data, e.g., HTTP, HTTPS, FTP, and custom protocols. It can be used as a mechanism to intercept outgoing requests and altering the URL loading behavior. To activate or deactivate a custom URL loading behavior in the URL Loading System, we must register or unregister the custom URLProtocol subclass using the URLProtocol.registerClass(AnyClass) and URLProtocol.unregisterClass(AnyClass) methods.

 Required methods when subclassing:

 class func canInit(with:URLRequest) -> Bool
 class func canonicalRequest(for:URLRequest)
 func startLoading()
 func stopLoading()
 */


//References
//URL Loading System reference https://developer.apple.com/documentation/foundation/url_loading_system
//URLProtocol reference https://developer.apple.com/documentation/foundation/urlprotocol
//URLSession reference https://developer.apple.com/documentation/foundation/urlsession
//Testing Tips & Tricks (WWDC 2018 – Session 417) https://developer.apple.com/videos/play/wwdc2018/417
