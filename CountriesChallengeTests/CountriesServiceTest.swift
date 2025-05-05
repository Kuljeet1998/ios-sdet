import XCTest
@testable import CountriesChallenge

// MARK: - Mocks & Helpers

    class NilParser: CountriesParser {
        override func parser(_ data: Data?) -> Result<[Country]?, Error> {
            return .success(nil)
        }
    }
    struct MockError: Error {}

        func makeMockCountryData() -> Data {
            let country = makeMockCountry_Normal()
            return try! JSONEncoder().encode([country])
        }

        func makeMockBadJSONData() -> Data {
            return Data("Invalid JSON".utf8)
        }

    func makeMockURLSession(with data: Data? = nil, error: Error? = nil, completionTrigger: (() -> Void)? = nil) -> URLSession {
        MockURLProtocol.stubResponseData = data
        MockURLProtocol.stubError = error
        MockURLProtocol.completionTrigger = completionTrigger

        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        return URLSession(configuration: config)
    }

    func makeParserAlwaysFailing() -> CountriesParser {
        class FailingParser: CountriesParser {
            override func parser(_ data: Data?) -> Result<[Country]?, Error> {
                .failure(CountriesParserError.decodingFailure)
            }
        }
        return FailingParser()
    }

    func makeParserReturningNil() -> CountriesParser {
        class NilParser: CountriesParser {
            override func parser(_ data: Data?) -> Result<[Country]?, Error> {
                .success(nil)
            }
        }
        return NilParser()
    }


    // MARK: - Test Class

    final class CountriesServiceTests: XCTestCase {
        

        func test_fetchCountries_withValidURLAndSuccessfulResponse_shouldReturnCountries() async throws {
        let mockSession = makeMockURLSession(with: makeValidCountryResponseData())
        let service = CountriesService(urlString: "https://mockurl.com", urlSession: mockSession, parser: CountriesParser())

        let countries = try await service.fetchCountries()

        XCTAssertEqual(countries.count, 1)
        XCTAssertEqual(countries.first?.name, "France")
    }

        func test_fetchCountries_withInvalidURL_shouldThrowInvalidURLError() async {
            // Arrange
            let invalidURLString = "invalid-url"
            let service = CountriesService(
                urlString: invalidURLString,
                urlSession: makeMockURLSession(),  // Ensure this returns a mock session
                parser: CountriesParser()
            )
            
            // Act & Assert
            do {
                _ = try await service.fetchCountries()
                XCTFail("Expected to throw invalidUrl error")
            } catch CountriesServiceError.invalidUrl(let urlString) {
                // Assert specific error case and value
                XCTAssertEqual(urlString, invalidURLString)
            } catch {
                XCTFail("Unexpected error type: \(error)")
            }
        }

        func test_fetchCountries_withNilData_shouldThrowInvalidDataError() async {
            let mockSession = makeMockURLSession(with: nil)
            let service = CountriesService(urlString: "https://mockurl.com", urlSession: mockSession, parser: CountriesParser())

            do {
                _ = try await service.fetchCountries()
                XCTFail("Expected to throw invalidData")
            } catch {
                guard case CountriesServiceError.invalidData = error else {
                    return XCTFail("Expected .invalidData but got \(error)")
                }
            }
        }
        

        func test_fetchCountries_withNetworkFailure_shouldThrowFailureError() async {
            let mockError = NSError(domain: "network", code: -1009)
            let mockSession = makeMockURLSession(error: mockError)
            let service = CountriesService(urlString: "https://mockurl.com", urlSession: mockSession, parser: CountriesParser())

            do {
                _ = try await service.fetchCountries()
                XCTFail("Expected to throw network failure")
            } catch {
                guard case let CountriesServiceError.failure(innerError) = error else {
                    return XCTFail("Expected .failure but got \(error)")
                }
                XCTAssertEqual((innerError as NSError).code, -1009)
            }
        }

        func test_fetchCountries_withDecodingFailure_shouldThrowDecodingError() async {
            let badData = Data("invalid-json".utf8)
            let mockSession = makeMockURLSession(with: badData)
            let service = CountriesService(urlString: "https://mockurl.com", urlSession: mockSession, parser: CountriesParser())

            do {
                _ = try await service.fetchCountries()
                XCTFail("Expected decoding failure")
            } catch {
                guard case CountriesServiceError.decodingFailure = error else {
                    return XCTFail("Expected .decodingFailure but got \(error)")
                }
            }
        }

    

    func test_fetchCountries_parserReturnsNilArray_shouldReturnEmptyArray() async throws {
        let parser = makeParserReturningNil()
        let mockSession = makeMockURLSession(with: makeValidCountryResponseData())
        let service = CountriesService(urlString: "https://mockurl.com", urlSession: mockSession, parser: parser)

        let countries = try await service.fetchCountries()

        XCTAssertTrue(countries.isEmpty)
    }

    func test_fetchCountries_sessionCompletion_shouldBeCalledOnce() async throws {
        var wasCalled = false
        let mockSession = makeMockURLSession(
            with: makeValidCountryResponseData(),
            completionTrigger: { wasCalled = true }
        )
        let service = CountriesService(urlString: "https://mockurl.com", urlSession: mockSession, parser: CountriesParser())

        _ = try await service.fetchCountries()

        XCTAssertTrue(wasCalled)
    }

    
    func test_fetchCountries_withMultipleCountries_returnsCorrectly() async throws {
    let countries = [
        makeMockCountry_Normal(),
        makeMockCountry_MissingSymbol(),
        makeMockCountry_NoLanguageCode()
    ]
    let data = try JSONEncoder().encode(countries)
    let session = makeMockURLSession(with: data)

    let service = CountriesService(
        urlString: "https://test.com",
        urlSession: session,
        parser: CountriesParser()
    )

    let result = try await service.fetchCountries()
    XCTAssertEqual(result.count, 3)
    XCTAssertEqual(result[1].currency.symbol, nil)
    XCTAssertNil(result[2].language.code)
}

func test_fetchCountries_countryWithEmptyFields_stillDecodes() async throws {
    let country = makeMockCountry_EmptyFields()
    let data = try JSONEncoder().encode([country])
    let session = makeMockURLSession(with: data)

    let service = CountriesService(
        urlString: "https://test.com",
        urlSession: session,
        parser: CountriesParser()
    )

    let result = try await service.fetchCountries()
    XCTAssertEqual(result.first?.capital, "")
    XCTAssertEqual(result.first?.currency.name, "")
}

func test_fetchCountries_nullSymbolField_doesNotCrash() async throws {
    let country = makeMockCountry_MissingSymbol()
    let data = try JSONEncoder().encode([country])
    let session = makeMockURLSession(with: data)

    let service = CountriesService(
        urlString: "https://test.com",
        urlSession: session,
        parser: CountriesParser()
    )

    let result = try await service.fetchCountries()
    XCTAssertNil(result.first?.currency.symbol)
}


}
