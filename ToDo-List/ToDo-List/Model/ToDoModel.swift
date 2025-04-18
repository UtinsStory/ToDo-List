//
//  ToDoModel.swift
//  ToDo-List
//
//  Created by Никита Соловьев on 18.04.2025.
//

import Foundation

struct ToDoModel: Codable {
    let id: Int
    let todo: String
    let completed: Bool
    let userId: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case todo
        case completed
        case userId
    }
}

struct TodoResponse: Codable {
    let todos: [ToDoModel]
    let total: Int
    let skip: Int
    let limit: Int
}
