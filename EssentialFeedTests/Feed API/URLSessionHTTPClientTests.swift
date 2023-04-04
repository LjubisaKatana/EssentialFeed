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

    func test_getFromURL_failsOnRequestError() {
        
        urlProtocolStub.startInterceptingRequests()
        
        let url = URL(string: "http://any-url.com")!
        let requestError = NSError(domain: "any error", code: 1)
        
        urlProtocolStub.stub(url: url, error: requestError)
        
        let sut = URLSessionHTTPClient()
        
        let exp = expectation(description: "Wait for completion")
        
        sut.get(from: url) { result in
            switch result {
            case let .failure(receivedError as NSError):
//                XCTAssertEqual(receivedError, error)
                // iOS 14 +
//                XCTAssertEqual(receivedError.domain, requestError.domain)
//                XCTAssertEqual(receivedError.code, requestError.code)
                
                // Or if you don’t care about the specific error values, you can just make sure it’s not nil:
                XCTAssertNotNil(receivedError)
            default:
                XCTFail("Expected failure with error \(requestError), got \(result) instead")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        urlProtocolStub.stopInterceptingRequests()
    }

    // MARK: - Helpers
    
    private class urlProtocolStub: URLProtocol {
        private static var stubs = [URL: Stub]()
        
        private struct Stub {
            let error: Error?
        }
        
        static func stub(url: URL, error: Error? = nil) {
            stubs[url] = Stub(error: error)
        }
        
        static func startInterceptingRequests() {
            URLProtocol.registerClass(urlProtocolStub.self)
        }
        
        static func stopInterceptingRequests() {
            URLProtocol.registerClass(urlProtocolStub.self)
            stubs = [:]
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            guard let url = request.url else {
                return false
            }
            
            return stubs[url] != nil
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            guard let url = request.url, let stub = urlProtocolStub.stubs[url] else {
                return
            }
            
            if let error = stub.error {
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
 

 
 */

