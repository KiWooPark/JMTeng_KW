//
//  ReadGroupAPI.swift
//  JMTeng
//
//  Created by PKW on 4/25/24.
//

import Alamofire
import Foundation

struct ReadGroupAPI {
    static func fetchMyGroupAsync() async throws -> MyGroupResponse {
        let response = try await AF.request(ReadGroupTarget.fetchMyGroup, interceptor: DefaultRequestInterceptor())
            .validate(statusCode: 200..<300)
            .serializingDecodable(MyGroupResponse.self)
            .value
        return response
    }
    
    static func fetchGroups(request: SearchGroupRequest) async throws -> SearchGroupResponse {
        do {
            let response = await AF.request(ReadGroupTarget.fetchGroups(request), interceptor: DefaultRequestInterceptor())
                .validate()
                .serializingDecodable(SearchGroupResponse.self)
                .response
            
            switch response.response?.statusCode {
            case 200:
                guard let result = response.value else {
                    throw GroupError.noGroupDataAvailable
                }
                return result
            default:
                throw GroupError.unknownError
            }
        } catch {
            throw error
        }
    }
}
