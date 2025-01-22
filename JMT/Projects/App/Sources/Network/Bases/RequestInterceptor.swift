//
//  RequestInterceptor.swift
//  JMTeng
//
//  Created by PKW on 2024/01/19.
//

import Alamofire
import Foundation
import UIKit

class DefaultRequestInterceptor: RequestInterceptor {
    
    let keychainService = DefaultKeychainService.shared
    
    // 리퀘스트 요청시 호출됨
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        guard urlRequest.url?.absoluteString.hasPrefix("https://api.jmt-matzip.dev/api/v1") == true else {
            completion(.success(urlRequest))
            return
        }
        
        var accessToken = ""
        
        if let tempAccessToken = keychainService.getValue(for: KeychainKey.tempAccessToken, type: String.self) {
            accessToken = tempAccessToken
        } else {
            accessToken = keychainService.getValue(for: KeychainKey.accessToken, type: String.self) ?? ""
        }

        print("-------- adapt", accessToken)
        
        var resultUrlRequest = urlRequest
        resultUrlRequest.headers.add(.authorization(bearerToken: accessToken))

        completion(.success(resultUrlRequest))
    }
    
    // adapt 후 실패할경우 401 상태코드일경우
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        
        print("-------- retry 호출", (request.task?.response as? HTTPURLResponse)?.statusCode)

        guard let response = request.task?.response as? HTTPURLResponse, response.statusCode == 401 else {
            completion(.doNotRetryWithError(error))
            return
        }
    
        let accessToken = keychainService.getValue(for: KeychainKey.accessToken, type: String.self) ?? ""
        let refreshToken = keychainService.getValue(for: KeychainKey.refreshToken, type: String.self) ?? ""
        
        RefreshTokenAPI.refreshToken(request: RefreshTokenRequest(accessToken: accessToken, refreshToken: refreshToken)) { response in
            switch response {
            case .success(let response):
                
                if let tempAccessToken = self.keychainService.getValue(for: KeychainKey.tempAccessToken, type: String.self) {
                    self.keychainService.setValue(response.accessToken, for: KeychainKey.tempAccessToken)
                    self.keychainService.setValue(response.refreshToken, for: KeychainKey.tempRefreshToken)
                    self.keychainService.setValue(response.accessTokenExpiresIn, for: KeychainKey.tempAccessTokenExpiresIn)
                } else {
                    self.keychainService.setValue(response.accessToken, for: KeychainKey.accessToken)
                    self.keychainService.setValue(response.refreshToken, for: KeychainKey.refreshToken)
                    self.keychainService.setValue(response.accessTokenExpiresIn, for: KeychainKey.accessTokenExpiresIn)
                }
                
                completion(.retry)
            case .failure(let error):
                print("---------- retry - RefreshTokenAPI.refreshToken 실패", error)
             
                SocialLoginAPI.logout { response in
                    switch response {
                    case .success:

                        guard let windowScene = UIApplication.shared
                            .connectedScenes
                            .filter({ $0.activationState == .foregroundActive })
                            .first as? UIWindowScene else {
                                return
                        }
                        
                        guard let sceneDelegate = windowScene.delegate as? SceneDelegate else {
                            return
                        }
    
                        self.keychainService.removeKeychain(KeychainKey.accessToken)
                        self.keychainService.removeKeychain(KeychainKey.refreshToken)
                        self.keychainService.removeKeychain(KeychainKey.accessTokenExpiresIn)
                        
                        let appCoordinator = sceneDelegate.appCoordinator
                        appCoordinator?.logout()

                    case .failure(let failure):
                        print("SocialLoginAPI.logout Error", failure)
                    }

                    completion(.doNotRetryWithError(error))
                }
            }
        }
    }
}
