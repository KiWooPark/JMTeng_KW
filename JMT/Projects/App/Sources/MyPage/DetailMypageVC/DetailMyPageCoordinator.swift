//
//  MyPageTestVoordinator.swift
//  App
//
//  Created by 이지훈 on 1/19/24.
//

import Alamofire
import Foundation
import UIKit

protocol DetailMyPageCoordinator: Coordinator {
    //
    //    func goToServiceTermsViewController()
    //    func goToServiceUseViewController()
    //
    func setMyPageChangeNicknameCoordinator()
    func showMyPageChangeNicknameVC()
    
    func setMyPageManageCoordinator()
    func showMyPageManageViewController()
    
    func setMyPageServiceTermsCoordinator()
    func showMyPageServiceTermsViewController()
    
    func setMyPageServiceUseCoordinator()
    func showMyPageServiceUseVC()
    
    func setProfileImagePopupCoordinator()
    func showProfileImagePopupViewController()
    
    func showImagePicker()
}

class DefaultDetailMyPageCoordinator: DetailMyPageCoordinator {
    var parentCoordinator: Coordinator? = nil
    
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController?
    var finishDelegate: CoordinatorFinishDelegate?
    var type: CoordinatorType = .detailMyPage
    
    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }
    
    func start() {
        guard let detailMyPageViewController = DetailMyPageVC.instantiateFromStoryboard(storyboardName: "DetailMyPage") as? DetailMyPageVC else { return }
        detailMyPageViewController.viewModel?.coordinator = self
        navigationController?.pushViewController(detailMyPageViewController, animated: true)
    }
    
    func setMyPageManageCoordinator() {
        let coordinator = DefaultMyPageManageCoordinator(navigationController: navigationController)
        childCoordinators.append(coordinator)
    }
    
    func showMyPageManageViewController() {
        // 있는지 예외처리
        if getChildCoordinator(.myPageManage) == nil {
            setMyPageManageCoordinator()
        }
    
        if let coordinator = getChildCoordinator(.myPageManage) as? MyPageManageCoordinator {
            coordinator.start()
        }
    }
    
    // 서비스 이용동의
    func setMyPageServiceTermsCoordinator() {
        let coordinator = DefaultMyPageServiceTermsVC(navigationController: navigationController)
        childCoordinators.append(coordinator)
    }
    
    func showMyPageServiceTermsViewController() {
        // 있는지 예외처리
        if getChildCoordinator(.serviceTerms) == nil {
            setMyPageServiceTermsCoordinator()
        }
        
        if let coordinator = getChildCoordinator(.serviceTerms) as? MyPageServiceTermsCoordinator {
            coordinator.start()
        }
    }
    
    // 개인정보 처리방침
    func setMyPageServiceUseCoordinator() {
        let coordinator = DefaultServiceUseCoordinator(navigationController: navigationController)
        childCoordinators.append(coordinator)
    }
    
    func showMyPageServiceUseVC() {
        // 있는지 예외처리
        if getChildCoordinator(.serviceUse) == nil {
            setMyPageServiceUseCoordinator()
        }
        
        if let coordinator = getChildCoordinator(.serviceUse) as? ServiceUseCoordinator {
            coordinator.start()
        }
    }
    
    // 닉네임 수정
    func setMyPageChangeNicknameCoordinator() {
        let coordinator = DefaultMyPageChangeNicknaemCoordinator(navigationController: navigationController)
        childCoordinators.append(coordinator)
    }
    
    func showMyPageChangeNicknameVC() {
        if getChildCoordinator(.serviceUse) == nil {
            setMyPageChangeNicknameCoordinator()
        }
        if let coordinator = getChildCoordinator(.changeNickname) as? MyPageChangeNicknaemCoordinator {
            coordinator.start()
        }
    }
    
    // 이미지 등록
    func setProfileImagePopupCoordinator() {
        let coordinator = DefaultProfileImagePopupCoordinator(navigationController: navigationController,
                                                              parentCoordinator: self,
                                                              finishDelegate: self)
        childCoordinators.append(coordinator)
    }
    
    func showProfileImagePopupViewController() {
        if getChildCoordinator(.profilePopup) == nil {
            setProfileImagePopupCoordinator()
        }
        
        if let coordinator = getChildCoordinator(.profilePopup) as? ProfileImagePopupCoordinator {
            coordinator.start()
        }
    }
    
    func showImagePicker() {
        let photoService = DefaultPhotoAuthService()
        
        var config = PhotoKitConfiguration.shared
        config.library.defaultMultipleSelection = false
        
        let picker = PhotoKitNavigationController(configuration: config)
        
        picker.didFinishCompletion = { photo in
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
    }
    
    func handleImagePickerResult(_ image: UIImage?, isDefault: Bool) {
        if let detailMyPageViewController = navigationController?.topViewController as? DetailMyPageVC {
            detailMyPageViewController.profileImage.image = image
            detailMyPageViewController.viewModel?.isDefaultProfileImage = isDefault
            
            uploadProfileImage(image: (image ?? UIImage(named: "DefaultImage"))!)
            NotificationCenter.default.post(name: NSNotification.Name("ProfileImageUpdated"), object: nil)
        }
    }
    
    func uploadProfileImage(image: UIImage) {
        guard let accessToken = DefaultKeychainService.shared.getValue(for: KeychainKey.accessToken, type: String.self),
              let imageData = image.jpegData(compressionQuality: 0.5)
        else {
            return
        }
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)",
            "Accept": "*/*"
        ]
        
        AF.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(imageData, withName: "profileImg", fileName: "profile.jpg", mimeType: "image/jpeg")
        }, to: "https://api.jmt-matzip.dev/api/v1/user/profileImg", method: .post, headers: headers)
            .responseDecodable(of: ImageResponse.self) { response in
                switch response.result {
                case .success(let responseData):
                    print("Image uploaded successfully: \(responseData.message)")
                case .failure(let error):
                    print("Failed to upload image: \(error.localizedDescription)")
                }
            }
    }
    
    // 배열내에 있는 코디네이터에 enum으로 선언한 애가 있는지
    func getChildCoordinator(_ type: CoordinatorType) -> Coordinator? {
        var childCoordinator: Coordinator? = nil
        
        switch type {
        case .serviceTerms:
            childCoordinator = childCoordinators.first(where: { $0 is MyPageServiceTermsCoordinator })
        case .myPageManage:
            childCoordinator = childCoordinators.first(where: { $0 is MyPageManageCoordinator })
        case .serviceUse:
            childCoordinator = childCoordinators.first(where: { $0 is ServiceUseCoordinator })
        case .profilePopup:
            childCoordinator = childCoordinators.first(where: { $0 is ProfileImagePopupCoordinator })
        case .changeNickname:
            childCoordinator = childCoordinators.first(where: { $0 is MyPageChangeNicknaemCoordinator })
        default:
            break
        }
        
        return childCoordinator
    }
}

extension DefaultDetailMyPageCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        childCoordinators = childCoordinators.filter { $0.type != childCoordinator.type }
    }
}
