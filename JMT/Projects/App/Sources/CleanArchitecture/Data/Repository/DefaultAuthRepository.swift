//
//  AuthRepositoryImpl.swift
//  JMTeng
//
//  Created by PKW on 1/21/25.
//

import AuthenticationServices
import Foundation
import GoogleSignIn

// 4번
class DefaultAuthRepository: AuthRepository {
    private let dataSource: AuthDataSource
    
    init(dataSource: AuthDataSource) {
        self.dataSource = dataSource
    }
    
    func googleLogin(idToken: String, completion: @escaping ((Result<AuthVO, Error>) -> Void)) {
        dataSource.googleLogin(idToken: idToken) { result in
            switch result {
            case .success(let result):
                // 여기서 데이터 가공이나 필터링 작업을 수행
                let result = result.toDomain()
                
                completion(.success(result))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
