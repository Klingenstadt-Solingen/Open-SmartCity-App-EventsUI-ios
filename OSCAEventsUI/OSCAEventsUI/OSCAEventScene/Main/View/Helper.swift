import Foundation
import SwiftUI

func formattedDateString(date: Date?) -> String {
    var dateString = ""
    if let date = date {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        dateString += formatter.string(from: date)
    }
    return dateString
}

func formattedTimeString(date: Date?) -> String {
    var timeString = ""
    if let date = date {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        timeString += formatter.string(from: date)
    }
    return String(
        format: NSLocalizedString(
            "events_time_of_day %@",
            bundle: OSCAEventsUI.bundle,
            comment: "The text for time of day"),
        "\(timeString)")
}

func favoriteIconName(isBookmarked: Bool) -> String {
    return isBookmarked ? "bookmark-solid-svg" : "bookmark-light-svg"
}

extension Color {
    func primary() -> Color { return Color("primaryColor", bundle: OSCAEventsUI.bundle) }
}
