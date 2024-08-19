//
//  TripDetailViewController.swift
//  TripEase
//
//  Created by Naitik Ratilal Patel on 16/08/24.
//

import UIKit
import MapKit

class TripDetailViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var containerStack: UIStackView!
    @IBOutlet weak var weatherDataView: UIView!
    @IBOutlet weak var addExpenseButton: UIButton!
    @IBOutlet weak var swipeLabel: UILabel!
    @IBOutlet weak var tripNameLbl: UILabel!
    @IBOutlet weak var fromLbl: UILabel!
    @IBOutlet weak var toLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var destinationLbl: UILabel!
    @IBOutlet weak var degreeLbl: UILabel!
    @IBOutlet weak var humidityLbl: UILabel!
    @IBOutlet weak var windSpeedLbl: UILabel!
    @IBOutlet weak var weatherTypeLbl: UILabel!
    @IBOutlet weak var weatherTypeImg: UIImageView!
    @IBOutlet weak var mapView: MKMapView!
    
    var trip: Trip?
    var weatherManager = WeatherManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        configureData()
        addSwipeGesture()
        
        showLocationsAndDistance(place1: trip?.from ?? "", place2: trip?.to ?? "")
    }
    
    @IBAction func addExpenseDidTapped(_ sender: UIButton) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "AddExpenseViewController") as! AddExpenseViewController
        vc.trip = trip
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension TripDetailViewController {
    
    private func setupView() {
        self.title = "Trip Detail"
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationController?.navigationBar.tintColor = .black
        
        weatherManager.delegate = self
        weatherManager.fetchWeather(cityName: trip?.to ?? "")
        
        mapView.delegate = self
    }
    
    private func configureData() {
        tripNameLbl.text = trip?.title
        destinationLbl.text = trip?.to
        fromLbl.text = "From: \(trip?.from ?? "")"
        toLbl.text = "To: \(trip?.to ?? "")"
        dateLbl.text = "From \(trip?.startDateStr ?? "") to \(trip?.endDateStr ?? "")"
    }
    
    private func addSwipeGesture() {
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeUp.direction = .up
        swipeUp.delegate = self
        containerStack.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeDown.direction = .down
        swipeDown.delegate = self
        containerStack.addGestureRecognizer(swipeDown)
    }
    
    @objc
    func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        switch gesture.direction {
        case .up:
            swipeLabel.text = "Swipe Down"
            UIView.animate(withDuration: 0.5) { [self] in
                weatherDataView.alpha = 1.0
                addExpenseButton.alpha = 1.0
                weatherDataView.isHidden = false
                addExpenseButton.isHidden = false
            }
            
        case .down:
            swipeLabel.text = "Swipe Up"
            UIView.animate(withDuration: 0.5) { [self] in
                weatherDataView.alpha = 0
                addExpenseButton.alpha = 0
                weatherDataView.isHidden = true
                addExpenseButton.isHidden = true
            }
        default:
            break
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}


//MARK: - WeatherManagerDelegate
extension TripDetailViewController: WeatherManagerDelegate {
    
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {
        DispatchQueue.main.async { [self] in
            degreeLbl.text = weather.temperatureString
            humidityLbl.text = "\(weather.humidity)"
            windSpeedLbl.text = "\(weather.windSpeed)"
            weatherTypeImg.image = UIImage(systemName: weather.conditionName)
            weatherTypeLbl.text = weather.weather
        }
    }
    
    func didFailWithError(error: Error) {
        self.presentAlert(with: "Error", message: "Failed to fetch weather data at trip's destination.")
    }
}


//MARK: - Map Methods
extension TripDetailViewController: MKMapViewDelegate {
    
    func showLocationsAndDistance(place1: String, place2: String) {
        let group = DispatchGroup()
        var location1: MKPlacemark?
        var location2: MKPlacemark?
        
        group.enter()
        searchLocation(byName: place1) { placemark in
            location1 = placemark
            group.leave()
        }
        
        group.enter()
        searchLocation(byName: place2) { placemark in
            location2 = placemark
            group.leave()
        }
        
        group.notify(queue: .main) {
            guard let location1 = location1, let location2 = location2 else {
                print("One or both locations could not be found.")
                return
            }
            
            let distanceInMeters = location1.location?.distance(from: location2.location!) ?? 0.0
            let distanceInKilometers = distanceInMeters / 1000.0
            
            // when location distance is too far
            if distanceInKilometers > 1500.0 {
                self.showSingleLocation(location: location2)
            } else {
                self.showLocationsOnMap(location1: location1, location2: location2)
                self.calculateAndShowDistance(location1: location1, location2: location2)
                self.drawRoute(from: location1, to: location2)
            }
        }
    }
    
    func searchLocation(byName name: String, completion: @escaping (MKPlacemark?) -> Void) {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = name
        
        let localSearch = MKLocalSearch(request: searchRequest)
        localSearch.start { (response, error) in
            guard let response = response, let mapItem = response.mapItems.first else {
                print("Error searching for location: \(String(describing: error?.localizedDescription))")
                completion(nil)
                return
            }
            completion(mapItem.placemark)
        }
    }
    
    func showLocationsOnMap(location1: MKPlacemark, location2: MKPlacemark) {
        let annotation1 = MKPointAnnotation()
        annotation1.title = location1.name
        annotation1.coordinate = location1.coordinate
        
        let annotation2 = MKPointAnnotation()
        annotation2.title = location2.name
        annotation2.coordinate = location2.coordinate
        
        mapView.showAnnotations([annotation1, annotation2], animated: true)
        
        // Zoom the map to show both locations
        let region = MKCoordinateRegion(center: annotation1.coordinate,
                                        latitudinalMeters: 5000,
                                        longitudinalMeters: 5000)
        mapView.setRegion(region, animated: true)
    }
    
    func showSingleLocation(location: MKPlacemark) {
        let annotation = MKPointAnnotation()
        annotation.title = location.name
        annotation.coordinate = location.coordinate
        
        mapView.showAnnotations([annotation], animated: true)
        
        // Zoom the map to show the location
        let region = MKCoordinateRegion(center: annotation.coordinate,
                                        latitudinalMeters: 10000,
                                        longitudinalMeters: 10000)
        mapView.setRegion(region, animated: true)
    }
    
    func calculateAndShowDistance(location1: MKPlacemark, location2: MKPlacemark) {
        let distanceInMeters = location1.location?.distance(from: location2.location!) ?? 0.0
        let distanceInKilometers = distanceInMeters / 1000.0
        print("Distance between \(location1.name ?? "") and \(location2.name ?? ""): \(distanceInKilometers) km")
    }
    
    func drawRoute(from sourcePlacemark: MKPlacemark, to destinationPlacemark: MKPlacemark) {
        let sourceItem = MKMapItem(placemark: sourcePlacemark)
        let destinationItem = MKMapItem(placemark: destinationPlacemark)
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = sourceItem
        directionRequest.destination = destinationItem
        directionRequest.transportType = .automobile
        
        let directions = MKDirections(request: directionRequest)
        directions.calculate { response, error in
            guard let response = response, let route = response.routes.first else {
                print("Error calculating directions: \(String(describing: error?.localizedDescription))")
                return
            }
            
            self.mapView.addOverlay(route.polyline, level: .aboveRoads)
            self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50), animated: true)
        }
    }
    
    // MARK: - MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = UIColor.mapRoute
            renderer.lineWidth = 4.0
            return renderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
}
