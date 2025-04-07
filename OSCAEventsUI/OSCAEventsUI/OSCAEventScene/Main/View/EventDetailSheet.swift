import SwiftUI
import OSCAEvents
import CoreLocation

struct EventDetailSheet: View {
    var event: OSCAEvent
    @State var isBookmarked: Bool
    var userLocation: CLLocation?
    var locationAuthorized: Bool
    var toggleBookmark: (String?) -> ()
    var addToCalendar: (OSCAEvent) -> ()
    @State var isRouteDialogPresented = false
    @State var isShareSheetPresented = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                ZStack {
                    VStack {
                        AsyncCachedImage(url: URL(string: event.image ?? ""), content: { view in
                            view.resizable().scaledToFill().frame(maxWidth: .infinity, maxHeight: 300).clipped()
                        }, placeholder: {
                            Image("event-default", bundle: OSCAEventsUI.bundle).resizable().scaledToFill().frame(maxWidth: .infinity, maxHeight: 300).clipped()
                        })
                        Spacer().frame(height: 100)
                    }
                    VStack {
                        Spacer()
                        EventMapView(userLocation: userLocation, eventLocation: event.location?.geopoint, locationAuthorized: locationAuthorized).frame(maxWidth: .infinity, maxHeight: 200).clipShape(RoundedRectangle(cornerRadius: 10)).padding(.horizontal, 30)
                    }
                }
                Text(verbatim: event.name ?? "").multilineTextAlignment(.leading).padding(.horizontal, 15).font(.system(size: 22, weight: .bold))
                HStack {
                    Image("clock-light-svg", bundle: OSCAEventsUI.bundle).resizable().tint(Color("primaryColor", bundle: OSCAEventsUI.bundle)).frame(maxWidth: 15, maxHeight: 15)
                    Text(formattedDateString(date: event.startDate?.dateISO8601)).foregroundColor(Color.black)
                    Text("|").foregroundColor(Color("primaryColor", bundle: OSCAEventsUI.bundle))
                    Text(formattedTimeString(date: event.startDate?.dateISO8601)).foregroundColor(Color.black)
                    Spacer()
                }.font(.system(size: 14)).padding(.horizontal, 15)
                Spacer().frame(maxWidth: .infinity, maxHeight: 2).background(Color("primaryColor", bundle: OSCAEventsUI.bundle))
                HStack(spacing: 40) {
                    Spacer()
                    Button(action: {
                        toggleBookmark(event.objectId)
                        isBookmarked.toggle()
                    }) {
                        VStack {
                            Image(favoriteIconName(isBookmarked: isBookmarked), bundle: OSCAEventsUI.bundle).resizable().tint(Color("primaryColor", bundle: OSCAEventsUI.bundle)).frame(maxWidth: 25, maxHeight: 25)
                            Text("events_bookmark_title", bundle: OSCAEventsUI.bundle).foregroundColor(Color.black)
                        }
                    }
                    Button(action: { isShareSheetPresented = true }) {
                        VStack {
                            // offset because icon looks weirdly aligned
                            Image(systemName: "square.and.arrow.up").resizable().tint(Color("primaryColor", bundle: OSCAEventsUI.bundle)).frame(maxWidth: 20, maxHeight: 25).offset(x:0 , y: -3)
                            Text("events_share_title", bundle: OSCAEventsUI.bundle).foregroundColor(Color.black)
                        }
                    }
                    Button(action: { addToCalendar(event) }) {
                        VStack {
                            Image(systemName: "calendar.badge.plus").resizable().tint(Color("primaryColor", bundle: OSCAEventsUI.bundle)).frame(maxWidth: 30, maxHeight: 25)
                            Text("events_calendar_title", bundle: OSCAEventsUI.bundle).foregroundColor(Color.black)
                        }
                    }
                    Spacer()
                }
                Spacer().frame(maxWidth: .infinity, maxHeight: 2).background(Color("primaryColor", bundle: OSCAEventsUI.bundle))
                VStack(alignment: .leading, spacing: 20) {
                    if let category = event.category {
                        Text(verbatim: category).foregroundColor(Color.gray)
                    }
                    if let htmlString = event.description {
                        HtmlView(html: htmlString)
                    }
                    if let url = URL(string: event.url ?? "") {
                        HStack {
                            Text("events_website_title", bundle: OSCAEventsUI.bundle).foregroundColor(Color.black).font(.system(size: 12))
                            Link(destination: url) {
                                Text(verbatim: event.url ?? "").font(.system(size: 12))
                            }
                        }
                    }
                    Button(action: { isRouteDialogPresented = true }) {
                        Text("events_route_title", bundle: OSCAEventsUI.bundle).foregroundColor(Color(UIColor.systemBlue)).padding(.vertical, 10).frame(maxWidth: .infinity).background(RoundedRectangle(cornerRadius: 10).strokeBorder(Color(UIColor.systemBlue)))
                    }.confirmationDialog("", isPresented: $isRouteDialogPresented) {
                        Button(action: { openAppleMaps() }) {
                            Text("events_apple_maps", bundle: OSCAEventsUI.bundle)
                        }
                        Button(action: { openGoogleMaps() }) {
                            Text("events_google_maps", bundle: OSCAEventsUI.bundle)
                        }
                    }.labelsHidden()
                }.padding(.horizontal, 15)
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
        }.sheet(isPresented: $isShareSheetPresented, onDismiss: { isShareSheetPresented = false }) {
            if #available(iOS 17.0, *) {
                ShareSheet(items: [event.url ?? ""]).presentationDetents([.medium])
            } else {
                ShareSheet(items: [event.url ?? ""])
            }
        }
        
    }
    func openAppleMaps() {
        if let eventLat = event.location?.geopoint?.latitude, let eventLon = event.location?.geopoint?.longitude {
            if let url = URL(string: "http://maps.apple.com/?daddr=\(eventLat),\(eventLon)&dirflg=w") {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                }
            }
        }
        isRouteDialogPresented = false
    }
    
    func openGoogleMaps() {
        if let eventLat = event.location?.geopoint?.latitude, let eventLon = event.location?.geopoint?.longitude {
            if let url = URL(string: "https://www.google.com/maps/dir/?api=1&destination=\(eventLat),\(eventLon)&travelmode=walking") {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                }
            }
        }
        isRouteDialogPresented = false
    }
}

// TODO: replace with ShareLink with iOS 16
struct ShareSheet: UIViewControllerRepresentable {
    var items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // Forced implementation
    }
}
