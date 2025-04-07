//
//  OSCAEventMainViewModel.swift
//  OSCAEventsUI
//
//  Created by Stephan Breidenbach on 11.02.22.
//

import OSCAEssentials
import OSCANetworkService
import OSCAEvents
import Foundation
import Combine
import SwiftUI
import EventKit

public enum OSCAEventMainViewModelError: Error, Equatable {
    case eventFetching
    case noResult
    case noResultBookmarks
}// end public enum OSCAEventMainViewModelError

public enum OSCAEventMainViewModelState: Equatable {
    case initialize
    case loading
    case finishedLoading
    case error(OSCAEventMainViewModelError)
}// end public enum OSCAEventMainViewModelState

@MainActor
public final class OSCAEventMainViewModel: ObservableObject {
    private let eventsModule     : OSCAEvents
    @Published var events: [OSCAEvent] = []
    
    /// view model initializer
    /// - Parameter eventsModule: data access module `OSCAEvents`
    /// - Parameter actions: actions that could be invoked by the view model
    public init ( eventsModule  : OSCAEvents) {
        self.eventsModule = eventsModule
        $searchText.debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .assign(to: &$debounceSearchText)
        
    }// end public init
    
    // MARK: - Output
    /// view model state
    @Published var state: OSCAEventMainViewModelState = .initialize
    @Published var bookmarkedIds: [String] = UserDefaults.standard.stringArray(forKey: "events_bookmarked_ids") ?? [String]()
    @Published var isBookmarkView = false
    @Published var searchText = ""
    @Published var debounceSearchText = ""
    @Published var infoText: String? = nil
    @Published var dateSelected: Date? = nil
    @Published var selectedEvent: OSCAEvent? = nil
    let eventStore = EKEventStore()
    
    let fetchLimit: Int = 20
    
    func initFetchEvents() {
        updateBookmarkedIds()
        self.state = .loading
        infoText = nil
        if (dateSelected == nil && debounceSearchText.isEmpty && !isBookmarkView) {
            fetchParseEventCount { count in
                self.updateInfoText(eventCount: count)
            }
            fetchParseEvent(skip: 0, updateState: true) { fetchedEvents in
                self.events = fetchedEvents
            }
        } else {
            fetchElasticEventCount { count in
                self.updateInfoText(eventCount: count)
            }
            fetchElasticEvent(skip: 0, updateState: true) { fetchedEvents in
                self.events = fetchedEvents
            }
        }
    }
    
    func fetchMore(atIndex: Int) {
        if (dateSelected == nil && debounceSearchText.isEmpty && !isBookmarkView) {
            fetchParseEvent(skip: atIndex + 1, updateState: false) { fetchedEvents in
                self.events.append(contentsOf: fetchedEvents)
            }
        } else {
            fetchElasticEvent(skip: 0, updateState: true) { fetchedEvents in
                self.events = fetchedEvents
            }
        }
    }
    
    func fetchParseEventCount(_ onCompletion: @escaping (Int?) -> ()) {
        _ = eventsModule.fetchParseEventCount().sink { _ in} receiveValue: { count in
            onCompletion(count)
        }
    }
    
    func fetchParseEvent(skip: Int, updateState: Bool, _ onCompletion: @escaping ([OSCAEvent]) -> ()) {
        _ = eventsModule.fetchParseEvents(limit: fetchLimit, skip: skip).sink { completion in
            switch completion {
            case .finished:
                if (updateState) { self.state = .finishedLoading }
            case .failure:
                if (updateState) { self.state = .error(.eventFetching) }
            }
        } receiveValue: { fetchedEvents in
            if (updateState && self.events.isEmpty) {
                self.state = .error(.noResultBookmarks)
            }
            onCompletion(fetchedEvents)
        }
    }
    
    func fetchElasticEventCount(_ onCompletion: @escaping (Int?) -> ()) {
        _ = eventsModule.fetchElasticEventsCount(date: dateSelected, bookmarkedIds: isBookmarkView ? bookmarkedIds: nil, query: debounceSearchText).sink {_ in } receiveValue: { count in
            onCompletion(count)
        }
    }
    
