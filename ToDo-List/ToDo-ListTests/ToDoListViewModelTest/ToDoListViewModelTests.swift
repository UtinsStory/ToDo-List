//
//  ToDoListViewModelTests.swift
//  ToDo-ListTests
//
//  Created by Никита Соловьев on 23.04.2025.
//

import XCTest
import CoreData
@testable import ToDo_List

class ToDoListViewModelTests: XCTestCase {
    var viewModel: ToDoListViewModel!
    var mockService: MockToDoService!
    
    override func setUp() async throws {
        mockService = MockToDoService()
        viewModel = await MainActor.run {
            ToDoListViewModel(todosService: mockService)
        }
    }
    
    override func tearDown() {
        viewModel = nil
        mockService = nil
    }
    
    func testFetchInitialTasksLoadsTasks() async {
        //Given
        mockService.stubbedTodos = [
            ToDoModel(id: 1, todo: "Test 1", completed: false, userId: 1),
            ToDoModel(id: 2, todo: "Test 2", completed: true, userId: 1)
        ]
        
        //When
        await viewModel.fetchInitialTasks()
        
        //Then
        let tasks = await MainActor.run { viewModel.tasks }
        XCTAssertEqual(tasks.count, 2)
        XCTAssertEqual(tasks[0].todo, "Test 1")
    }
    
    func testAddTaskAppendsNewTask() async throws {
        //Given
        let newTask = ToDoModel(id: 3, todo: "New Task", completed: false, userId: 1)
        mockService.stubbedAddTodo = newTask
        
        //When
        try await viewModel.addTask(todo: "New Task")
        
        //Then
        let tasks = await MainActor.run { viewModel.tasks }
        XCTAssertEqual(tasks.last?.todo, "New Task")
    }
    
    func testUpdateTaskCompletionUpdatesCorrectTask() async throws {
        //Given
        await MainActor.run {
            viewModel.tasks = [
                ToDoModel(id: 1, todo: "Task 1", completed: false, userId: 1)
            ]
        }
        let updated = ToDoModel(id: 1, todo: "Task 1", completed: true, userId: 1)
        mockService.stubbedUpdateTodo = updated
        
        //When
        try await viewModel.updateTaskCompletion(at: 0, completed: true)
        
        //Then
        let updatedTasks = await MainActor.run { viewModel.tasks }
        XCTAssertTrue(updatedTasks[0].completed)
    }
    
    func testDeleteTaskRemovesFromList() async {
        //Given
        await MainActor.run {
            viewModel.tasks = [
                ToDoModel(id: 1, todo: "Task 1", completed: false, userId: 1)
            ]
        }
        
        //When
        await MainActor.run {
            viewModel.deleteTask(at: 0)
        }
        
        //Then
        let tasks = await MainActor.run { viewModel.tasks }
        XCTAssertTrue(tasks.isEmpty)
    }
}

