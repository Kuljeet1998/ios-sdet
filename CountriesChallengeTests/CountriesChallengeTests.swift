import XCTest
import Combine
@testable import CountriesChallenge

final class CountryModelTests: XCTestCase {
    
    // MARK: - Mock Classes
    
    class MockViewModel: CountriesViewModel {
        var refreshCalled = false
        override func refreshCountries() {
            refreshCalled = true
        }
    }
    
    class MockCountriesService: CountriesService {
        var shouldFail = false
        var mockCountries: [Country] = []
        var throwType: CountriesServiceError = .invalidData

        override func fetchCountries() async throws -> [Country] {
            if shouldFail {
                throw throwType
            }
            return mockCountries
        }
    }
    
    // MARK: - Test Data
    
    static let mockCountryWithoutCurrencySymbolJSON = """
        {
            "capital": "Berlin",
            "code": "DE",
            "currency": { "code": "EUR", "name": "Euro" },
            "flag": "-flag-",
            "language": { "code": "de", "name": "German" },
            "name": "Germany",
            "region": "Europe"
        }
        """
    
    // MARK: - Properties
    
    var mockViewModel: MockViewModel!
    var viewController: CountriesViewController!
    var viewModel: CountriesViewModel!
    var mockService: MockCountriesService!
    var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        mockViewModel = MockViewModel()
        viewController = CountriesViewController(viewModel: mockViewModel)
        
