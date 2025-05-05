import Foundation

class MockURLProtocol: URLProtocol {
    static var stubResponseData: Data?
    static var stubError: Error?
    static var completionTrigger: (() -> Void)?

    override class func canInit(with request: URLRequest) -> Bool {
        // Intercept all requests
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        if let error = MockURLProtocol.stubError {
            client?.urlProtocol(self, didFailWithError: error)
        } else {
            if let data = MockURLProtocol.stubResponseData {
                client?.urlProtocol(self, didLoad: data)
            }
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }

        MockURLProtocol.completionTrigger?()
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {
        // No cleanup needed for mocks
    }
}
