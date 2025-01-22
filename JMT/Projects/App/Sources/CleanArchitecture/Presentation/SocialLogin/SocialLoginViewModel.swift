//
//  SocialLoginViewModel.swift
//  App
//
//  Created by PKW on 2023/12/22.
//

import Foundation

enum UserLoginAction: String {
    case SIGN_UP
    case NICKNAME_PROCESS
    case PROFILE_IMAGE_PROCESS
    case LOG_IN
}

class SocialLoginViewModel {
    weak var coordinator: SocialLoginCoordinator?
    var isEnabled = true
    
    private var authUserCase: AuthUseCase
    
    init(authUserCase: AuthUseCase) {
        self.authUserCase = authUserCase
    }

    func startGooleLoginTest(idToken: String, completion: @escaping ((Result<AuthVO, Error>) -> Void)) {
        let result = authUserCase.googleLogin(idToken: idToken) { result in
            switch result {
            case .success(let data):
                completion(.success(data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func startGoogleLogin() {
        isEnabled = false
        
        coordinator?.showGoogleLoginViewController(completion: { result in
            switch result {
            case .success(let idToken):
                
                self.coordinator?.navigationController?.showLoadingIndicator()
                
                SocialLoginAPI.googleLogin(request: SocialLoginRequest(token: idToken)) { loginResult in
                    
                    UserInfoAPI.getLoginInfo { userResult in
                        switch userResult {
                        case .success(let infoData):
                            
                            UserDefaultManager.userInfo = UserInfoModel(id: infoData.id, nickname: infoData.nickname, profileImg: infoData.profileImg)
                            
                            switch loginResult {
                            case .success(let response):
                                if let action = UserLoginAction(rawValue: response.userLoginAction) {
                                    switch action {
                                    case .SIGN_UP, .NICKNAME_PROCESS:
                                        self.coordinator?.showNicknameViewController()
                                    case .PROFILE_IMAGE_PROCESS:
                                        self.coordinator?.showProfileViewController()
                                    case .LOG_IN:
                                        DefaultKeychainService.shared.setValue(DefaultKeychainService.shared.getValue(for: KeychainKey.tempAccessToken,
                                                                                                                      type: String.self),
                                                                               for: KeychainKey.accessToken)
                                        DefaultKeychainService.shared.setValue(DefaultKeychainService.shared.getValue(for: KeychainKey.tempRefreshToken,
                                                                                                                      type: String.self),
                                                                               for: KeychainKey.refreshToken)
                                        DefaultKeychainService.shared.setValue(DefaultKeychainService.shared.getValue(for: KeychainKey.tempAccessTokenExpiresIn,
                                                                                                                      type: Int.self),
                                                                               for: KeychainKey.accessTokenExpiresIn)
                                        
                                        DefaultKeychainService.shared.removeKeychain(KeychainKey.tempAccessToken)
                                        DefaultKeychainService.shared.removeKeychain(KeychainKey.tempRefreshToken)
                                        DefaultKeychainService.shared.removeKeychain(KeychainKey.tempAccessTokenExpiresIn)
                                        
                                        let appCoordinator = self.coordinator?.getTopCoordinator()
                                        appCoordinator?.showTabBarViewController()
                                    }
                                }
                            case .failure(let error):
                                print("startGoogleLogin - SocialLoginAPI.googleLogin 실패!!", error)
                            }
                            
                            self.coordinator?.navigationController?.hideLoadingIndicator()
                        case .failure(let error):
                            print(error)
                        }
                    }
                }
            case .failure(let error):
                print("startGoogleLogin 실패!!", error)
            }
            
            self.isEnabled = true
        })
    }
    
    func startAppleLogin() {
        // 클로저 등록
        coordinator?.onAppleLoginSuccess = { [weak self] result in
            switch result {
            case .success(let idToken):
                
                SocialLoginAPI.appleLogin(request: SocialLoginRequest(token: idToken)) { result in
                    switch result {
                    case .success(let response):
                        if let action = UserLoginAction(rawValue: response.userLoginAction) {
                            switch action {
                            case .SIGN_UP, .NICKNAME_PROCESS:
                                self?.coordinator?.showNicknameViewController()
                            case .PROFILE_IMAGE_PROCESS:
                                self?.coordinator?.showProfileViewController()
                            case .LOG_IN:
                                DefaultKeychainService.shared.setValue(DefaultKeychainService.shared.getValue(for: KeychainKey.tempAccessToken,
                                                                                                              type: String.self),
                                                                       for: KeychainKey.accessToken)
                                DefaultKeychainService.shared.setValue(DefaultKeychainService.shared.getValue(for: KeychainKey.tempRefreshToken,
                                                                                                              type: String.self),
                                                                       for: KeychainKey.refreshToken)
                                DefaultKeychainService.shared.setValue(DefaultKeychainService.shared.getValue(for: KeychainKey.tempAccessTokenExpiresIn,
                                                                                                              type: Int.self),
                                                                       for: KeychainKey.accessTokenExpiresIn)
                                
                                DefaultKeychainService.shared.removeKeychain(KeychainKey.tempAccessToken)
                                DefaultKeychainService.shared.removeKeychain(KeychainKey.tempRefreshToken)
                                DefaultKeychainService.shared.removeKeychain(KeychainKey.tempAccessTokenExpiresIn)
                                
                                let appCoordinator = self?.coordinator?.getTopCoordinator()
                                appCoordinator?.showTabBarViewController()
                            }
                        }
                    case .failure(let error):
                        print("startAppleLogin - SocialLoginAPI.appleLogin 실패!!", error)
                    }
                }
            case .failure(let error):
                // 에러 처리
                print("startAppleLogin 실패!!", error)
            }
        }
        coordinator?.showAppleLoginViewController()
    }
}
