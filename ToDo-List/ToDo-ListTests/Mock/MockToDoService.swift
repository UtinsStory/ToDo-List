//
//  MockToDoService.swift
//  ToDo-ListTests
//
//  Created by Никита Соловьев on 23.04.2025.
//

import Foundation
@testable import ToDo_List

final class MockToDoService: TodosServiceProtocol {
    
    var stubbedTodos: [ToDoModel] = []
    var stubbedAddTodo: ToDoModel?
    var stubbedUpdateTodo: ToDoModel?
    
    func fetchTodos(skip: Int, limit: Int) async throws -> [ToDoModel] {
        return stubbedTodos
    }
    
    func addTodo(todo: String, completed: Bool, userId: Int) async throws -> ToDoModel {
        return stubbedAddTodo ?? ToDoModel(id: 999, todo: todo, completed: completed, userId: userId)
    }
    
    func updateTodo(id: Int, completed: Bool) async throws -> ToDoModel {
        return stubbedUpdateTodo ?? ToDoModel(id: id, todo: "Updated", completed: completed, userId: 1)
    }
}
