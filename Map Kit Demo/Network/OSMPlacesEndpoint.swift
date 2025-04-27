//
//  OSMPlacesEndpoint.swift
//  Map Kit Demo
//
//  Created by Abdullah-Shahid  on 26/04/2025.
//

import Alamofire

//https://nominatim.openstreetmap.org/search?q=masjid&format=json&viewbox=72.5,33.4,73.5,33.8&limit=50

//struct OSMPlacesEndpoint: APIEndpoint {
//    let query: String
//    let viewBox: [Float]
//    
//    typealias ResponseType = OSMPlacesResponse
//    
//    var baseURL: String = "https://nominatim.openstreetmap.org"
//    var path: String = "/search"
//    var method: Alamofire.HTTPMethod = .get
//    var headers: HTTPHeaders? = [
//        "User-Agent": "YourAppName/1.0 (contact@yourapp.com)"
//    ]
//    
//    var parameters: Parameters? {
//        return [
//            "q": query,
//            "format": "json",
//            "viewbox": viewBox.map { String($0) }.joined(separator: ","),
//            "limit": "50" // Optional: Cast to String
//        ]
//    }
//}

//struct OSMPlacesEndpoint: APIEndpoint {
//    let query: String
//    let viewBox: [Float]
//    
//    typealias ResponseType = OSMPlacesResponse
//    
//    var baseURL: String = "https://nominatim.openstreetmap.org"
//    
//    var headers: Alamofire.HTTPHeaders? = nil
//    
//    var path: String = "/search"
//    
//    var method: Alamofire.HTTPMethod = .get
//    
//    var parameters: Parameters? {
//        return [
//            "q": query,
//            "format": "json",
//            "viewbox": viewBox,
//            "limit": 50
//        ]
//    }
//}
