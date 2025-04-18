//
//  ToDoListTableViewCell.swift
//  ToDo-List
//
//  Created by Никита Соловьев on 18.04.2025.
//

import UIKit

final class ToDoListTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "ToDoListTableViewCell"
    
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
    
    private lazy var taskCompletionMark: UIImageView = {
        let image = UIImageView(image: UIImage(systemName: "circle"))
        image.tintColor = .gray
        
        return image
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with model: ToDoModel) {
        titleLabel.text = model.todo
        taskLabel.text = model.todo
        taskCompletionMark.image = UIImage(systemName: model.completed ? "checkmark.circle" : "circle")
        taskCompletionMark.tintColor = model.completed ? .yellow : .gray
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
