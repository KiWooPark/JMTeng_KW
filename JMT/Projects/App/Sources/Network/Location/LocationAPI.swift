//
//  LocationAPI.swift
//  JMTeng
//
//  Created by PKW on 4/25/24.
//

import Alamofire
import Foundation

struct LocationAPI {
    
    static func getSearchLocations(request: SearchLocationRequest) async throws -> SearchLocationResponse {
        let response = try await AF.request(LocationTarget.getSearchLocations(request), interceptor: DefaultRequestInterceptor())
            .validate(statusCode: 200..<300)
            .serializingDecodable(SearchLocationResponse.self)
            .value
        return response
    }
    
    static func fetchCurrentLoctionAsync(request: CurrentLocationRequest) async throws -> CurrentLocationResponse {
        let response = try await AF.request(LocationTarget.getCurrentLocation(request), interceptor: DefaultRequestInterceptor())
            .validate(statusCode: 200..<300)
            .serializingDecodable(CurrentLocationResponse.self)
            .value
        return response
    }
}
