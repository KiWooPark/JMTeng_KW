//
//  KeychainService.swift
//  JMTeng
//
//  Created by PKW on 2024/01/19.
//

import Foundation
import SwiftKeychainWrapper

enum KeychainKey: String {
    case accessToken
    case refreshToken
    case accessTokenExpiresIn
   
    case tempAccessToken
    case tempRefreshToken
    case tempAccessTokenExpiresIn
    
    case idToken
    case isIdTokenSaved  
}

class DefaultKeychainService {
    static let shared = DefaultKeychainService()
    private let keychain = KeychainWrapper.standard
    private init() { }
    
    func getValue<T>(for key: KeychainKey, type: T.Type) -> T? {
        switch type {
        case is String.Type:
            return keychain.string(forKey: key.rawValue) as? T
        case is Int.Type:
            return keychain.integer(forKey: key.rawValue) as? T
        case is Bool.Type:
            return keychain.bool(forKey: key.rawValue) as? T
        default:
            return nil
        }
    }
    
    func setValue<T>(_ value: T?, for key: KeychainKey) {
        if let value = value as? String {
            keychain.set(value, forKey: key.rawValue)
        } else if let value = value as? Int {
            keychain.set(value, forKey: key.rawValue)
        } else if let value = value as? Bool {
            keychain.set(value, forKey: key.rawValue)
        } else if value == nil {
            keychain.removeObject(forKey: key.rawValue)
        }
    }
    
    func removeKeychain(_ key: KeychainKey) {
        keychain.removeObject(forKey: key.rawValue)
    }
    
    func removeAllKeychain() {
        keychain.removeAllKeys()
    }
}

