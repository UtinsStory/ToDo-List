//
//  ToDoListTableViewCell.swift
//  ToDo-List
//
//  Created by Никита Соловьев on 18.04.2025.
//

import UIKit

final class ToDoListTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "ToDoListTableViewCell"
    
    // Замыкание для уведомления о смене статуса задачи
    var onCompletionToggled: ((Bool) -> Void)?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .white
        
        return label
    }()
    
    private lazy var taskLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .white
        
        return label
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .gray
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy"
        let dateString = dateFormatter.string(from: Date())
        label.text = dateString
        
        return label
    }()
    
    private lazy var taskCompletionMark: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "circle"), for: .normal)
        button.tintColor = .gray
        button.addTarget(self, action: #selector(toggleCompletion), for: .touchUpInside)
        
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func toggleCompletion() {
        let newCompletionStatus = taskCompletionMark.image(for: .normal) == UIImage(systemName: "circle")
        onCompletionToggled?(newCompletionStatus)
    }
    
    func configure(with model: ToDoModel) {
        // Настраиваем кнопку
        taskCompletionMark.setImage(
            UIImage(systemName: model.completed ? "checkmark.circle" : "circle"),
            for: .normal
        )
        taskCompletionMark.tintColor = model.completed ? .yellow : .gray
        
        // Настраиваем текст
        let titleText = model.todo
        let taskText = model.todo
        
        // Базовые атрибуты
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 16, weight: .medium)
        ]
        let taskAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 12, weight: .regular)
        ]
        
        if model.completed {
            // Перечеркивание для выполненной задачи
            var completedTitleAttributes = titleAttributes
            completedTitleAttributes[.strikethroughStyle] = NSUnderlineStyle.single.rawValue
            completedTitleAttributes[.strikethroughColor] = UIColor.white
            
            var completedTaskAttributes = taskAttributes
            completedTaskAttributes[.strikethroughStyle] = NSUnderlineStyle.single.rawValue
            completedTaskAttributes[.strikethroughColor] = UIColor.white
            
            titleLabel.attributedText = NSAttributedString(
                string: titleText,
                attributes: completedTitleAttributes
            )
            taskLabel.attributedText = NSAttributedString(
                string: taskText,
                attributes: completedTaskAttributes
            )
        } else {
            // Обычный текст без перечеркивания для невыполненной задачи
            titleLabel.attributedText = NSAttributedString(
                string: titleText,
                attributes: titleAttributes
            )
            taskLabel.attributedText = NSAttributedString(
                string: taskText,
                attributes: taskAttributes
            )
        }
    }
    
    private func setupView() {
        [
            titleLabel,
            taskLabel,
            dateLabel,
            taskCompletionMark
        ].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            taskCompletionMark.topAnchor.constraint(equalTo: contentView.topAnchor),
            taskCompletionMark.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            taskCompletionMark.heightAnchor.constraint(equalToConstant: 24),
            taskCompletionMark.widthAnchor.constraint(equalToConstant: 24),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: taskCompletionMark.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            taskLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            taskLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            taskLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            dateLabel.topAnchor.constraint(equalTo: taskLabel.bottomAnchor, constant: 6),
            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
        backgroundColor = .black
    }
}
