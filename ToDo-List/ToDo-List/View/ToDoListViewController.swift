//
//  ToDoListViewController.swift
//  ToDo-List
//
//  Created by Никита Соловьев on 16.04.2025.
//

import UIKit

final class ToDoListViewController: UIViewController {
    
    private let viewModel: ToDoListViewModel
    private var filteredTasks: [ToDoModel] = []
    private var isSearching = false
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.text = "Задачи"
        
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(
            ToDoListTableViewCell.self,
            forCellReuseIdentifier: ToDoListTableViewCell.reuseIdentifier
        )
        tableView.backgroundColor = .clear
        
        return tableView
    }()
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.placeholder = "Search"
        searchBar.searchBarStyle = .minimal
        searchBar.searchTextField.textColor = .white
        
        return searchBar
    }()
    
    private lazy var footerView: ToDoListFooterView = {
        let footer = ToDoListFooterView()
        footer.translatesAutoresizingMaskIntoConstraints = false
        footer.configure(taskCount: viewModel.tasks.count)
        footer.onAddTodoButtonTapped = { [weak self] in
            self?.addTodoButtonTapped()
        }
        
        return footer
    }()
    
    private lazy var homeIndicatorBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .darkGray // Цвет фона области Home Indicator
        
        return view
    }()
    
    init(viewModel: ToDoListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupView()
        setupNotifications()
        footerView.configure(taskCount: viewModel.tasks.count)
    }
    
    private func setupView() {
        view.backgroundColor = .black
        
        [
            titleLabel,
            searchBar,
            tableView,
            footerView,
            homeIndicatorBackgroundView
        ].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            searchBar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            searchBar.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 16),
            tableView.bottomAnchor.constraint(equalTo: footerView.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            footerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            footerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            footerView.heightAnchor.constraint(equalToConstant: 50),
            
            homeIndicatorBackgroundView.topAnchor.constraint(equalTo: footerView.bottomAnchor),
            homeIndicatorBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            homeIndicatorBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            homeIndicatorBackgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(tasksUpdated),
            name: .tasksUpdated,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(taskUpdated(_:)),
            name: .taskUpdated,
            object: nil
        )
    }
    
    @objc private func tasksUpdated() {
        DispatchQueue.main.async {
            self.footerView.configure(taskCount: self.viewModel.tasks.count)
            self.tableView.reloadData()
        }
    }
    
    @objc private func taskUpdated(_ notification: Notification) {
        if let index = notification.userInfo?["index"] as? Int {
            DispatchQueue.main.async {
                let indexPath = IndexPath(row: index, section: 0)
                // Проверяем, видима ли ячейка
                if self.tableView.indexPathsForVisibleRows?.contains(indexPath) ?? false {
                    self.tableView.reloadRows(at: [indexPath], with: .automatic)
                } else {
                    self.tableView.reloadData()
                }
            }
        } else {
            print("Ошибка: индекс не передан в уведомлении taskUpdated")
        }
    }
    
    private func addTodoButtonTapped() {
        let todoVC = ToDoViewController(viewModel: viewModel, screenType: .new)
        navigationController?.pushViewController(todoVC, animated: true)
    }
    
    // Показ уведомления об ошибке
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func updateTasks() {
        footerView.configure(taskCount: viewModel.tasks.count)
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource
extension ToDoListViewController: UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        isSearching ? filteredTasks.count : viewModel.tasks.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ToDoListTableViewCell.reuseIdentifier,
            for: indexPath
        ) as? ToDoListTableViewCell else {
            return UITableViewCell()
        }
        let task = isSearching ? filteredTasks[indexPath.row] : viewModel.tasks[indexPath.row]
        cell.configure(with: task)
        
        cell.onCompletionToggled = { [weak self] newCompletionStatus in
            guard let self = self else {
                return
            }
            Task {
                do {
                    try await self.viewModel.updateTaskCompletion(at: indexPath.row, completed: newCompletionStatus)
                } catch {
                    DispatchQueue.main.async {
                        self.showErrorAlert(message: "Не удалось обновить задачу: \(error.localizedDescription)")
                    }
                }
            }
        }
        
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let scrollViewHeight = scrollView.frame.size.height
        
        if offsetY > contentHeight - scrollViewHeight - 100 {
            Task {
                await viewModel.fetchMoreTasks()
            }
        }
    }
    
}

// MARK: - UITableViewDelegate
extension ToDoListViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        80
    }
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)
        let todoVC = ToDoViewController(
            viewModel: viewModel,
            screenType: .edit(index: indexPath.row)
        )
        navigationController?.pushViewController(todoVC, animated: true)
    }
    
    func tableView(
        _ tableView: UITableView,
        contextMenuConfigurationForRowAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        let task = viewModel.tasks[indexPath.row]
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let editAction = UIAction(
                title: "Редактировать",
                image: UIImage(resource: .iconEdit)
            ) { _ in
                let todoVC = ToDoViewController(
                    viewModel: self.viewModel,
                    screenType: .edit(index: indexPath.row)
                )
                self.navigationController?.pushViewController(todoVC, animated: true)
            }
            
            let shareAction = UIAction(
                title: "Поделиться",
                image: UIImage(resource: .iconExport)
            ) { _ in
                let activityController = UIActivityViewController(activityItems: [task.todo], applicationActivities: nil)
                self.present(activityController, animated: true)
            }
            
            let deleteAction = UIAction(
                title: "Удалить",
                image: UIImage(resource: .iconTrash),
                attributes: .destructive
            ) { _ in
                self.viewModel.deleteTask(at: indexPath.row)
            }
            
            return UIMenu(title: "", children: [editAction, shareAction, deleteAction])
        }
    }
}

// MARK: - UISearchBarDelegate
extension ToDoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            isSearching = false
        } else {
            isSearching = true
            filteredTasks = viewModel.tasks.filter {
                $0.todo.lowercased().contains(searchText.lowercased())
            }
        }
        tableView.reloadData()
    }
}

