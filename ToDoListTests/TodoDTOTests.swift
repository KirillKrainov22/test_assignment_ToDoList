import XCTest
@testable import ToDoList

final class TodoDTOTests: XCTestCase {

    func testDecodingDummyJSONResponse() throws {
        let json = """
        {
          "todos": [
            {"id": 1, "todo": "Do something nice", "completed": false, "userId": 152},
            {"id": 2, "todo": "Memorize a poem", "completed": true, "userId": 13}
          ],
          "total": 254,
          "skip": 0,
          "limit": 30
        }
        """.data(using: .utf8)!

        let response = try JSONDecoder().decode(TodosResponse.self, from: json)

        XCTAssertEqual(response.total, 254)
        XCTAssertEqual(response.todos.count, 2)
        XCTAssertEqual(response.todos[0].id, 1)
        XCTAssertEqual(response.todos[0].todo, "Do something nice")
        XCTAssertFalse(response.todos[0].completed)
        XCTAssertTrue(response.todos[1].completed)
    }

    func testMappingToDomain() {
        let date = Date(timeIntervalSince1970: 1_000_000)
        let dto = TodoDTO(id: 7, todo: "Solve a Rubik's cube", completed: true, userId: 76)

        let domain = dto.toDomain(createdAt: date)

        XCTAssertEqual(domain.remoteId, 7)
        XCTAssertEqual(domain.title, "Solve a Rubik's cube")
        XCTAssertEqual(domain.details, "")
        XCTAssertEqual(domain.createdAt, date)
        XCTAssertTrue(domain.isCompleted)
    }
}
