import SwiftUI
import OSCAEssentials
import CoreLocation
import OSCAEvents

struct EventListItemView: View {
    var event: OSCAEvent
    var location: CLLocation?
    var isBookmarked: Bool
    var onClick: () -> ()
    var onBookmark: () -> ()
    
    var body: some View {
        Button(action: onClick) {
            ZStack {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        AsyncCachedImage(url: URL(string: event.image ?? "")) { image in
                            image.resizable().frame(maxWidth: 100, maxHeight: 100).clipShape(RoundedRectangle(cornerRadius: 10)).rotationEffect(Angle(degrees: 45)).offset(x: 15, y: 45)
                        } placeholder: {
                            Image("MenschSolingen_Button", bundle: OSCAEventsUI.bundle).resizable().frame(maxWidth: 100, maxHeight: 100).clipShape(RoundedRectangle(cornerRadius: 10)).rotationEffect(Angle(degrees: 45)).offset(x: 15, y: 45)
                        }
                    }
                }
                VStack(spacing: 5) {
                    HStack {
                        if #available(iOS 16.0, *) {
                            Text(event.name ?? "").lineLimit(2, reservesSpace: true).truncationMode(.tail).foregroundColor(Color.black).font(.system(size: 14, weight: .bold)).multilineTextAlignment(.leading)
                        } else {
                            Text(event.name ?? "").truncationMode(.tail).foregroundColor(Color.black).font(.system(size: 14, weight: .bold)).multilineTextAlignment(.leading)
                        }
                        Spacer()
                        VStack {
                            Button(action: onBookmark) {
                                Image(favoriteIconName(isBookmarked: isBookmarked), bundle: OSCAEventsUI.bundle).resizable().tint(Color("primaryColor", bundle: OSCAEventsUI.bundle)).frame(maxWidth: 25, maxHeight: 25)
                            }
                            Spacer()
                        }
                    }
                    HStack {
                        VStack {
                            HStack {
                                Text(formattedDateString(date: event.startDate?.dateISO8601)).foregroundColor(Color("primaryColor", bundle: OSCAEventsUI.bundle))
                                Text("|").foregroundColor(Color.black)
                                Text(formattedTimeString(date: event.startDate?.dateISO8601)).foregroundColor(Color("primaryColor", bundle: OSCAEventsUI.bundle))
                                Spacer()
                            }.font(.system(size: 14, weight: .regular))
                            Spacer()
                            if let location = location, let geopoint = event.location?.geopoint {
                                HStack {
                                    Image("location-arrow-light-svg", bundle: OSCAEventsUI.bundle).resizable().scaleEffect(x: -1, y: 1).tint(Color.black).frame(maxWidth: 15, maxHeight: 15)
                                    Text(verbatim: "\(calculateDistance(location: location, geopoint: geopoint)) km").foregroundColor(Color("primaryColor", bundle: OSCAEventsUI.bundle)).font(.system(size: 14, weight: .regular))
                                    Spacer()
                                }
                            }
                        }
                        Spacer()
                    }
                }
            }.frame(maxWidth: .infinity).padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
        }.clipShape(RoundedRectangle(cornerRadius: 10)).background(RoundedRectangle(cornerRadius: 10).shadow(radius: 5).foregroundColor(Color.white))
    }
    
    func calculateDistance(location: CLLocation, geopoint: ParseGeoPoint) -> String {
        var distanceString = "?"
        if let latitude = geopoint.latitude, let longitude = geopoint.longitude {
            let distance = CLLocation(latitude: latitude, longitude: longitude).distance(from: location) / 1000
            distanceString = String(format: "%.1f", distance)
        }
        
        return distanceString
    }
}
