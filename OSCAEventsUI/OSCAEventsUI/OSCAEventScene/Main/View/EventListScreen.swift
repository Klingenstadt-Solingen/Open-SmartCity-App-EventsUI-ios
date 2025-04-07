import SwiftUI
import OSCAEvents
import CoreLocation
import EventKit

struct EventListScreen: View {
    @ObservedObject var viewModel: OSCAEventMainViewModel
    @State var dateDialoguePresented = false
    @State var selectedInDatePicker = Date.now
    var locationManager: CLLocationManager
    
    var body: some View {
        VStack {
            EventHeaderView(searchText: $viewModel.searchText, isBookmarkView: viewModel.isBookmarkView, dateSelected: viewModel.dateSelected != nil, infoText: viewModel.infoText) {
                viewModel.isBookmarkView.toggle()
            } toggleDatePicker: {
                if (viewModel.dateSelected != nil) {
                    viewModel.dateSelected = nil
                } else {
                    dateDialoguePresented = true
                }
            }
            VStack {
                if #available(iOS 16.0, *) {
                    Spacer().frame(maxWidth: .infinity, maxHeight: 15).background(Color("primaryColor", bundle: OSCAEventsUI.bundle).clipShape(.rect(bottomLeadingRadius: 20, bottomTrailingRadius: 20)))
                    Spacer()
                }
                switch (viewModel.state) {
                case .finishedLoading:
                    ScrollView {
                        let location = locationManager.location
                        LazyVStack(spacing: 10) {
                            ForEach(Array(viewModel.events.enumerated()), id: \.offset) { index, event in
                                EventListItemView(event: event, location: location, isBookmarked: viewModel.isBookmarked(objectId: event.objectId), onClick: {
                                    viewModel.selectedEvent = event
                                }, onBookmark: {
                                    viewModel.toggleBookmark(objectId: event.objectId)
                                }).task(id: index) {
                                    if (index==viewModel.events.endIndex - 1) {
                                        viewModel.fetchMore(atIndex: index)
                                    }
                                }
                            }
                        }.padding(EdgeInsets(top: 10, leading: 15, bottom: 0, trailing: 15))
                    }.refreshable {
                        viewModel.initFetchEvents()
                    }
                case .error(_):
                    ZStack {
                        Text("events_error_title", bundle: OSCAEventsUI.bundle)
                    }.frame(maxWidth: .infinity, maxHeight: .infinity).refreshable {
                        viewModel.initFetchEvents()
                    }
                default:
                    ZStack {
                        ProgressView()
                    }.frame(maxWidth: .infinity, maxHeight: .infinity).refreshable {
                        viewModel.initFetchEvents()
                    }
                }
            }.frame(maxWidth: .infinity, maxHeight: .infinity).background(Color.white)
        }.task(id: "\(viewModel.debounceSearchText)\(viewModel.dateSelected)\(viewModel.isBookmarkView)") {
            viewModel.initFetchEvents()
        }.sheet(isPresented: Binding<Bool>(get: { viewModel.selectedEvent != nil }, set: { _ in }), onDismiss: {
            viewModel.selectedEvent = nil
        }) {
            if let event = viewModel.selectedEvent {
                EventDetailSheet(event: event, isBookmarked: viewModel.isBookmarked(objectId: event.objectId), userLocation: locationManager.location, locationAuthorized: getLocationAuthorized()) { objectId in
                    viewModel.toggleBookmark(objectId: objectId)
                } addToCalendar: { event in
                    viewModel.eventStore.requestAccess(to: .event) { (granted, _ ) in
                        if (granted) {
                            guard let calendar = viewModel.eventStore.defaultCalendarForNewEvents else { return }
                            let calendarEvent = EKEvent(eventStore: viewModel.eventStore)
                            
                            calendarEvent.startDate = event.startDate?.dateISO8601
                            calendarEvent.endDate = event.endDate?.dateISO8601 ?? event.startDate?.dateISO8601
                            calendarEvent.title = event.name
                            calendarEvent.calendar = calendar
                            try? viewModel.eventStore.save(calendarEvent, span: .thisEvent, commit: true)
                        }
                    }
                    
                }
            }
        }.sheet(isPresented: $dateDialoguePresented, onDismiss: { dateDialoguePresented = false }) {
            if #available(iOS 17.0, *) {
                VStack{
                    HStack {
                        Button(action: {
                            dateDialoguePresented = false
                        }) {
                            Text("events_picker_title_cancel", bundle: OSCAEventsUI.bundle)
                        }
                        Spacer()
                        Button(action: {
                            viewModel.dateSelected = selectedInDatePicker
                            dateDialoguePresented = false
                        }) {
                            Text("events_picker_title_confirm", bundle: OSCAEventsUI.bundle)
                        }
                    }
                    DatePicker("", selection: $selectedInDatePicker, displayedComponents: .date).labelsHidden().datePickerStyle(.graphical)
                }.padding(.horizontal, 15).presentationDetents([.medium])
            } else {
                VStack{
                    HStack {
                        Button(action: {
                            dateDialoguePresented = false
                        }) {
                            Text("events_picker_title_cancel", bundle: OSCAEventsUI.bundle)
                        }
                        Spacer()
                        Button(action: {
                            viewModel.dateSelected = selectedInDatePicker
                            dateDialoguePresented = false
                        }) {
                            Text("events_picker_title_confirm", bundle: OSCAEventsUI.bundle)
                        }
                    }
                    DatePicker("", selection: $selectedInDatePicker, displayedComponents: .date).labelsHidden().datePickerStyle(.graphical)
                }.padding(.horizontal, 15)
            }
        }
    }
    
    func getLocationAuthorized() -> Bool {
        switch (locationManager.authorizationStatus) {
        case .authorizedAlways, .authorizedWhenInUse:
            return true
        default:
            return false
        }
    }
}
