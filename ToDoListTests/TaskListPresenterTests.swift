import XCTest
@testable import ToDoList

final class TaskListPresenterTests: XCTestCase {

    final class SpyView: TaskListViewProtocol {
        var items: [TaskCellViewModel] = []
        var countText: String?
        var errorMessage: String?
        var sharedText: String?

        func show(items: [TaskCellViewModel]) {
            self.items = items
        }

        func showCount(_ text: String) {
            countText = text
        }

        func showError(_ message: String) {
            errorMessage = message
        }

        func presentShare(text: String) {
            sharedText = text
        }
    }

    final class SpyRouter: TaskListRouterProtocol {
        var didOpenCreate = false
        var editedTodo: Todo?

        func openCreate(onComplete: @escaping () -> Void) {
            didOpenCreate = true
        }

        func openEdit(todo: Todo, onComplete: @escaping () -> Void) {
            editedTodo = todo
        }
    }

    private func makeModule(
        todos: [Todo]
    ) -> (TaskListPresenter, SpyView, SpyRouter, MockTodoRepository) {
        let repo = MockTodoRepository(todos: todos)
        let interactor = TaskListInteractor(repository: repo)
        let presenter = TaskListPresenter()
        let view = SpyView()
        let router = SpyRouter()

        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        interactor.output = presenter

        return (presenter, view, router, repo)
    }

    func testViewDidLoadShowsMappedItemsAndCount() {
        let todos = [
            Todo(title: "Alpha", details: "d1", isCompleted: false),
            Todo(title: "Beta", details: "", isCompleted: true)
        ]
        let (presenter, view, _, _) = makeModule(todos: todos)

        presenter.viewDidLoad()

        XCTAssertEqual(view.items.count, 2)
        XCTAssertEqual(view.items[0].title, "Alpha")
        XCTAssertTrue(view.items[1].isCompleted)
        XCTAssertEqual(view.countText, "2 Задачи")
    }

    func testTapAddOpensCreate() {
        let (presenter, _, router, _) = makeModule(todos: [])
        presenter.viewDidLoad()

        presenter.didTapAdd()

        XCTAssertTrue(router.didOpenCreate)
    }

    func testSelectItemOpensEditWithSameTodo() {
        let todo = Todo(title: "Editable")
        let (presenter, _, router, _) = makeModule(todos: [todo])
        presenter.viewDidLoad()

        presenter.didSelectItem(id: todo.id)

        XCTAssertEqual(router.editedTodo?.id, todo.id)
    }

    func testShareBuildsTextFromTitleAndDetails() {
        let todo = Todo(title: "Title", details: "Body")
        let (presenter, view, _, _) = makeModule(todos: [todo])
        presenter.viewDidLoad()

        presenter.didTapShare(id: todo.id)

        XCTAssertEqual(view.sharedText, "Title\n\nBody")
    }

    func testDeleteRemovesItemAndRefreshes() {
        let todo = Todo(title: "Delete me")
        let (presenter, view, _, repo) = makeModule(todos: [todo])
        presenter.viewDidLoad()
        XCTAssertEqual(view.items.count, 1)

        presenter.didTapDelete(id: todo.id)

        XCTAssertTrue(repo.todos.isEmpty)
        XCTAssertEqual(view.items.count, 0)
        XCTAssertEqual(view.countText, "0 Задач")
    }

    func testToggleFlipsCompletionAndRefreshes() {
        let todo = Todo(title: "Toggle", isCompleted: false)
        let (presenter, view, _, _) = makeModule(todos: [todo])
        presenter.viewDidLoad()

        presenter.didToggleCompletion(id: todo.id)

        XCTAssertTrue(view.items.first?.isCompleted ?? false)
    }

    func testSearchFiltersItems() {
        let todos = [
            Todo(title: "Buy milk"),
            Todo(title: "Read book")
        ]
        let (presenter, view, _, _) = makeModule(todos: todos)
        presenter.viewDidLoad()

        presenter.didChangeSearch(query: "milk")

        XCTAssertEqual(view.items.count, 1)
        XCTAssertEqual(view.items.first?.title, "Buy milk")
    }
}
