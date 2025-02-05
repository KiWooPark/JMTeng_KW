//
//  AuthDataSource.swift
//  JMTeng
//
//  Created by PKW on 1/21/25.
//

import GoogleSignIn
import Alamofire
import Foundation

// 2번
protocol AuthDataSource {
    func signInGoogle(completion: @escaping ((Result<AuthDTO, Error>) -> Void))
}

class DefaultAuthDataSource: AuthDataSource {
    
    func signInGoogle(completion: @escaping ((Result<AuthDTO, Error>) -> Void)) {
        guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else { return }
    
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
            
            if let error = error {
                return
            }
            
            guard let idToken = result?.user.idToken?.tokenString else { return }
            
            if let url = Bundle.main.url(forResource: "GoogleMock", withExtension: "json"),
                let data = try? Data(contentsOf: url) {
                
                do {
                    let decodedData = try JSONDecoder().decode(AuthDTO.self, from: data)
                    completion(.success(decodedData))
                } catch {
                    completion(.failure(error))
                }
            }
        }
    }
}
