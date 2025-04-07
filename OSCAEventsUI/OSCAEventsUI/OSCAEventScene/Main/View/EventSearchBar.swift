//
//  EventSearchBar.swift
//  OSCAEventsUI
//
//  Created by Silvester Nita on 11.07.24.
//

import SwiftUI

struct EventSearchBar: View {
    @Binding var searchText: String
    
    var body: some View {
        HStack {
            TextField(NSLocalizedString("events_search_placeholder", bundle: OSCAEventsUI.bundle, comment: "search bar placeholder text"), text: $searchText)
                .padding(10)
                .padding(.horizontal, 25)
                .background(Color(.systemGray6))
                .cornerRadius(10)
            
        }
    }
}
