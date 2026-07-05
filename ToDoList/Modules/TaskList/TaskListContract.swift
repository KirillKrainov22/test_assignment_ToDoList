import UIKit

struct TaskCellViewModel {
    let id: UUID
    let title: String
    let details: String
    let dateText: String
    let isCompleted: Bool
}

protocol TaskListViewProtocol: AnyObject {
    func show(items: [TaskCellViewModel])
    func showCount(_ text: String)
    func showError(_ message: String)
    func presentShare(text: String)
}

protocol TaskListPresenterProtocol: AnyObject {
    func viewDidLoad()
    func didSelectItem(id: UUID)
    func didToggleCompletion(id: UUID)
    func didChangeSearch(query: String)
    func didTapAdd()
    func didTapEdit(id: UUID)
    func didTapShare(id: UUID)
    func didTapDelete(id: UUID)
}

protocol TaskListInteractorInputProtocol: AnyObject {
    func fetchTodos()
    func search(query: String)
    func toggleCompletion(id: UUID)
    func delete(id: UUID)
}

protocol TaskListInteractorOutputProtocol: AnyObject {
    func didLoad(todos: [Todo])
    func didFail(error: Error)
}

protocol TaskListRouterProtocol: AnyObject {
    func openCreate(onComplete: @escaping () -> Void)
    func openEdit(todo: Todo, onComplete: @escaping () -> Void)
}
