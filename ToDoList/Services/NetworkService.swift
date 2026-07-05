import Foundation

enum NetworkError: Error {
    case invalidURL
    case noData
    case underlying(Error)
    case decoding(Error)
}

protocol NetworkServiceProtocol {

    func fetchTodos(completion: @escaping (Result<[TodoDTO], NetworkError>) -> Void)
}

final class NetworkService: NetworkServiceProtocol {

    private let urlString = "https://dummyjson.com/todos?limit=0"

    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchTodos(completion: @escaping (Result<[TodoDTO], NetworkError>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidURL))
            return
        }

        let task = session.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(.underlying(error)))
                return
            }

            guard let data = data else {
                completion(.failure(.noData))
                return
            }

            do {
                let response = try JSONDecoder().decode(TodosResponse.self, from: data)
                completion(.success(response.todos))
            } catch {
                completion(.failure(.decoding(error)))
            }
        }

        task.resume()
    }
}
