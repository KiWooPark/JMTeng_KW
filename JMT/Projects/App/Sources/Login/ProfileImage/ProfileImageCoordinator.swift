//
//  ProfileImageCoordinator.swift
//  App
//
//  Created by PKW on 2023/12/22.
//

import UIKit

protocol ProfileImageCoordinator: Coordinator {
    func showTabBarViewController()
    func showImagePicker()
    
    func setProfilePopupCoordinator()
    func showProfilePopupViewController()
}

class DefaultProfileImageCoordinator: ProfileImageCoordinator {
    weak var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    
    var navigationController: UINavigationController?
    var finishDelegate: CoordinatorFinishDelegate?
    var type: CoordinatorType = .socialLogin
    
    init(navigationController: UINavigationController?,
         parentCoordinator: Coordinator,
         finishDelegate: CoordinatorFinishDelegate)
    {
        self.navigationController = navigationController
        self.parentCoordinator = parentCoordinator
        self.finishDelegate = finishDelegate
    }
    
    func start() {
        guard let profileViewController = ProfileImageViewController.instantiateFromStoryboard(storyboardName: "Login") as? ProfileImageViewController else { return }
        profileViewController.viewModel?.coordinator = self
        navigationController?.pushViewController(profileViewController, animated: true)
    }
    
    func showTabBarViewController() {
        if let appCoordinator = getTopCoordinator() {
            let socialLoginCoordinator = appCoordinator.childCoordinators.first(where: { $0 is SocialLoginCoordinator })
            socialLoginCoordinator?.finish()
            
            appCoordinator.showTabBarViewController()
        }
    }
    
    func showImagePicker() {
        let photoService = DefaultPhotoAuthService()
        
        var config = PhotoKitConfiguration.shared
        config.library.defaultMultipleSelection = false
        
        let picker = PhotoKitNavigationController(configuration: config)
        
        picker.didFinishCompletion = { photo in
        
            self.handleImagePickerResult(photo.first, isDefault: false)
            picker.dismiss(animated: true)
        }

        photoService.requestAuthorization { result in
            switch result {
            case .success:
                self.navigationController?.present(picker, animated: true)
            case .failure:
                if let topViewController = self.navigationController?.topViewController {
                    topViewController.showAccessDeniedAlert(type: .photo)
                }
            }
        }
    }
    
    func handleImagePickerResult(_ image: UIImage?, isDefault: Bool) {
        if let profileImageViewController = navigationController?.topViewController as? ProfileImageViewController {
            profileImageViewController.profileImageView.image = image
            profileImageViewController.viewModel?.isDefaultProfileImage = isDefault
        }
    }
    
    func setProfilePopupCoordinator() {
        let coordinator = DefaultProfileImagePopupCoordinator(navigationController: navigationController,
                                                              parentCoordinator: self,
                                                              finishDelegate: self)
        childCoordinators.append(coordinator)
    }
    
    func showProfilePopupViewController() {
        if getChildCoordinator(.profilePopup) == nil {
            setProfilePopupCoordinator()
        }
        
        if let coordinator = getChildCoordinator(.profilePopup) as? ProfileImagePopupCoordinator {
            coordinator.start()
        }
    }
    
    func getChildCoordinator(_ type: CoordinatorType) -> Coordinator? {
        var childCoordinator: Coordinator? = nil
        
        switch type {
        case .profilePopup:
            childCoordinator = childCoordinators.first(where: { $0 is ProfileImagePopupCoordinator })
        default:
            break
        }
    
        return childCoordinator
    }
}

extension DefaultProfileImageCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        childCoordinators = childCoordinators.filter { $0.type != childCoordinator.type }
    }
}
