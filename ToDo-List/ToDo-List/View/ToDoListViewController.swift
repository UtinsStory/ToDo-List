//
//  ToDoListViewController.swift
//  ToDo-List
//
//  Created by Никита Соловьев on 16.04.2025.
//

import UIKit

final class ToDoListViewController: UIViewController {
    
    private let viewModel: ToDoListViewModel
    
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
        footer.onEditButtonTapped = { [weak self] in
            self?.editButtonTapped()
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
        setupView()
        tableView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("FooterView frame: \(footerView.frame)")
        print("SafeAreaInsets bottom: \(view.safeAreaInsets.bottom)")
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
    
    private func editButtonTapped() {
        
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
        viewModel.tasks.count
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
        cell.configure(with: viewModel.mockTodo)
        
        return cell
    }
    
}

// MARK: - UITableViewDelegate
extension ToDoListViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        return 44
    }
}

// MARK: - UISearchBarDelegate
extension ToDoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

