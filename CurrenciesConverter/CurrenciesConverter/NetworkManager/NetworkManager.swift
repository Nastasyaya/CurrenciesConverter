//
//  NetworkManager.swift
//  CurrenciesConverter
//
//  Created by Анастасия Кутняхова on 30.03.2024.
//

import Foundation

class NetworkManager {
    enum Error {
        case invalidData
        case invalidJSONDecode
        case invalidResponse
        case invalidURL
    }

    enum State {
        case success(Double)
        case loading
        case error(Error)
    }

    static let shared = NetworkManager()

    private init() {}

    func exchange(
        request: ExchangeCurrencyRequest,
        completion: @escaping (State) -> Void
    ) {
        completion(.loading)

        guard let url = makeURL(
            firstQueryValue: request.initialCurrency,
            secondQueryValue: request.targetCurrency,
            thirdQueryValue: request.value
        ) else {
            completion(.error(.invalidURL))
            return
        }
        let urlRequest = makeURLRequest(from: url)

        makeURLSessionDataTask(from: urlRequest, completion: completion).resume()
    }

    private func makeURLSessionDataTask(
        from urlRequest: URLRequest,
        completion: @escaping (State) -> Void
    ) -> URLSessionDataTask {
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            guard let response = response as? HTTPURLResponse else {
                completion(.error(.invalidResponse))
                return
            }

            print(response.statusCode)
            print(response.allHeaderFields)
            print(response.url?.description ?? "")

            guard let data else {
                completion(.error(.invalidData))
                return
            }

            do {
                let currency = try JSONDecoder().decode(Double.self, from: data)
                completion(.success(currency))
            } catch {
                completion(.error(.invalidJSONDecode))
            }
        }
    }

    private func makeURLRequest(from url: URL) -> URLRequest {
        var request = URLRequest(url: url)

        request.httpMethod = "GET"
        request.setValue(
            "1cb1beadb3mshacf37d2a60acf53p189f1ejsnebc851d7a365",
            forHTTPHeaderField: "X-RapidAPI-Key"
        )
        request.setValue(
            "currency-exchange.p.rapidapi.com",
            forHTTPHeaderField: "X-RapidAPI-Host"
        )
        request.timeoutInterval = 10.0

        return request
    }

    /// firstQueryValue - initial currency
    /// secondQueryValue - target currency
    /// thirdQueryValue - value
    private func makeURL(
        firstQueryValue: String,
        secondQueryValue: String,
        thirdQueryValue: String
    ) -> URL? {
        var urlComponents = URLComponents()

        urlComponents.scheme = "https"
        urlComponents.host = "currency-exchange.p.rapidapi.com"
        urlComponents.path = "/exchange"
        urlComponents.queryItems = [
            URLQueryItem(name: "from", value: firstQueryValue),
            URLQueryItem(name: "to", value: secondQueryValue),
            URLQueryItem(name: "q", value: thirdQueryValue)
        ]

        return urlComponents.url
    }
}
