import Foundation

protocol TaskDetailViewProtocol: AnyObject {
    func display(title: String, dateText: String, details: String)
    func showError(_ message: String)
}

protocol TaskDetailPresenterProtocol: AnyObject {
    func viewDidLoad()

    func onLeave(title: String, details: String)
}

protocol TaskDetailInteractorInputProtocol: AnyObject {
    func save(_ todo: Todo)
}

protocol TaskDetailInteractorOutputProtocol: AnyObject {
    func didSave()
    func didFail(error: Error)
}

protocol TaskDetailRouterProtocol: AnyObject {}
