//
//  ToDoListFooterView.swift
//  ToDo-List
//
//  Created by Никита Соловьев on 18.04.2025.
//

import UIKit

final class ToDoListFooterView: UIView {
    
    var onAddTodoButtonTapped: (() -> Void)?
    
    private lazy var taskCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11, weight: .regular)
        label.textColor = .white
        label.text = "7 задач"
        
        return label
    }()
    
    private lazy var addTodoButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "square.and.pencil"), for: .normal)
        button.tintColor = .yellow
        button.addTarget(
            self,
            action: #selector(handleAddTodoButtonTapped),
            for: .touchUpInside
        )
        
        return button
    }()
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(resource: .footerSeparator)
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func handleAddTodoButtonTapped() {
        onAddTodoButtonTapped?()
    }
    
    private func setupView() {
        backgroundColor = UIColor(resource: .footerBackground)
        [
            separatorView,
            taskCountLabel,
            addTodoButton
        ].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            separatorView.topAnchor.constraint(equalTo: topAnchor),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            
            taskCountLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            taskCountLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            addTodoButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            addTodoButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            addTodoButton.widthAnchor.constraint(equalToConstant: 68),
            addTodoButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    func configure(taskCount: Int) {
        if taskCount == 1 {
            taskCountLabel.text = "\(taskCount) задача"
        } else if taskCount <= 4 {
            taskCountLabel.text = "\(taskCount) задачи"
        } else {
            taskCountLabel.text = "\(taskCount) задач"
        }
    }
    
    
}
