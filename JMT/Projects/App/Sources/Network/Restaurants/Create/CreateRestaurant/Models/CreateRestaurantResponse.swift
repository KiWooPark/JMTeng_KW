//
//  RegistrationRestaurantResponse.swift
//  JMTeng
//
//  Created by PKW on 3/9/24.
//

import Foundation

struct CreateRestaurantResponse: Decodable {
    let data: RestaurantLocationData
    let message: String
    let code: String
}

struct RestaurantLocationData: Decodable {
    let restaurantLocationId: Int
    let recommendRestaurantId: Int
}
