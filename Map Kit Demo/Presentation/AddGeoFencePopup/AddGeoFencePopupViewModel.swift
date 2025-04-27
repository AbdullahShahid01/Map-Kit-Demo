//
//  AddGeoFencePopupViewModel.swift
//  Map Kit Demo
//
//  Created by Abdullah-Shahid  on 27/04/2025.
//

import Foundation

final class AddGeoFencePopupViewModel {
    
    enum Input {
        case viewDidLoad
        case saveButtonTapped
    }
    
    enum Output {
        case configureUI
    }
    
    var output: ((Output)->())?
    
    var nameLabelValue: String {
        return name
    }
    
    var longitudeLabelValue: String {
        return "Longitude: \(longitude)"
    }
    
    var latitudeLabelValue: String {
        return "Latitude: \(latitude)"
    }
    
    private let name: String
    private let latitude: Double
    private let longitude: Double
    var userNote: String?
    var radius: Double?
    
    private let geofenceRepository = DefaultGeoFenceRepository()
    
    init(name: String, longitude: Double, latitude: Double) {
        self.name = name
        self.longitude = longitude
        self.latitude = latitude
    }
    
    func input(_ input: Input) {
        switch input {
        case .viewDidLoad:
            output?(.configureUI)
        case .saveButtonTapped:
            _ = geofenceRepository.create(geoFence: Geofence(identifier: UUID(), name: name, centerLatitude: latitude, centerLongitude: longitude, radius: radius ?? 100, userNote: userNote ?? ""))
        }
    }
}
