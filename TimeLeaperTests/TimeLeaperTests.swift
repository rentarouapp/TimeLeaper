//
//  TimeLeaperTests.swift
//  TimeLeaperTests
//
//  Created by 上條蓮太朗 on 2025/12/26.
//

import Testing
import Foundation
@testable import TimeLeaper

struct TimeLeaperTests {

    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    }

}

// MARK: - APIClient HTTP Status Code Tests

/// Mock URL Protocol for simulating HTTP responses
class MockURLProtocol: URLProtocol {
    static var mockResponse: HTTPURLResponse?
    static var mockData: Data?
    static var mockError: Error?

    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        if let error = MockURLProtocol.mockError {
            client?.urlProtocol(self, didFailWithError: error)
        } else {
            if let response = MockURLProtocol.mockResponse {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            if let data = MockURLProtocol.mockData {
                client?.urlProtocol(self, didLoad: data)
            }
            client?.urlProtocolDidFinishLoading(self)
        }
    }

    override func stopLoading() {
        // No-op
    }
}

struct APIClientTests {

    /// Helper to create an APIClient with mock URLSession
    func createMockAPIClient() -> APIClient {
        let client = APIClient.shared()

        // Configure session with mock protocol
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let mockSession = URLSession(configuration: config)

        // Use KVC to inject mock session
        client.setValue(mockSession, forKey: "session")

        return client
    }

    /// Reset mock state
    func resetMocks() {
        MockURLProtocol.mockResponse = nil
        MockURLProtocol.mockData = nil
        MockURLProtocol.mockError = nil
    }

    @Test func httpStatusCode200Success() async throws {
        resetMocks()

        let client = createMockAPIClient()

        // Prepare mock response
        let url = URL(string: "https://www.googleapis.com/books/v1/volumes")!
        let response = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: "HTTP/1.1",
            headerFields: nil
        )!
        let jsonDict: [String: Any] = ["items": []]
        let jsonData = try! JSONSerialization.data(withJSONObject: jsonDict)

        MockURLProtocol.mockResponse = response
        MockURLProtocol.mockData = jsonData

        // Execute request
        let result = await withCheckedContinuation { continuation in
            client.getPath("volumes", parameters: ["q": "Swift"]) { json, error in
                continuation.resume(returning: (json, error))
            }
        }

        #expect(result.1 == nil, "Should not have error for 200 OK")
        #expect(result.0 != nil, "Should have JSON data")
    }

    @Test func httpStatusCode404NotFound() async throws {
        resetMocks()

        let client = createMockAPIClient()

        // Prepare mock response
        let url = URL(string: "https://www.googleapis.com/books/v1/volumes")!
        let response = HTTPURLResponse(
            url: url,
            statusCode: 404,
            httpVersion: "HTTP/1.1",
            headerFields: nil
        )!
        let htmlData = "<html>Not Found</html>".data(using: .utf8)!

        MockURLProtocol.mockResponse = response
        MockURLProtocol.mockData = htmlData

        // Execute request
        let result = await withCheckedContinuation { continuation in
            client.getPath("volumes", parameters: ["q": "Swift"]) { json, error in
                continuation.resume(returning: (json, error))
            }
        }

        #expect(result.1 != nil, "Should have error for 404")
        #expect(result.0 == nil, "Should not have JSON data")
        if let error = result.1 as NSError? {
            #expect(error.code == 404, "Error code should be 404")
            #expect(error.domain == "APIClientErrorDomain", "Error domain should match")
            #expect(error.localizedDescription.contains("HTTPエラー"), "Error should mention HTTP error")
            #expect(error.localizedDescription.contains("404"), "Error should include status code")
        }
    }

    @Test func httpStatusCode500InternalServerError() async throws {
        resetMocks()

        let client = createMockAPIClient()

        // Prepare mock response
        let url = URL(string: "https://www.googleapis.com/books/v1/volumes")!
        let response = HTTPURLResponse(
            url: url,
            statusCode: 500,
            httpVersion: "HTTP/1.1",
            headerFields: nil
        )!
        let htmlData = "<html>Internal Server Error</html>".data(using: .utf8)!

        MockURLProtocol.mockResponse = response
        MockURLProtocol.mockData = htmlData

        // Execute request
        let result = await withCheckedContinuation { continuation in
            client.getPath("volumes", parameters: ["q": "Swift"]) { json, error in
                continuation.resume(returning: (json, error))
            }
        }

        #expect(result.1 != nil, "Should have error for 500")
        #expect(result.0 == nil, "Should not have JSON data")
        if let error = result.1 as NSError? {
            #expect(error.code == 500, "Error code should be 500")
            #expect(error.domain == "APIClientErrorDomain", "Error domain should match")
            #expect(error.localizedDescription.contains("HTTPエラー"), "Error should mention HTTP error")
            #expect(error.localizedDescription.contains("500"), "Error should include status code")
        }
    }

    @Test func httpStatusCode403Forbidden() async throws {
        resetMocks()

        let client = createMockAPIClient()

        // Prepare mock response
        let url = URL(string: "https://www.googleapis.com/books/v1/volumes")!
        let response = HTTPURLResponse(
            url: url,
            statusCode: 403,
            httpVersion: "HTTP/1.1",
            headerFields: nil
        )!
        let htmlData = "<html>Forbidden</html>".data(using: .utf8)!

        MockURLProtocol.mockResponse = response
        MockURLProtocol.mockData = htmlData

        // Execute request
        let result = await withCheckedContinuation { continuation in
            client.getPath("volumes", parameters: ["q": "Swift"]) { json, error in
                continuation.resume(returning: (json, error))
            }
        }

        #expect(result.1 != nil, "Should have error for 403")
        #expect(result.0 == nil, "Should not have JSON data")
        if let error = result.1 as NSError? {
            #expect(error.code == 403, "Error code should be 403")
            #expect(error.domain == "APIClientErrorDomain", "Error domain should match")
            #expect(error.localizedDescription.contains("HTTPエラー"), "Error should mention HTTP error")
            #expect(error.localizedDescription.contains("403"), "Error should include status code")
        }
    }
}
