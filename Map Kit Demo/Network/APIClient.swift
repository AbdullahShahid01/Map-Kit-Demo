//
//  APIClient.swift
//  Map Kit Demo
//
//  Created by Abdullah-Shahid  on 26/04/2025.
//

import Foundation
import Alamofire

var isConnectedToInternet:Bool {
    return NetworkReachabilityManager()?.isReachable ?? false
}

class APIClient: @unchecked Sendable {
    
    static let shared = APIClient() // Singleton instance for global use
    
    private init() {}
    
    /// Executes a network request
    /// - Parameters:
    ///   - endpoint: APIEndpoint conforming object
    ///   - completion: Result type with Decodable response or AFError
    
    func request<E: APIEndpoint>(
        endpoint: E,
        completion: @escaping @Sendable (Result<E.ResponseType, AFError>) -> Void
    ) {
        let request = AF.request(endpoint.url,
                                 method: endpoint.method,
                                 parameters: endpoint.parameters,
                                 encoding: endpoint.encoding,
                                 headers: endpoint.headers)
        request.validate()
        request.responseDecodable(of: E.ResponseType.self) { response in
            switch response.result {
            case .success(let value):
                completion(.success(value))
            case .failure(let error):
                completion(.failure(error))
            }
            
//            print("\n*_*_*_*_*_*_*_* Response Start *_*_*_*_*_*_*_*")
//            self.printJSON(response.data)
//            print("*_*_*_*_*_*_*_*_*_* Response End  *_*_*_*_*_*_*_*_*_*")
//            
//            request.cURLDescription { curl in
//                print("*_*_*_*_*_*_*_*_*_* Curl Start *_*_*_*_*_*_*_*_*_*")
//                print("\(curl)")
//                print("*_*_*_*_*_*_*_*_*_* Curl End *_*_*_*_*_*_*_*_*_*")
//            }
        }
        
        
    }
    
    private func printJSON(_ data: Data?) {
        if let data = data {
            do {
                let json = try JSONSerialization.jsonObject(with: data)
                if let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
                   let jsonString = String(data: jsonData, encoding: .utf8) {
                    print("Response JSON: \n\(jsonString)")
                }
            } catch {
                print("Failed to parse JSON: \(error.localizedDescription)")
            }
        }
    }
}
