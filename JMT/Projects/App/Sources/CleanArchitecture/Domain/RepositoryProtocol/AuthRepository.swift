//
//  AuthRepository.swift
//  JMTeng
//
//  Created by PKW on 1/21/25.
//

import Foundation

// 3번
protocol AuthRepository {
    func signInGoogle(completion: @escaping ((Result<AuthVO, Error>) -> Void))
}
