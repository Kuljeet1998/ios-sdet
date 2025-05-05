import Foundation

enum CountriesServiceError: Error, Equatable {
    case failure(NSError)  // NSError is Equatable
    case invalidUrl(String)
    case invalidData
    case decodingFailure
}

protocol CountriesServiceRequestDelegate: AnyObject {
    func didUpdate(error: Error?)
}

class CountriesService {
    private let urlString: String
    private let session: URLSession
    private let countriesParser: CountriesParser

    // ✅ Dependency injection
    init(urlString: String = "https://gist.githubusercontent.com/peymano-wmt/32dcb892b06648910ddd40406e37fdab/raw/db25946fd77c5873b0303b858e861ce724e0dcd0/countries.json",
         urlSession: URLSession = .shared,
         parser: CountriesParser = CountriesParser()) {
        self.urlString = urlString
        self.session = urlSession
        self.countriesParser = parser
    }

    func fetchCountries() async throws -> [Country] {
        guard let url = URL(string: urlString) else {
            throw CountriesServiceError.invalidUrl(urlString)
        }

        return try await withUnsafeThrowingContinuation { continuation in
            let task = session.dataTask(with: url) { [weak self] data, response, error in
                if let error = error {
                    return continuation.resume(throwing: CountriesServiceError.failure(error as NSError))
                }
                guard let data = data else {
                    return continuation.resume(throwing: CountriesServiceError.invalidData)
                }
                guard let result = self?.countriesParser.parser(data) else {
                    return continuation.resume(throwing: CountriesServiceError.decodingFailure)
                }
                switch result {
                case .success(let countries):
                    continuation.resume(returning: countries ?? [])
                case .failure:
                    continuation.resume(throwing: CountriesServiceError.decodingFailure)
                }
            }
            task.resume()
        }
    }
}