    func fetchElasticEvent(skip: Int, updateState: Bool, _ onCompletion: @escaping ([OSCAEvent]) -> ()) {
        _ = eventsModule.fetchElasticEvents(date: dateSelected, bookmarkedIds: isBookmarkView ? bookmarkedIds : nil, query: debounceSearchText).sink { completion in
                switch completion {
                case .finished:
                    if (updateState) { self.state = .finishedLoading }
                case .failure:
                    if (updateState) { self.state = .error(.eventFetching) }
                }
            } receiveValue: { fetchedEvents in
                if (updateState && self.events.isEmpty) {
                    self.state = .error(.noResultBookmarks)
                }
                onCompletion(fetchedEvents)
            }
    }
    
    func fetchDeeplinkEvent(objectId: String?)  {
        if let objectId = objectId {
            _ = eventsModule.fetchSingularEvent(objectId: objectId).sink { l in } receiveValue: { fetchedEvents in
                Task {
                    await MainActor.run {
                        self.selectedEvent = fetchedEvents.first
                    }
                }
            }
        }
    }
    
    func updateBookmarkedIds() {
        bookmarkedIds = UserDefaults.standard.stringArray(forKey: "events_bookmarked_ids") ?? [String]()
    }
    
    func toggleBookmark(objectId: String?) {
        if let objectId = objectId {
            if (bookmarkedIds.contains(where: { bookmarkId in
                bookmarkId == objectId
            })) {
                let filteredBookmarkedIds = bookmarkedIds.filter({ bookmarkId in
                    return bookmarkId != objectId
                })
                bookmarkedIds = filteredBookmarkedIds
            } else {
                bookmarkedIds.append(objectId)
            }
            UserDefaults.standard.setValue(bookmarkedIds, forKey: "events_bookmarked_ids")
        }
    }
    
    func isBookmarked(objectId: String?) -> Bool {
        return bookmarkedIds.contains(where: { bookmarkId in
            bookmarkId == objectId
        })
    }
    
    func isOnSameDay(firstDate: Date?, secondDate: Date?) -> Bool {
        if let firstDate = firstDate, let secondDate = secondDate {
            return Calendar.current.isDate(firstDate, equalTo: secondDate, toGranularity: .day)
        }
        return false
    }
    
    func updateInfoText(eventCount: Int?) {
        if let count = eventCount {
            if ((dateSelected == nil || isOnSameDay(firstDate: dateSelected, secondDate: Date.now)) && debounceSearchText.isEmpty && !isBookmarkView) {
                if count > 0 {
                    infoText = String(
                        format: NSLocalizedString(
                            "events_event_subtitle %@",
                            bundle: OSCAEventsUI.bundle,
                            comment: "how many events on the same day"),
                        "\(count)")
                } else {
                    infoText = String(
                        format: NSLocalizedString(
                            "events_no_event_today_subtitle",
                            bundle: OSCAEventsUI.bundle,
                            comment: "no events on the same day"))
                }
            } else {
                if count > 0 {
                    infoText = String(
                        format: NSLocalizedString(
                            "events_event_searched_subtitle %@",
                            bundle: OSCAEventsUI.bundle,
                            comment: "how many events on the same day"),
                        "\(count)")
                } else {
                    infoText = String(
                        format: NSLocalizedString(
                            "events_no_event_title",
                            bundle: OSCAEventsUI.bundle,
                            comment: "no events available"))
                }
            }
        } else {
            infoText = nil
        }
    }
    
    func didReceiveDeeplink(with reference: String?) {
        fetchDeeplinkEvent(objectId: reference)
    }
    /**
     Use this to get access to the __Bundle__ delivered from this module's configuration parameter __externalBundle__.
     - Returns: The __Bundle__ given to this module's configuration parameter __externalBundle__. If __externalBundle__ is __nil__, The module's own __Bundle__ is returned instead.
     */
    var bundle: Bundle = {
        if let bundle = OSCAEventsUI.configuration.externalBundle {
            return bundle
        }
        else { return OSCAEventsUI.bundle }
    }()
}// end final class OSCAEventMainViewModel
