import Foundation

struct TaskItem: Codable, Identifiable {
    let id: Int
    var title: String
    var completed: Bool
}

struct NewTask: Encodable {
    let title: String
}

enum APIError: Error {
    case invalidResponse
    case badStatusCode(Int)
}

final class TaskAPI {
    // Замени на адрес своего сервера
    private let baseURL = URL(string: "https://example.com/api")!

    func fetchTasks() async throws -> [TaskItem] {
        let url = baseURL.appending(path: "tasks")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await URLSession.shared.data(for: request)
        try checkResponse(response)

        return try JSONDecoder().decode([TaskItem].self, from: data)
    }

    func createTask(title: String) async throws -> TaskItem {
        let url = baseURL.appending(path: "tasks")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        request.httpBody = try JSONEncoder().encode(NewTask(title: title))

        let (data, response) = try await URLSession.shared.data(for: request)
        try checkResponse(response)

        return try JSONDecoder().decode(TaskItem.self, from: data)
    }

    private func checkResponse(_ response: URLResponse) throws {
        guard let http = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(http.statusCode) else {
            throw APIError.badStatusCode(http.statusCode)
        }
    }
}
