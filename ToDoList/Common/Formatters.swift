import Foundation

enum Formatters {

    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()

    static func tasksCount(_ count: Int) -> String {
        let remainder100 = count % 100
        let remainder10 = count % 10

        let word: String
        if remainder100 >= 11 && remainder100 <= 14 {
            word = "Задач"
        } else if remainder10 == 1 {
            word = "Задача"
        } else if remainder10 >= 2 && remainder10 <= 4 {
            word = "Задачи"
        } else {
            word = "Задач"
        }

        return "\(count) \(word)"
    }
}
