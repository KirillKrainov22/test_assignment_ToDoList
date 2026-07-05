import UIKit

final class TaskListCell: UITableViewCell {

    static let reuseIdentifier = "TaskListCell"

    var onToggle: (() -> Void)?

    private let checkboxButton = UIButton(type: .system)
    private let titleLabel = UILabel()
    private let detailsLabel = UILabel()
    private let dateLabel = UILabel()
    private let textStack = UIStackView()

    private var isCompleted = false

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        backgroundColor = .clear
        selectionStyle = .none

        checkboxButton.tintColor = Theme.accent
        checkboxButton.translatesAutoresizingMaskIntoConstraints = false
        checkboxButton.addTarget(self, action: #selector(toggleTapped), for: .touchUpInside)
        checkboxButton.setContentHuggingPriority(.required, for: .horizontal)

        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        titleLabel.numberOfLines = 1

        detailsLabel.font = .systemFont(ofSize: 12, weight: .regular)
        detailsLabel.textColor = Theme.secondaryText
        detailsLabel.numberOfLines = 2

        dateLabel.font = .systemFont(ofSize: 12, weight: .regular)
        dateLabel.textColor = Theme.secondaryText

        textStack.axis = .vertical
        textStack.spacing = 6
        textStack.translatesAutoresizingMaskIntoConstraints = false
        textStack.addArrangedSubview(titleLabel)
        textStack.addArrangedSubview(detailsLabel)
        textStack.addArrangedSubview(dateLabel)

        contentView.addSubview(checkboxButton)
        contentView.addSubview(textStack)

        NSLayoutConstraint.activate([
            checkboxButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            checkboxButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
            checkboxButton.widthAnchor.constraint(equalToConstant: 24),
            checkboxButton.heightAnchor.constraint(equalToConstant: 24),

            textStack.leadingAnchor.constraint(equalTo: checkboxButton.trailingAnchor, constant: 12),
            textStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            textStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            textStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }

    func configure(with viewModel: TaskCellViewModel) {
        isCompleted = viewModel.isCompleted
        dateLabel.text = viewModel.dateText

        updateCheckbox()
        updateTitle(viewModel.title)

        detailsLabel.text = viewModel.details
        detailsLabel.isHidden = viewModel.details.isEmpty
        detailsLabel.textColor = isCompleted ? Theme.completedText : Theme.primaryText
    }

    private func updateCheckbox() {
        let name = isCompleted ? "checkmark.circle" : "circle"
        checkboxButton.setImage(UIImage(systemName: name), for: .normal)
        checkboxButton.tintColor = isCompleted ? Theme.accent : Theme.secondaryText
    }

    private func updateTitle(_ title: String) {
        if isCompleted {
            let attributed = NSAttributedString(
                string: title,
                attributes: [
                    .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                    .foregroundColor: Theme.completedText
                ]
            )
            titleLabel.attributedText = attributed
        } else {
            titleLabel.attributedText = nil
            titleLabel.text = title
            titleLabel.textColor = Theme.primaryText
        }
    }

    @objc private func toggleTapped() {
        onToggle?()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        onToggle = nil
        titleLabel.attributedText = nil
        titleLabel.text = nil
    }
}
