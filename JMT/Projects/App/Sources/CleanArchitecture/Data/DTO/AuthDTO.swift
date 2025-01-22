//
//  AuthResponse.swift
//  JMTeng
//
//  Created by PKW on 1/21/25.
//

import Foundation

// 1번
struct AuthDTO: Codable {
    let data: AuthData
    let message: String
    let code: String
}

struct AuthData: Codable {
    let grantType: String
    let accessToken: String
    let refreshToken: String
    let accessTokenExpiresIn: Int
    let userLoginAction: String
}

extension AuthDTO {
    func toDomain() -> AuthVO {
        return AuthVO(accessToken: data.accessToken,
                      refreshToken: data.refreshToken,
                      userLoginAction: data.userLoginAction,
                      accessTokenExpiresIn: data.accessTokenExpiresIn)
    }
}
