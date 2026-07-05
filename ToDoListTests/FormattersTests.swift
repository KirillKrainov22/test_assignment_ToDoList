import XCTest
@testable import ToDoList

final class FormattersTests: XCTestCase {

    func testTasksCountPluralization() {
        XCTAssertEqual(Formatters.tasksCount(0), "0 Задач")
        XCTAssertEqual(Formatters.tasksCount(1), "1 Задача")
        XCTAssertEqual(Formatters.tasksCount(2), "2 Задачи")
        XCTAssertEqual(Formatters.tasksCount(4), "4 Задачи")
        XCTAssertEqual(Formatters.tasksCount(5), "5 Задач")
        XCTAssertEqual(Formatters.tasksCount(7), "7 Задач")
        XCTAssertEqual(Formatters.tasksCount(11), "11 Задач")
        XCTAssertEqual(Formatters.tasksCount(12), "12 Задач")
        XCTAssertEqual(Formatters.tasksCount(21), "21 Задача")
        XCTAssertEqual(Formatters.tasksCount(22), "22 Задачи")
        XCTAssertEqual(Formatters.tasksCount(25), "25 Задач")
        XCTAssertEqual(Formatters.tasksCount(111), "111 Задач")
        XCTAssertEqual(Formatters.tasksCount(101), "101 Задача")
    }

    func testShortDateFormat() {
        var components = DateComponents()
        components.year = 2024
        components.month = 10
        components.day = 9
        let date = Calendar(identifier: .gregorian).date(from: components)!

        XCTAssertEqual(Formatters.shortDate.string(from: date), "09/10/24")
    }
}
