//
//  SearchRestaurantViewController.swift
//  JMTeng
//
//  Created by PKW on 2024/02/04.
//

import UIKit
import SnapKit

class SearchRestaurantViewController: UIViewController {

    var viewModel: SearchRestaurantViewModel?
    
    @IBOutlet weak var searchRestaurantResultTableView: UITableView!
    @IBOutlet weak var searchRestaurantTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "맛집 등록"
        setCustomNavigationBarBackButton(isSearchVC: false)
        
        viewModel?.didUpdateRestaurantsInfo = {
            self.searchRestaurantResultTableView.reloadData()
        }
        
        updateEmptyBackgroundView()
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
    
    func updateEmptyBackgroundView() {
        let emptyView = UIView(frame: CGRect(x: 0, y: 0, width: searchRestaurantResultTableView.bounds.width, height: searchRestaurantResultTableView.bounds.height))
        let emptyImageView = UIImageView(image: JMTengAsset.emptyRestaurant.image)
        emptyImageView.contentMode = .scaleAspectFit
        
        emptyView.addSubview(emptyImageView)
        emptyImageView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
        
        searchRestaurantResultTableView.backgroundView = emptyView
    }
    
    func setupUI() {
        searchRestaurantTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        searchRestaurantResultTableView.keyboardDismissMode = .onDrag
    }
    
    @IBAction func didTabCancelButton(_ sender: Any) {
        searchRestaurantTextField.text = ""
        searchRestaurantTextField.resignFirstResponder()
        
        viewModel?.restaurantsInfo.removeAll()
        viewModel?.didUpdateRestaurantsInfo?()
    }
}

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

extension SearchRestaurantViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel?.coordinator?.showSearchRestaurantMapViewController(info: viewModel?.restaurantsInfo[indexPath.row])
    }
}

extension SearchRestaurantViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        viewModel?.fetchRestaurantsInfo(keyword: textField.text ?? "")
        return true
    }

    @objc func textFieldDidChange(_ textField: UITextField) {
        guard viewModel?.restaurantsInfo.isEmpty == false else { return }

        viewModel?.restaurantsInfo.removeAll()
        viewModel?.didUpdateRestaurantsInfo?()
    }
}