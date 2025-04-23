//
//  TodosService.swift
//  ToDo-List
//
//  Created by Никита Соловьев on 18.04.2025.
//

import Foundation

// Протокол для сервиса
protocol TodosServiceProtocol {
    func fetchTodos(skip: Int, limit: Int) async throws -> [ToDoModel]
    func addTodo(todo: String, completed: Bool, userId: Int) async throws -> ToDoModel
    func updateTodo(id: Int, completed: Bool) async throws -> ToDoModel
}

// Ошибки сервиса
enum TodoServiceError: Error {
    case invalidURL
    case networkError(Error)
    case invalidResponse
    case decodingError(Error)
}

// Структура ответа API
struct TodoResponse: Codable {
    let todos: [ToDoModel]
    let total: Int
    let skip: Int
    let limit: Int
}

// Сервис
final class TodosService: TodosServiceProtocol {
    private let baseURL = "https://dummyjson.com/todos"
    
    func fetchTodos(skip: Int = 0, limit: Int = 30) async throws -> [ToDoModel] {
        guard var urlComponents = URLComponents(string: baseURL) else {
            throw TodoServiceError.invalidURL
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "skip", value: "\(skip)"),
            URLQueryItem(name: "limit", value: "\(limit)")
        ]
        
        guard let url = urlComponents.url else {
            throw TodoServiceError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw TodoServiceError.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            let todoResponse = try decoder.decode(TodoResponse.self, from: data)
            return todoResponse.todos
        } catch {
            throw TodoServiceError.decodingError(error)
        }
    }
    
    func updateTodo(id: Int, completed: Bool) async throws -> ToDoModel {
        let urlString = "\(baseURL)/\(id)"
        guard let url = URL(string: urlString) else {
            throw TodoServiceError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["completed": completed]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            throw TodoServiceError.decodingError(error)
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw TodoServiceError.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            let updatedTodo = try decoder.decode(ToDoModel.self, from: data)
            return updatedTodo
        } catch {
            throw TodoServiceError.decodingError(error)
        }
    }
    
    func addTodo(todo: String, completed: Bool, userId: Int) async throws -> ToDoModel {
        let urlString = "\(baseURL)/add"
        guard let url = URL(string: urlString) else {
            throw TodoServiceError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "todo": todo,
            "completed": completed,
            "userId": userId
        ]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            print("Ошибка сериализации тела: \(error)")
            throw TodoServiceError.decodingError(error)
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
            print("Ошибка ответа POST: status=\((response as? HTTPURLResponse)?.statusCode ?? -1)")
            throw TodoServiceError.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            let newTodo = try decoder.decode(ToDoModel.self, from: data)
            return newTodo
        } catch {
            print("Ошибка декодирования ответа: \(error)")
            throw TodoServiceError.decodingError(error)
        }
    }
}
