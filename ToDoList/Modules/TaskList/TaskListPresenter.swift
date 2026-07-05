import Foundation

final class TaskListPresenter: TaskListPresenterProtocol {

    weak var view: TaskListViewProtocol?
    var interactor: TaskListInteractorInputProtocol?
    var router: TaskListRouterProtocol?

    private var todos: [Todo] = []
    private var currentQuery: String = ""

    func viewDidLoad() {
        interactor?.fetchTodos()
    }

    func didSelectItem(id: UUID) {
        didTapEdit(id: id)
    }

    func didToggleCompletion(id: UUID) {
        interactor?.toggleCompletion(id: id)
    }

    func didChangeSearch(query: String) {
        currentQuery = query
        interactor?.search(query: query)
    }

    func didTapAdd() {
        router?.openCreate(onComplete: { [weak self] in
            self?.reload()
        })
    }

    func didTapEdit(id: UUID) {
        guard let todo = todos.first(where: { $0.id == id }) else {
            return
        }
        router?.openEdit(todo: todo, onComplete: { [weak self] in
            self?.reload()
        })
    }

    func didTapShare(id: UUID) {
        guard let todo = todos.first(where: { $0.id == id }) else {
            return
        }
        let text = todo.details.isEmpty ? todo.title : "\(todo.title)\n\n\(todo.details)"
        view?.presentShare(text: text)
    }

    func didTapDelete(id: UUID) {
        interactor?.delete(id: id)
    }

    private func reload() {
        if currentQuery.isEmpty {
            interactor?.fetchTodos()
        } else {
            interactor?.search(query: currentQuery)
        }
    }

    private func makeViewModels() -> [TaskCellViewModel] {
        return todos.map { todo in
            TaskCellViewModel(
                id: todo.id,
                title: todo.title,
                details: todo.details,
                dateText: Formatters.shortDate.string(from: todo.createdAt),
                isCompleted: todo.isCompleted
            )
        }
    }
}

extension TaskListPresenter: TaskListInteractorOutputProtocol {

    func didLoad(todos: [Todo]) {
        self.todos = todos
        view?.show(items: makeViewModels())
        view?.showCount(Formatters.tasksCount(todos.count))
    }

    func didFail(error: Error) {
        view?.showError(error.localizedDescription)
    }
}
