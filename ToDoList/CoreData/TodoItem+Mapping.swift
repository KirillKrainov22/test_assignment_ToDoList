import CoreData

extension TodoItem {

    func toDomain() -> Todo {
        return Todo(
            id: id ?? UUID(),
            remoteId: remoteId?.intValue,
            title: title ?? "",
            details: details ?? "",
            createdAt: createdAt ?? Date(),
            isCompleted: isCompleted
        )
    }

    func apply(_ todo: Todo) {
        id = todo.id
        remoteId = todo.remoteId.map { NSNumber(value: $0) }
        title = todo.title
        details = todo.details
        createdAt = todo.createdAt
        isCompleted = todo.isCompleted
    }
}
