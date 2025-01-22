//
//  CreateGroupCoordinator.swift
//  JMTeng
//
//  Created by PKW on 3/20/24.
//

import Foundation
import UIKit

protocol CreateGroupCoordinator: Coordinator {
    func goToHomeViewController()
}

class DefaultCreateGroupCoordinator: CreateGroupCoordinator {
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController?
    var finishDelegate: CoordinatorFinishDelegate?
    var type: CoordinatorType = .createGroup
    
    init(navigationController: UINavigationController?, parentCoordinator: Coordinator,
         finishDelegate: CoordinatorFinishDelegate)
    {
        self.navigationController = navigationController
        self.parentCoordinator = parentCoordinator
        self.finishDelegate = finishDelegate
    }
    
    func start() {
        guard let createGroupViewController = CreateGroupViewController.instantiateFromStoryboard(storyboardName: "CreateGroup") as? CreateGroupViewController else { return }
        createGroupViewController.coordinator = self
        self.navigationController?.pushViewController(createGroupViewController, animated: true)
    }
    
    func getChildCoordinator(_ type: CoordinatorType) -> Coordinator? {
        var childCoordinator: Coordinator? = nil
        
        switch type {
        case .buttonPopup:
            childCoordinator = self.childCoordinators.first(where: { $0 is ButtonPopupCoordinator })
        case .convertUserLocation:
            childCoordinator = self.childCoordinators.first(where: { $0 is ConvertUserLocationCoordinator })
        default:
            break
        }
    
        return childCoordinator
    }
    
    func goToHomeViewController() {
        if let homeViewController = self.navigationController?.viewControllers[0] as? HomeViewController {
            homeViewController.updateViewBasedOnGroupStatus()
            self.navigationController?.popViewController(animated: true)
            self.navigationController?.tabBarController?.tabBar.isHidden = false
        }
    }
}

extension DefaultCreateGroupCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        self.childCoordinators = self.childCoordinators.filter { $0.type != childCoordinator.type }
    }
}
