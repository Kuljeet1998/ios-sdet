//
//  CountryDetailViewController.swift
//  CountriesChallenge
//

import UIKit

class CountryDetailViewController: UIViewController {
    private let country: Country
    
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
    
    init(country: Country) {
        self.country = country
        super.init(nibName: nil, bundle: nil)

        title = country.name

        setupViews()
        configureViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Use init(viewModel:)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
    }
    
    private func setupViews() {
        view.addSubview(mainStackView)
        mainStackView.addArrangedSubview(firstLineStack)
        mainStackView.addArrangedSubview(secondLineStack)
        firstLineStack.addArrangedSubview(nameAndRegionLabel)
        firstLineStack.addArrangedSubview(codeLabel)
        secondLineStack.addArrangedSubview(capitalLabel)
        
        mainStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.insets.left).isActive = true
        mainStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.insets.top).isActive = true
        mainStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: Constants.insets.right).isActive = true
    }
    
    private func configureViews() {
        nameAndRegionLabel.text = "\(country.name), \(country.region)"
        codeLabel.text = country.code
        capitalLabel.text = country.capital
    }
}
