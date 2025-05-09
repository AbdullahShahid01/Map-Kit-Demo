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
import Anchorage

class MainViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var activityIndicatorView: UIView!
    
    private let viewModel = MainViewModel()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        configureBindings()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureBindings()
    }
    
    private func configureBindings() {
        viewModel.output = { [weak self] output in
            guard let strongSelf = self else { return }
            switch output {
            case .configureUI:
                strongSelf.configureUI()
            case .addCustomMarkers(let places):
                strongSelf.addCustomMarkers(places)
            case .showLoader:
                strongSelf.activityIndicatorView.isHidden = false
            case .hideLoader:
                strongSelf.activityIndicatorView.isHidden = true
            case .showSettingsPopup:
                strongSelf.showSettingsPopup()
            case .showLocationPermissionAlert:
                strongSelf.showLocationPermissionAlert()
            case .showAlert(let message):
                strongSelf.showAlert(message: message)
            }
        }
    }
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.input(.viewDidLoad)
    }
    
    private func configureUI() {
        configureSearchBar()
        configureMap()
        configureSeeGeoFencesButton()
    }
    
    private func configureSearchBar() {
        searchBar.delegate = self
        searchBar.showsCancelButton = true
        searchBar.placeholder = "Search..."
    }
    
    private func configureMap() {
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.showsScale = true
        mapView.showsCompass = true
        mapView.showsLargeContentViewer = true
        //mapView.setVisibleMapRect()
        centerMapOnLocation()
        addGeofenceOverlay()
    }
    
    private func configureSeeGeoFencesButton() {
        let button = UIButton(type: .system)
        button.backgroundColor = .systemBlue
        button.setTitle("See Saved Geo Fences", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.configuration = .borderedProminent()
        button.layer.cornerRadius = 4
        button.addTarget(self, action: #selector(seeSavedGeoFencesTapped), for: .touchUpInside)
        view.addSubview(button)
        button.bottomAnchor == view.safeAreaLayoutGuide.bottomAnchor + 8
        button.centerXAnchor == view.centerXAnchor
    }
    
    @objc
    private func seeSavedGeoFencesTapped() {
        let vc = GeoFenceListViewController()
        present(vc, animated: true)
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
    
    private func addCustomMarkers(_ places: [Place]) {
        mapView.removeAnnotations(mapView.annotations)
        places.forEach { place in
            let coordinate = CLLocationCoordinate2D(
                latitude: Double(place.lat) ?? 0,
                longitude: Double(place.lon) ?? 0
            )
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = place.displayName
            mapView.addAnnotation(annotation)
        }
        if let lat = places.first?.lat,
           let long = places.first?.lon,
           let latitude = Double(lat),
           let longitude = Double(long)
        {
            mapView.setCenter( CLLocationCoordinate2D(latitude: latitude, longitude: longitude), animated: true)
        }
        
    }
    
    private func getViewbox(/*from mapView: MKMapView*/) -> String {
        let region = mapView.region
        let center = region.center
        let span = region.span // Defines the "zoom level" (latitudeDelta/longitudeDelta)
        
        // Calculate the four corners of the visible region
        let minLat = center.latitude - span.latitudeDelta / 2
        let maxLat = center.latitude + span.latitudeDelta / 2
        let minLon = center.longitude - span.longitudeDelta / 2
        let maxLon = center.longitude + span.longitudeDelta / 2
        
        // Format: "minLon,minLat,maxLon,maxLat"
        return String(format: "%.6f,%.6f,%.6f,%.6f", minLon, minLat, maxLon, maxLat)
    }
    
    private func showAddGeoFencePopup(name: String, longitude: Double, latitude: Double) {
        let vc = AddGeoFencePopup(
            viewModel: AddGeoFencePopupViewModel(
                name: name,
                longitude: longitude,
                latitude: latitude
            )
        )
        self.present(vc, animated: true)
    }
    
    private func showSettingsPopup() {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            let alert = UIAlertController(title: "Permission Required", message: "Need notifications permission to get notified when you enter or leave a geo fence", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { action in
                if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                }
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            strongSelf.present(alert, animated: true)
        }
    }
    
    private func showLocationPermissionAlert() {
        let alert = UIAlertController(
            title: "Location Permission Required",
            message: "Please enable location access in Settings to use this feature.",
            preferredStyle: .alert
        )
        
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(settingsAction)
        alert.addAction(cancelAction)
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .cancel))
        present(alert, animated: true)
    }
}

// MARK: - MKMapViewDelegate
extension MainViewController: MKMapViewDelegate {
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
    
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        // Skip if it's the user's location annotation
//        guard !(annotation is MKUserLocation) else {
//            return nil
//        }
//        
//        let identifier = "CustomMarker"
//        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
//        
//        if annotationView == nil {
//            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
//            annotationView?.canShowCallout = true // Enable callout
//        } else {
//            annotationView?.annotation = annotation
//        }
//        
//        // Set custom image (replace "custom_pin" with your image name)
////        annotationView?.image = UIImage(named: "custom_pin")
//        
//        return annotationView
//    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        showAddGeoFencePopup(
            name: (view.annotation?.title ?? "") ?? "",
            longitude: view.annotation?.coordinate.longitude ?? 0,
            latitude: view.annotation?.coordinate.latitude ?? 0)
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        print("Deselected annotation: \(view.annotation!)")
    }
    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        let region: MKCoordinateRegion = mapView.region
        print(">>> region.center.latitude: \(region.center.latitude)")
        print(">>> region.center.longitude: \(region.center.longitude)")
        print(">>> region.span.latitudeDelta: \(region.span.latitudeDelta)")
        print(">>> region.span.longitudeDelta: \(region.span.longitudeDelta)")
        print(">>> ")
        viewModel.viewBox = getViewbox()
    }
}

extension MainViewController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        true
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        true
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
    }

    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        true
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        viewModel.searchBarText = searchBar.text ?? ""
        viewModel.input(.searchButtonTapped)
        searchBar.resignFirstResponder()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        
    }
    
    func searchBarResultsListButtonClicked(_ searchBar: UISearchBar) {
        
    }

    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        
    }
}
