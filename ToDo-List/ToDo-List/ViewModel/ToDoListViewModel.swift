//
//  ToDoListViewModel.swift
//  ToDo-List
//
//  Created by Никита Соловьев on 18.04.2025.
//

import Foundation

final class ToDoListViewModel {
    
    var tasks: [ToDoModel] = []
    
    let todosService: TodosService
    
    
    
    init(todosService: TodosService) {
        self.todosService = todosService
        Task {
            await fetchInitialTasks()
        }
    }
    
    private func fetchInitialTasks() async {
        do {
            let todos = try await todosService.fetchTodos(skip: 0, limit: 30)
            self.tasks = todos
            // Уведомляем контроллер об обновлении
            NotificationCenter.default.post(name: .tasksUpdated, object: nil)
        } catch {
            print("Ошибка загрузки задач: \(error.localizedDescription)")
        }
    }
    
    func fetchMoreTasks() async {
        do {
            let skip = tasks.count
            let newTodos = try await todosService.fetchTodos(skip: skip, limit: 30)
            self.tasks.append(contentsOf: newTodos)
            NotificationCenter.default.post(name: .tasksUpdated, object: nil)
        } catch {
            print("Ошибка загрузки дополнительных задач: \(error.localizedDescription)")
        }
    }
    
    func updateTaskCompletion(at index: Int, completed: Bool) async throws {
        guard index < tasks.count else {
            print("Ошибка: некорректный индекс \(index)")
            throw TodoServiceError.invalidResponse
        }
        let updatedTodo = try await todosService.updateTodo(id: tasks[index].id, completed: completed)
        tasks[index] = updatedTodo
        NotificationCenter.default.post(
            name: .taskUpdated,
            object: nil,
            userInfo: ["index": index]
        )
    }
    
    func deleteTask(at index: Int) {
        guard index < tasks.count else {
            print("Ошибка: некорректный индекс \(index)")
            return
        }
        let taskId = tasks[index].id
        print("Локальное удаление задачи: index=\(index), id=\(taskId)")
        tasks.remove(at: index)
        NotificationCenter.default.post(name: .tasksUpdated, object: nil)
    }
}

extension Notification.Name {
    static let tasksUpdated = Notification.Name("tasksUpdated")
    static let taskUpdated = Notification.Name("taskUpdated")
}
