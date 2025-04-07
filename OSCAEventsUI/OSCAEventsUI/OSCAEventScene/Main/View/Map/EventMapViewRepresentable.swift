import SwiftUI
import MapKit

struct EventMapViewRepresentable: UIViewRepresentable {
    
    let region: MKCoordinateRegion
    var route: MKRoute?
    let locationAuthorized: Bool
    let eventCoordinate: CLLocationCoordinate2D?
    
    // Create the MKMapView using UIKit.
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.region = region
        if let polyline = route?.polyline {
            mapView.addOverlay(polyline)
        }
        mapView.showsUserLocation = locationAuthorized
        mapView.isUserInteractionEnabled = false
        if let eventCoordinate = eventCoordinate {
            let pin = MKPointAnnotation()
            pin.coordinate = eventCoordinate
            mapView.removeAnnotations(mapView.annotations)
            mapView.addAnnotation(pin)
        }
        return mapView
    }
    
    func updateUIView(_ view: MKMapView, context: Context) {
        //update route polyline
        if let polyline = route?.polyline {
            // in case update is triggered multiple times
            view.removeOverlays(view.overlays)
            view.addOverlay(polyline)
        }
    }
    
    func makeCoordinator() -> EventMapCoordinator {
        EventMapCoordinator(self)
    }
    
}

class EventMapCoordinator: NSObject, MKMapViewDelegate {
    var parent: EventMapViewRepresentable
    
    init(_ parent: EventMapViewRepresentable) {
        self.parent = parent
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let routePolyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: routePolyline)
            renderer.strokeColor = UIColor.systemBlue
            renderer.lineWidth = 5
            return renderer
        }
        return MKOverlayRenderer()
    }
    
}
