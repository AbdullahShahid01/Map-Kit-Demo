//
//  GeoFenceListViewModel.swift
//  Map Kit Demo
//
//  Created by Abdullah-Shahid  on 28/04/2025.
//

import Foundation

final class GeoFenceListViewModel {
    
    enum Input {
        case viewDidLoad
        case backButtonTapped
    }
    
    enum Output {
        case configureUI
        case dismissVC
    }
    
    var output: ((Output)->())?
    
    var locations: [GeoFence] {
        return geoFenceRepository.getAll() ?? []
    }
    
    var tableViewRowCount: Int {
        return locations.count
    }
    
    private let geoFenceRepository = DefaultGeoFenceRepository()
    
    func input(_ input: Input) {
        switch input {
        case .viewDidLoad:
            output?(.configureUI)
        case .backButtonTapped:
            output?(.dismissVC)
        }
    }
}
