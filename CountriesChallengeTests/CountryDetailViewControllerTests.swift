import XCTest
@testable import CountriesChallenge

final class CountryDetailViewControllerTests: XCTestCase {

    var country: Country!
    var viewController: CountryDetailViewController!

    override func setUp() {
        super.setUp()
        country = Country(
            capital: "Testville",
            code: "TV",
            currency: Currency(code: "TVC", name: "TestCoin", symbol: "$"),
            flag: "\u{1F3F3}",
            language: Language(code: "tv", name: "Testish"),
            name: "Testland",
            region: "Testonia"
        )
        viewController = CountryDetailViewController(country: country)
        _ = viewController.view // force viewDidLoad
    }

    override func tearDown() {
        country = nil
        viewController = nil
        super.tearDown()
    }

    func testViewControllerLoadsCorrectly() {
        XCTAssertNotNil(viewController.view)
    }

    func testTitleIsSetCorrectly() {
        XCTAssertEqual(viewController.title, "Testland")
    }

    func testNameAndRegionLabelDisplaysCorrectData() {
        let labelText = viewController.view.allLabelsTexts().first(where: { $0.contains("Testland") })
        XCTAssertNotNil(labelText)
        XCTAssertTrue(labelText?.contains("Testonia") ?? false)
    }

    func testCodeLabelDisplaysCorrectData() {
        let labelText = viewController.view.allLabelsTexts().first { $0 == "TV" }
        XCTAssertNotNil(labelText)
    }

    func testCapitalLabelDisplaysCorrectData() {
        let labelText = viewController.view.allLabelsTexts().first { $0 == "Testville" }
        XCTAssertNotNil(labelText)
    }

    func testMissingCapitalDisplaysEmptyString() {
        let emptyCapitalCountry = Country(
            capital: "",
            code: "TV",
            currency: Currency(code: "TVC", name: "TestCoin", symbol: "$"),
            flag: "\u{1F3F3}",
            language: Language(code: "tv", name: "Testish"),
            name: "Nowhere",
            region: "Unknown"
        )
        let vc = CountryDetailViewController(country: emptyCapitalCountry)
        _ = vc.view
        let labelText = vc.view.allLabelsTexts().first { $0 == "" }
        XCTAssertNotNil(labelText)
    }

    func testViewContainsMainStackView() {
        let stackViews = viewController.view.subviewsRecursive().compactMap { $0 as? UIStackView }
        XCTAssertFalse(stackViews.isEmpty)
    }

    func testStackViewHierarchyIntegrity() {
        let targetStack = viewController.view
            .subviewsRecursive()
            .compactMap { $0 as? UIStackView }
            .first(where: { stack in
                stack.arrangedSubviews.contains(where: { $0 is UILabel && ($0 as? UILabel)?.text == "Testland, Testonia" })
            })

        XCTAssertNotNil(targetStack, "Expected stack view with nameAndRegionLabel")
        XCTAssertTrue(targetStack?.arrangedSubviews.contains(where: { $0 is UILabel }) ?? false)
    }

    func testMultipleLabelsAreVisible() {
        let labels = viewController.view.subviewsRecursive().compactMap { $0 as? UILabel }
        XCTAssertGreaterThanOrEqual(labels.count, 3)
        labels.forEach {
            XCTAssertFalse($0.isHidden)
        }
    }
}

// MARK: - UIView Helper Extensions for Test Assertions

extension UIView {
    func subviewsRecursive() -> [UIView] {
        return subviews + subviews.flatMap { $0.subviewsRecursive() }
    }

    func allLabelsTexts() -> [String] {
        return subviewsRecursive()
            .compactMap { $0 as? UILabel }
            .compactMap { $0.text }
    }
}

