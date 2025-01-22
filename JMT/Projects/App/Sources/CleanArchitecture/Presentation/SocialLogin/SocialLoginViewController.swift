//
//  SocialLocinViewController.swift
//  App
//
//  Created by PKW on 2023/12/19.
//

import AuthenticationServices
import UIKit
import GoogleSignIn

class SocialLoginViewController: UIViewController {
    
    deinit {
        print("SocialLoginViewController Deinit")
    }
    
    @IBOutlet weak var appleLoginView: UIView!
    @IBOutlet weak var googleLoginView: UIView!
    
    var viewModel: SocialLoginViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    func setupUI() {
        appleLoginView.layer.cornerRadius = 10
        googleLoginView.layer.cornerRadius = 10
        
        googleLoginView.layer.borderColor = JMTengAsset.gray100.color.cgColor
        googleLoginView.layer.borderWidth = 1.5
    }
    
    @IBAction func didTabGoogleLoginButton(_ sender: Any) {
        guard viewModel?.isEnabled == true else { return }
        
//        viewModel?.startGoogleLogin()
        guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else { return }
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { [weak self] result, error in
            guard let self = self else { return }
            
            if let error = error {
                print(error)
                return
            }
            
            guard let idToken = result?.user.idToken?.tokenString else {
                print(error)
                return
            }
            
            viewModel?.startGooleLoginTest(idToken: idToken, completion: { result in
                switch result {
                case .success(let data):
                    print("ussCase", data)
                case .failure(let error):
                    print(error)
                }
            })
        }
    }
    
    @IBAction func didTabAppleLoginButton(_ sender: Any) {
        guard viewModel?.isEnabled == true else { return }
        
        viewModel?.startAppleLogin()
    }
}
