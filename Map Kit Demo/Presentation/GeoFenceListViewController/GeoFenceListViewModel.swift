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
    
    private(set) var locations: [Geofence] = [
        Geofence(identifier: UUID(), name: "NAme", centerLatitude: 0, centerLongitude: 0, radius: 100, userNote: "Mote "),
        Geofence(identifier: UUID(), name: "NAme", centerLatitude: 0, centerLongitude: 0, radius: 100, userNote: "Mote "),
        Geofence(identifier: UUID(), name: "NAme", centerLatitude: 0, centerLongitude: 0, radius: 100, userNote: "Mote "),
        Geofence(identifier: UUID(), name: "NAme", centerLatitude: 0, centerLongitude: 0, radius: 100, userNote: "Mote dafds fa sdf adsf a sdfasd fasd fakjs f askdf akd fka dfk asdkf adks fak dfka dsfk adkf adkj fka sdk fakd fkjs dfja dskfj akjsdf")
    ]
    
    var tableViewRowCount: Int {
        return locations.count
    }
    
    func input(_ input: Input) {
        switch input {
        case .viewDidLoad:
            output?(.configureUI)
        case .backButtonTapped:
            output?(.dismissVC)
        }
    }
}
