//
//  ToDoViewController.swift
//  ToDo-List
//
//  Created by Никита Соловьев on 22.04.2025.
//

import UIKit

enum ScreenType {
    case edit(index: Int)
    case new
}

final class ToDoViewController: UIViewController {
    
    private let viewModel: ToDoListViewModel
    
    private var screenType: ScreenType
    
    private lazy var titleTextField: UITextField = {
        let textField = UITextField()
        let placeholderText = NSAttributedString(
            string: "Заголовок задачи",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        )
        textField.attributedPlaceholder = placeholderText
        textField.font = .systemFont(ofSize: 34, weight: .bold)
        textField.textColor = .white
        
        return textField
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .gray
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yy"
        let dateString = dateFormatter.string(from: Date())
        label.text = dateString
        
        return label
    }()
    
    private lazy var todoDescriptionTextField: UITextField = {
        let textField = UITextField()
        let placeholderText = NSAttributedString(
            string: "Описание задачи",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        )
        textField.attributedPlaceholder = placeholderText
        textField.font = .systemFont(ofSize: 16, weight: .regular)
        textField.textColor = .white
        
        return textField
    }()
    
    init(viewModel: ToDoListViewModel, screenType: ScreenType) {
        self.viewModel = viewModel
        self.screenType = screenType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupNavigation()
        setupScreen()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        saveChanges()
    }
    
    private func setupViews() {
        [
            titleTextField,
            dateLabel,
            todoDescriptionTextField
        ].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate ([
            titleTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            dateLabel.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 8),
            dateLabel.leadingAnchor.constraint(equalTo: titleTextField.leadingAnchor),
            
            todoDescriptionTextField.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 16),
            todoDescriptionTextField.leadingAnchor.constraint(equalTo: titleTextField.leadingAnchor),
            todoDescriptionTextField.trailingAnchor.constraint(equalTo: titleTextField.trailingAnchor)
        ])
    }
    
    private func setupNavigation() {
        let backItem = UIBarButtonItem()
        backItem.image = nil
        backItem.title = "Назад"
        backItem.tintColor = .yellow
        navigationController?.navigationBar.topItem?.backBarButtonItem = backItem
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.yellow,
            .font: UIFont.systemFont(ofSize: 17, weight: .regular)
        ]
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    private func setupScreen() {
        switch screenType {
        case .edit(let index):
            guard index < viewModel.tasks.count else {
                print("Ошибка: некорректный индекс \(index)")
                return
            }
            let task = viewModel.tasks[index]
            titleTextField.text = task.todo
            todoDescriptionTextField.text = task.todo
        case .new:
            titleTextField.text = ""
            todoDescriptionTextField.text = ""
        }
    }
    
    private func saveChanges() {
        guard let description = todoDescriptionTextField.text, !description.isEmpty else {
            print("Описание задачи пустое, изменения не сохранены")
            return
        }
        
        let title = titleTextField.text ?? ""
        
        switch screenType {
        case .edit(let index):
            viewModel.updateTask(at: index, title: title, description: description)
        case .new:
            Task {
                do {
                    try await viewModel.addTask(title: title, description: description)
                } catch {
                    print("Ошибка при создании задачи: \(error.localizedDescription)")
                }
            }
        }
    }
}
