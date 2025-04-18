//
//  ToDoListViewModel.swift
//  ToDo-List
//
//  Created by Никита Соловьев on 18.04.2025.
//

import Foundation

final class ToDoListViewModel {
    
    var tasks: [ToDoModel] = []
    var mockTodo = ToDoModel(
        id: 1,
        todo: "Сходить в спортзал",
        completed: false, userId: 1
    )
    
}
