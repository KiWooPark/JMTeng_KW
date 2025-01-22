//
//  SocialLoginTarget.swift
//  App
//
//  Created by PKW on 2024/01/02.
//

import Alamofire
import Foundation

enum SocialLoginTarget {
    case appleLogin(SocialLoginRequest)
    case googleLogin(SocialLoginRequest)
    case testLogin
    case logout(LogoutRequest)
    
    case googleLoginToken(token: String)
}

extension SocialLoginTarget: TargetType {
    var method: HTTPMethod {
        switch self {
        case .appleLogin: return .post
        case .googleLogin: return .post
        case .testLogin: return .post
        case .logout: return .delete
        case .googleLoginToken: return .post
        }
    }
    
    var path: String {
        switch self {
        case .appleLogin: return "/auth/apple"
        case .googleLogin: return "/auth/google"
        case .testLogin: return "/auth/test"
        case .logout: return "/auth/user"
        case .googleLoginToken: return "/auth/google"
        }
    }
    
    var parameters: RequestParams {
        switch self {
        case .appleLogin(let request): return .body(request)
        case .googleLogin(let request): return .body(request)
        case .testLogin: return .qurey(nil)
        case .logout(let request): return .body(request)
        case .googleLoginToken(let token): return .body(["token": token])
        }
   
    }
}
