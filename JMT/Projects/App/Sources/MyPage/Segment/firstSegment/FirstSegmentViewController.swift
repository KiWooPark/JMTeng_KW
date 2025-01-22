//
//  FirstSegmentViewController.swift
//  JMTeng
//
//  Created by 이지훈 on 2/16/24.
//

import Alamofire
import UIKit

class FirstSegmentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var viewModel: MyPageViewModel?
    
    // 필터링용
    var selectedDistance: String = "가까운순"
    var selectedType: String = ""
    var selectedAlcohol: Bool = false
    var restaurantID: Int?
    
    @IBOutlet weak var registerHeaderView: UIView!
    
    @IBOutlet weak var typeFilterView: UIView!
    @IBOutlet weak var alcholrFilterView: UIView!
    
    @IBOutlet weak var mainTable: UITableView!
    
    @IBOutlet weak var nearFilterView: UIView!
    
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var alcholLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    
    @IBOutlet weak var typeBtn: UIButton!
    @IBOutlet weak var distanceButton: UIButton!
    
    @IBOutlet weak var alcholBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainTable.delegate = self
        mainTable.dataSource = self
        
        layout()
        
        viewModel?.onRestaurantsDataUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.mainTable.reloadData()
            }
        }
        
        distanceButton.layer.zPosition = 1
        self.view.bringSubviewToFront(distanceButton)
        
        viewModel?.fetchUserInfo { }
        
        setupMenus() // 이 함수를 viewDidLoad에 추가합니다.
        
        // 탭 제스처 인식기를 추가하여 뷰를 탭했을 때 UIMenu를 표시하도록 설정
        addTapGestureToView(distanceLabel, action: #selector(showDistanceMenuAction))
        addTapGestureToView(typeLabel, action: #selector(showTypeMenuAction))
        addTapGestureToView(alcholLabel, action: #selector(showAlcoholMenuAction))
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    // 뷰에 탭 제스처 인식기를 추가하는 메서드
    private func addTapGestureToView(_ view: UIView, action: Selector) {
        let tapGesture = UITapGestureRecognizer(target: self, action: action)
        view.addGestureRecognizer(tapGesture)
        view.isUserInteractionEnabled = true // 뷰의 사용자 인터랙션 활성화
    }
    
    func getUserInfo() {
        UserInfoAPI.getLoginInfo { response in
            switch response {
            case .success:
                print(1)
            case .failure(let error):
                print("getUserInfo 실패!!", error)
            }
        }
    }
    
    func setupMenus() {
        // 거리 필터 메뉴 설정
        let distanceActions = [
            UIAction(title: "가까운순", handler: { [weak self] _ in self?.handleDistanceFilterChange("가까운순") }),
            UIAction(title: "좋아요", handler: { [weak self] _ in self?.handleDistanceFilterChange("좋아요") }),
            UIAction(title: "최신순", handler: { [weak self] _ in self?.handleDistanceFilterChange("최신순") })
        ]
        distanceButton.menu = UIMenu(title: "", children: distanceActions)
        distanceButton.showsMenuAsPrimaryAction = true
        
        // 알코올 필터 메뉴 설정
        let alcoholActions = [
            UIAction(title: "주류가능", handler: { [weak self] _ in self?.handleAlcoholFilterChange(true) }),
            UIAction(title: "주류불가능/모름", handler: { [weak self] _ in self?.handleAlcoholFilterChange(false) })
        ]
        alcholBtn.menu = UIMenu(title: "", children: alcoholActions)
        alcholBtn.showsMenuAsPrimaryAction = true
    }
    
    
    func layout() {
        nearFilterView.layer.cornerRadius = nearFilterView.frame.height / 2
        nearFilterView.clipsToBounds = true
        
        typeFilterView.layer.cornerRadius = typeFilterView.frame.height / 2
        typeFilterView.clipsToBounds = true
        
        alcholrFilterView.layer.cornerRadius = alcholrFilterView.frame.height / 2
        alcholrFilterView.clipsToBounds = true
    }
    
    // 가까운순 필터링
    @objc
    func showDistanceMenuAction() {
        let actions = [
            UIAction(title: "가까운순", handler: { [weak self] _ in self?.handleDistanceFilterChange("가까운순") }),
            UIAction(title: "좋아요", handler: { [weak self] _ in self?.handleDistanceFilterChange("좋아요") }),
            UIAction(title: "최신순", handler: { [weak self] _ in self?.handleDistanceFilterChange("최신순") })
        ]
        distanceButton.menu = UIMenu(title: "", children: actions)
        distanceButton.showsMenuAsPrimaryAction = true
    }
    
    @objc 
    func showTypeMenuAction() {
        let foodTypes: [FoodType] = [
            FoodType(filter: .KOREA),
            FoodType(filter: .JAPAN),
            FoodType(filter: .CHINA),
            FoodType(filter: .FOREIGN),
            FoodType(filter: .CAFE),
            FoodType(filter: .BAR),
            FoodType(filter: .ETC)
        ]
        
        let actions = foodTypes.map { foodType in
            UIAction(title: foodType.name, image: nil) { [weak self] _ in
                self?.selectedType = foodType.filter.rawValue
                self?.typeLabel.text = foodType.name
                //                self?.fetchRestaurants()
            }
        }
        
        typeBtn.menu = UIMenu(title: "", children: actions)
        typeBtn.showsMenuAsPrimaryAction = true
    }
    
    
    
    
    @objc 
    func showAlcoholMenuAction() {
        let actions = [
            UIAction(title: "주류가능", handler: { [weak self] _ in self?.handleAlcoholFilterChange(true) }),
            UIAction(title: "주류불가능/모름", handler: { [weak self] _ in self?.handleAlcoholFilterChange(false) })
        ]
        
        alcholBtn.menu = UIMenu(title: "", children: actions)
        alcholBtn.showsMenuAsPrimaryAction = true
    }
    
    func handleDistanceFilterChange(_ filter: String) {
        selectedDistance = filter
        distanceLabel.text = filter
        //        fetchRestaurants()
    }
    
    func handleAlcoholFilterChange(_ canDrink: Bool) {
        selectedAlcohol = canDrink
        alcholLabel.text = canDrink ? "주류가능" : "주류불가능/모름"
        //        fetchRestaurants()
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.testRestaurantsData.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyPageRegisterResturantTableViewCell", for: indexPath) as? MyPageRegisterResturantTableViewCell else {
            return UITableViewCell()
        }
        
        let target = viewModel?.testRestaurantsData[indexPath.row]
        cell.configureData(with: target)
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let restaurant = viewModel?.testRestaurantsData[indexPath.row]
        
        if let restaurantId = restaurant?.id {
            // coordinator를 통해 상세 화면으로 전환합니다.
            viewModel?.coordinator?.showRestaurantDetail(for: restaurantId)
        }
    }

    @IBAction func didtapDistance(_ sender: Any) {
        showDistanceMenuAction()
    }
    
    
    @IBAction func typeBtn(_ sender: Any) {
        showTypeMenuAction()
    }
    
    @IBAction func alcholBtn(_ sender: Any) {
        showAlcoholMenuAction()
    }
}
