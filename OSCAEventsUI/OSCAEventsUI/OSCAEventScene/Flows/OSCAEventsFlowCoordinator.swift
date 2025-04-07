//
//  OSCAEventsFlowCoordinator.swift
//  OSCAEventsUI
//
//  Created by Stephan Breidenbach on 09.02.22.
//

import OSCAEssentials
import OSCAEvents
import Foundation

protocol OSCAEventsFlowCoordinatorDependencies {
    var deeplinkScheme: String { get }
    func makeOSCAEventMainViewController() -> OSCAEventMainViewController
}// end protocol OSCAEventsFlowCoordinatorDependencies

public final class OSCAEventsFlowCoordinator: Coordinator {
    /**
     `children`property for conforming to `Coordinator` protocol is a list of `Coordinator`'s
     */
    public var children: [Coordinator] = []
    /**
     router injected via initializer: `router` will be used to push and pop view controllers
     */
    public var router: Router
    /**
     dependencies injected via initializer DI conforming to the `OSCAEventsFlowCoordinatorDependencies` protocol
     */
    let dependencies: OSCAEventsFlowCoordinatorDependencies
    /**
     waste view controller `OSCAEventMainViewController`
     */
    weak var eventMainVC: OSCAEventMainViewController?
    
    init(router: Router,
         dependencies: OSCAEventsFlowCoordinatorDependencies) {
        self.router = router
        self.dependencies = dependencies
    }// end public init
    
    func showEventsMain(animated: Bool,
                        onDismissed: (() -> Void)?) -> Void {
        if self.eventMainVC == nil {
            let vc = self.dependencies.makeOSCAEventMainViewController()
            self.eventMainVC = vc
        }
        guard let vc = self.eventMainVC else { return }
        self.router.present(vc, animated: animated, onDismissed: onDismissed)
    }// end func showEventsMain
    
    public func present(animated: Bool, onDismissed: (() -> Void)?) -> Void {
#if DEBUG
        print("\(String(describing: self)): \(#function)")
#endif
        // Note: here we keep strong reference with actions, this way this flow do not need to be strong referenced
        showEventsMain(animated: animated,
                       onDismissed: onDismissed)
    }// end public func present
}// end public final class OSCAEventsFlowCoordinator
