import XCTest
@testable import CountriesChallenge

class CountriesParserTests: XCTestCase {

    var parser: CountriesParser!

    // MARK: - Constants
    let franceName = "France"
    let japaneseName = "Japanese"
    let specialCurrencyCode = "CHF$"
    let nullFieldJSON = #"[{ "name": null, "capital": "N/A", "code": "XX", "currency": { "code": "USD", "name": "Dollar" }, "flag": "🇺🇸", "language": { "code": "en", "name": "English" }, "region": "Americas" }]"#
    let noFieldsJSON = "[{}]"

    // MARK: - Lifecycle
    override func setUp() {
        super.setUp()
        parser = CountriesParser()
    }

    override func tearDown() {
        parser = nil
        super.tearDown()
    }

    // MARK: - Helpers
    func makeMockJSON(from countries: [Country]) -> Data? {
        return try? JSONEncoder().encode(countries)
    }

    func makeCorruptedJSON() -> Data {
        return Data("{ invalid-json".utf8)
    }

    // MARK: - Tests
    func test_parser_withValidSingleCountry_shouldReturnSuccess() {
        let country = makeMockCountry_Normal()
        let jsonData = makeMockJSON(from: [country])
        
        let result = parser.parser(jsonData)
        
        switch result {
        case .success(let countries):
            XCTAssertEqual(countries?.count, 1)
            XCTAssertEqual(countries?.first?.name, franceName)
        case .failure:
            XCTFail("Expected valid result but got failure")
        }
    }

    func test_parser_withMultipleValidCountries_shouldReturnAll() {
        let countries = [makeMockCountry_Normal(), makeMockCountry_MissingSymbol()]
        let jsonData = makeMockJSON(from: countries)
        
        let result = parser.parser(jsonData)
        
        switch result {
        case .success(let parsedCountries):
            XCTAssertEqual(parsedCountries?.count, countries.count)
        case .failure:
            XCTFail("Expected success but got failure")
        }
    }

    func test_parser_withNilData_shouldReturnSuccessWithNil() {
        let result = parser.parser(nil)
        
        switch result {
        case .success(let countries):
            XCTAssertNil(countries)
        case .failure:
            XCTFail("Expected success with nil but got failure")
        }
    }

    func test_parser_withInvalidJSON_shouldReturnFailure() {
        let jsonData = makeCorruptedJSON()
        
        let result = parser.parser(jsonData)
        
        switch result {
        case .success:
            XCTFail("Expected failure but got success")
        case .failure(let error):
            XCTAssertEqual(error as? CountriesParserError, .decodingFailure)
        }
    }

    func test_parser_withCountryMissingCurrencySymbol_shouldDecodeSuccessfully() {
        let country = makeMockCountry_MissingSymbol()
        let jsonData = makeMockJSON(from: [country])
        
        let result = parser.parser(jsonData)
        
        switch result {
        case .success(let countries):
            XCTAssertEqual(countries?.first?.currency.symbol, nil)
        case .failure:
            XCTFail("Expected success despite missing symbol")
        }
    }

    func test_parser_withCountryMissingLanguageCode_shouldDecodeSuccessfully() {
        let country = makeMockCountry_MissingLanguageCode()
        let jsonData = makeMockJSON(from: [country])
        
        let result = parser.parser(jsonData)
        
        switch result {
        case .success(let countries):
            XCTAssertNil(countries?.first?.language.code)
            XCTAssertEqual(countries?.first?.language.name, japaneseName)
        case .failure:
            XCTFail("Expected success with missing language code")
        }
    }

    func test_parser_withEmptyCountryList_shouldReturnEmptyArray() {
        let jsonData = makeMockJSON(from: [])
        
        let result = parser.parser(jsonData)
        
        switch result {
        case .success(let countries):
            XCTAssertEqual(countries?.count, 0)
        case .failure:
            XCTFail("Expected empty array, not failure")
        }
    }

    func test_parser_withMultipleComplexCountries_shouldReturnCorrectCount() {
        let countries = [
            makeMockCountry_SpecialCharacters(),
            makeMockCountry_LargeRegionName(),
            makeMockCountry_LanguageCodeNil()
        ]
        let jsonData = makeMockJSON(from: countries)
        
        let result = parser.parser(jsonData)
        
        switch result {
        case .success(let parsedCountries):
            XCTAssertEqual(parsedCountries?.count, countries.count)
        case .failure:
            XCTFail("Expected all countries to parse")
        }
    }

    func test_parser_withSpecialCurrencyCode_shouldStillParse() {
        let country = makeMockCountry_SpecialCurrencyCode()
        let jsonData = makeMockJSON(from: [country])
        
        let result = parser.parser(jsonData)
        
        switch result {
        case .success(let countries):
            XCTAssertEqual(countries?.first?.currency.code, specialCurrencyCode)
        case .failure:
            XCTFail("Special characters in currency code should be allowed")
        }
    }

    func test_parser_withNullFieldAsJSON_shouldFail() {
        let jsonData = Data(nullFieldJSON.utf8)
        
        let result = parser.parser(jsonData)
        
        switch result {
        case .success:
            XCTFail("Expected decoding failure with null name")
        case .failure(let error):
            XCTAssertEqual(error as? CountriesParserError, .decodingFailure)
        }
    }

    func test_parser_withDuplicateCountries_shouldParseAll() {
        let country = makeMockCountry_Normal()
        let jsonData = makeMockJSON(from: [country, country])
        
        let result = parser.parser(jsonData)
        
        switch result {
        case .success(let countries):
            XCTAssertEqual(countries?.count, 2)
        case .failure:
            XCTFail("Expected duplicates to be parsed successfully")
        }
    }

    func test_parser_withNoFields_shouldFailGracefully() {
        let jsonData = Data(noFieldsJSON.utf8)
        
        let result = parser.parser(jsonData)
        
        switch result {
        case .success:
            XCTFail("Expected decoding failure due to missing required fields")
        case .failure(let error):
            XCTAssertEqual(error as? CountriesParserError, .decodingFailure)
        }
    }
}
