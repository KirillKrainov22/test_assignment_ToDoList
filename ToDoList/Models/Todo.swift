import Foundation

struct Todo: Equatable {

    let id: UUID

    let remoteId: Int?
    var title: String
    var details: String
    let createdAt: Date
    var isCompleted: Bool

    init(
        id: UUID = UUID(),
        remoteId: Int? = nil,
        title: String,
        details: String = "",
        createdAt: Date = Date(),
        isCompleted: Bool = false
    ) {
        self.id = id
        self.remoteId = remoteId
        self.title = title
        self.details = details
        self.createdAt = createdAt
        self.isCompleted = isCompleted
    }
}
