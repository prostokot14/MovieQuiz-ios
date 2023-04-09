//
//  MoviesLoader.swift
//  MovieQuiz
//
//  Created by Антон Кашников on 08.04.2023.
//

import Foundation

protocol MoviesLoading {
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}

struct MoviesLoader: MoviesLoading {
    // MARK: - NetworkClient
    private let networkClient = NetworkClient()
    
    // MARK: - URL
    private var mostPopularMoviesUrl: URL {
        // Если мы не смогли преобразовать строку в URL, то приложение упадёт с ошибкой
        guard let url = URL(string: "https://imdb-api.com/en/API/Top250Movies/k_e3g62h7a") else {
            preconditionFailure("Unable to construct mostPopularMoviesUrl")
        }
        return url
    }
    
    public enum CustomError: Error, LocalizedError {
        case wrongAPIKey
        case custom(message: String)
        
        public var errorDescription: String? {
            switch self {
            case .wrongAPIKey:
                return "Wrong API - Key"
            case .custom(let message):
                return message
            }
        }
    }
    
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void) {
        networkClient.fetch(url: mostPopularMoviesUrl) { result in
            switch result {
            case .success(let data):
                do {
                    let mostPopularMovies = try JSONDecoder().decode(MostPopularMovies.self, from: data)
                    if mostPopularMovies.errorMessage.isEmpty { // если сообщение об ошибке пустое
                        handler(.success(mostPopularMovies))
                    } else {
                        let error = CustomError.custom(message: mostPopularMovies.errorMessage) // Иначе создаём нашу ошибку
                        handler(.failure(error))
                    }
                } catch {
                    handler(.failure(error))
                }
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
}
