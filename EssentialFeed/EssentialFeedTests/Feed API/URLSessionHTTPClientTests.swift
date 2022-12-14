//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Andrey on 8/8/22.
//

import XCTest
import EssentialFeed

class URLSessionHTTPClientTests: XCTestCase {
    override func tearDown() {
        URLProtocolStub.removeStub()
    }
    
    func test_getFromURL_performsGETRequestWithURL() {
        let url = anyURL()
        let exp = expectation(description: "Wait for request")
        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        
        makeSUT().get(from: url) { _ in }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_getFromURL_failsOnRequestError() {
        let requestError = anyNSError()
        let receivedError = resultErrorFor((data: nil, response: nil, error: requestError))
        
        XCTAssertEqual((receivedError as? NSError)?.code, requestError.code)
        XCTAssertEqual((receivedError as? NSError)?.domain, requestError.domain)
        
    }
    
    func test_getFromURL_failsOnAllInvalidRepresentationCases() {
        XCTAssertNotNil(resultErrorFor((data: nil, response: nil, error: nil)))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: nil, error: nil)))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: nonHTTPURLResponse(), error: nil)))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: nonHTTPURLResponse(), error: anyNSError())))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: anyHTTPURLResponse(), error: anyNSError())))
        XCTAssertNotNil(resultErrorFor((data: nil, response: nonHTTPURLResponse(), error: nil)))
        XCTAssertNotNil(resultErrorFor((data: nil, response: nonHTTPURLResponse(), error: anyNSError())))
        XCTAssertNotNil(resultErrorFor((data: nil, response: anyHTTPURLResponse(), error: anyNSError())))
    }
    
    func test_getFromURL_succeedsOnHTTPURLResponseWithData() {
        let requestResponse = anyHTTPURLResponse()
        let requestData = anyData()
        let receivedValues = resultValuesFor((data: requestData, response: requestResponse, error: nil))
        
        XCTAssertEqual(receivedValues?.response.url, requestResponse.url)
        XCTAssertEqual(receivedValues?.response.statusCode, requestResponse.statusCode)
        XCTAssertEqual(receivedValues?.data, requestData)
    }
    
    func test_getFromURL_succeedsOnHTTPURLResponseWithEmptyData() {
        let requestResponse = anyHTTPURLResponse()
        let receivedValues = resultValuesFor((data: nil, response: requestResponse, error: nil))
        
        let emptyData = Data()
        XCTAssertEqual(receivedValues?.response.url, requestResponse.url)
        XCTAssertEqual(receivedValues?.response.statusCode, requestResponse.statusCode)
        XCTAssertEqual(receivedValues?.data, emptyData)
    }
    
    func test_getFromURL_cancelsURLRequest() {
        let error = resultErrorFor(taskHandler: { $0.cancel() }) as? NSError
        XCTAssertEqual(error?.code, URLError.cancelled.rawValue)
    }
    
    // MARK: - Helpers
    
    func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> HTTPClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: configuration)
        
        let sut = URLSessionHTTPClient(session: session)
        trackMemoryLeaks(instance: sut, file: file, line: line)
        return sut
    }
    
    func makeEphemeralURLSession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        return URLSession(configuration: configuration)
    }
    
    func resultValuesFor(_ values: (data: Data?, response: URLResponse?, error: Error?), file: StaticString = #filePath, line: UInt = #line) -> (data: Data, response: HTTPURLResponse)? {
        
        let result = resultFor(values, file: file, line: line)
        
        switch result {
        case let .success((response, data)):
            return (data, response)
            
        default:
            XCTFail("Should have succeed but failed with: \(result) instead", file: file, line: line)
            return nil
        }
    }
    
    func resultErrorFor(_ values: (data: Data?, response: URLResponse?, error: Error?)? = nil, taskHandler: (HTTPClientTask) -> Void = { _ in }, file: StaticString = #filePath, line: UInt = #line) -> Error? {
        
        let result = resultFor(values, taskHandler: taskHandler, file: file, line: line)
        
        switch result {
        case let .failure(receivedError as NSError):
            return receivedError
            
        default:
            XCTFail("Should have failed but succeeded with: \(result) instead", file: file, line: line)
            return nil
        }
    }
    
    func resultFor(_ values: (data: Data?, response: URLResponse?, error: Error?)?, taskHandler: (HTTPClientTask) -> Void = { _ in }, file: StaticString = #filePath, line: UInt = #line) -> HTTPClient.Result {
        values.map { URLProtocolStub.stub(data: $0, response: $1, error: $2) }
        
        let sut = makeSUT()
        
        var capturedValue: HTTPClient.Result!
        let exp = expectation(description: "wait for completion")
        
        taskHandler(sut.get(from: anyURL()) { result in
            capturedValue = result
            exp.fulfill()
        })
        
        wait(for: [exp], timeout: 1.0)
        return capturedValue
    }
    
    func nonHTTPURLResponse() -> URLResponse {
        URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    func anyHTTPURLResponse() -> HTTPURLResponse {
        HTTPURLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
}
