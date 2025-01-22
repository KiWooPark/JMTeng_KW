//
//  UserLocationViewController.swift
//  JMTeng
//
//  Created by PKW on 2024/01/19.
//

import UIKit

class UserLocationViewController: UIViewController, KeyboardEvent {

    // MARK: - Enum
    
    // MARK: - Properties
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var addressListTableView: UITableView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var recentSearchView: UIView!
    
    var transformView: UIView { return addressListTableView.backgroundView ?? UIView() }
    
    var viewModel: UserLocationViewModel?
    
    var isFolded = false
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        addressTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        addressListTableView.keyboardDismissMode = .onDrag
        
        viewModel?.onSuccess = {
            DispatchQueue.main.async {
                self.addressListTableView.reloadData()
                self.addressListTableView.isUserInteractionEnabled = true
            }
        }
        
        if viewModel?.fetchRecentLocations() == true {
            addressListTableView.setEmptyBackgroundView(str: "최근 검색한 위치가 없어요")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationItem.title = "위치 변경"
        
        setCustomNavigationBarBackButton(goToViewController: .popVC)
        
        setupKeyboardEvent { [weak self] noti in
            guard let self = self else { return }
            guard let keyboardFrame = noti.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
            self.addressListTableView.adjustBackgroundViewHeight(keyboardHeight: keyboardFrame.cgRectValue.height - 48)

        } keyboardWillHide: { [weak self] noti in
            guard let self = self else { return }
            
            self.addressListTableView.adjustBackgroundViewHeight(keyboardHeight: 0)
        }
    }
    
    // MARK: - SetupBindings
    
    // MARK: - FetchData
    
    // MARK: - SetupData
    
    // MARK: - SetupUI
    func setupUI() {
        cancelButton.isHidden = true
        setupTextField()
    }
    
    func setupTextField() {
        // 텍스트 필드
        addressTextField.layer.cornerRadius = 8
        
        // 오른쪽 패딩을 설정
        let rightPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: addressTextField.frame.height))
        addressTextField.rightView = rightPaddingView
        addressTextField.rightViewMode = .always
        
        let image = UIImage(named: "TextFieldSearch")!
        let leftImageView = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: image.size.width, height: addressTextField.frame.height))
        leftImageView.image = image
        leftImageView.contentMode = .scaleAspectFit // 이미지를 중앙에 배치
        
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 38, height: addressTextField.frame.height))
        leftView.addSubview(leftImageView)
        leftImageView.center = CGPoint(x: leftView.frame.width / 2, y: leftView.frame.height / 2)
        addressTextField.leftView = leftView
        addressTextField.leftViewMode = .always // 항상 보이도록 설정
    }
    
    
    // MARK: - Actions
    @IBAction func didTabTextFieldCancelButton(_ sender: Any) {
        
        DispatchQueue.main.async {
            self.addressTextField.text = ""
            self.addressTextField.resignFirstResponder()
            
            if self.viewModel?.recentLocations.isEmpty == true {
                self.addressListTableView.setEmptyBackgroundView(str: "최근 검색한 위치가 없어요")
            } else {
                self.addressListTableView.removeEmptyBackgroundView()
            }
            
            self.viewModel?.currentPage = 1
            self.viewModel?.previousCount = 0
            self.viewModel?.isEmpty = false
            
            self.viewModel?.resultLocations.removeAll()
            
            self.viewModel?.isSearch = false
            self.recentSearchView.isHidden = false
            self.cancelButton.isHidden = true
            
            self.addressListTableView.reloadData()
        }
    }
    
    @IBAction func recentLocationDeleteAll(_ sender: Any) {
        viewModel?.coordinator?.showButtonPopupViewController()
    }
    
    // MARK: - Helper Methods
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
//    func finishSearch() {
//        viewModel?.isSearch = false
//        viewModel?.isDataLoading = false
//        viewModel?.hasMoreData = false
//        cancelButton.isHidden = true
//        recentSearchView.isHidden = false
//        addressListTableView.reloadData()
//    }
    
//    func searchAndUpdateUI() {
//        DispatchQueue.main.async {
//            if self.viewModel?.resultLocations.isEmpty == true {
//                self.addressListTableView.setEmptyBackgroundView(str: "검색 결과가 없어요.")
//            }
//            self.addressTextField.resignFirstResponder()
//            self.addressListTableView.reloadData()
//        }
//    }
    
    // 최초 검색
    func fetchSearchLocation(keyword: String) {
        Task {
            do {
                viewModel?.resultLocations.removeAll()
                
                viewModel?.currentPage = 1
                viewModel?.previousCount = 0
                viewModel?.isEmpty = false
                
                try await viewModel?.fetchSearchLocationData(keyword: keyword)
                
                viewModel?.saveRecentLocation(keyword: keyword)
                viewModel?.fetchRecentLocations1()
                
                DispatchQueue.main.async {
                    if self.viewModel?.resultLocations.isEmpty == true {
                        self.addressListTableView.setEmptyBackgroundView(str: "검색 결과가 없어요")
                    } else {
                        self.recentSearchView.isHidden = true
                    }
                    
                    self.addressTextField.resignFirstResponder()
                    self.addressListTableView.reloadData()
                    self.addressListTableView.isUserInteractionEnabled = true
                }
            } catch {
                print(error)
            }
        }
    }
    
    func prefetchSearchLocation() {
        Task {
            do {
                try await viewModel?.fetchSearchLocationData(keyword: addressTextField.text ?? "")
                
                if viewModel?.previousCount != viewModel?.resultLocations.count {
                    let newIndices = ((viewModel?.previousCount ?? 0)..<(viewModel?.resultLocations.count ?? 0)).map { IndexPath(item: $0, section: 0) }
                    
                    DispatchQueue.main.async {
                        self.addressListTableView.performBatchUpdates {
                            self.addressListTableView.insertRows(at: newIndices, with: .bottom)
                        }
                    }
                }
            } catch {
                print(error)
            }
        }
    }
}

