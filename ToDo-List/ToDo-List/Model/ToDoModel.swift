//
//  ToDoModel.swift
//  ToDo-List
//
//  Created by Никита Соловьев on 18.04.2025.
//

import Foundation
import CoreData

struct ToDoModel: Codable {
    let id: Int
    var todo: String
    var completed: Bool
    var userId: Int
    
    init(id: Int, todo: String, completed: Bool, userId: Int) {
        self.id = id
        self.todo = todo
        self.completed = completed
        self.userId = userId
    }
    
    init(from entity: Todo) {
        self.id = Int(entity.id)
        self.todo = entity.todo ?? ""
        self.completed = entity.completed
        self.userId = Int(entity.userId)
    }
    
    func toEntity(context: NSManagedObjectContext) -> Todo {
        let entity = Todo(context: context)
        entity.id = Int32(id)
        entity.todo = todo
        entity.completed = completed
        entity.userId = Int32(userId)
        
        return entity
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case todo
        case completed
        case userId
    }
}
