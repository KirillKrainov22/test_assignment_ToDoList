import Foundation

final class TaskDetailInteractor: TaskDetailInteractorInputProtocol {

    weak var output: TaskDetailInteractorOutputProtocol?

    private let repository: TodoRepositoryProtocol

    init(repository: TodoRepositoryProtocol = TodoRepository()) {
        self.repository = repository
    }

    func save(_ todo: Todo) {
        repository.update(todo) { [weak self] result in
            switch result {
            case .success:
                self?.output?.didSave()
            case let .failure(error):
                self?.output?.didFail(error: error)
            }
        }
    }
}
