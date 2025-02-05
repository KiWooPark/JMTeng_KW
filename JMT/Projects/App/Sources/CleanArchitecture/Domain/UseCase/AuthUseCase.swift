//
//  SocialLoginUseCase.swift
//  JMTeng
//
//  Created by PKW on 1/21/25.
//

import Foundation

// 5번
protocol AuthUseCase {
    func signInGoogle(completion: @escaping ((Result<AuthVO, Error>) -> Void))
}

class DefaultAuthUseCase: AuthUseCase {
    private let repository: AuthRepository

    init(repository: AuthRepository) {
        self.repository = repository
    }
    
    func signInGoogle(completion: @escaping ((Result<AuthVO, Error>) -> Void)) {
        repository.signInGoogle { result in
            switch result {
            case .success(let data):
                // 비즈니스 로직 처리!
                completion(.success(data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
