//
//  NicknameViewModel.swift
//  App
//
//  Created by PKW on 2023/12/22.
//

import Foundation

protocol NicknameModelProtocol {
    func didChangeTextField(text: String)
    func checkDuplicate(text: String)
    func saveNickname(text: String)
}

class NicknameViewModel: NicknameModelProtocol {
    
    enum UIUpdateState {
        case updateNextButtonAndAvailabilityLabelText(Bool, String)
    }
    
    weak var coordinator: DefaultNicknameCoordinator?
    var textFieldCheckWorkItem: DispatchWorkItem?
    
    var onSuccess: ((UIUpdateState) -> ())?
    
    func didChangeTextField(text: String) {
        
        textFieldCheckWorkItem?.cancel()
        
        let workItem = DispatchWorkItem {
            
            // 1. 빈 문자열 검사
            let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmedText.isEmpty {
                self.onSuccess?(.updateNextButtonAndAvailabilityLabelText(false, ""))
                return
            }
            
            // 2. 정규식 검증
            if !self.isValidNickname(text: text) {
                self.onSuccess?(.updateNextButtonAndAvailabilityLabelText(false, "사용할 수 없는 닉네임입니다."))
                return
            }
           
            // 3. 중복된 닉네임 검사
            self.checkDuplicate(text: text)
        }
        
        textFieldCheckWorkItem = workItem
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: workItem)
    }
    
    func checkDuplicate(text: String) {
        NicknameAPI.checkDuplicate(request: NicknameRequest(nickname: text)) { response in
            switch response {
            case .success(let code):
                switch code {
                case "NICKNAME_IS_DUPLICATED":
                    self.onSuccess?(.updateNextButtonAndAvailabilityLabelText(false, "이미 사용중인 닉네임 입니다."))
                case "NICKNAME_IS_AVAILABLE":
                    self.onSuccess?(.updateNextButtonAndAvailabilityLabelText(true, "사용가능한 닉네임 입니다."))
                default:
                    return
                }
            case .failure(let error):
                print("2", error)
            }
        }
    }
    
    func saveNickname(text: String) {
        NicknameAPI.saveNickname(request: NicknameRequest(nickname: text)) { response in
            switch response {
            case .success(_):
                self.coordinator?.showProfileViewController()
            case .failure(let error):
                print("2", error)
            }
        }
    }
    
    func isValidNickname(text: String) -> Bool {
        // 정규식 패턴 정의: 알파벳, 숫자, 밑줄, 대시 포함, 3~10자 길이
        let pattern = "^[A-Za-z0-9_-]{3,10}$"
        let regex = try! NSRegularExpression(pattern: pattern)
        let range = NSRange(location: 0, length: text.utf16.count)
        
        return regex.firstMatch(in: text, options: [], range: range) != nil
    }
}


