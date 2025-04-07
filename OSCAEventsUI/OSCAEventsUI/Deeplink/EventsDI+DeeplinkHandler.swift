//
//  EventsDI+DeeplinkHandler.swift
//  OSCAEventsUI
//
//  Created by Stephan Breidenbach on 09.09.22.
//

import Foundation

extension OSCAEventsUIDIContainer {
  var deeplinkScheme: String {
    return self
      .dependencies
      .moduleConfig
      .deeplinkScheme
  }// end var deeplinkScheme
}// end extension OSCAEventsUIDIContainer
