import Foundation
@testable import CountriesChallenge

func makeMockCountry_Normal() -> Country {
    return Country(
        capital: "Paris",
        code: "FR",
        currency: Currency(code: "EUR", name: "Euro", symbol: "€"),
        flag: "-france-flag-",
        language: Language(code: "fr", name: "French"),
        name: "France",
        region: "Europe"
    )
}

func makeMockCountry_MissingSymbol() -> Country {
    return Country(
        capital: "Madrid",
        code: "ES",
        currency: Currency(code: "EUR", name: "Euro", symbol: nil),
        flag: "-spain-flag-",
        language: Language(code: "es", name: "Spanish"),
        name: "Spain",
        region: "Europe"
    )
}

func makeMockCountry_NoCode() -> Country {
    return Country(
        capital: "Unknown",
        code: "",
        currency: Currency(code: "", name: "Unknown", symbol: nil),
        flag: "",
        language: Language(code: nil, name: "Unknown"),
        name: "Nowhere",
        region: "Unknown"
    )
}
   

func makeMockCountry_LongNames() -> Country {
    return Country(
        capital: "Sri Jayawardenepura Kotte",
        code: "LK",
        currency: Currency(code: "LKR", name: "Sri Lankan Rupee", symbol: "රු"),
        flag: "-lanka-flag-",
        language: Language(code: "si", name: "Sinhalese"),
        name: "Democratic Socialist Republic of Sri Lanka",
        region: "Asia"
    )
}

func makeMockCountry_EmojiFlag() -> Country {
    return Country(
        capital: "Funafuti",
        code: "TV",
        currency: Currency(code: "AUD", name: "Australian Dollar", symbol: "$"),
        flag: "-aus-flag-",
        language: Language(code: "tvl", name: "Tuvaluan"),
        name: "Tuvalu",
        region: "Oceania"
    )
}

func makeMockCountry_WeirdCodes() -> Country {
    return Country(
        capital: "N/A",
        code: "123",
        currency: Currency(code: "XXX", name: "Test Currency", symbol: "?"),
        flag: "-undefined-flag-",
        language: Language(code: "", name: "None"),
        name: "Unknownland",
        region: "Undefined"
    )
}




func makeMockCountry_MultiWordName() -> Country {
    return Country(
        capital: "Sri Jayawardenepura Kotte",
        code: "LK",
        currency: Currency(code: "LKR", name: "Rupee", symbol: "Rs"),
        flag: "-lanka-flag-",
        language: Language(code: "si", name: "Sinhala"),
        name: "Sri Lanka",
        region: "Asia"
    )
}

func makeMockCountry_NullCurrencyFields() -> Country {
    return Country(
        capital: "Canberra",
        code: "AU",
        currency: Currency(code: "", name: "", symbol: nil),
        flag: "-aus-flag-",
        language: Language(code: "en", name: "English"),
        name: "Australia",
        region: "Oceania"
    )
}

func makeMockCountry_EmptyFields() -> Country {
    return Country(
        capital: "",
        code: "",
        currency: Currency(code: "", name: "", symbol: nil),
        flag: "",
        language: Language(code: nil, name: ""),
        name: "",
        region: ""
    )
}

func makeMockCountry_LanguageOnlyCode() -> Country {
    return Country(
        capital: "Berlin",
        code: "DE",
        currency: Currency(code: "EUR", name: "Euro", symbol: "€"),
        flag: "-germany-flag-",
        language: Language(code: "de", name: ""),
        name: "Germany",
        region: "Europe"
    )
}

func makeMockCountry_SpecialCharacters() -> Country {
    return Country(
        capital: "São Tomé",
        code: "ST",
        currency: Currency(code: "STD", name: "Dobra", symbol: "Db"),
        flag: "-africa-flag-",
        language: Language(code: "pt", name: "Português"),
        name: "São Tomé and Príncipe",
        region: "Africa"
    )
}

