//
//  SearchRestaurantCoordinator.swift
//  JMTeng
//
//  Created by PKW on 2024/02/04.
//

import Foundation
import UIKit

protocol SearchRestaurantCoordinator: Coordinator {
    func setSearchRestaurantMapCoordinator()
    func showSearchRestaurantMapViewController()
}

class DefaultSearchRestaurantCoordinator: SearchRestaurantCoordinator {
    
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController?
    var finishDelegate: CoordinatorFinishDelegate?
    var type: CoordinatorType = .searchRestaurant
    
    init(navigationController: UINavigationController?,
         parentCoordinator: Coordinator?,
         finishDelegate: CoordinatorFinishDelegate?) {
        self.navigationController = navigationController
        self.parentCoordinator = parentCoordinator
        self.finishDelegate = finishDelegate
    }
    
    func start() {
        let searchRestaurantViewModel = SearchRestaurantViewController.instantiateFromStoryboard(storyboardName: "SearchRestaurant") as SearchRestaurantViewController
        searchRestaurantViewModel.viewModel?.coordinator = self
        self.navigationController?.pushViewController(searchRestaurantViewModel, animated: true)
    }
    
    func setSearchRestaurantMapCoordinator() {
        let coordinator = DefaultSearchRestaurantMapCoordinator(navigationController: navigationController, parentCoordinator: self, finishDelegate: self)
        childCoordinators.append(coordinator)
    }
    
    func showSearchRestaurantMapViewController() {
        if getChildCoordinator(.searchRestaurantMap) == nil {
            setSearchRestaurantMapCoordinator()
        }
        
        let coordinator = getChildCoordinator(.searchRestaurantMap) as! SearchRestaurantMapCoordinator
        coordinator.start()
    }
    
    func getChildCoordinator(_ type: CoordinatorType) -> Coordinator? {
        var childCoordinator: Coordinator? = nil
        
        switch type {
        case .searchRestaurantMap:
            childCoordinator = childCoordinators.first(where: { $0 is SearchRestaurantMapCoordinator })
        default:
            break
        }
        return childCoordinator
    }
}

extension DefaultSearchRestaurantCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        self.childCoordinators = self.childCoordinators.filter{ $0.type != childCoordinator.type }
    }
}

