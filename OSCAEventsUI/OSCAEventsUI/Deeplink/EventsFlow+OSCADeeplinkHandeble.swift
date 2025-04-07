//
//  EventsFlow+OSCADeeplinkHandeble.swift
//  OSCAEventsUI
//
//  Created by Stephan Breidenbach on 09.09.22.
//

import Foundation
import OSCAEssentials

extension OSCAEventsFlowCoordinator: OSCADeeplinkHandeble {
    ///```console
    ///xcrun simctl openurl booted \
    /// "solingen://events/"
    /// ```
    public func canOpenURL(_ url: URL) -> Bool {
        let deeplinkScheme: String = dependencies
            .deeplinkScheme
        return url.absoluteString.hasPrefix("\(deeplinkScheme)://events")
    }// end public func canOpenURL
    
    public func openURL(_ url: URL,
                        onDismissed:(() -> Void)?) throws -> Void {
        guard canOpenURL(url) else { return }
        
        let deeplinkParser = DeeplinkParser()
        if let payload = deeplinkParser.parse(content: url) {
            switch payload.target {
            case "main":
                let sourceUrl = payload.parameters["sourceUrl"]
                self.showEvent(with: sourceUrl,
                               onDismissed: onDismissed)
                
            case "detail":
                let objectId = payload.parameters["object"]
                self.showEvent(with: objectId, onDismissed: onDismissed)
                
            default:
                self.showEventsMain(animated: true,
                                    onDismissed: onDismissed)
            }
            
        } else {
            self.showEventsMain(animated: true,
                                onDismissed: onDismissed)
        }
    }// end public func openURL
    
    public func showEvent(with reference: String?, onDismissed:(() -> Void)?) {
        self.showEventsMain(animated: true,
                            onDismissed: onDismissed)
        guard let eventVC = self.eventMainVC else { return }
        eventVC.didReceiveDeeplink(with: reference)
    }
}// end extension final class OSCAEventsFlowCoordinator
