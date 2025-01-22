//
//  MyPageViewModel.swift
//  App
//
//  Created by 이지훈 on 1/19/24.
//

import Alamofire
import Foundation
import UIKit

class DetailMyPageViewModel {
    
    weak var coordinator: DetailMyPageCoordinator?
    private let keychainAccess: DefaultKeychainService
    
    
    var userInfo: MyPageUserLogin? {
        didSet {
            self.onUserInfoLoaded?()
        }
    }
    
    var onUserInfoLoaded: (() -> Void)?
        
    var isDefaultProfileImage: Bool = false
    
    init(keychainAccess: DefaultKeychainService = DefaultKeychainService.shared) {
        self.keychainAccess = keychainAccess
    }
    
    // ID 토큰과 액세스 토큰 값을 확인하는 함수
    func fetchTokens() {
        // ID 토큰 저장 여부 플래그 확인
        if let isIdTokenSaved = keychainAccess.getValue(for: KeychainKey.isIdTokenSaved, type: Bool.self),
            isIdTokenSaved == true,
           let idToken = keychainAccess.getValue(for: KeychainKey.idToken, type: String.self){
            print("---===---")
            print("ID Token: \(idToken)")
        } else {
            print("ID Token is not available. Checking if saved correctly...")
        }
        
        // 액세스 토큰 조회
        if let accessToken = keychainAccess.getValue(for: KeychainKey.accessToken, type: String.self) {
            print("Access Token: \(accessToken)")
        } else {
            print("Access Token is not available")
        }
    }
    
    func fetchUserInfo() {
        guard let accessToken = keychainAccess.getValue(for: KeychainKey.accessToken, type: String.self) else { return }
        
        let headers: HTTPHeaders = [
            "accept": "*/*",
            "Authorization": "Bearer \(accessToken)"
        ]

        AF.request("https://api.jmt-matzip.dev/api/v1/user/info", method: .get, headers: headers).responseDecodable(of: MyPageUserLogin.self) { response in
            switch response.result {
            case .success(let userInfo):
                self.userInfo = userInfo
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func getUserInfo() {
        UserInfoAPI.getLoginInfo { response in
            switch response {
            case .success:
               print(1)
            case .failure(let error):
                print("getUserInfo 실패!!", error)
            }
        }
    }
    
    func getMyPagUserLoginInfo() {
        MyPageUserInfo.getUserInfo { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let userInfo):
                    // 사용자 정보 처리 로직 (예: 데이터 바인딩)
                    print(userInfo)
                    self?.onDataUpdated?()
                case .failure(let error):
                    print("getUserInfo 실패: \(error)")
                }
            }
        }
    }
        
    func uploadProfileImage(_ image: UIImage) {
        guard let accessToken = keychainAccess.getValue(for: KeychainKey.accessToken, type: String.self) else {
            return
        }

        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)",
            "Content-Type": "multipart/form-data"
        ]

        AF.upload(
            multipartFormData: { multipartFormData in
                if let imageData = image.jpegData(compressionQuality: 0.5) {
                    multipartFormData.append(imageData, withName: "profileImg", fileName: "file.jpeg", mimeType: "image/jpeg")
                }
            },
            to: "https://api.jmt-matzip.dev/api/v1/user/profileImg",
            method: .post,
            headers: headers
        ).responseDecodable(of: ImageResponse.self) { response in
            switch response.result {
            case .success:
                self.onUserInfoLoaded?()
            case .failure(let error):
                print(error)
            }
        }
    }

    func handleLoginSuccess(idToken: String) {
        keychainAccess.setValue(idToken, for: KeychainKey.idToken)
        keychainAccess.setValue(true, for: KeychainKey.isIdTokenSaved)
        print("ID Token saved: \(idToken)")
    }
    
    // 로그아웃 처리
    func logout() {
        keychainAccess.removeAllKeychain()
        print("Logged out and all tokens removed.")
    }

    
    var onDataUpdated: (() -> Void)?
    
    
        
}
