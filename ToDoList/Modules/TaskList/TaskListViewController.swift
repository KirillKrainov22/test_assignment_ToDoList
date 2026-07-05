import UIKit

final class TaskListViewController: UIViewController {

    var presenter: TaskListPresenterProtocol?

    private let tableView = UITableView(frame: .zero, style: .plain)
    private let searchController = UISearchController(searchResultsController: nil)
    private let countLabel = UILabel()

    private var items: [TaskCellViewModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupSearch()
        setupTableView()
        setupToolbar()
        presenter?.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(false, animated: animated)
    }

    private func setupNavigation() {
        title = "Задачи"
        view.backgroundColor = Theme.background
        navigationItem.largeTitleDisplayMode = .always
    }

    private func setupSearch() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = Theme.background
        tableView.separatorColor = UIColor(white: 1.0, alpha: 0.15)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 90
        tableView.register(TaskListCell.self, forCellReuseIdentifier: TaskListCell.reuseIdentifier)
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupToolbar() {
        countLabel.font = .systemFont(ofSize: 11, weight: .regular)
        countLabel.textColor = Theme.primaryText
        countLabel.textAlignment = .center

        let countItem = UIBarButtonItem(customView: countLabel)
        let flexLeft = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let flexRight = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let addItem = UIBarButtonItem(
            image: UIImage(systemName: "square.and.pencil"),
            style: .plain,
            target: self,
            action: #selector(addTapped)
        )
        addItem.tintColor = Theme.accent

        toolbarItems = [flexLeft, countItem, flexRight, addItem]
    }

    @objc private func addTapped() {
        presenter?.didTapAdd()
    }
}

extension TaskListViewController: TaskListViewProtocol {

    func show(items: [TaskCellViewModel]) {
        self.items = items
        tableView.reloadData()
    }

    func showCount(_ text: String) {
        countLabel.text = text
        countLabel.sizeToFit()
    }

    func showError(_ message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    func presentShare(text: String) {
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        present(activityVC, animated: true)
    }
}

extension TaskListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: TaskListCell.reuseIdentifier,
            for: indexPath
        ) as? TaskListCell else {
            return UITableViewCell()
        }

        let item = items[indexPath.row]
        cell.configure(with: item)
        cell.onToggle = { [weak self] in
            self?.presenter?.didToggleCompletion(id: item.id)
        }
        return cell
    }
}

extension TaskListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        presenter?.didSelectItem(id: items[indexPath.row].id)
    }

    func tableView(
        _ tableView: UITableView,
        contextMenuConfigurationForRowAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        let id = items[indexPath.row].id

        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            let edit = UIAction(
                title: "Редактировать",
                image: UIImage(systemName: "square.and.pencil")
            ) { _ in
                self?.presenter?.didTapEdit(id: id)
            }

            let share = UIAction(
                title: "Поделиться",
                image: UIImage(systemName: "square.and.arrow.up")
            ) { _ in
                self?.presenter?.didTapShare(id: id)
            }

            let delete = UIAction(
                title: "Удалить",
                image: UIImage(systemName: "trash"),
                attributes: .destructive
            ) { _ in
                self?.presenter?.didTapDelete(id: id)
            }

            return UIMenu(title: "", children: [edit, share, delete])
        }
    }

    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let id = items[indexPath.row].id
        let delete = UIContextualAction(style: .destructive, title: "Удалить") { [weak self] _, _, done in
            self?.presenter?.didTapDelete(id: id)
            done(true)
        }
        return UISwipeActionsConfiguration(actions: [delete])
    }
}

extension TaskListViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        presenter?.didChangeSearch(query: searchController.searchBar.text ?? "")
    }
}
