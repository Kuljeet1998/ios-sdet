//
//  CountriesParser.swift
//  CountriesChallenge
//

import Foundation

enum CountriesParserError: Error {
    case decodingFailure
}

class CountriesParser {
    func parser(_ data: Data?) -> Result<[Country]?, Error> {
        guard let data = data else {
            return Result.success(nil)
        }
        do {
            let countries = try JSONDecoder().decode([Country].self, from: data)
            return Result.success(countries)
        } catch {
            return Result.failure(CountriesParserError.decodingFailure)
        }
    }
}
