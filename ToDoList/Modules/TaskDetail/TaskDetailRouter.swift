import UIKit

final class TaskDetailRouter: TaskDetailRouterProtocol {

    static func build(todo: Todo?, onComplete: @escaping () -> Void) -> UIViewController {
        let view = TaskDetailViewController()
        let interactor = TaskDetailInteractor()
        let presenter = TaskDetailPresenter(todo: todo)
        let router = TaskDetailRouter()

        view.presenter = presenter

        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        presenter.onComplete = onComplete

        interactor.output = presenter

        return view
    }
}
