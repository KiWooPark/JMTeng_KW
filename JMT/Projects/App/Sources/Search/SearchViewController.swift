//
//  SearchViewController.swift
//  App
//
//  Created by PKW on 2023/12/22.
//

import CoreLocation
import SnapKit
import UIKit

class SearchViewController: UIViewController {
    
    // MARK: - Properties
    var viewModel: SearchViewModel?

    @IBOutlet weak var searchTextField: SearchTextField!
    
    @IBOutlet weak var recentContainerView: UIView!
    @IBOutlet weak var tagCollectionView: UICollectionView!
    
    @IBOutlet weak var segmentedControllerContainerView: UIView!
    @IBOutlet weak var segmentedController: CustomSegmentedControl!
    
    @IBOutlet weak var pageVCContainerView: UIView!
    
    var pageViewController: SearchPageViewController?
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupBind()
        
        tagCollectionView.delegate = self
        tagCollectionView.dataSource = self
        pageViewController?.searchPVDelegate = self
        
        viewModel?.fetchRecentSearchRestaurants()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    // MARK: - SetupBindings
    func setupBind() {
        viewModel?.didUpdateSegIndex = { [weak self] index in
            self?.segmentedController.selectedSegmentIndex = index
    
            let direction: UIPageViewController.NavigationDirection = self?.viewModel?.currentSegIndex ?? 0 <= index ? .forward : .reverse

            if let pageVC = self?.pageViewController {
                pageVC.setViewControllers([pageVC.vcArray[index]], direction: direction, animated: true)
                self?.viewModel?.currentSegIndex = index
            }
        }
    }
    
    // MARK: - FetchData
    
    // MARK: - SetupData
    
    // MARK: - SetupUI
    func setupUI() {
        
        self.navigationItem.title = "검색"
        tagCollectionView.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        segmentedControllerContainerView.isHidden = true
        pageVCContainerView.isHidden = true
        
        if let pageVC = pageViewController {
            self.addChild(pageVC)
            pageVCContainerView.addSubview(pageVC.view)
            pageVC.didMove(toParent: self)
            
            pageVC.view.snp.makeConstraints { make in
                make.leading.trailing.top.bottom.equalToSuperview()
            }
        }
    }
    
    // MARK: - Actions
    @IBAction func didTabSegmentedController(_ sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        let direction: UIPageViewController.NavigationDirection = viewModel?.currentSegIndex ?? 0 <= index ? .forward : .reverse

        if let pageVC = pageViewController {
            pageVC.setViewControllers([pageVC.vcArray[index]], direction: direction, animated: true)
            viewModel?.currentSegIndex = index
        }
    }
    
    @IBAction func didTabCancelButton(_ sender: Any) {
        viewModel?.restaurants.removeAll()
        viewModel?.groupList.removeAll()
        viewModel?.outBoundrestaurants.removeAll()
        
        updateUI(isSearch: false)
    }
    
    @IBAction func didTabDeleteRecentKeywordButton(_ sender: Any) {
        viewModel?.coordinator?.showButtonPopupViewController()
    }
    
    
    // MARK: - Helper Methods
    // 최근 검색어 업데이트
    func updateRecentKeyword(keyword: String) {
        viewModel?.saveRecentSearchRestaurants(keyword: keyword)
        viewModel?.fetchRecentSearchRestaurants()
    }
    
    // 검색 상태 UI 업데이트
    func updateUI(isSearch: Bool) {
        DispatchQueue.main.async {
            if isSearch {
                self.searchTextField.resignFirstResponder()
                self.tagCollectionView.reloadData()
                self.recentContainerView.isHidden = true
                self.tagCollectionView.isHidden = true
                self.pageVCContainerView.isHidden = false
                self.segmentedControllerContainerView.isHidden = false
            } else {
                self.searchTextField.text = ""
                self.searchTextField.resignFirstResponder()
                self.tagCollectionView.reloadData()
                self.recentContainerView.isHidden = false
                self.tagCollectionView.isHidden = false
                self.segmentedControllerContainerView.isHidden = true
                self.pageVCContainerView.isHidden = true
            }
        }
    }
    
    // 검색 데이터 가져오기
    func fetchData(keyword: String) {
        
        guard keyword != "" else { return }
        
        viewModel?.restaurants.removeAll()
        viewModel?.groupList.removeAll()
        viewModel?.outBoundrestaurants.removeAll()
        
        // 그룹에 가입되어 있는지 체크
        viewModel?.isEmptyGroup = UserDefaultManager.selectedGroupId == nil
        
        Task {
            do {
                if viewModel?.isEmptyGroup == false {
                    try await viewModel?.fetchRestaurantsAsync(keyword: keyword)
                }
                
                try await viewModel?.fetchGroupsAsync(keyword: keyword)
                try await viewModel?.fetchOutBoundRestaurantsAsync(keyword: keyword)
                
                NotificationCenter.default.post(name: .didUpdateSearchTabData, object: nil)
                
                updateUI(isSearch: true)
                
            } catch {
                print("SearchViewController fetchData Error", error)
            }
        }
    }
}

// MARK: - Extention

// MARK: - CollectionView Delegate
extension SearchViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let keyword = self.viewModel?.recentSearchRestaurants[indexPath.row] ?? ""
        self.searchTextField.text = keyword
        updateRecentKeyword(keyword: keyword)
        
        fetchData(keyword: keyword)
    }
}

// MARK: - CollectionView DataSource
extension SearchViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.recentSearchRestaurants.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tagCell", for: indexPath) as? TagCollectionViewCell else { return UICollectionViewCell() }
        cell.setupData(text: viewModel?.recentSearchRestaurants[indexPath.item] ?? "")
        cell.delegate = self
        cell.deleteButton.tag = indexPath.item
        return cell
    }
}

// MARK: - CollectionView Delegate FlowLayout
extension SearchViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (viewModel?.recentSearchRestaurants[indexPath.item].size(withAttributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14)]).width)! + 48, height: 29)
    }
}

// MARK: - UITextField Delegate
extension SearchViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        guard let keyword = textField.text, keyword != "" else { return false }
        
        updateRecentKeyword(keyword: keyword)
        
        fetchData(keyword: keyword)
        
        return true
    }
}

// MARK: - SearchPageViewController Delegate
extension SearchViewController: SearchPageViewControllerDelegate {
    func updateSegmentIndex(index: Int) {
        viewModel?.currentSegIndex = index
        segmentedController.selectedSegmentIndex = index
    }
}

// MARK: - TagCollectionViewCell Delegate
extension SearchViewController: TagCollectionViewCellDelegate {
    func didTabDeleteButton(index: Int) {
        
        viewModel?.deleteRecentSearchRestaurants(index)
       
        tagCollectionView.performBatchUpdates {
            tagCollectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
        } completion: { _ in
            self.tagCollectionView.reloadData()
        }
    }
}

extension SearchViewController: ButtonPopupDelegate {
    func didTabDoneButton() {
        viewModel?.deleteAllRecentSearchRestaurants()
        
        DispatchQueue.main.async {
            self.tagCollectionView.reloadData()
        }
    }
    
    func didTabCloseButton() { }
    
    func didTabCancelButton() { }
}

