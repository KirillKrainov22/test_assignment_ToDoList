import CoreData

protocol TodoRepositoryProtocol {
    func loadTodos(completion: @escaping (Result<[Todo], Error>) -> Void)
    func search(query: String, completion: @escaping (Result<[Todo], Error>) -> Void)
    func create(_ todo: Todo, completion: @escaping (Result<Void, Error>) -> Void)
    func update(_ todo: Todo, completion: @escaping (Result<Void, Error>) -> Void)
    func delete(id: UUID, completion: @escaping (Result<Void, Error>) -> Void)
    func toggleCompletion(id: UUID, completion: @escaping (Result<Void, Error>) -> Void)
}

final class TodoRepository: TodoRepositoryProtocol {

    private let stack: CoreDataStack
    private let network: NetworkServiceProtocol
    private let defaults: UserDefaults
    private let seededKey = "TodoRepository.didSeedFromAPI"

    init(
        stack: CoreDataStack = .shared,
        network: NetworkServiceProtocol = NetworkService(),
        defaults: UserDefaults = .standard
    ) {
        self.stack = stack
        self.network = network
        self.defaults = defaults
    }

    func loadTodos(completion: @escaping (Result<[Todo], Error>) -> Void) {
        stack.performBackgroundTask { [weak self] context in
            guard let self = self else {
                return
            }

            if !self.defaults.bool(forKey: self.seededKey) {
                self.seedFromNetwork(into: context, completion: completion)
                return
            }

            do {
                let todos = try self.fetchAll(in: context)
                self.deliver(.success(todos), to: completion)
            } catch {
                self.deliver(.failure(error), to: completion)
            }
        }
    }

    private func seedFromNetwork(
        into context: NSManagedObjectContext,
        completion: @escaping (Result<[Todo], Error>) -> Void
    ) {
        network.fetchTodos { [weak self] result in
            guard let self = self else {
                return
            }

            switch result {
            case let .success(dtos):
                context.perform {
                    let importDate = Date()
                    for dto in dtos {
                        let item = TodoItem(context: context)
                        item.apply(dto.toDomain(createdAt: importDate))
                    }

                    do {
                        try context.save()
                        self.defaults.set(true, forKey: self.seededKey)
                        let todos = try self.fetchAll(in: context)
                        self.deliver(.success(todos), to: completion)
                    } catch {
                        self.deliver(.failure(error), to: completion)
                    }
                }

            case let .failure(error):
                self.deliver(.failure(error), to: completion)
            }
        }
    }

    func search(query: String, completion: @escaping (Result<[Todo], Error>) -> Void) {
        stack.performBackgroundTask { [weak self] context in
            guard let self = self else {
                return
            }

            let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
            do {
                let predicate: NSPredicate? = trimmed.isEmpty
                    ? nil
                    : NSPredicate(
                        format: "title CONTAINS[cd] %@ OR details CONTAINS[cd] %@",
                        trimmed, trimmed
                    )
                let todos = try self.fetchAll(in: context, predicate: predicate)
                self.deliver(.success(todos), to: completion)
            } catch {
                self.deliver(.failure(error), to: completion)
            }
        }
    }

    func create(_ todo: Todo, completion: @escaping (Result<Void, Error>) -> Void) {
        stack.performBackgroundTask { [weak self] context in
            guard let self = self else {
                return
            }
            let item = TodoItem(context: context)
            item.apply(todo)
            self.saveAndReportVoid(context, completion: completion)
        }
    }

    func update(_ todo: Todo, completion: @escaping (Result<Void, Error>) -> Void) {
        stack.performBackgroundTask { [weak self] context in
            guard let self = self else {
                return
            }
            do {
                if let item = try self.fetchItem(id: todo.id, in: context) {
                    item.apply(todo)
                } else {

                    let item = TodoItem(context: context)
                    item.apply(todo)
                }
                self.saveAndReportVoid(context, completion: completion)
            } catch {
                self.deliver(.failure(error), to: completion)
            }
        }
    }

    func delete(id: UUID, completion: @escaping (Result<Void, Error>) -> Void) {
        stack.performBackgroundTask { [weak self] context in
            guard let self = self else {
                return
            }
            do {
                if let item = try self.fetchItem(id: id, in: context) {
                    context.delete(item)
                }
                self.saveAndReportVoid(context, completion: completion)
            } catch {
                self.deliver(.failure(error), to: completion)
            }
        }
    }

    func toggleCompletion(id: UUID, completion: @escaping (Result<Void, Error>) -> Void) {
        stack.performBackgroundTask { [weak self] context in
            guard let self = self else {
                return
            }
            do {
                if let item = try self.fetchItem(id: id, in: context) {
                    item.isCompleted.toggle()
                }
                self.saveAndReportVoid(context, completion: completion)
            } catch {
                self.deliver(.failure(error), to: completion)
            }
        }
    }

    private func fetchAll(
        in context: NSManagedObjectContext,
        predicate: NSPredicate? = nil
    ) throws -> [Todo] {
        let request = NSFetchRequest<TodoItem>(entityName: "TodoItem")
        request.predicate = predicate
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        let items = try context.fetch(request)
        return items.map { $0.toDomain() }
    }

    private func fetchItem(id: UUID, in context: NSManagedObjectContext) throws -> TodoItem? {
        let request = NSFetchRequest<TodoItem>(entityName: "TodoItem")
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        return try context.fetch(request).first
    }

    private func saveAndReportVoid(
        _ context: NSManagedObjectContext,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        do {
            if context.hasChanges {
                try context.save()
            }
            deliver(.success(()), to: completion)
        } catch {
            deliver(.failure(error), to: completion)
        }
    }

    private func deliver<T>(
        _ result: Result<T, Error>,
        to completion: @escaping (Result<T, Error>) -> Void
    ) {
        DispatchQueue.main.async {
            completion(result)
        }
    }
}
