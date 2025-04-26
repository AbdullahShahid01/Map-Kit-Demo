//
//  ViewController.swift
//  Map Kit Demo
//
//  Created by Abdullah-Shahid  on 25/04/2025.
//

import UIKit
import MapKit
import CoreLocation
import UserNotifications

class ViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: - Properties
    let locationManager = CLLocationManager()
    let regionCenter = CLLocationCoordinate2D(latitude: 33.597892, longitude: 73.021813)
    let regionRadius: CLLocationDistance = 100
    let regionIdentifier = "CustomGeofence"
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocationManager()
        setupMapView()
        requestNotificationAuthorization()
    }
    
    // MARK: - Setup Methods
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestAlwaysAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
    }
    
    private func setupMapView() {
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.showsScale = true
        mapView.showsCompass = true
        mapView.showsLargeContentViewer = true
        centerMapOnLocation()
        addGeofenceOverlay()
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
        
        let geofenceRegion = CLCircularRegion(
            center: regionCenter,
            radius: regionRadius,
            identifier: regionIdentifier
        )
        
        geofenceRegion.notifyOnEntry = true
        geofenceRegion.notifyOnExit = true
        
        locationManager.startMonitoring(for: geofenceRegion)
    }
    
    // MARK: - Map Helpers
    private func centerMapOnLocation() {
        let coordinateRegion = MKCoordinateRegion(
            center: regionCenter,
            latitudinalMeters: 500,
            longitudinalMeters: 500
        )
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    private func addGeofenceOverlay() {
        let circle = MKCircle(center: regionCenter, radius: regionRadius)
        mapView.addOverlay(circle)
    }
    
    @IBAction func buttonTapped(_ sender: Any) {
        sendNotification(title: "Hello!", body: "This is a test notification!")
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
extension ViewController: CLLocationManagerDelegate {
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
        if region.identifier == regionIdentifier {
            sendNotification(title: "Welcome!", body: "You've entered the geofence area")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region.identifier == regionIdentifier {
            sendNotification(title: "Goodbye!", body: "You've left the geofence area")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Monitoring failed for region: \(error.localizedDescription)")
    }
}

// MARK: - MKMapViewDelegate
extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let circleOverlay = overlay as? MKCircle {
            let renderer = MKCircleRenderer(circle: circleOverlay)
            renderer.fillColor = UIColor.blue.withAlphaComponent(0.2)
            renderer.strokeColor = UIColor.blue
            renderer.lineWidth = 1
            return renderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
}
