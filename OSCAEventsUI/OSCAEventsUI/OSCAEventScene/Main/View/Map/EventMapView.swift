import SwiftUI
import MapKit
import CoreLocation
import OSCAEssentials

struct EventMapView: View {
    var userLocation: CLLocation?
    var eventLocation: ParseGeoPoint?
    var locationAuthorized: Bool
    @State var nothingToShow = false
    @State var route: MKRoute? = nil
    
    var body: some View {
        var eventCoordinate: CLLocationCoordinate2D?
        if let eventLat = eventLocation?.latitude, let eventLon = eventLocation?.longitude {
            eventCoordinate = CLLocationCoordinate2D(latitude: eventLat, longitude: eventLon)
        }
        return ZStack {
            EventMapViewRepresentable(region: getRegion(), route: route, locationAuthorized: locationAuthorized, eventCoordinate: eventCoordinate).task {
                await getRoute()
            }
            
        }
    }
    
    func getRegion() -> MKCoordinateRegion {
        // Adds additional span so the markes are not directly in the corners
        let spanPadding = 1.5
        
        if let eventLat = eventLocation?.latitude, let eventLon = eventLocation?.longitude {
            if let userLat = userLocation?.coordinate.latitude, let userLon = userLocation?.coordinate.longitude {
                let minLat = eventLat < userLat ? eventLat : userLat
                let minLon = eventLon < userLon ? eventLon : userLon
                let maxLat = eventLat > userLat ? eventLat : userLat
                let maxLon = eventLon > userLon ? eventLon : userLon
                let latSpan = maxLat - minLat
                let lonSpan = maxLon - minLon
                let center = CLLocationCoordinate2D(latitude: minLat + latSpan / 2, longitude: minLon + lonSpan / 2)
                let span = MKCoordinateSpan(latitudeDelta: latSpan * spanPadding, longitudeDelta: lonSpan * spanPadding)
                
                return MKCoordinateRegion(center: center, span: span)
            } else {
                let center = CLLocationCoordinate2D(latitude: eventLat, longitude: eventLon)
                let span = MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003)
                
                return MKCoordinateRegion(center: center, span: span)
            }
        } else {
            if let userLat = userLocation?.coordinate.latitude, let userLon = userLocation?.coordinate.longitude {
                let center = CLLocationCoordinate2D(latitude: userLat, longitude: userLon)
                let span = MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003)
                
                return MKCoordinateRegion(center: center, span: span)
            } else {
                let center = CLLocationCoordinate2D(latitude: 51.177411, longitude: 7.085249)
                let span = MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003)
                nothingToShow = true
                
                return MKCoordinateRegion(center: center, span: span)
            }
        }
    }
    
    func getRoute() async {
        if let userLocation = userLocation, let eventLat = eventLocation?.latitude, let eventLon = eventLocation?.longitude {
            let eventCoordinate = CLLocationCoordinate2D(latitude: eventLat, longitude: eventLon)
            let request = MKDirections.Request()
            let routeSource = MKMapItem(placemark: MKPlacemark(coordinate: userLocation.coordinate))
            let routeDestination = MKMapItem(placemark: MKPlacemark(coordinate: eventCoordinate))
            request.source = routeSource
            request.destination = routeDestination
            request.transportType = .automobile
            let calculatedRoute = try? await MKDirections(request: request).calculate()
            
            route = calculatedRoute?.routes.first
        }
    }
}
