//
//  Country.swift
//  CountriesChallenge
//

import Foundation

struct Country: Codable, Equatable {
    let capital: String
    let code: String
    let currency: Currency
    let flag: String
    let language: Language
    let name: String
    let region: String
}
