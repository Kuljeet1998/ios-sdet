//
//  CountryCell.swift
//  CountriesChallenge
//

import Foundation
import UIKit

class CountryCell: UITableViewCell {
    static let identifier = "CountryCell"

    struct Constants {
        static let insets = UIEdgeInsets(top: 8, left: 16, bottom: -8, right: -16)
    }

    private lazy var mainStackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.spacing = 8
        view.distribution = .fillEqually
        return view
    }()

    private lazy var firstLineStack: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .horizontal
        view.spacing = 8
        view.distribution = .fillProportionally
        return view
    }()

    private lazy var secondLineStack: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .horizontal
        view.spacing = 8
        view.distribution = .fillProportionally
        return view
    }()

    private lazy var nameAndRegionLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = .preferredFont(forTextStyle: .body)
        return view
    }()

    private lazy var codeLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textAlignment = .right
        view.font = .preferredFont(forTextStyle: .body)
        return view
    }()

    private lazy var capitalLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = .preferredFont(forTextStyle: .body)
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Use init(style:reuseIdentifier:)")
    }

    private func setupViews() {
        contentView.addSubview(mainStackView)
        mainStackView.addArrangedSubview(firstLineStack)
        mainStackView.addArrangedSubview(secondLineStack)
        firstLineStack.addArrangedSubview(nameAndRegionLabel)
        firstLineStack.addArrangedSubview(codeLabel)
        secondLineStack.addArrangedSubview(capitalLabel)

        mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.insets.left).isActive = true
        mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.insets.top).isActive = true
        mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: Constants.insets.right).isActive = true
        mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: Constants.insets.bottom).isActive = true
    }

    func configure(country: Country) {
        nameAndRegionLabel.text = "\(country.name), \(country.region)"
        codeLabel.text = country.code
        capitalLabel.text = country.capital
    }
}
