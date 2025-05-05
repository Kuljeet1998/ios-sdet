//
//  CountriesViewModel.swift
//  CountriesChallenge
//

import Combine
import Foundation

class CountriesViewModel {
    private var service = CountriesService()


    private(set) var countriesSubject = CurrentValueSubject<[Country], Never>([])
    private(set) var errorSubject = CurrentValueSubject<Error?, Never>(nil)

     init(service: CountriesService = CountriesService()) {
        self.service = service
    }


    func refreshCountries() {
        Task {
            do {
                let countries = try await service.fetchCountries()
                self.countriesSubject.value = countries
            } catch {
                self.errorSubject.value = error
            }
        }
    }
}
