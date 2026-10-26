import SwiftUI
import Combine

@MainActor
final class TasksViewModel: ObservableObject {
    @Published var tasks: [TaskItem] = []
    @Published var errorMessage: String?

    private let api = TaskAPI()

    func loadTasks() async {
        do {
            tasks = try await api.fetchTasks()
            errorMessage = nil
        } catch {
            errorMessage = "Не удалось загрузить задачи: \(error.localizedDescription)"
        }
    }

    func addTask(title: String) async {
        do {
            let newTask = try await api.createTask(title: title)
            tasks.append(newTask)
            errorMessage = nil
        } catch {
            errorMessage = "Не удалось добавить задачу: \(error.localizedDescription)"
        }
    }
}

struct TasksView: View {
    @StateObject private var viewModel = TasksViewModel()
    @State private var newTitle = ""

    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    TextField("Новая задача", text: $newTitle)
                        .textFieldStyle(.roundedBorder)

                    Button("Добавить") {
                        let title = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !title.isEmpty else { return }

                        Task {
                            await viewModel.addTask(title: title)
                            newTitle = ""
                        }
                    }
                }
                .padding()

                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundStyle(.red)
                        .padding(.horizontal)
                }

                List(viewModel.tasks) { task in
                    HStack {
                        Text(task.title)
                        Spacer()
                        if task.completed {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
            .navigationTitle("Задачи")
            .task {
                await viewModel.loadTasks()
            }
        }
    }
}
