//
//  APIEndpoint.swift
//  Map Kit Demo
//
//  Created by Abdullah-Shahid  on 26/04/2025.
//

import Foundation
import Alamofire

protocol APIEndpoint {
    associatedtype ResponseType: Codable
    var baseURL: String { get }
    var path: String { get }
    var method: Alamofire.HTTPMethod { get }
    var headers: HTTPHeaders? { get }
    var parameters: Parameters? { get }
    var encoding: ParameterEncoding { get }
    var cacheKey: String? { get }
    var cacheTime: Double? { get }
}

extension APIEndpoint {
    var url: String {
        return baseURL + path
    }
    
    var encoding: ParameterEncoding {
        return JSONEncoding.default
    }
    
    var cacheKey: String? {
        return nil
    }
    
    var cacheTime: Double? {
        return nil
    }
}
