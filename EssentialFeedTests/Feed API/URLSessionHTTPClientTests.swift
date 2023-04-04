//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Ljubisa Katana on 4.4.23..
//

import XCTest

class URLSessionHTTPClient {
    private let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func get(from url: URL) {
        session.dataTask(with: url) { _, _, _ in
        
        }.resume() // if we remove resume test will fail
    }
}

final class URLSessionHTTPClientTests: XCTestCase {

    func test_getFromURL_createDataTaskWithURL() {
        let url = URL(string: "http://any-url.com")!
        let session = URLSessionSpy()
        let sut = URLSessionHTTPClient(session: session)
        
        sut.get(from: url)
        
        XCTAssertEqual(session.receivedURLs, [url])
    }
    
    func test_getFromURL_resumesDataTaskWithURL() {
        let url = URL(string: "http://any-url.com")!
        let session = URLSessionSpy()
        let task = URLSessionDataTaskSpy()
        session.stub(url: url, task: task)
        
        let sut = URLSessionHTTPClient(session: session)
        
        sut.get(from: url)
         
        XCTAssertEqual(task.resumeCallCount, 1)
    }

    
    // MARK: - Helpers
    
    private class URLSessionSpy: URLSession {
        var receivedURLs = [URL]()
        private var stubs = [URL: URLSessionDataTask]()
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            receivedURLs.append(url)
            return stubs[url] ?? FakeURLSessionsDataTask()
        }
        
        func stub(url: URL, task: URLSessionDataTask) {
            stubs[url] = task
        }
        
//        override init() {}
    }
    
    private class FakeURLSessionsDataTask: URLSessionDataTask {
//        override init() {}
        
        override func resume() {}
    }
    
    private class URLSessionDataTaskSpy: URLSessionDataTask {
        var resumeCallCount = 0
        
        override func resume() {
            resumeCallCount += 1
        }
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

