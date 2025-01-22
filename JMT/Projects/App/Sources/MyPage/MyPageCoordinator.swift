//
//  MyPageCoordinator.swift
//  App
//
//  Created by PKW on 2023/12/22.
//

import UIKit

protocol MyPageCoordinator: Coordinator {
    func goToDetailView(for segmentIndex: Int)
    func goToDetailMyPageView()
    
    func setDetailMyPageCoordinator()
    func showDetailMyPageVieController()
    
    func setRestaurantCoordinator()
    func showRestaurantDetail(for restaurantId: Int)
}

class DefaultMyPageCoordinator: MyPageCoordinator {
    var parentCoordinator: Coordinator? = nil
    
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController?
    var finishDelegate: CoordinatorFinishDelegate?
    var type: CoordinatorType = .mypage
    
    init(navigationController: UINavigationController?, parentCoordinator: Coordinator) {
        self.navigationController = navigationController
        self.parentCoordinator = parentCoordinator
    }
    
    func start() {
        guard let mypageViewController = MyPageViewController.instantiateFromStoryboard(storyboardName: "MyPage") as? MyPageViewController else { return }
        mypageViewController.viewModel?.coordinator = self
        navigationController?.pushViewController(mypageViewController, animated: true)
    }
    
    func goToDetailView(for segmentIndex: Int) {
        //   goToSegmentViewController(for : segmentIndex)
    }
        
    func goToDetailMyPageView() {
        let storyboard = UIStoryboard(name: "DetailMyPage", bundle: nil)
        if let viewController = storyboard.instantiateViewController(withIdentifier: "DetailMyPageVC") as? DetailMyPageVC {
            navigationController?.pushViewController(viewController, animated: true)
        } else {
            print("DetailMyPageVC could not be instantiated.")
        }
    }
    
    func showUserInfoViewController() {
        let storyboard = UIStoryboard(name: "MyPage", bundle: nil)
        if let userInfoVC = storyboard.instantiateViewController(withIdentifier: "MyPageViewController") as? MyPageViewController {
            //  userInfoVC.viewModel = MyPageViewModel()
            navigationController?.pushViewController(userInfoVC, animated: true)
        }
    }
    
    func setDetailMyPageCoordinator() {
        let coordinator = DefaultDetailMyPageCoordinator(navigationController: navigationController)
        childCoordinators.append(coordinator)
    }
    
    func showDetailMyPageVieController() {
        if getChildCoordinator(.detailMyPage) == nil {
            setDetailMyPageCoordinator()
        }
        
        if let coordinator = getChildCoordinator(.detailMyPage) as? DetailMyPageCoordinator {
            coordinator.start()
        }
    }
    
    func setRestaurantCoordinator() {
        let coordinator = DefaultRestaurantDetailCoordinator(navigationController: navigationController,
                                                             parentCoordinator: self,
                                                             finishDelegate: self)
        childCoordinators.append(coordinator)
    }
    
    func showRestaurantDetail(for restaurantId: Int) {
        if getChildCoordinator(.restaurantDetail) == nil {
            setRestaurantCoordinator()
        }
        
        if let coordinator = getChildCoordinator(.restaurantDetail) as? RestaurantDetailCoordinator {
            coordinator.start(id: restaurantId)
        }
    }

    func getChildCoordinator(_ type: CoordinatorType) -> Coordinator? {
        var childCoordinator: Coordinator? = nil
        
        switch type {
        case .detailMyPage:
            childCoordinator = childCoordinators.first(where: { $0 is DetailMyPageCoordinator })
        case .restaurantDetail:
            childCoordinator = childCoordinators.first(where: { $0 is RestaurantDetailCoordinator })
        default:
            break
        }
        return childCoordinator
    }
}

extension DefaultMyPageCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        childCoordinators = childCoordinators.filter { $0.type != childCoordinator.type }
    }
}

extension DefaultMyPageCoordinator: RestaurantsDataUpdatable {
    func updateRestaurantsData() {
        if let vc = navigationController?.viewControllers.first as? MyPageViewController {
            Task {
                try await vc.viewModel?.fetchUserRestaurants()
            }
        }
    }
}
