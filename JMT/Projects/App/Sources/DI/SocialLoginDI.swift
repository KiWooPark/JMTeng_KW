//
//  SocialLoginDI.swift
//  App
//
//  Created by PKW on 2023/12/22.
//

import Swinject
import SwinjectStoryboard

struct SocialLoginDI: Assembly {
    func assemble(container: Swinject.Container) {
        // 클린아키텍처 의존성 주입
        
        // 데이터 소스 레지스트리 등록
        container.register(AuthDataSource.self) { _ in
            DefaultAuthDataSource()
        }
        
        // 레파지토리 레지스트리 등록
        container.register(AuthRepository.self) { r in
            let datasource = r.resolve(AuthDataSource.self)!
            return DefaultAuthRepository(dataSource: datasource)
        }
        
        // 유스케이스 레지스트리 등록
        container.register(AuthUseCase.self) { r in
            let repository = r.resolve(AuthRepository.self)!
            return DefaultAuthUseCase(repository: repository)
        }
        
        // 뷰 모델 레지스트리 등록
        container.register(SocialLoginViewModel.self) { r in
            let useCase = r.resolve(AuthUseCase.self)!
            return SocialLoginViewModel(authUserCase: useCase)
        }
        
        container.storyboardInitCompleted(SocialLoginViewController.self) { r, c in
            let viewModel = r.resolve(SocialLoginViewModel.self)!
            c.viewModel = viewModel
        }
        
    }
}
