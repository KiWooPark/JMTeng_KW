//
//  SearchRestaurantViewController.swift
//  JMTeng
//
//  Created by PKW on 2024/02/04.
//

import UIKit
import SnapKit


class SearchRestaurantViewController: UIViewController {

    deinit {
        print("SearchRestaurantViewController Deinit")
    }
    
    // MARK: - Properties
    var viewModel: SearchRestaurantViewModel?
    
    @IBOutlet weak var searchRestaurantResultTableView: UITableView!
    @IBOutlet weak var searchRestaurantTextField: UITextField!
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "맛집 등록"
        setCustomNavigationBarBackButton(goToViewController: .popVC)
        
        setupBind()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: - SetupBindings
    func setupBind() {
        viewModel?.didUpdateRestaurantsInfo = { [weak self] in
            self?.searchRestaurantResultTableView.reloadData()
        }
    }
    
    // MARK: - SetupData
    func fetchSearchRestaurantsData() {
        
        viewModel?.locationManager.didUpdateLocations = { [weak self] in
            
            let x = self?.viewModel?.locationManager.coordinate?.longitude ?? 0.0
            let y = self?.viewModel?.locationManager.coordinate?.latitude ?? 0.0
            
            Task {
                do {
                    let keyword = self?.searchRestaurantTextField.text ?? ""
                    try await self?.viewModel?.fetchSearchRestaurants(keyword: keyword, x:"\(x)", y:"\(y)")
                    self?.updateTableView()
                } catch {
                    print(error)
                }
            }
        }
        
        viewModel?.locationManager.startUpdateLocation()
    }
    
    // MARK: - SetupUI
    func setupUI() {
        updateEmptyTableViewBackgroundView()
        
        searchRestaurantTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        searchRestaurantResultTableView.keyboardDismissMode = .onDrag
    }
    
    func updateEmptyTableViewBackgroundView() {
        let emptyView = UIView(frame: CGRect(x: 0, y: 0, width: searchRestaurantResultTableView.bounds.width, height: searchRestaurantResultTableView.bounds.height))
        let emptyImageView = UIImageView(image: JMTengAsset.emptyRestaurant.image)
        emptyImageView.contentMode = .scaleAspectFit
        
        emptyView.addSubview(emptyImageView)
        emptyImageView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
        
        searchRestaurantResultTableView.backgroundView = emptyView
    }
    
    func updateTableView() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.searchRestaurantResultTableView.reloadData()
        }
    }

    // MARK: - Actions
    @IBAction func didTabCancelButton(_ sender: Any) {
        searchRestaurantTextField.text = ""
        searchRestaurantTextField.resignFirstResponder()
        
        viewModel?.restaurantsInfo.removeAll()
        updateTableView()
    }
    
    // MARK: - Helper Methods
    
    // MARK: - CollectionView Delegate
    
    // MARK: - CollectionView DataSource
    
    // MARK: - Extention
}

// MARK: - TableView Delegate
extension SearchRestaurantViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel?.coordinator?.showSearchRestaurantMapViewController(info: viewModel?.restaurantsInfo[indexPath.row])
    }
}

// MARK: - TableView DataSource
extension SearchRestaurantViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.restaurantsInfo.isEmpty == true ? 0 : viewModel?.restaurantsInfo.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell", for: indexPath) as? RestaurantLocationCell else { return UITableViewCell() }
        cell.setupData(viewModel: viewModel?.restaurantsInfo[indexPath.row])
        return cell
    }
}

// MARK: - TextField Delegate
extension SearchRestaurantViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        fetchSearchRestaurantsData()
        return true
    }

    @objc func textFieldDidChange(_ textField: UITextField) {
        guard viewModel?.restaurantsInfo.isEmpty == false else { return }

        viewModel?.restaurantsInfo.removeAll()
        viewModel?.didUpdateRestaurantsInfo?()
    }
}




