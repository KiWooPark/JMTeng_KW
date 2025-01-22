//
//  SocialLoginEntity.swift
//  JMTeng
//
//  Created by PKW on 1/21/25.
//

import Foundation

// 앱에서 사용할 가공된 최종 데이터
struct AuthVO: Decodable {
    let accessToken: String
    let refreshToken: String
    let userLoginAction: String
    let accessTokenExpiresIn: Int
}
