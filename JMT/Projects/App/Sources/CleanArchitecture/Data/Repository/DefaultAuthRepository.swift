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

    func signInGoogle(completion: @escaping ((Result<AuthVO, Error>) -> Void)) {
        dataSource.signInGoogle { result in
            switch result {
            case .success(let data):
                // DTO -> VO 변환
                completion(.success(data.toDomain()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
