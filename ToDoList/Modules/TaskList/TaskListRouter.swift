import UIKit

final class TaskListRouter: TaskListRouterProtocol {

    private weak var viewController: UIViewController?

    static func build() -> UIViewController {
        let view = TaskListViewController()
        let interactor = TaskListInteractor()
        let presenter = TaskListPresenter()
        let router = TaskListRouter()

        view.presenter = presenter

        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router

        interactor.output = presenter
        router.viewController = view

        return view
    }

    func openCreate(onComplete: @escaping () -> Void) {
        let detail = TaskDetailRouter.build(todo: nil, onComplete: onComplete)
        viewController?.navigationController?.pushViewController(detail, animated: true)
    }

    func openEdit(todo: Todo, onComplete: @escaping () -> Void) {
        let detail = TaskDetailRouter.build(todo: todo, onComplete: onComplete)
        viewController?.navigationController?.pushViewController(detail, animated: true)
    }
}
