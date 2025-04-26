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
    
    private let viewModel = ViewModel()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        configureBindings()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureBindings()
    }
    
    func configureBindings() {
        viewModel.output = { [weak self] output in
            guard let strongSelf = self else { return }
            switch output {
            case .configureUI:
                strongSelf.configureUI()
            }
        }
    }
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.input(.viewDidLoad)
    }
    
    private func configureUI() {
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.showsScale = true
        mapView.showsCompass = true
        mapView.showsLargeContentViewer = true
        centerMapOnLocation()
        addGeofenceOverlay()
    }
    
    ///
    /// Sets map view region to user's location
    ///
    private func centerMapOnLocation() {
        let coordinateRegion = MKCoordinateRegion(
            center: viewModel.currentUserLocation ?? .init(latitude: 33.6975317, longitude: 73.0500902),
            latitudinalMeters: 500,
            longitudinalMeters: 500
        )
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    ///
    /// Adds circles on geo fences regions on map
    ///
    private func addGeofenceOverlay() {
        viewModel.geofences.forEach { geofence in
            let circle = MKCircle(center: CLLocationCoordinate2D(latitude: geofence.centerLatitude, longitude: geofence.centerLongitude), radius: geofence.radius)
            mapView.addOverlay(circle)
        }
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