// MARK: - TableView Delegate
extension UserLocationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if viewModel?.isSearch == false {
            let keyword = viewModel?.recentLocations[indexPath.row] ?? ""
            viewModel?.isSearch = true
            viewModel?.isFinishSearch = true
            
            DispatchQueue.main.async {
                self.addressListTableView.isUserInteractionEnabled = false
                self.addressTextField.text = keyword
                self.cancelButton.isHidden = false
            }
            
            fetchSearchLocation(keyword: keyword)
            
        } else {
            if let location = viewModel?.resultLocations[indexPath.row] {
                DispatchQueue.main.async {
                    self.viewModel?.coordinator?.showConvertUserLocationViewController(with: location)
                    self.addressListTableView.isUserInteractionEnabled = true
                }
            }
        }
    }
}

// MARK: - TableView DataSource
extension UserLocationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.isSearch == true ? viewModel?.resultLocations.count ?? 0 : viewModel?.recentLocations.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "addressCell", for: indexPath) as? AddressTitleCell else { return UITableViewCell() }
        if viewModel?.isSearch == false {
            cell.addressNameLabel.text = viewModel?.recentLocations[indexPath.row] ?? ""
            cell.indexPath = indexPath
            cell.delegate = self
            return cell
        } else {
            cell.addressNameLabel.text = viewModel?.resultLocations[indexPath.row].placeName ?? ""
            cell.deleteButton.isHidden = true
            return cell
        }
    }
}

extension UserLocationViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        
        guard viewModel?.isEmpty == false && viewModel?.isSearch == true else { return }
        
        if indexPaths.contains(where: isLoadingCell) && viewModel?.isFetching == false {
            prefetchSearchLocation()
        }
    }

    // 지정된 인덱스 패스가 로딩 셀인지 확인하는 메소드
    private func isLoadingCell(for indexPath: IndexPath) -> Bool {
        return indexPath.row >= (viewModel?.resultLocations.count ?? 0) - 2
    }
}

// MARK: - CollectionView Delegate

// MARK: - CollectionView DataSource

// MARK: - Extention
extension UserLocationViewController: UITextFieldDelegate {
    
    // 텍스트 입력 시작
    func textFieldDidBeginEditing(_ textField: UITextField) {
        DispatchQueue.main.async {
            self.viewModel?.isSearch = true
            self.recentSearchView.isHidden = true
            self.cancelButton.isHidden = false
            
            self.addressListTableView.removeEmptyBackgroundView()
            self.addressListTableView.reloadData()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
    
        DispatchQueue.main.async {
            if textField.text?.isEmpty == true {
                
                self.viewModel?.isSearch = false
                self.recentSearchView.isHidden = false
                self.cancelButton.isHidden = true
                
                if self.viewModel?.recentLocations.isEmpty == true {
                    self.addressListTableView.setEmptyBackgroundView(str: "최근 검색한 위치가 없어요")
                } else {
                    self.addressListTableView.removeEmptyBackgroundView()
                }
                
                self.addressListTableView.reloadData()
            } else {
                if self.viewModel?.isFinishSearch == false {
                    self.addressListTableView.setEmptyBackgroundView(str: "다시 검색해 주세요")
                }
            }
        }
    }

    // 리턴 키보드
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard textField.text?.isEmpty == false else {
            return false
        }
        
        viewModel?.isFinishSearch = true
        fetchSearchLocation(keyword: textField.text ?? "" )

        return true
    }

    @objc 
    func textFieldDidChange(_ textField: UITextField) {
        
        viewModel?.isFinishSearch = false
        
        guard viewModel?.resultLocations.isEmpty == false else { return }

        viewModel?.resultLocations.removeAll()
        
        DispatchQueue.main.async {
            self.addressListTableView.reloadData()
        }
    }
}

extension UserLocationViewController: AddressTitleCellDelegate {
    func didTapDeleteButton(at indexPath: IndexPath) {
        
        viewModel?.deleteRecentLocation(indexPath.row)
        
        if viewModel?.recentLocations.isEmpty == true {
            DispatchQueue.main.async {
                self.addressListTableView.setEmptyBackgroundView(str: "최근 검색한 위치가 없어요")
            }
        }
    }
}

extension UserLocationViewController: ButtonPopupDelegate {
    func didTabDoneButton() {
        viewModel?.deleteAllRecentLocation()
        
        DispatchQueue.main.async {
            self.addressListTableView.setEmptyBackgroundView(str: "최근 검색한 위치가 없어요")
        }
    }
    
    func didTabCloseButton() { }
    func didTabCancelButton() { }
}
