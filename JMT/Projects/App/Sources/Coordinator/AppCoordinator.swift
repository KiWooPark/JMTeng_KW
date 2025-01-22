//
//  AppCoordinator.swift
//  App
//
//  Created by PKW on 2023/12/20.
//

import UIKit

protocol AppCoordinator: Coordinator {
    func setSocialLoginCoordinator()
    func showSocialLoginViewController()
    
    func setTabBarCoordinator()
    func showTabBarViewController()

    func logout()
    func updateAllRestaurantsData()
}

protocol RestaurantsDataUpdatable {
    func updateRestaurantsData()
}

class DefaultAppCoordinator: AppCoordinator {
   
    var parentCoordinator: Coordinator?
    
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController?
    
    var finishDelegate: CoordinatorFinishDelegate?
    var type: CoordinatorType = .app
    
    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }
    
    func start() {
        if DefaultKeychainService.shared.getValue(for: KeychainKey.accessToken, type: String.self) != nil {
            showSocialLoginViewController()
        } else {
            showTabBarViewController()
        }
    }
    
    func logout() {
        if getChildCoordinator(.socialLogin) == nil {
            setSocialLoginCoordinator()
        }
    
        if let socialLocinCoordinator = getChildCoordinator(.socialLogin) as? SocialLoginCoordinator {
            socialLocinCoordinator.logout()
        }
    }
    
    func setSocialLoginCoordinator() {
        let socialLoginCoordinator = DefaultSocialLoginCoordinator(
            navigationController: navigationController,
            parentCoordinator: self,
            finishDelegate: self)
        
        childCoordinators.append(socialLoginCoordinator)
    }
    
    func showSocialLoginViewController() {
        if getChildCoordinator(.socialLogin) == nil {
            setSocialLoginCoordinator()
        }
        
        if let socialLocinCoordinator = getChildCoordinator(.socialLogin) as? SocialLoginCoordinator {
            socialLocinCoordinator.start()
        }
    }
    
    func setTabBarCoordinator() {
        let coordinator = DefaultTabBarCoordinator(
            parentCoordinator: self,
            finishDelegate: self)
        
        childCoordinators.append(coordinator)
    }
    
    func showTabBarViewController() {
        if getChildCoordinator(.tabBar) == nil {
            setTabBarCoordinator()
        }
        
        if let coordinator = getChildCoordinator(.tabBar) as? TabBarCoordinator {
            coordinator.start()
        }
    }
    
    func getChildCoordinator(_ type: CoordinatorType) -> Coordinator? {
        var childCoordinator: Coordinator?
        
        switch type {
        case .socialLogin:
            childCoordinator = childCoordinators.first(where: { $0 is SocialLoginCoordinator })
        case .tabBar:
            childCoordinator = childCoordinators.first(where: { $0 is TabBarCoordinator })
        default:
            break
        }
        return childCoordinator
    }

    func updateAllRestaurantsData() {
        if let tab = childCoordinators.first {
            if let home = tab.childCoordinators[0] as? DefaultHomeCoordinator,
               let myPage = tab.childCoordinators[3] as? DefaultMyPageCoordinator {
                home.updateRestaurantsData()
                myPage.updateRestaurantsData()
            }
        }
    }
}

extension DefaultAppCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        self.childCoordinators = self.childCoordinators.filter { $0.type != childCoordinator.type }
    }
}
