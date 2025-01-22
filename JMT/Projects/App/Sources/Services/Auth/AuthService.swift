////
////  LoginServiceType.swift
////  JMTeng
////
////  Created by PKW on 1/21/25.
////
//
//import AuthenticationServices
//import Foundation
//import GoogleSignIn
//
//protocol AuthServiceType {
//    func signInWithGoogle(completion: @escaping (Result<String, Error>) -> Void)
//    func signInWithApple(completion: @escaping (Result<String, Error>) -> Void)
//}
//
//class Authservice: AuthServiceType {
//    private var authRepository: AuthRepository
//
//    init(authRepository: AuthRepository) {
//        self.authRepository = authRepository
//    }
//
//    func signInWithGoogle(completion: @escaping (Result<String, Error>) -> Void) {
//        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//              let window = windowScene.windows.first,
//              let rootViewController = window.rootViewController
//        else {
//            return
//        }
//
//        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { [weak self] signInResult, error in
//            guard let self = self else { return }
//
//            if let error = error {
//                completion(.failure(error))
//                return
//            }
//
//            guard let idToken = signInResult?.user.idToken?.tokenString else {
//                completion(.failure(NSError(domain: "AuthError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid ID Token"])))
//
//                return
//            }
//
//            authRepository.loginWithGoogle(idToken: idToken, completion: completion)
//        }
//    }
//
//    func signInWithApple(completion: @escaping (Result<String, Error>) -> Void) {
//        authRepository.loginWithApple(identityToken: "", completion: completion)
//    }
//}
