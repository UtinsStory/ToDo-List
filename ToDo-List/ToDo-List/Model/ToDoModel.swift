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
