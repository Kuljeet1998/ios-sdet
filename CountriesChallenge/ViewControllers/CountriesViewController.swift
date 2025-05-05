//
//  CountriesViewController.swift
//  CountriesChallenge
//

import Combine
import UIKit

class CountriesViewController: UIViewController {
     var viewModel = CountriesViewModel()
    
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "No countries available"
        label.textAlignment = .center
        label.textColor = .darkGray
        label.isHidden = true
        label.accessibilityIdentifier = "NoCountriesLabel"
        return label
    }()

    

     init(viewModel: CountriesViewModel = CountriesViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)

        title = "Countries"
        tableView.register(CountryCell.self, forCellReuseIdentifier: CountryCell.identifier)
        searchController.hidesNavigationBarDuringPresentation = true
        
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("Use init(viewModel:)")
    }

    private lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.attributedTitle = NSAttributedString(string: "Pull to refresh")
        control.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        return control
    }()

    private var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }

    private var isFiltering: Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!isSearchBarEmpty || searchBarScopeIsFiltering)
    }

    private var countries: [Country] {
        if isFiltering {
            return filteredCountries
        }
        return viewModel.countriesSubject.value
    }

    private var filteredCountries: [Country] = []

    internal lazy var tableView: UITableView = {
        let view = UITableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.dataSource = self
        view.delegate = self
        view.addSubview(refreshControl)
        return view
    }()

    private lazy var searchController: UISearchController = {
        let searchController = UISearchController()
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.autocapitalizationType = .none
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        definesPresentationContext = true
        return searchController
    }()

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.style = .large
        return view
    }()

    private var tasks = Set<AnyCancellable>()

    init() {
        super.init(nibName: nil, bundle: nil)

        title = "Countries"
        tableView.register(CountryCell.self, forCellReuseIdentifier: CountryCell.identifier)
        searchController.hidesNavigationBarDuringPresentation = true
        
        setupViews()
    }

//    required init?(coder: NSCoder) {
//        fatalError("Use init()")
//    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        activityIndicator.startAnimating()
        setupSubscribers()
        viewModel.refreshCountries()
    }

    private func setupViews() {
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        view.addSubview(emptyLabel)

        tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        activityIndicator.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        activityIndicator.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        activityIndicator.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        activityIndicator.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
    }

    @objc private func refresh(_ sender: AnyObject) {
        viewModel.refreshCountries()
    }

    private func setupSubscribers() {
        viewModel.countriesSubject
        .receive(on: DispatchQueue.main)
        .sink { countries in
            self.activityIndicator.stopAnimating()
            self.refreshControl.endRefreshing()
            self.tableView.reloadData()

            // ✅ Show/hide empty label
            self.emptyLabel.isHidden = !countries.isEmpty
            self.tableView.isHidden = countries.isEmpty

        }.store(in: &tasks)

        viewModel.errorSubject
        .receive(on: DispatchQueue.main)
        .sink { error in
            guard let error = error else { return }
            let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)
            alert.addAction(cancel)
            let retry = UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
                guard let self = self else { return }
                self.activityIndicator.startAnimating()
                self.viewModel.refreshCountries()
            }
            alert.addAction(retry)
            self.present(alert, animated: true)
        }.store(in: &tasks)
    }
}

extension CountriesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CountryCell.identifier, for: indexPath) as? CountryCell else {
            return UITableViewCell()
        }
        let country = countries[indexPath.row]
        cell.configure(country: country)
        return cell
    }
}

extension CountriesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let country = countries[indexPath.row]
        let detailViewController = CountryDetailViewController(country: country)
        tableView.deselectRow(at: indexPath, animated: false)
        navigationController?.pushViewController(detailViewController, animated: true)
    }
}

extension CountriesViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased() else { return }
        filteredCountries = countries.filter { country in
            if isSearchBarEmpty {
                return true
            } else {
                return country.name.lowercased().contains(searchText) ||
                    country.capital.lowercased().contains(searchText)
            }
        }
        tableView.reloadData()
    }
}
