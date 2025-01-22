//
//  AuthDataSource.swift
//  JMTeng
//
//  Created by PKW on 1/21/25.
//

import Alamofire
import Foundation

// 2번
protocol AuthDataSource {
    func googleLogin(idToken: String, completion: @escaping ((Result<AuthDTO, Error>) -> Void))
}

class DefaultAuthDataSource: AuthDataSource {
    func googleLogin(idToken: String, completion: @escaping ((Result<AuthDTO, Error>) -> Void)) {
        
        // TODO: 네트워크 작업 Mock 데이터로 테스트
        if let url = Bundle.main.url(forResource: "GoogleMock", withExtension: "json"),
           let data = try? Data(contentsOf: url)
        {
            do {
                let decodedData = try JSONDecoder().decode(AuthDTO.self, from: data)
                completion(.success(decodedData))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
