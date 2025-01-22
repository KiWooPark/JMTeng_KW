//
//  ProfileImageViewModel.swift
//  App
//
//  Created by PKW on 2023/12/22.
//

import Foundation

class ProfileImageViewModel {
    enum UpdateUI {
        case nicknameLabel
        case saveProfileImage
    }
    
    weak var coordinator: ProfileImageCoordinator?
    var photoAuthService: PhotoAuthService?
    
    var onSuccess: ((UpdateUI) -> Void)?
    var onFailure: (() -> Void)?
    
    var nickname: String?
    var isDefaultProfileImage: Bool = true
    var preventButtonTouch: Bool = false
    
    func getUserInfo() {
        UserInfoAPI.getLoginInfo { response in
            switch response {
            case .success(let info):
                self.nickname = info.nickname
                self.onSuccess?(.nicknameLabel)
            case .failure(let error):
                print("getUserInfo 실패!!", error)
                self.onFailure?()
            }
        }
    }
    
    func saveProfileImage(imageData: Data?) {
        
        preventButtonTouch = true
        
        if let data = imageData {
            let base64 = data.base64EncodedString()
            ProfileImageAPI.saveProfileImage(request: ProfileImageReqeust(imageStr: base64)) { response in
                switch response {
                case .success(let response):
                
                    switch response.code {
                    case "UNAUTHORIZED":
                        print("인증이 필요하므로 엑세스토큰 갱신 필요")
                    default:
    
                        DefaultKeychainService.shared.setValue(DefaultKeychainService.shared.getValue(for: KeychainKey.tempAccessToken, type: String.self), for: KeychainKey.accessToken)
                        DefaultKeychainService.shared.setValue(DefaultKeychainService.shared.getValue(for: KeychainKey.tempRefreshToken, type: String.self), for: KeychainKey.refreshToken)
                        DefaultKeychainService.shared.setValue(DefaultKeychainService.shared.getValue(for: KeychainKey.tempAccessTokenExpiresIn, type: Int.self), for: KeychainKey.accessTokenExpiresIn)
                        
                        DefaultKeychainService.shared.removeKeychain(KeychainKey.tempAccessToken)
                        DefaultKeychainService.shared.removeKeychain(KeychainKey.tempRefreshToken)
                        DefaultKeychainService.shared.removeKeychain(KeychainKey.tempAccessTokenExpiresIn)
                        
                        self.onSuccess?(.saveProfileImage)
                    }
                case .failure(let error):
                    print("saveProfileImage - ProfileImageAPI.saveProfileImage 실패!!", error)
                    self.onFailure?()
                }
                
                self.preventButtonTouch = false
            }
        }
    }
    
    func saveDefaultProfileImage() {
        
        preventButtonTouch = true
        
        ProfileImageAPI.saveDefaultProfileImage { response in
            switch response {
            case .success(let response):
                
                switch response.code {
                case "UNAUTHORIZED":
                    print("인증이 필요하므로 엑세스토큰 갱신 필요")
                default:
                    DefaultKeychainService.shared.setValue(DefaultKeychainService.shared.getValue(for: KeychainKey.tempAccessToken, type: String.self), for: KeychainKey.accessToken)
                    DefaultKeychainService.shared.setValue(DefaultKeychainService.shared.getValue(for: KeychainKey.tempRefreshToken, type: String.self), for: KeychainKey.refreshToken)
                    DefaultKeychainService.shared.setValue(DefaultKeychainService.shared.getValue(for: KeychainKey.tempAccessTokenExpiresIn, type: Int.self), for: KeychainKey.accessTokenExpiresIn)
                    
                    DefaultKeychainService.shared.removeKeychain(KeychainKey.tempAccessToken)
                    DefaultKeychainService.shared.removeKeychain(KeychainKey.tempRefreshToken)
                    DefaultKeychainService.shared.removeKeychain(KeychainKey.tempAccessTokenExpiresIn)
                    
                    self.onSuccess?(.saveProfileImage)
                }
            case .failure(let error):
                print("saveDefaultProfileImage - 실패!!", error)
            }
            
            self.preventButtonTouch = false
        }
    }
}
