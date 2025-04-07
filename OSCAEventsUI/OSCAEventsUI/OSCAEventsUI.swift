//
//  OSCAEventsUI.swift
//  OSCAEventsUI
//
//  Created by Stephan Breidenbach on 09.02.22.
//

import OSCAEvents
import OSCAEssentials
import UIKit
import OSCANetworkService

public struct OSCAEventsUIDependencies {
  let moduleConfig                 : OSCAEventsUIConfig
  let dataModule                   : OSCAEvents
  let eventWatchlistMaxStorageLimit: Int
  let analyticsModule              : OSCAAnalyticsModule?
  
  public init(moduleConfig                 : OSCAEventsUIConfig,
              dataModule                   : OSCAEvents,
              eventWatchlistMaxStorageLimit: Int,
              analyticsModule              : OSCAAnalyticsModule? = nil
  ) {
    self.moduleConfig                  = moduleConfig
    self.dataModule                    = dataModule
    self.eventWatchlistMaxStorageLimit = eventWatchlistMaxStorageLimit
    self.analyticsModule               = analyticsModule
  }// end public memberwise init
}// end public struct OSCAEventsUIDependencies

/// The configuration of the `OSCAEventsUI` module
public struct OSCAEventsUIConfig: OSCAUIModuleConfig {
  /// module title
  public var title                      : String?
  public var externalBundle             : Bundle?
  public var cityBundle             : Bundle?
  /// `UIView` corner radius
  public var cornerRadius               : Double
  public var shadow                     : OSCAShadowSettings
  public var itemHeight                 : CGFloat
  /// typeface configuration
  public var fontConfig                 : OSCAFontConfig
  /// color configuration
  public var colorConfig                : OSCAColorConfig
  public var deeplinkScheme             : String
  public var placeholderImage           : UIImage?
  public var placeholderImageContentMode: UIImageView.ContentMode
  /// rotation angle for image transformations
  public var imageRotationAngle         : Double
  
  public var mainWidget: MainWidget
  
  public init(
    title                  : String?,
    cityBundle         : Bundle? = nil,
    externalBundle         : Bundle? = nil,
    cornerRadius           : Double = 10.0,
    shadow                 : OSCAShadowSettings = OSCAShadowSettings(
      opacity: 0.2,
      radius: 10,
      offset: CGSize(width: 0,   height: 2)),
    itemHeight             : CGFloat = 135,
    fontConfig             : OSCAFontConfig,
    colorConfig            : OSCAColorConfig,
    deeplinkScheme         : String = "solingen",
    placeholderImage       : UIImage? = nil,
    placeholderContentMode : UIImageView.ContentMode = .scaleAspectFill,
    eventImageRotationAngle: Double = .pi / 5,
    mainWidget             : MainWidget = MainWidget()) {
#if DEBUG
    print("\(String(describing: Self.self)): \(#function)")
#endif
    self.title                       = title
    self.externalBundle              = externalBundle
    self.cityBundle = cityBundle
    self.cornerRadius                = cornerRadius
    self.shadow                      = shadow
    self.itemHeight                  = itemHeight
    self.fontConfig                  = fontConfig
    self.colorConfig                 = colorConfig
    self.deeplinkScheme              = deeplinkScheme
    self.placeholderImage            = placeholderImage
    self.placeholderImageContentMode = placeholderContentMode
    self.imageRotationAngle          = eventImageRotationAngle
    self.mainWidget                  = mainWidget
  }// end public memberwise init
}// end public struct OSCAEventsUIConfig

/// OSCAEventsUI module
public struct OSCAEventsUI: OSCAModule {
  /// module DI container
  private var moduleDIContainer: OSCAEventsUIDIContainer!
  /// version of the module
  public var version: String = "1.0.4"
  /// bundle prefix of the module
  public var bundlePrefix: String = "de.osca.events.ui"
  ///  module configuration
  public internal(set) static var configuration: OSCAEventsUIConfig!
  /// module `Bundle`
  ///
  /// **available after module initialization only!!!**
  public internal(set) static var bundle: Bundle!
  
  /**
   create module and inject module dependencies
   - Parameter mduleDependencies: module dependencies
   */
  public static func create(with moduleDependencies: OSCAEventsUIDependencies) -> OSCAEventsUI {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    var module: Self = Self.init(with: moduleDependencies.moduleConfig)
    module.moduleDIContainer = OSCAEventsUIDIContainer(dependencies: moduleDependencies)
    return module
  }// end public static func create with module dependencies
  
  /// public initializer with module configuration
  /// - Parameter config: module configuration
  public init(with config: OSCAUIModuleConfig) {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
#if SWIFT_PACKAGE
    Self.bundle = Bundle.module
#else
    guard let bundle: Bundle = Bundle(identifier: self.bundlePrefix) else { fatalError("Module bundle not initialized!") }
    Self.bundle = bundle
#endif
    guard let extendedConfig = config as? OSCAEventsUIConfig
    else { fatalError("Config couldn't be initialized!")}
    OSCAEventsUI.configuration = extendedConfig
    
    setPlaceholderImageIfNeeded()
  }// end public init with config
  
  /// public getter of `OSCAEventsFlowCoordinator`
  /// - Parameter router: router needed for the navigation graph
  public func getOSCAEventsFlowCoordinator(router: Router) -> OSCAEventsFlowCoordinator {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    let flow = self.moduleDIContainer.makeOSCAEventsFlowCoordinator(router: router)
    return flow
  }// end public func getOSCAEventsFLowCoordinator
  
  private func setPlaceholderImageIfNeeded() {
    // Must be set when bundle is already created
    if Self.configuration.placeholderImage == nil {
      Self.configuration.placeholderImage = UIImage(named: "event-default", in: OSCAEventsUI.bundle, with: .none)
    }
  }
}// end public struct OSCAEventsUI

// MARK: - Keys
extension OSCAEventsUI {
  /// UserDefaults object keys
  public enum Keys: String {
    case eventsWidgetVisibility = "Events_Widget_Visibility"
    case eventsWidgetPosition   = "Events_Widget_Position"
  }
}

// MARK: Main Widget Config
extension OSCAEventsUIConfig {
  public struct MainWidget {
    public var title: String?
    public var maxItems: Int
    
    public init(title: String? = nil, maxItems: Int = 5) {
      self.title = title
      self.maxItems = maxItems
    }
  }
}
