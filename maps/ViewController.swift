import UIKit
import MapKit
import SnapKit
import CoreLocation
class ViewController: UIViewController {
    let mapView = MKMapView()
    let locationManager = CLLocationManager()
    var locationStory: [CLLocationCoordinate2D] = []
    var totalDistance: CLLocationDistance = 0.0
    let distanceAnnotation = MKPointAnnotation()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(mapView)
        mapView.showsUserLocation = true
        mapView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        let annotation = MKPointAnnotation()
        annotation.title = "Ala"
        annotation.subtitle = "Almaty"
        annotation.coordinate = CLLocationCoordinate2D(latitude: 43.2380, longitude: 76.8829)
        mapView.addAnnotation(annotation)
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        mapView.delegate = self
        locationManager.startUpdatingLocation()
        distanceAnnotation.title = "Пройдено"
        mapView.addAnnotation(distanceAnnotation)
    }
}
extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let locationC = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        locationStory.append(locationC)
        mapView.zoomTo(locationC)
        drowLocations()
        if locationStory.count >= 2 {
            let previousLocation = CLLocation(latitude: locationStory[locationStory.count - 2].latitude, longitude: locationStory[locationStory.count - 2].longitude)
            let currentLocation = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let distance = previousLocation.distance(from: currentLocation)
            totalDistance += distance
            distanceAnnotation.title = String(format: "Пройдено %.2f метров", totalDistance)
            distanceAnnotation.coordinate = locationC
        }
    }
    func drowLocations() {
        let line = MKPolygon(coordinates: locationStory, count: locationStory.count)
        mapView.addOverlay(line)
    }
}
extension MKMapView {
    func zoomTo(_ location: CLLocationCoordinate2D) {
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: location, span: span)
        self.setRegion(region, animated: true)
    }
}
extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let polyLineRenderer = MKPolylineRenderer(overlay: overlay)
        polyLineRenderer.strokeColor = .systemRed
        polyLineRenderer.lineWidth = 10
        return polyLineRenderer
    }
}
