//
//  ProfileImagePopupCoordinator.swift
//  JMTeng
//
//  Created by PKW on 2024/01/17.
//

import Foundation
import UIKit

protocol ProfileImagePopupCoordinator: Coordinator {
    func showAlbum()
    func setDefaultProfileImage()
}

class DefaultProfileImagePopupCoordinator: ProfileImagePopupCoordinator {
    
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController?
    var finishDelegate: CoordinatorFinishDelegate?
    var type: CoordinatorType = .profilePopup
    
    init(navigationController: UINavigationController?,
         parentCoordinator: Coordinator,
         finishDelegate: CoordinatorFinishDelegate) {
        self.navigationController = navigationController
        self.parentCoordinator = parentCoordinator
        self.finishDelegate = finishDelegate
    }
    
    func start() {
        let profileImagePopupViewController = ProfileImagePopupViewController.instantiateFromStoryboard(storyboardName: "Login") as ProfileImagePopupViewController
        profileImagePopupViewController.viewModel?.coordinator = self
        profileImagePopupViewController.modalPresentationStyle = .overFullScreen
        self.navigationController?.present(profileImagePopupViewController, animated: false)
    }
    
    func showAlbum() {
        switch parentCoordinator {
        case is DefaultProfileImageCoordinator:
            let parentCoordinator = parentCoordinator as! DefaultProfileImageCoordinator
            parentCoordinator.showImagePicker()
        case is DefaultDetailMyPageCoordinator:
            let parentCoordinator = parentCoordinator as! DefaultDetailMyPageCoordinator
            parentCoordinator.showImagePicker()
        default:
            print("3333")
        }
    }
    
    func setDefaultProfileImage() {
        switch parentCoordinator {
        case is DefaultProfileImageCoordinator:
            let parentCoordinator = parentCoordinator as! DefaultProfileImageCoordinator
            parentCoordinator.handleImagePickerResult(UIImage(named: "DefaultProfileImage"), isDefault: true)
        case is DefaultDetailMyPageCoordinator:
            let parentCoordinator = parentCoordinator as! DefaultDetailMyPageCoordinator
            parentCoordinator.handleImagePickerResult(UIImage(named: "DefaultProfileImage"), isDefault: true)
        default:
            print("3333")
        }
    }
}