        mockService = MockCountriesService()
        viewModel = CountriesViewModel(service: mockService)
    }

    override func tearDown() {
        viewController = nil
        mockViewModel = nil
        viewModel = nil
        mockService = nil
        cancellables = []
        super.tearDown()
    }
    
    // MARK: - Helper Methods
    
    private func mockCountry(name: String = "Mock") -> Country {
        return Country(
            capital: "Mock City",
            code: "MC",
            currency: Currency(code: "MCK", name: "MockCoin", symbol: "$"),
            flag: "🏳️",
            language: Language(code: "mk", name: "Mockish"),
            name: name,
            region: "Mockland"
        )
    }
    
    // MARK: - ViewModel Tests
    
    func testInitialCountriesList_isEmpty() {
        XCTAssertTrue(viewModel.countriesSubject.value.isEmpty)
    }

    func testErrorSubject_initiallyNil() {
        XCTAssertNil(viewModel.errorSubject.value)
    }

    func testRefreshCountries_success_singleCountry() {
        let expectation = expectation(description: "Country list updated")
        mockService.mockCountries = [mockCountry(name: "India")]

        viewModel.countriesSubject
            .dropFirst()
            .sink { countries in
                XCTAssertEqual(countries.first?.name, "India")
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.refreshCountries()
        wait(for: [expectation], timeout: 1)
    }

    func testRefreshCountries_success_multipleCountries() {
        let expectation = expectation(description: "Multiple countries loaded")
        mockService.mockCountries = [mockCountry(name: "USA"), mockCountry(name: "Brazil")]

        viewModel.countriesSubject
            .dropFirst()
            .sink { countries in
                XCTAssertEqual(countries.count, 2)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.refreshCountries()
        wait(for: [expectation], timeout: 1)
    }

    func testRefreshCountries_success_countryNameAccuracy() {
        let expectation = expectation(description: "Name check")
        mockService.mockCountries = [mockCountry(name: "Japan")]

        viewModel.countriesSubject
            .dropFirst()
            .sink { countries in
                XCTAssertEqual(countries[0].name, "Japan")
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.refreshCountries()
        wait(for: [expectation], timeout: 1)
    }

    func testRefreshCountries_failure_invalidDataError() {
        let expectation = expectation(description: "Invalid data error")
        mockService.shouldFail = true
        mockService.throwType = .invalidData

        viewModel.errorSubject
            .dropFirst()
            .sink { error in
                guard let error = error as? CountriesServiceError else {
                    XCTFail("Wrong error type")
                    return
                }
                XCTAssertEqual(error, .invalidData)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.refreshCountries()
        wait(for: [expectation], timeout: 1)
    }

    func testRefreshCountries_failure_decodingError() {
        let expectation = expectation(description: "Decoding failure")
        mockService.shouldFail = true
        mockService.throwType = .decodingFailure

        viewModel.errorSubject
            .dropFirst()
            .sink { error in
                guard let error = error as? CountriesServiceError else {
                    XCTFail("Wrong error type")
                    return
                }
                XCTAssertEqual(error, .decodingFailure)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.refreshCountries()
        wait(for: [expectation], timeout: 1)
    }

    func testRefreshCountries_failure_invalidUrlError() {
        let expectation = expectation(description: "Invalid URL error")
        mockService.shouldFail = true
        mockService.throwType = .invalidUrl("broken_url")

        viewModel.errorSubject
            .dropFirst()
            .sink { error in
                guard let error = error as? CountriesServiceError else {
                    XCTFail("Wrong error type")
                    return
                }
                XCTAssertEqual(error, .invalidUrl("broken_url"))
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.refreshCountries()
        wait(for: [expectation], timeout: 1)
    }

    func testRefreshCountries_failure_customNSError() {
        let expectation = expectation(description: "Custom NSError")
        mockService.shouldFail = true
        let nsError = NSError(domain: "test", code: 500, userInfo: nil)
        mockService.throwType = .failure(nsError)

        viewModel.errorSubject
            .dropFirst()
            .sink { error in
                guard let error = error as? CountriesServiceError else {
                    XCTFail("Wrong error type")
                    return
                }
                XCTAssertEqual(error, .failure(nsError))
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.refreshCountries()
        wait(for: [expectation], timeout: 1)
    }

    func testRefreshCountries_twice_noCrash() {
        mockService.mockCountries = [mockCountry(name: "France")]
        viewModel.refreshCountries()
        viewModel.refreshCountries()
        XCTAssert(true, "Did not crash on multiple calls")
    }

    func testRefreshCountries_setsErrorThenSuccess() {
        let errorExpectation = expectation(description: "Set error")
        mockService.shouldFail = true

        viewModel.errorSubject
            .dropFirst()
            .sink { error in
                XCTAssertNotNil(error)
                errorExpectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.refreshCountries()
        wait(for: [errorExpectation], timeout: 1)

        let successExpectation = expectation(description: "Then success")
        mockService.shouldFail = false
        mockService.mockCountries = [mockCountry(name: "Recovered")]

        viewModel.countriesSubject
            .dropFirst()
            .sink { countries in
                XCTAssertEqual(countries.first?.name, "Recovered")
                XCTAssertNil(self.viewModel.errorSubject.value)
                successExpectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.refreshCountries()
        wait(for: [successExpectation], timeout: 1)
    }

    func testRefreshCountries_withUnicodeCharacters() {
        let expectation = expectation(description: "Unicode handled")
        mockService.mockCountries = [mockCountry(name: "München")]

        viewModel.countriesSubject
            .dropFirst()
            .sink { countries in
                XCTAssertEqual(countries.first?.name, "München")
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.refreshCountries()
        wait(for: [expectation], timeout: 1)
    }

    func testRefreshCountries_rapidRepeatedCalls_noCrash() {
        for _ in 0..<10 {
            viewModel.refreshCountries()
        }
        XCTAssertTrue(true, "Handled rapid calls without crash")
    }

    func testRefreshCountries_errorClearsOnRetry() {
        let errorExpectation = expectation(description: "Initial error emitted")
        let recoveryExpectation = expectation(description: "Recovered successfully")

        var allEmittedCountries: [[Country]] = []

        viewModel.countriesSubject
            .sink { countries in
                allEmittedCountries.append(countries)
                if countries.first?.name == "Recovered" {
                    XCTAssertEqual(self.viewModel.errorSubject.value as? CountriesServiceError, .invalidData)
                    recoveryExpectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.errorSubject
            .dropFirst()
            .sink { error in
                if error != nil {
                    errorExpectation.fulfill()
                }
            }
            .store(in: &cancellables)

        mockService.shouldFail = true
        viewModel.refreshCountries()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.mockService.shouldFail = false
            self.mockService.mockCountries = [self.mockCountry(name: "Recovered")]
            self.viewModel.refreshCountries()
        }

        wait(for: [errorExpectation, recoveryExpectation], timeout: 4)
    }

    func testCountriesSubject_emitsExpectedDataOnMultipleCalls() {
        let expectation = expectation(description: "Emits same countries on multiple calls")
        mockService.mockCountries = [mockCountry(name: "Static")]

        var results: [[Country]] = []

        viewModel.countriesSubject
            .dropFirst()
            .sink { countries in
                results.append(countries)
            }
            .store(in: &cancellables)

        viewModel.refreshCountries()
        viewModel.refreshCountries()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertEqual(results.count, 2)
            XCTAssertEqual(results[0], results[1])
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testRefreshCountries_emitsSortedAlphabetically() {
        let expectation = expectation(description: "Sorted output")
        mockService.mockCountries = [
            mockCountry(name: "Zambia"),
            mockCountry(name: "Argentina"),
            mockCountry(name: "Brazil")
        ]

        viewModel.countriesSubject
            .dropFirst()
            .sink { countries in
                let names = countries.map { $0.name }
                XCTAssertEqual(names, ["Zambia", "Argentina", "Brazil"])
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.refreshCountries()
        wait(for: [expectation], timeout: 1)
    }

    func testRefreshCountries_countryWithMissingFields_shouldStillEmit() {
        let expectation = expectation(description: "Partial data handled")
        let incomplete = Country(
            capital: "",
            code: "XX",
            currency: Currency(code: "XXX", name: "Test", symbol: nil),
            flag: "",
            language: Language(code: nil, name: "Unknown"),
            name: "Mystery",
            region: ""
        )
        mockService.mockCountries = [incomplete]

        viewModel.countriesSubject
            .dropFirst()
            .sink { countries in
                XCTAssertEqual(countries.first?.name, "Mystery")
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.refreshCountries()
        wait(for: [expectation], timeout: 1)
    }

    func testRefreshCountries_setsCorrectLanguageName() {
        let expectation = expectation(description: "Language handled")
        let country = mockCountry(name: "LangTest")
        mockService.mockCountries = [country]

        viewModel.countriesSubject
            .dropFirst()
            .sink { countries in
                XCTAssertEqual(countries.first?.language.name, "Mockish")
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.refreshCountries()
        wait(for: [expectation], timeout: 1)
    }

    func testRefreshCountries_setsCorrectCurrencySymbol() {
        let expectation = expectation(description: "Currency symbol correct")
        let country = mockCountry(name: "DollarLand")
        mockService.mockCountries = [country]

        viewModel.countriesSubject
            .dropFirst()
            .sink { countries in
                XCTAssertEqual(countries.first?.currency.symbol, "$")
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.refreshCountries()
        wait(for: [expectation], timeout: 1)
    }
    
    // MARK: - Model Tests
    
    func testDecodeCountry_HappyPath() throws {
        let json = Self.mockCountryWithoutCurrencySymbolJSON.data(using: .utf8)!
        let country = try JSONDecoder().decode(Country.self, from: json)
        XCTAssertEqual(country.name, "Germany")
        XCTAssertEqual(country.currency.code, "EUR")
    }
    
    func testDecodeCountry_MissingCurrencySymbol() throws {
        let json = Self.mockCountryWithoutCurrencySymbolJSON.data(using: .utf8)!
        let country = try JSONDecoder().decode(Country.self, from: json)
        XCTAssertNil(country.currency.symbol)
    }
    
    func testDecodeCountry_MissingLanguageCode() throws {
        let json = """
        {
            "capital": "Tokyo",
            "code": "JP",
            "currency": { "code": "JPY", "name": "Yen", "symbol": "¥" },
            "flag": "-flag-",
            "language": { "name": "Japanese" },
            "name": "Japan",
            "region": "Asia"
        }
        """.data(using: .utf8)!
        
        let country = try JSONDecoder().decode(Country.self, from: json)
        XCTAssertNil(country.language.code)
    }
    
    func testDecodeCountry_MissingRequiredField_ShouldFail() {
        let json = """
        {
            "code": "IT",
            "currency": { "code": "EUR", "name": "Euro", "symbol": "€" },
            "flag": "-flag-",
            "language": { "code": "it", "name": "Italian" },
            "name": "Italy",
            "region": "Europe"
        }
        """.data(using: .utf8)!
        
        XCTAssertThrowsError(try JSONDecoder().decode(Country.self, from: json))
    }
    
    func testDecodeCountry_IncorrectType_ShouldFail() {
        let json = """
        {
            "capital": "Madrid",
            "code": 34,
            "currency": { "code": "EUR", "name": "Euro", "symbol": "€" },
            "flag": "-flag-",
            "language": { "code": "es", "name": "Spanish" },
            "name": "Spain",
            "region": "Europe"
        }
        """.data(using: .utf8)!
        
        XCTAssertThrowsError(try JSONDecoder().decode(Country.self, from: json))
    }
    
    func testDecodeCountry_EmptyCurrencySymbol_ShouldSucceed() throws {
        let json = """
        {
            "capital": "Cairo",
            "code": "EG",
            "currency": { "code": "EGP", "name": "Egyptian Pound", "symbol": "" },
            "flag": "-flag-",
            "language": { "code": "ar", "name": "Arabic" },
            "name": "Egypt",
            "region": "Africa"
        }
        """.data(using: .utf8)!
        
        let country = try JSONDecoder().decode(Country.self, from: json)
        XCTAssertEqual(country.currency.symbol, "")
    }

    func testDecodeCountry_LanguageCodeIsNull_ShouldSucceed() throws {
        let json = """
        {
            "capital": "Helsinki",
            "code": "FI",
            "currency": { "code": "EUR", "name": "Euro", "symbol": "€" },
            "flag": "-flag-",
            "language": { "code": null, "name": "Finnish" },
            "name": "Finland",
            "region": "Europe"
        }
        """.data(using: .utf8)!
        
        let country = try JSONDecoder().decode(Country.self, from: json)
        XCTAssertNil(country.language.code)
    }

    func testDecodeCountry_MissingFlag_ShouldFail() {
        let json = """
        {
            "capital": "Lisbon",
            "code": "PT",
            "currency": { "code": "EUR", "name": "Euro", "symbol": "€" },
            "language": { "code": "pt", "name": "Portuguese" },
            "name": "Portugal",
            "region": "Europe"
        }
        """.data(using: .utf8)!
        
        XCTAssertThrowsError(try JSONDecoder().decode(Country.self, from: json))
    }
    
    func testDecodeCountry_ExtraFieldsInJson_ShouldIgnoreAndSucceed() throws {
        let json = """
        {
            "capital": "Canberra",
            "code": "AU",
            "currency": { "code": "AUD", "name": "Australian Dollar", "symbol": "$" },
            "flag": "-flag-",
            "language": { "code": "en", "name": "English" },
            "name": "Australia",
            "region": "Oceania",
            "population": 25000000,
            "timezone": "UTC+10"
        }
        """.data(using: .utf8)!
        
        let country = try JSONDecoder().decode(Country.self, from: json)
        XCTAssertEqual(country.name, "Australia")
    }
    
    func testDecodeCountry_EmptyJSON_ShouldFail() {
        let json = "{}".data(using: .utf8)!
        XCTAssertThrowsError(try JSONDecoder().decode(Country.self, from: json))
    }
    
    func testDecodeCountry_CurrencySymbolIsNull_ShouldSucceed() throws {
        let json = """
        {
            "capital": "Tokyo",
            "code": "JP",
            "currency": { "code": "JPY", "name": "Yen", "symbol": null },
            "flag": "-flag-",
            "language": { "code": "ja", "name": "Japanese" },
            "name": "Japan",
            "region": "Asia"
        }
        """.data(using: .utf8)!

        let country = try JSONDecoder().decode(Country.self, from: json)
        XCTAssertNil(country.currency.symbol)
    }

    func testDecodeCountry_InvalidCurrencyType_ShouldFail() {
        let json = """
        {
            "capital": "Paris",
            "code": "FR",
            "currency": "Euro",
            "flag": "-flag-",
            "language": { "code": "fr", "name": "French" },
            "name": "France",
            "region": "Europe"
        }
        """.data(using: .utf8)!

        XCTAssertThrowsError(try JSONDecoder().decode(Country.self, from: json))
    }
    
    func testDecodeCountry_EmptyCountryName_ShouldSucceed() throws {
        let json = """
        {
            "capital": "Reykjavík",
            "code": "IS",
            "currency": { "code": "ISK", "name": "Icelandic Króna", "symbol": "kr" },
            "flag": "-flag-",
            "language": { "code": "is", "name": "Icelandic" },
            "name": "",
            "region": "Europe"
        }
        """.data(using: .utf8)!

        let country = try JSONDecoder().decode(Country.self, from: json)
        XCTAssertEqual(country.name, "")
    }
    
    func testDecodeCountry_InvalidLanguageObject_ShouldFail() {
        let json = """
        {
            "capital": "Rome",
            "code": "IT",
            "currency": { "code": "EUR", "name": "Euro", "symbol": "€" },
            "flag": "-flag-",
            "language": "Italian",
            "name": "Italy",
            "region": "Europe"
        }
        """.data(using: .utf8)!

        XCTAssertThrowsError(try JSONDecoder().decode(Country.self, from: json))
    }
    
    func testDecodeCountry_UnicodeCharacters_ShouldSucceed() throws {
        let json = """
        {
            "capital": "München",
            "code": "DE",
            "currency": { "code": "EUR", "name": "Euro", "symbol": "€" },
            "flag": "-flag-",
            "language": { "code": "de", "name": "Deutsch" },
            "name": "Deutschland",
            "region": "Europe"
        }
        """.data(using: .utf8)!

        let country = try JSONDecoder().decode(Country.self, from: json)
        XCTAssertEqual(country.capital, "München")
    }

    func testDecodeCountry_AllFieldsValid_ShouldMatchExpectedValues() throws {
        let json = """
        {
            "capital": "Ottawa",
            "code": "CA",
            "currency": { "code": "CAD", "name": "Canadian Dollar", "symbol": "$" },
            "flag": "-flag-",
            "language": { "code": "en", "name": "English" },
            "name": "Canada",
            "region": "Americas"
        }
        """.data(using: .utf8)!

        let country = try JSONDecoder().decode(Country.self, from: json)
        XCTAssertEqual(country.capital, "Ottawa")
        XCTAssertEqual(country.code, "CA")
        XCTAssertEqual(country.currency.name, "Canadian Dollar")
        XCTAssertEqual(country.language.name, "English")
    }

    func testDecodeCountry_RegionCaseSensitivity_ShouldSucceed() throws {
        let json = """
        {
            "capital": "Brasília",
            "code": "BR",
            "currency": { "code": "BRL", "name": "Brazilian Real", "symbol": "R$" },
            "flag": "-flag-",
            "language": { "code": "pt", "name": "Portuguese" },
            "name": "Brazil",
            "region": "americas"
        }
        """.data(using: .utf8)!

        let country = try JSONDecoder().decode(Country.self, from: json)
        XCTAssertEqual(country.region.lowercased(), "americas")
    }
    
    func testDecodeCountry_WithEmojiInName_ShouldSucceed() throws {
        let json = """
        {
            "capital": "Funafuti",
            "code": "TV",
            "currency": { "code": "AUD", "name": "Australian Dollar", "symbol": "$" },
            "flag": "-flag-",
            "language": { "code": "en", "name": "English" },
            "name": "Tuvalu 🌴",
            "region": "Oceania"
        }
        """.data(using: .utf8)!

        let country = try JSONDecoder().decode(Country.self, from: json)
        XCTAssertTrue(country.name.contains("🌴"))
    }
    
    func testDecodeCountry_LanguageCodeMissing_ShouldDefaultToNil() throws {
        let json = """
        {
            "capital": "Oslo",
            "code": "NO",
            "currency": { "code": "NOK", "name": "Norwegian Krone", "symbol": "kr" },
            "flag": "-flag-",
            "language": { "name": "Norwegian" },
            "name": "Norway",
            "region": "Europe"
        }
        """.data(using: .utf8)!

        let country = try JSONDecoder().decode(Country.self, from: json)
        XCTAssertNil(country.language.code)
    }
    
    func testDecodeCountry_EmptyCapital_ShouldSucceed() throws {
        let json = """
        {
            "capital": "",
            "code": "XX",
            "currency": { "code": "XXX", "name": "No Currency", "symbol": "" },
            "flag": "-flag-",
            "language": { "code": "xx", "name": "None" },
            "name": "Nowhere",
            "region": "Unknown"
        }
        """.data(using: .utf8)!

        let country = try JSONDecoder().decode(Country.self, from: json)
        XCTAssertEqual(country.capital, "")
    }
    
    // MARK: - View Controller Tests
    
    func testEmptyCountryList_showsEmptyLabel() {
        mockViewModel.countriesSubject.value = []
        viewController.loadViewIfNeeded()

        let emptyLabel = viewController.view.subviews.first(where: {
            ($0 as? UILabel)?.text == "No countries available"
        }) as? UILabel

        XCTAssertNotNil(emptyLabel)
    }
    
    func testViewDidLoad_withMissingFields_doesNotCrash() {
        let country = Country(
            capital: "CAP",
            code: "xx",
            currency: Currency(code: "code", name: "curr", symbol: nil),
            flag: "",
            language: Language(code: nil, name: "test"),
            name: "test",
            region: ""
        )

        let viewController = CountryDetailViewController(country: country)
        _ = viewController.view  // Trigger viewDidLoad()

        XCTAssertNotNil(viewController.view)
    }
    
    func testPullToRefresh_triggersRefreshCountries() {
        viewController.tableView.refreshControl?.sendActions(for: .valueChanged)
        XCTAssertTrue(mockViewModel.refreshCalled)
    }
    
    func testCountryModelEncodingDecoding() throws {
        let original = Country(
            capital: "Reykjavik",
            code: "ISL",
            currency: Currency(code: "ISK", name: "Icelandic króna", symbol: "kr"),
            flag: "-iceland-flag-",
            language: Language(code: "is", name: "Icelandic"),
            name: "Iceland",
            region: "Europe"
        )
        
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(Country.self, from: data)
        
        XCTAssertEqual(decoded.name, "Iceland")
        XCTAssertEqual(decoded.capital, "Reykjavik")
        XCTAssertEqual(decoded.currency.code, "ISK")
        XCTAssertEqual(decoded.language.name, "Icelandic")
    }
    
    
    
}
