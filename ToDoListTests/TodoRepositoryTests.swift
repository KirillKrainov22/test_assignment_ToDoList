import XCTest
import CoreData
@testable import ToDoList

final class TodoRepositoryTests: XCTestCase {

    private var stack: CoreDataStack!
    private var defaults: UserDefaults!
    private var suiteName: String!

    override func setUp() {
        super.setUp()
        stack = CoreDataStack(inMemory: true)
        suiteName = "TodoRepositoryTests.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        stack = nil
        defaults = nil
        super.tearDown()
    }

    private func makeRepository(
        network: NetworkServiceProtocol
    ) -> TodoRepository {
        return TodoRepository(stack: stack, network: network, defaults: defaults)
    }

    func testFirstLaunchSeedsFromNetwork() {
        let dtos = [
            TodoDTO(id: 1, todo: "First", completed: false, userId: 1),
            TodoDTO(id: 2, todo: "Second", completed: true, userId: 2)
        ]
        let repo = makeRepository(network: MockNetworkService(result: .success(dtos)))

        let expectation = expectation(description: "seed")
        var loaded: [Todo] = []
        repo.loadTodos { result in
            if case let .success(todos) = result {
                loaded = todos
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)

        XCTAssertEqual(loaded.count, 2)
        XCTAssertTrue(defaults.bool(forKey: "TodoRepository.didSeedFromAPI"))
        XCTAssertEqual(Set(loaded.map { $0.title }), ["First", "Second"])
    }

    func testSecondLoadReadsFromStoreWithoutNetwork() {

        let seedRepo = makeRepository(
            network: MockNetworkService(result: .success([
                TodoDTO(id: 1, todo: "Persisted", completed: false, userId: 1)
            ]))
        )
        let seedExp = expectation(description: "seed")
        seedRepo.loadTodos { _ in seedExp.fulfill() }
        wait(for: [seedExp], timeout: 2.0)

        let repo = makeRepository(network: MockNetworkService(result: .failure(.noData)))
        let loadExp = expectation(description: "load")
        var loaded: [Todo] = []
        repo.loadTodos { result in
            if case let .success(todos) = result {
                loaded = todos
            }
            loadExp.fulfill()
        }
        wait(for: [loadExp], timeout: 2.0)

        XCTAssertEqual(loaded.count, 1)
        XCTAssertEqual(loaded.first?.title, "Persisted")
    }

    func testCreateAndLoad() {
        defaults.set(true, forKey: "TodoRepository.didSeedFromAPI")
        let repo = makeRepository(network: MockNetworkService(result: .success([])))

        let todo = Todo(title: "New task", details: "Details")
        expectSuccess { done in repo.create(todo) { done($0) } }

        var loaded: [Todo] = []
        expectSuccess { done in
            repo.loadTodos { result in
                if case let .success(todos) = result {
                    loaded = todos
                }
                done(result.map { _ in () })
            }
        }

        XCTAssertEqual(loaded.count, 1)
        XCTAssertEqual(loaded.first?.title, "New task")
        XCTAssertEqual(loaded.first?.details, "Details")
    }

    func testUpdate() {
        defaults.set(true, forKey: "TodoRepository.didSeedFromAPI")
        let repo = makeRepository(network: MockNetworkService(result: .success([])))

        var todo = Todo(title: "Old", details: "")
        expectSuccess { done in repo.create(todo) { done($0) } }

        todo.title = "Updated"
        todo.details = "New details"
        expectSuccess { done in repo.update(todo) { done($0) } }

        var loaded: [Todo] = []
        expectSuccess { done in
            repo.loadTodos { result in
                if case let .success(todos) = result { loaded = todos }
                done(result.map { _ in () })
            }
        }

        XCTAssertEqual(loaded.count, 1)
        XCTAssertEqual(loaded.first?.title, "Updated")
        XCTAssertEqual(loaded.first?.details, "New details")
    }

    func testDelete() {
        defaults.set(true, forKey: "TodoRepository.didSeedFromAPI")
        let repo = makeRepository(network: MockNetworkService(result: .success([])))

        let todo = Todo(title: "To delete")
        expectSuccess { done in repo.create(todo) { done($0) } }
        expectSuccess { done in repo.delete(id: todo.id) { done($0) } }

        var loaded: [Todo] = [Todo(title: "placeholder")]
        expectSuccess { done in
            repo.loadTodos { result in
                if case let .success(todos) = result { loaded = todos }
                done(result.map { _ in () })
            }
        }

        XCTAssertTrue(loaded.isEmpty)
    }

    func testToggleCompletion() {
        defaults.set(true, forKey: "TodoRepository.didSeedFromAPI")
        let repo = makeRepository(network: MockNetworkService(result: .success([])))

        let todo = Todo(title: "Toggle me", isCompleted: false)
        expectSuccess { done in repo.create(todo) { done($0) } }
        expectSuccess { done in repo.toggleCompletion(id: todo.id) { done($0) } }

        var loaded: [Todo] = []
        expectSuccess { done in
            repo.loadTodos { result in
                if case let .success(todos) = result { loaded = todos }
                done(result.map { _ in () })
            }
        }

        XCTAssertEqual(loaded.first?.isCompleted, true)
    }

    func testSearchFiltersByTitle() {
        defaults.set(true, forKey: "TodoRepository.didSeedFromAPI")
        let repo = makeRepository(network: MockNetworkService(result: .success([])))

        expectSuccess { done in repo.create(Todo(title: "Buy milk")) { done($0) } }
        expectSuccess { done in repo.create(Todo(title: "Read book")) { done($0) } }

        var loaded: [Todo] = []
        expectSuccess { done in
            repo.search(query: "milk") { result in
                if case let .success(todos) = result { loaded = todos }
                done(result.map { _ in () })
            }
        }

        XCTAssertEqual(loaded.count, 1)
        XCTAssertEqual(loaded.first?.title, "Buy milk")
    }

    private func expectSuccess(
        file: StaticString = #file,
        line: UInt = #line,
        _ operation: (@escaping (Result<Void, Error>) -> Void) -> Void
    ) {
        let exp = expectation(description: "operation")
        operation { result in
            if case let .failure(error) = result {
                XCTFail("Ожидался успех, получена ошибка: \(error)", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 2.0)
    }
}
