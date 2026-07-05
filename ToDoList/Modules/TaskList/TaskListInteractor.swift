import Foundation

final class TaskListInteractor: TaskListInteractorInputProtocol {

    weak var output: TaskListInteractorOutputProtocol?

    private let repository: TodoRepositoryProtocol

    init(repository: TodoRepositoryProtocol = TodoRepository()) {
        self.repository = repository
    }

    func fetchTodos() {
        repository.loadTodos { [weak self] result in
            self?.handle(result)
        }
    }

    func search(query: String) {
        repository.search(query: query) { [weak self] result in
            self?.handle(result)
        }
    }

    func toggleCompletion(id: UUID) {
        repository.toggleCompletion(id: id) { [weak self] result in
            switch result {
            case .success:
                self?.fetchTodos()
            case let .failure(error):
                self?.output?.didFail(error: error)
            }
        }
    }

    func delete(id: UUID) {
        repository.delete(id: id) { [weak self] result in
            switch result {
            case .success:
                self?.fetchTodos()
            case let .failure(error):
                self?.output?.didFail(error: error)
            }
        }
    }

    private func handle(_ result: Result<[Todo], Error>) {
        switch result {
        case let .success(todos):
            output?.didLoad(todos: todos)
        case let .failure(error):
            output?.didFail(error: error)
        }
    }
}
