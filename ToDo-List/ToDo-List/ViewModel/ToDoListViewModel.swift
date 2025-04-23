//
//  ToDoListViewModel.swift
//  ToDo-List
//
//  Created by Никита Соловьев on 18.04.2025.
//

import UIKit
import CoreData

@MainActor
final class ToDoListViewModel {
    
    var tasks: [ToDoModel] = []
    let todosService: TodosService
    private let context: NSManagedObjectContext
    private var isFetchingInitialTasks = false // Флаг для предотвращения дублирующих вызовов
    
    init(todosService: TodosService) {
        self.todosService = todosService
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Не удалось получить AppDelegate")
        }
        self.context = appDelegate.persistentContainer.viewContext
        loadTasks()
    }
    
    private func loadTasks() {
        // Выполняем операции с Core Data на главном потоке
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let fetchRequest: NSFetchRequest<Todo> = Todo.fetchRequest()
            
            do {
                let entities = try self.context.fetch(fetchRequest)
                self.tasks = entities.map { ToDoModel(from: $0) }
                // Уведомляем об обновлении
                NotificationCenter.default.post(name: .tasksUpdated, object: nil)
                
                // Если задач нет, загружаем из API
                if self.tasks.isEmpty {
                    Task { await self.fetchInitialTasks() }
                }
            } catch {
                print("Ошибка загрузки из Core Data: \(error)")
                // Если не удалось загрузить из Core Data, пробуем API
                Task { await self.fetchInitialTasks() }
            }
        }
    }
    
    private func fetchInitialTasks() async {
        // Предотвращаем дублирующий вызов
        guard !isFetchingInitialTasks else {
            return
        }
        isFetchingInitialTasks = true
        defer { isFetchingInitialTasks = false }
        
        do {
            let todos = try await todosService.fetchTodos(skip: 0, limit: 30)
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.tasks = todos
                self.saveTasksToCoreData()
                NotificationCenter.default.post(name: .tasksUpdated, object: nil)
            }
        } catch {
            print("Ошибка загрузки задач из API: \(error)")
        }
    }
    
    func fetchMoreTasks() async {
        do {
            let skip = tasks.count
            let newTodos = try await todosService.fetchTodos(skip: skip, limit: 30)
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.tasks.append(contentsOf: newTodos)
                self.saveTasksToCoreData()
                NotificationCenter.default.post(name: .tasksUpdated, object: nil)
            }
        } catch {
            print("Ошибка загрузки дополнительных задач: \(error)")
        }
    }
    
    func updateTaskCompletion(at index: Int, completed: Bool) async throws {
        guard index < tasks.count else {
            throw TodoServiceError.invalidResponse
        }
        let updatedTodo = try await todosService.updateTodo(id: tasks[index].id, completed: completed)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.tasks[index] = updatedTodo
            self.saveTasksToCoreData()
            NotificationCenter.default.post(
                name: .taskUpdated,
                object: nil,
                userInfo: ["index": index]
            )
        }
    }
    
    func deleteTask(at index: Int) {
        guard index < tasks.count else {
            return
        }
        let taskId = tasks[index].id
        tasks.remove(at: index)
        saveTasksToCoreData()
        NotificationCenter.default.post(name: .tasksUpdated, object: nil)
    }
    
    func addTask(todo: String) async throws {
        let newTask = try await todosService.addTodo(
            todo: todo,
            completed: false,
            userId: 1
        )
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.tasks.append(newTask)
            self.saveTasksToCoreData()
            NotificationCenter.default.post(name: .tasksUpdated, object: nil)
        }
    }
    
    func updateTask(at index: Int, todo: String) {
        guard index < tasks.count else {
            return
        }
        let task = tasks[index]
        let updatedTask = ToDoModel(
            id: task.id,
            todo: todo,
            completed: task.completed,
            userId: task.userId
        )
        tasks[index] = updatedTask
        saveTasksToCoreData()
        NotificationCenter.default.post(name: .taskUpdated, object: nil, userInfo: ["index": index])
    }
    
    private func saveTasksToCoreData() {
        // Выполняем сохранение на главном потоке
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            // Очищаем существующие данные
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Todo.fetchRequest()
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            do {
                try self.context.execute(deleteRequest)
            } catch {
                print("Ошибка удаления существующих данных из Core Data: \(error)")
            }
            
            // Сохраняем текущие задачи
            for task in self.tasks {
                _ = task.toEntity(context: self.context)
            }
            
            // Сохраняем контекст
            if self.context.hasChanges {
                do {
                    try self.context.save()
                } catch {
                    print("Ошибка сохранения контекста: \(error)")
                }
            } else {
                print("Нет изменений для сохранения в Core Data")
            }
        }
    }
}

extension Notification.Name {
    static let tasksUpdated = Notification.Name("tasksUpdated")
    static let taskUpdated = Notification.Name("taskUpdated")
}
