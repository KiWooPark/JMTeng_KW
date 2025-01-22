//
//  UserInfoAPI.swift
//  JMTeng
//
//  Created by PKW on 2024/01/19.
//

import Alamofire
import Foundation

struct UserInfoAPI {
    static func getLoginInfo(completion: @escaping (Result<UserInfoModel, NetworkError>) -> Void) {
        AF.request(UserInfoTarget.getUserInfo, interceptor: DefaultRequestInterceptor())
            .validate(statusCode: 200..<300)
            .responseDecodable(of: UserInfoResponse<UserInfoData>.self) { response in
                switch response.result {
                case .success(let response):
                    if let model = response.toDomain {
                        completion(.success(model))
                    }
                case .failure(let error):
                    print("getLoginInfo 실패!!", error)
                    completion(.failure(.custom("getLoginInfo Error")))
                }
            }
    }
    
    static func getLoginInfo() async throws -> UserInfoResponse<UserInfoData> {
        let response = try await AF.request(UserInfoTarget.getUserInfo, interceptor: DefaultRequestInterceptor())
            .validate(statusCode: 200..<300)
            .serializingDecodable(UserInfoResponse<UserInfoData>.self)
            .value
        return response
    }
}
