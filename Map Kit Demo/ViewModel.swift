//
//  ViewModel.swift
//  Map Kit Demo
//
//  Created by Abdullah-Shahid  on 26/04/2025.
//

import Foundation
import CoreLocation
import UserNotifications

final class ViewModel: NSObject {
    
    enum Input {
        case viewDidLoad
    }
    
    enum Output {
        case configureUI
    }
    
    var output: ((Output)->())?
    
    var currentUserLocation: CLLocationCoordinate2D? {
        return locationManager.location?.coordinate
    }
    
    let locationManager = CLLocationManager()
    let geofences: [Geofence] = [
        Geofence(
            identifier: "CustomGeofence",
            name: "Afshan Colony, Rawalpindi",
            centerLatitude: 33.597892,
            centerLongitude: 73.021813,
            radius: 100
        ),
        Geofence(
            identifier: "CustomGeofence",
            name: "Mumbai",
            centerLatitude: 19.017175,
            centerLongitude: 72.856001,
            radius: 100
        )
    ]
    
    func input(_ input: Input) {
        switch input {
        case .viewDidLoad:
            output?(.configureUI)
            setupLocationManager()
            requestNotificationAuthorization()
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
        for (i, geofence) in geofences.enumerated() {
            let region = CLCircularRegion(
                center: CLLocationCoordinate2D(latitude: geofence.centerLatitude, longitude: geofence.centerLongitude),
                radius: geofence.radius,
                identifier: geofence.identifier + "\(i)"
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
}


// MARK: - CLLocationManagerDelegate
extension ViewModel: CLLocationManagerDelegate {
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
            if region.identifier == geofence.identifier + "\(i)" {
                sendNotification(title: "Welcome!", body: "You've entered \(geofence.name)")
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        for (i, geofence) in geofences.enumerated() {
            if region.identifier == geofence.identifier + "\(i)" {
                sendNotification(title: "Goodbye!", body: "You've left \(geofence.name)")
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Monitoring failed for region: \(error.localizedDescription)")
    }
}
