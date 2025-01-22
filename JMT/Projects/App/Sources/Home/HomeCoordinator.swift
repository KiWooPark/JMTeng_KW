//
//  HomeCoordinator.swift
//  App
//
//  Created by PKW on 2023/12/22.
//

import FloatingPanel
import UIKit

protocol HomeCoordinator: Coordinator {
    func setUserLocationCoordinator()
    func showUserLocationViewController(endPoint: Int)
    
    func setSearchRestaurantCoordinator()
    func showSearchRestaurantViewController()
    
    func showSearchTabWithButton()

    func setCreateGroupCoordinator()
    func showCreateGroupViewController()
    
    func setDetailRestaurantCoordinator()
    func showDetailRestaurantViewController(id: Int)
}

class DefaultHomeCoordinator: HomeCoordinator {
    var parentCoordinator: Coordinator? = nil
    
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController?
    var finishDelegate: CoordinatorFinishDelegate?
    var type: CoordinatorType = .home
    
    init(navigationController: UINavigationController?, parentCoordinator: Coordinator) {
        self.navigationController = navigationController
        self.parentCoordinator = parentCoordinator
    }
    
    func start() {
        guard let homeViewController = HomeViewController.instantiateFromStoryboard(storyboardName: "Home") as? HomeViewController else { return }
        homeViewController.viewModel?.coordinator = self
        navigationController?.pushViewController(homeViewController, animated: true)
    }
    
    func setUserLocationCoordinator() {
        let coordinator = DefaultUserLocationCoordinator(navigationController: navigationController,
                                                         parentCoordinator: self,
                                                         finishDelegate: self)
        childCoordinators.append(coordinator)
    }
    
    func showUserLocationViewController(endPoint: Int) {
        if getChildCoordinator(.userLocation) == nil {
            setUserLocationCoordinator()
        }
        
        if let coordinator = getChildCoordinator(.userLocation) as? UserLocationCoordinator {
            coordinator.enterPoint = endPoint
            coordinator.start()
        }
    }
    
    func setSearchRestaurantCoordinator() {
        let coordinator = DefaultSearchRestaurantCoordinator(navigationController: navigationController,
                                                             parentCoordinator: self,
                                                             finishDelegate: self)
        childCoordinators.append(coordinator)
    }
    
    func showSearchRestaurantViewController() {
        if getChildCoordinator(.searchRestaurant) == nil {
            setSearchRestaurantCoordinator()
        }
        
        if let coordinator = getChildCoordinator(.searchRestaurant) as? SearchRestaurantCoordinator {
            coordinator.start()
        }
    }
    
    func showSearchTabWithButton() {
        if let coordinator = parentCoordinator as? DefaultTabBarCoordinator {
            coordinator.tabBarController.selectedIndex = 1
        }
    }
    
    func setCreateGroupCoordinator() {
        let coordinator = DefaultCreateGroupCoordinator(navigationController: navigationController, parentCoordinator: self, finishDelegate: self)
        childCoordinators.append(coordinator)
    }
    
    func showCreateGroupViewController() {
        if getChildCoordinator(.createGroup) == nil {
            setCreateGroupCoordinator()
        }
        
        if let coordinator = getChildCoordinator(.createGroup) as? CreateGroupCoordinator {
            coordinator.start()
        }
    }
    
    func setDetailRestaurantCoordinator() {
        let coordinator = DefaultRestaurantDetailCoordinator(navigationController: navigationController,
                                                             parentCoordinator: self,
                                                             finishDelegate: self)
        childCoordinators.append(coordinator)
    }
    
    func showDetailRestaurantViewController(id: Int) {
        if getChildCoordinator(.restaurantDetail) == nil {
            setDetailRestaurantCoordinator()
        }
        
        if let coordinator = getChildCoordinator(.restaurantDetail) as? RestaurantDetailCoordinator {
            coordinator.start(id: id)
        }
    }
    
    func getChildCoordinator(_ type: CoordinatorType) -> Coordinator? {
        var childCoordinator: Coordinator? = nil
        
        switch type {
        case .userLocation:
            childCoordinator = childCoordinators.first(where: { $0 is UserLocationCoordinator })
        case .searchRestaurant:
            childCoordinator = childCoordinators.first(where: { $0 is SearchRestaurantCoordinator })
        case .restaurantDetail:
            childCoordinator = childCoordinators.first(where: { $0 is RestaurantDetailCoordinator })
        case .createGroup:
            childCoordinator = childCoordinators.first(where: { $0 is CreateGroupCoordinator })
        default:
            break
        }
    
        return childCoordinator
    }
}

extension DefaultHomeCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        childCoordinators = childCoordinators.filter { $0.type != childCoordinator.type }
    }
}

extension DefaultHomeCoordinator: RestaurantsDataUpdatable {
    func updateRestaurantsData() {
        if let vc = navigationController?.viewControllers.first as? HomeViewController {
            vc.viewModel?.didUpdateGroupRestaurantsData?()
        }
    }
}
