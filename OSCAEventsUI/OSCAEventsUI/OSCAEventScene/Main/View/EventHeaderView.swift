import SwiftUI

struct EventHeaderView: View {
    @Binding var searchText: String
    var isBookmarkView: Bool
    var dateSelected: Bool
    var infoText: String?
    var toggleBookmarkView: () -> ()
    var toggleDatePicker: () -> ()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("events_screen_title", bundle: OSCAEventsUI.bundle).foregroundColor(Color.white).font(.system(size: 24, weight: .bold))
                Spacer()
                Button(action: toggleBookmarkView) {
                    Image(getBookmarkIconName(), bundle: OSCAEventsUI.bundle).resizable().tint(Color.white).frame(maxWidth: 25, maxHeight: 25)
                }
            }
            ZStack {
                if let infoText = infoText {
                    Text(verbatim: infoText).foregroundColor(Color("lightColor", bundle: OSCAEventsUI.bundle)).multilineTextAlignment(.leading)
                }
            }.frame(height: 10)
            HStack {
                EventSearchBar(searchText: $searchText).frame(maxWidth: .infinity)
                    Button(action: toggleDatePicker) {
                        Image(getDatePickerIconName(), bundle: OSCAEventsUI.bundle).resizable().tint(Color("primaryColor", bundle: OSCAEventsUI.bundle)).frame(maxWidth: 25, maxHeight: 25).padding(9).background(RoundedRectangle(cornerRadius: 10).foregroundColor(Color(UIColor.systemGray6)))
                    }
            }
        }.padding(.horizontal, 15)
    }
    
    func getBookmarkIconName() -> String {
        return isBookmarkView ? "bookmark-solid-svg" : "bookmark-light-svg"
    }
    
    func getDatePickerIconName() -> String {
        return dateSelected ? "times-light-svg" : "calendar-plus-light-svg"
    }
}
