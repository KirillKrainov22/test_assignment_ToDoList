import Foundation
@testable import ToDoList

final class MockNetworkService: NetworkServiceProtocol {

    var result: Result<[TodoDTO], NetworkError>

    init(result: Result<[TodoDTO], NetworkError>) {
        self.result = result
    }

    func fetchTodos(completion: @escaping (Result<[TodoDTO], NetworkError>) -> Void) {

        DispatchQueue.global().async {
            completion(self.result)
        }
    }
}

final class MockTodoRepository: TodoRepositoryProtocol {

    var todos: [Todo]

    init(todos: [Todo] = []) {
        self.todos = todos
    }

    func loadTodos(completion: @escaping (Result<[Todo], Error>) -> Void) {
        completion(.success(todos))
    }

    func search(query: String, completion: @escaping (Result<[Todo], Error>) -> Void) {
        let filtered = query.isEmpty
            ? todos
            : todos.filter { $0.title.localizedCaseInsensitiveContains(query) }
        completion(.success(filtered))
    }

    func create(_ todo: Todo, completion: @escaping (Result<Void, Error>) -> Void) {
        todos.append(todo)
        completion(.success(()))
    }

    func update(_ todo: Todo, completion: @escaping (Result<Void, Error>) -> Void) {
        if let index = todos.firstIndex(where: { $0.id == todo.id }) {
            todos[index] = todo
        } else {
            todos.append(todo)
        }
        completion(.success(()))
    }

    func delete(id: UUID, completion: @escaping (Result<Void, Error>) -> Void) {
        todos.removeAll { $0.id == id }
        completion(.success(()))
    }

    func toggleCompletion(id: UUID, completion: @escaping (Result<Void, Error>) -> Void) {
        if let index = todos.firstIndex(where: { $0.id == id }) {
            todos[index].isCompleted.toggle()
        }
        completion(.success(()))
    }
}
