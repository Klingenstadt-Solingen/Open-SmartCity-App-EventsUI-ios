//
//  OSCAEventsUIDIContainer.swift
//  OSCAEventsUI
//
//  Created by Stephan Breidenbach on 01.02.22.
//  Reviewed by Stephan Breidenbach on 21.06.2022
//

import OSCAEvents
import OSCAEssentials
import UIKit

/**
 Every isolated module feature will have its own Dependency Injection Container,
 to have one entry point where we can see all dependencies and injections of the module
 */
final class OSCAEventsUIDIContainer {
  let dependencies: OSCAEventsUIDependencies
  private let dataModule: OSCAEvents
  
  public init(dependencies: OSCAEventsUIDependencies) {
#if DEBUG
    print("\(String(describing: Self.self)): \(#function)")
#endif
    self.dependencies = dependencies
    self.dataModule = OSCAEventsUIDIContainer.makeOSCAEventsModule(dependencies: dependencies)
  }// end public init
  
  // MARK: - OSCAEventsModule
  private static func makeOSCAEventsModule(dependencies: OSCAEventsUIDependencies) -> OSCAEvents {
    return dependencies.dataModule
  }// end func makeOSCAEventsModule
  
  // MARK: - Main
  /// `make-function`for `OSCAEventMainViewController
  /// - Parameter actions: view model actions
  /// - Returns : controller `OSCAEventMainViewController`
    @MainActor func makeOSCAEventMainViewController() -> OSCAEventMainViewController {
    return OSCAEventMainViewController.create(with: makeOSCAEventMainViewModel())
  }// end makeOSCAEventMainViewController
  
  /// `make-function`for `OSCAEventMainViewModel
  /// - Parameter actions: view model actions
  /// - Returns : view model `OSCAEventMainViewModel`
    @MainActor func makeOSCAEventMainViewModel() -> OSCAEventMainViewModel{
    return OSCAEventMainViewModel(eventsModule: self.dataModule)
  }// end func makeOSCAEventMainViewModel
  
  // MARK: - flow coordinator
  func makeOSCAEventsFlowCoordinator(router: Router) -> OSCAEventsFlowCoordinator {
    return OSCAEventsFlowCoordinator(router: router, dependencies: self)
  }// end func makeOSCAEventsFlowCoordinator
  
}// end final class OSCAEventsUIDIContainer

extension OSCAEventsUIDIContainer: OSCAEventsFlowCoordinatorDependencies {
  
}// end extension final class OSCAEventsUIDIContainer
