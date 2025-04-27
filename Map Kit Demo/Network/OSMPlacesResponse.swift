//
//  OSMPlacesResponse.swift
//  Map Kit Demo
//
//  Created by Abdullah-Shahid  on 26/04/2025.
//

import Foundation

struct Place: Codable {
    let placeID: Int
    let displayName: String
    let lat: String
    let lon: String
    
    private enum CodingKeys: String, CodingKey {
        case placeID = "place_id"
        case displayName = "display_name"
        case lat
        case lon
    }
}
