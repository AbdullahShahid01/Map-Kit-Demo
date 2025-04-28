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
        case showSettingsPopup
        case showLocationPermissionAlert
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
    
    var geofences: [GeoFence] {
        return geoFenceRepository.getAll() ?? []
    }
    
    private let geoFenceRepository = DefaultGeoFenceRepository()
    
    func input(_ input: Input) {
        switch input {
        case .viewDidLoad:
            output?(.configureUI)
            setupLocationManager()
            requestNotificationAuthorization()
            checkLocationAuthorization()
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
    
    private func checkLocationAuthorization() {
        let status = locationManager.authorizationStatus
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            // Location access granted; proceed with location-related tasks
            break
        case .denied, .restricted:
            // Location access denied; show alert
            output?(.showLocationPermissionAlert)
        case .notDetermined:
            // Request location permission
            locationManager.requestWhenInUseAuthorization()
        @unknown default:
            break
        }
    }
    
    private func requestNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { [weak self] granted, error in
            guard let strongSelf = self else { return }
            if !granted {
                strongSelf.output?(.showSettingsPopup)
            }
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
                identifier: geofence.identifier?.uuidString ?? ""
            )
            region.notifyOnEntry = true
            region.notifyOnExit = true
            
            locationManager.startMonitoring(for: region)
        }
    }
    
    // MARK: - Notification
    private func sendNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
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
            "bounded": 1, // Restrict results to the viewbox
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
            output?(.showLocationPermissionAlert)
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        for geofence in geofences {
            if region.identifier == geofence.identifier?.uuidString {
                sendNotification(title: "Welcome!", body: "You've entered \(geofence.name ?? "")")
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        for geofence in geofences {
            if region.identifier == geofence.identifier?.uuidString {
                sendNotification(title: "Goodbye!", body: "You've left \(geofence.name ?? "")")
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Monitoring failed for region: \(error.localizedDescription)")
    }
}
