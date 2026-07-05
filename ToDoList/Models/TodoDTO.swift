import Foundation

struct TodosResponse: Decodable {
    let todos: [TodoDTO]
    let total: Int
    let skip: Int
    let limit: Int
}

struct TodoDTO: Decodable {
    let id: Int
    let todo: String
    let completed: Bool
    let userId: Int
}

extension TodoDTO {

    func toDomain(createdAt: Date = Date()) -> Todo {
        return Todo(
            remoteId: id,
            title: todo,
            details: "",
            createdAt: createdAt,
            isCompleted: completed
        )
    }
}
