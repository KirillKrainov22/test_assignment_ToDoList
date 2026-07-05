import Foundation

final class TaskDetailPresenter: TaskDetailPresenterProtocol {

    weak var view: TaskDetailViewProtocol?
    var interactor: TaskDetailInteractorInputProtocol?
    var router: TaskDetailRouterProtocol?

    var onComplete: (() -> Void)?

    private var todo: Todo?

    init(todo: Todo?) {
        self.todo = todo
    }

    func viewDidLoad() {
        let existing = todo
        let dateSource = existing?.createdAt ?? Date()
        view?.display(
            title: existing?.title ?? "",
            dateText: Formatters.shortDate.string(from: dateSource),
            details: existing?.details ?? ""
        )
    }

    func onLeave(title: String, details: String) {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDetails = details.trimmingCharacters(in: .whitespacesAndNewlines)

        if todo == nil && trimmedTitle.isEmpty && trimmedDetails.isEmpty {
            return
        }

        if let existing = todo,
           existing.title == trimmedTitle,
           existing.details == trimmedDetails {
            return
        }

        let updated: Todo
        if let existing = todo {
            updated = Todo(
                id: existing.id,
                remoteId: existing.remoteId,
                title: trimmedTitle.isEmpty ? existing.title : trimmedTitle,
                details: trimmedDetails,
                createdAt: existing.createdAt,
                isCompleted: existing.isCompleted
            )
        } else {
            updated = Todo(
                title: trimmedTitle,
                details: trimmedDetails,
                createdAt: Date(),
                isCompleted: false
            )
        }

        interactor?.save(updated)
    }
}

extension TaskDetailPresenter: TaskDetailInteractorOutputProtocol {

    func didSave() {
        onComplete?()
    }

    func didFail(error: Error) {
        view?.showError(error.localizedDescription)
    }
}