func makeMockCountry_NonLatinName() -> Country {
    return Country(
        capital: "Москва",
        code: "RU",
        currency: Currency(code: "RUB", name: "Рубль", symbol: "₽"),
        flag: "-russia-flag-",
        language: Language(code: "ru", name: "Русский"),
        name: "Россия",
        region: "Europe"
    )
}

func makeValidCountryResponseData() -> Data {
    let country = Country(
        capital: "Paris",
        code: "FR",
        currency: Currency(code: "EUR", name: "Euro", symbol: "€"),
        flag: "-france-flag-",
        language: Language(code: "fr", name: "French"),
        name: "France",
        region: "Europe"
    )
    let encoder = JSONEncoder()
    return try! encoder.encode([country]) // Note: we encode as an array
}

func makeMockCountry_NoLanguageCode() -> Country {
    return Country(
        capital: "Berlin",
        code: "DE",
        currency: Currency(code: "EUR", name: "Euro", symbol: "€"),
        flag: "-germany-flag-",
        language: Language(code: nil, name: "German"),
        name: "Germany",
        region: "Europe"
    )
}


func makeMockCountry_MissingLanguageName() -> Country {
    return Country(
        capital: "Madrid",
        code: "ES",
        currency: Currency(code: "EUR", name: "Euro", symbol: "€"),
        flag: "-spain-flag-",
        language: Language(code: "es", name: ""),
        name: "Spain",
        region: "Europe"
    )
}

func makeMockCountry_WithSpecialCharacterCode() -> Country {
    return Country(
        capital: "Rome",
        code: "IT_@",
        currency: Currency(code: "EUR", name: "Euro", symbol: "€"),
        flag: "-italy-flag-",
        language: Language(code: "it", name: "Italian"),
        name: "Italy",
        region: "Europe"
    )
}
func makeMockCountry_LargeRegionName() -> Country {
    return Country(
        capital: "Canberra",
        code: "AU",
        currency: Currency(code: "AUD", name: "Australian Dollar", symbol: "$"),
        flag: "🇦🇺",
        language: Language(code: "en", name: "English"),
        name: "Australia",
        region: String(repeating: "Oceania-", count: 20)
    )
}


func makeMockCountry_LanguageCodeNil() -> Country {
    return Country(
        capital: "Lisbon",
        code: "PT",
        currency: Currency(code: "EUR", name: "Euro", symbol: "€"),
        flag: "-portugal-flag-",
        language: Language(code: nil, name: "Portuguese"),
        name: "Portugal",
        region: "Europe"
    )
}

func makeMockCountry_WithEmoji() -> Country {
    return Country(
        capital: "Reykjavik",
        code: "IS",
        currency: Currency(code: "ISK", name: "Icelandic Króna", symbol: "kr"),
        flag: "-iceland-flag-",
        language: Language(code: "is", name: "Icelandic"),
        name: "Iceland 🧊",
        region: "Europe"
    )
}

func makeMockCountry_WithWhitespace() -> Country {
    return Country(
        capital: "Ottawa",
        code: "CA",
        currency: Currency(code: "CAD", name: " Canadian Dollar ", symbol: "$"),
        flag: "-canada-flag-",
        language: Language(code: "en", name: "English "),
        name: " Canada ",
        region: " North America "
    )
}

func makeMockCountry_SpecialCurrencyCode() -> Country {
    return Country(
        capital: "Bern",
        code: "CH",
        currency: Currency(code: "CHF$", name: "Swiss Franc", symbol: "₣"),
        flag: "-france-flag-",
        language: Language(code: "de", name: "German"),
        name: "Switzerland",
        region: "Europe"
    )
}

func makeMockCountry_MissingLanguageCode() -> Country {
    return Country(
        capital: "Tokyo",
        code: "JP",
        currency: Currency(code: "JPY", name: "Yen", symbol: "¥"),
        flag: "-japan-flag-",
        language: Language(code: nil, name: "Japanese"),
        name: "Japan",
        region: "Asia"
    )
}
