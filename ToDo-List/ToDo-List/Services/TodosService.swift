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
}
