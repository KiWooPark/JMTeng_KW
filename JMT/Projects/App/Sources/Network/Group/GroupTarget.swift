//
//  GroupTarget.swift
//  JMTeng
//
//  Created by PKW on 2024/02/28.
//

import Alamofire
import Foundation

enum GroupTarget {
    case leaveGroup(MyGroupRequest)
}

extension GroupTarget: TargetType {
    var method: HTTPMethod {
        switch self {
        case .leaveGroup: return .delete
        }
    }
    
    var path: String {
        switch self {
        case .leaveGroup(let request): return "/group/\(request.groupId)"
        }
    }
    
    var parameters: RequestParams {
        switch self {
        case .leaveGroup(let request): return .qurey(request)
        }
    }
}
