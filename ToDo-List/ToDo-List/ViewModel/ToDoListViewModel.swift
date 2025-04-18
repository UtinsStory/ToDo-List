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
            print("Ошибка загрузки задач: \(error)")
        }
    }
    
    func fetchMoreTasks() async {
            do {
                let skip = tasks.count
                let newTodos = try await todosService.fetchTodos(skip: skip, limit: 30)
                self.tasks.append(contentsOf: newTodos)
                NotificationCenter.default.post(name: .tasksUpdated, object: nil)
            } catch {
                print("Ошибка загрузки дополнительных задач: \(error)")
            }
        }
    
}

extension Notification.Name {
    static let tasksUpdated = Notification.Name("tasksUpdated")
}
