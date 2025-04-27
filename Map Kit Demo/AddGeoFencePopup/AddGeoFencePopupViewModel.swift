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
    }
    
    enum Output {
        case configureUI
    }
    
    var output: ((Output)->())?
    
    var nameLabelValue = "Name Label"
    var longitudeLabelValue = "longitude Label"
    var latitudeLabelValue = "latitude Value"
    
    func input(_ input: Input) {
        switch input {
        case .viewDidLoad:
            output?(.configureUI)
        }
    }
}
