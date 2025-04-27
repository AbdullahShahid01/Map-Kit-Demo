//
//  ViewModel.swift
//  Map Kit Demo
//
//  Created by Abdullah-Shahid  on 26/04/2025.
//

import Foundation
import CoreLocation
import UserNotifications
import Alamofire

final class MainViewModel: NSObject {
    
    enum Input {
        case viewDidLoad
        case searchButtonTapped
    }
    
    enum Output {
        case configureUI
        case addCustomMarkers([Place])
        case showLoader
        case hideLoader
    }
    
    var output: ((Output)->())?
    
    var currentUserLocation: CLLocationCoordinate2D? {
        return locationManager.location?.coordinate
    }
    
    var searchBarText: String = ""
    var viewBox: String = "" {
        didSet {
            print("Viewbox: \(viewBox)")
        }
    }
    
    let locationManager = CLLocationManager()
    let geofences: [Geofence] = [
        Geofence(
            identifier: UUID(),
            name: "Afshan Colony, Rawalpindi",
            centerLatitude: 33.597892,
            centerLongitude: 73.021813,
            radius: 100,
            userNote: "Sample note"
        ),
        Geofence(
            identifier: UUID(),
            name: "Mumbai",
            centerLatitude: 19.017175,
            centerLongitude: 72.856001,
            radius: 100,
            userNote: "Example note here"
        )
    ]
    
    func input(_ input: Input) {
        switch input {
        case .viewDidLoad:
            output?(.configureUI)
            setupLocationManager()
            requestNotificationAuthorization()
            
        case .searchButtonTapped:
            output?(.showLoader)
            let text = searchBarText.trimmingCharacters(in: .whitespacesAndNewlines)
            if !text.isEmpty {
                fetchPlaces(searchQuery: text, viewBox: viewBox/*"72.5,33.4,73.5,33.8"*/) { [weak self] places in
                    guard let strongSelf = self else { return }
                    strongSelf.output?(.hideLoader)
                    if let places = places {
                        print(places.count)
                        strongSelf.output?(.addCustomMarkers(places))
                    }
                }
            }
        }
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestAlwaysAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
    }
    
    private func requestNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Error requesting notification permissions: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Region Monitoring
    private func startGeofenceMonitoring() {
        guard CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) else {
            print("Geofencing is not supported on this device!")
            return
        }
        for geofence in geofences {
            let region = CLCircularRegion(
                center: CLLocationCoordinate2D(latitude: geofence.centerLatitude, longitude: geofence.centerLongitude),
                radius: geofence.radius,
                identifier: geofence.identifier.uuidString
            )
            region.notifyOnEntry = true
            region.notifyOnExit = true
            
            locationManager.startMonitoring(for: region)
        }
    }
    
    // MARK: - Notification
    private func sendNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title + " \(Date())"
        content.body = body
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString + "\(Date().timeIntervalSince1970)",
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request)
    }

    ///
    /// Fetches places data for the `searchQuery`.
    /// `viewBox` is the minimum and maximum longitude and latitude passed as a comma separated string.
    /// Sequence => min Longitude, min Latitude, max Longitude, max Latitude
    ///
    private func fetchPlaces(searchQuery: String, viewBox: String, completion: @escaping ([Place]?) -> Void) {
        // API Endpoint
        let url = "https://nominatim.openstreetmap.org/search"
        
        // Parameters
        let parameters: [String: Any] = [
            "q": searchQuery,
            "format": "json",
            "viewbox": viewBox, // Format: minLon, minLat, maxLon, maxLat
            "limit": 50
        ]
        
        AF.request(
            url,
            method: .get,
            parameters: parameters,
            encoding: URLEncoding.default,
            headers: [:]
        )
        .validate()
        .responseDecodable(of: [Place].self) { response in
            switch response.result {
            case .success(let places):
                completion(places)
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }
}


// MARK: - CLLocationManagerDelegate
extension MainViewModel: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways:
            startGeofenceMonitoring()
        case .authorizedWhenInUse:
            print("Location authorized when in use - geofencing might not work in background")
        case .denied, .restricted:
            print("Location access denied")
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        for (i, geofence) in geofences.enumerated() {
            if region.identifier == geofence.identifier.uuidString {
                sendNotification(title: "Welcome!", body: "You've entered \(geofence.name)")
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        for (i, geofence) in geofences.enumerated() {
            if region.identifier == geofence.identifier.uuidString {
                sendNotification(title: "Goodbye!", body: "You've left \(geofence.name)")
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Monitoring failed for region: \(error.localizedDescription)")
    }
}
