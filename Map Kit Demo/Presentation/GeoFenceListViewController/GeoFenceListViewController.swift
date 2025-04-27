//
//  GeoFenceListViewController.swift
//  Map Kit Demo
//
//  Created by Abdullah-Shahid  on 28/04/2025.
//

import UIKit
import Anchorage

class GeoFenceListViewController: UIViewController {
    private let viewModel = GeoFenceListViewModel()
    private let customNavBar = UIView()
    private let tableView = UITableView()
    private let noDataLabel = UILabel()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        configureBindings()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.input(.viewDidLoad)
    }
    
    private func configureBindings() {
        viewModel.output = { [weak self] output in
            guard let strongSelf = self else { return }
            switch output {
            case .configureUI:
                strongSelf.configureUI()
            case .dismissVC:
                strongSelf.dismiss(animated: true)
            case .hideNoDateLabel:
                strongSelf.noDataLabel.isHidden = true
            }
        }
    }
    
    func configureUI() {
        configureNavBar()
        configureTableView()
        configureNoDataLabel()
    }
    
    private func configureNavBar() {
        
        let backButton = UIButton(type: .system)
        let titleLabel = UILabel()
        navigationController?.isNavigationBarHidden = true
        
        // Custom nav bar setup
        view.addSubview(customNavBar)
        customNavBar.backgroundColor = .systemBackground
        
        // Back button configuration
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        customNavBar.addSubview(backButton)
        
        // Title label configuration
        titleLabel.text = "Saved Geo-Fences"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textAlignment = .center
        customNavBar.addSubview(titleLabel)
        
        // Constraints
        customNavBar.topAnchor == view.safeAreaLayoutGuide.topAnchor
        customNavBar.horizontalAnchors == view.horizontalAnchors
        customNavBar.heightAnchor == 44
        
        backButton.leadingAnchor == customNavBar.leadingAnchor + 16
        backButton.centerYAnchor == customNavBar.centerYAnchor
        backButton.widthAnchor == 24
        backButton.heightAnchor == 24
        
        titleLabel.centerXAnchor == customNavBar.centerXAnchor
        titleLabel.centerYAnchor == customNavBar.centerYAnchor
    }
    
    private func configureTableView() {
        view.addSubview(tableView)
        tableView.horizontalAnchors == view.horizontalAnchors
        tableView.bottomAnchor == view.bottomAnchor
        tableView.topAnchor == customNavBar.bottomAnchor
        
        tableView.register(LocationCell.self, forCellReuseIdentifier: "LocationCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
    }
    
    private func configureNoDataLabel() {
        noDataLabel.textColor = .label
        noDataLabel.font = .systemFont(ofSize: 17, weight: .medium)
        noDataLabel.textAlignment = .center
        noDataLabel.text = "No Data Found"
        view.addSubview(noDataLabel)
        noDataLabel.centerAnchors == view.centerAnchors
    }
    @objc
    private func backButtonTapped() {
        viewModel.input(.backButtonTapped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension GeoFenceListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.tableViewRowCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as! LocationCell
        let location = viewModel.locations[indexPath.row]
        
        cell.configure(with: location)
        return cell
    }
}

extension GeoFenceListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
