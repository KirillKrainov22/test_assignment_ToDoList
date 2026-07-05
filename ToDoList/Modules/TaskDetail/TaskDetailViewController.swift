import UIKit

final class TaskDetailViewController: UIViewController {

    var presenter: TaskDetailPresenterProtocol?

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let titleTextView = UITextView()
    private let dateLabel = UILabel()
    private let detailsTextView = UITextView()
    private let titlePlaceholder = UILabel()
    private let detailsPlaceholder = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presenter?.viewDidLoad()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if isMovingFromParent {
            presenter?.onLeave(title: titleTextView.text, details: detailsTextView.text)
        }
    }

    private func setupUI() {
        view.backgroundColor = Theme.background
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.setToolbarHidden(true, animated: false)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        configureTitleView()
        configureDateLabel()
        configureDetailsView()

        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 12),
            contentStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -12)
        ])
    }

    private func configureTitleView() {
        titleTextView.font = .systemFont(ofSize: 34, weight: .bold)
        titleTextView.textColor = Theme.primaryText
        titleTextView.backgroundColor = .clear
        titleTextView.isScrollEnabled = false
        titleTextView.textContainerInset = .zero
        titleTextView.textContainer.lineFragmentPadding = 0
        titleTextView.delegate = self
        titleTextView.returnKeyType = .next

        titlePlaceholder.text = "Название"
        titlePlaceholder.font = .systemFont(ofSize: 34, weight: .bold)
        titlePlaceholder.textColor = Theme.completedText
        titlePlaceholder.translatesAutoresizingMaskIntoConstraints = false
        titleTextView.addSubview(titlePlaceholder)

        NSLayoutConstraint.activate([
            titlePlaceholder.topAnchor.constraint(equalTo: titleTextView.topAnchor),
            titlePlaceholder.leadingAnchor.constraint(equalTo: titleTextView.leadingAnchor)
        ])

        contentStack.addArrangedSubview(titleTextView)
    }

    private func configureDateLabel() {
        dateLabel.font = .systemFont(ofSize: 12, weight: .regular)
        dateLabel.textColor = Theme.secondaryText
        contentStack.addArrangedSubview(dateLabel)
    }

    private func configureDetailsView() {
        detailsTextView.font = .systemFont(ofSize: 16, weight: .regular)
        detailsTextView.textColor = Theme.primaryText
        detailsTextView.backgroundColor = .clear
        detailsTextView.isScrollEnabled = false
        detailsTextView.textContainerInset = .zero
        detailsTextView.textContainer.lineFragmentPadding = 0
        detailsTextView.delegate = self

        detailsPlaceholder.text = "Описание"
        detailsPlaceholder.font = .systemFont(ofSize: 16, weight: .regular)
        detailsPlaceholder.textColor = Theme.completedText
        detailsPlaceholder.translatesAutoresizingMaskIntoConstraints = false
        detailsTextView.addSubview(detailsPlaceholder)

        NSLayoutConstraint.activate([
            detailsPlaceholder.topAnchor.constraint(equalTo: detailsTextView.topAnchor),
            detailsPlaceholder.leadingAnchor.constraint(equalTo: detailsTextView.leadingAnchor),
            detailsTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 120)
        ])

        contentStack.addArrangedSubview(detailsTextView)
    }

    private func updatePlaceholders() {
        titlePlaceholder.isHidden = !titleTextView.text.isEmpty
        detailsPlaceholder.isHidden = !detailsTextView.text.isEmpty
    }
}

extension TaskDetailViewController: TaskDetailViewProtocol {

    func display(title: String, dateText: String, details: String) {
        titleTextView.text = title
        dateLabel.text = dateText
        detailsTextView.text = details
        updatePlaceholders()
    }

    func showError(_ message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension TaskDetailViewController: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        updatePlaceholders()
    }

    func textView(
        _ textView: UITextView,
        shouldChangeTextIn range: NSRange,
        replacementText text: String
    ) -> Bool {

        if textView === titleTextView && text == "\n" {
            detailsTextView.becomeFirstResponder()
            return false
        }
        return true
    }
}
