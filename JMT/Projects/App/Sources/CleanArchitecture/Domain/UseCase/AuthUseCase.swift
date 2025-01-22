//
//  SocialLoginUseCase.swift
//  JMTeng
//
//  Created by PKW on 1/21/25.
//

import Foundation

// 5번
protocol AuthUseCase {
    func googleLogin(idToken: String, completion: @escaping ((Result<AuthVO, Error>) -> Void))
}

class DefaultAuthUseCase: AuthUseCase {
    private let repository: AuthRepository

    init(repository: AuthRepository) {
        self.repository = repository
    }
    
    func googleLogin(idToken: String, completion: @escaping ((Result<AuthVO, Error>) -> Void)) {
        repository.googleLogin(idToken: idToken) { result in
            switch result {
            case .success(let result):
                // VO를 뷰모델에 전달해야함
                completion(.success(result))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
