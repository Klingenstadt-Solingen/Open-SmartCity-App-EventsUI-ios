// Reviewed by Stephan Breidenbach on 08.07.22
#if canImport(XCTest) && canImport(OSCATestCaseExtension)
import XCTest
@testable import OSCAEventsUI
import OSCAEssentials
import OSCAEvents
import OSCATestCaseExtension

final class OSCAEventsUITests: XCTestCase {
  static let moduleVersion = "1.0.4"
  override func setUpWithError() throws {
    try super.setUpWithError()
  }// end override func setupWithError
  
  func testModuleInit() throws -> Void {
    let uiModule = try makeDevUIModule()
    XCTAssertNotNil(uiModule)
    XCTAssertEqual(uiModule.version, OSCAEventsUITests.moduleVersion)
    XCTAssertEqual(uiModule.bundlePrefix, "de.osca.events.ui")
    let bundle = OSCAEvents.bundle
    XCTAssertNotNil(bundle)
    let uiBundle = OSCAEventsUI.bundle
    XCTAssertNotNil(uiBundle)
    let configuration = OSCAEventsUI.configuration
    XCTAssertNotNil(configuration)
    XCTAssertNotNil(self.devPlistDict)
    XCTAssertNotNil(self.productionPlistDict)
  }// end func testModuleInit
  
  func testEventsUIConfiguration() throws -> Void {
    let _ = try makeDevUIModule()
    let uiModuleConfig = try makeUIModuleConfig()
    XCTAssertEqual(OSCAEventsUI.configuration.title, uiModuleConfig.title)
    XCTAssertEqual(OSCAEventsUI.configuration.colorConfig.accentColor, uiModuleConfig.colorConfig.accentColor)
    XCTAssertEqual(OSCAEventsUI.configuration.fontConfig.bodyHeavy, uiModuleConfig.fontConfig.bodyHeavy)
  }// end func testEventsUIConfiguration
}// end final class OSCAEventsUITests

// MARK: - factory methods
extension OSCAEventsUITests {
  public func makeDevModuleDependencies() throws -> OSCAEventsDependencies {
    let networkService = try makeDevNetworkService()
    let userDefaults   = try makeUserDefaults(domainString: "de.osca.events.ui")
    let dependencies = OSCAEventsDependencies(
      appStoreURL: nil, networkService: networkService,
      userDefaults: userDefaults,
      eventWatchlistMaxStorageLimit: 1000)
    return dependencies
  }// end public func makeDevModuleDependencies
  
  public func makeDevModule() throws -> OSCAEvents {
    let devDependencies = try makeDevModuleDependencies()
    // initialize module
    let module = OSCAEvents.create(with: devDependencies)
    return module
  }// end public func makeDevModule
  
  public func makeProductionModuleDependencies() throws -> OSCAEventsDependencies {
    let networkService = try makeProductionNetworkService()
    let userDefaults   = try makeUserDefaults(domainString: "de.osca.events.ui")
    let dependencies = OSCAEventsDependencies(
      appStoreURL: nil, networkService: networkService,
      userDefaults: userDefaults,
      eventWatchlistMaxStorageLimit: 1000)
    return dependencies
  }// end public func makeProductionModuleDependencies
  
  public func makeProductionModule() throws -> OSCAEvents {
    let productionDependencies = try makeProductionModuleDependencies()
    // initialize module
    let module = OSCAEvents.create(with: productionDependencies)
    return module
  }// end public func makeProductionModule
  
  public func makeUIModuleConfig() throws -> OSCAEventsUIConfig {
    return OSCAEventsUIConfig(title: "OSCAEventsUI",
                              fontConfig: OSCAFontSettings(),
                              colorConfig: OSCAColorSettings())
  }// end public func makeUIModuleConfig
  
  public func makeDevUIModuleDependencies() throws -> OSCAEventsUIDependencies {
    let module      = try makeDevModule()
    let uiConfig    = try makeUIModuleConfig()
    return OSCAEventsUIDependencies(moduleConfig: uiConfig,
                                    dataModule: module, eventWatchlistMaxStorageLimit: 1000)
  }// end public func makeDevUIModuleDependencies
  
  public func makeDevUIModule() throws -> OSCAEventsUI {
    let devDependencies = try makeDevUIModuleDependencies()
    // init ui module
    let uiModule = OSCAEventsUI.create(with: devDependencies)
    return uiModule
  }// end public func makeUIModule
  
  public func makeProductionUIModuleDependencies() throws -> OSCAEventsUIDependencies {
    let module      = try makeProductionModule()
    let uiConfig    = try makeUIModuleConfig()
    return OSCAEventsUIDependencies(moduleConfig: uiConfig,
                                    dataModule: module, eventWatchlistMaxStorageLimit: 1000)
  }// end public func makeProductionUIModuleDependencies
  
  public func makeProductionUIModule() throws -> OSCAEventsUI {
    let productionDependencies = try makeProductionUIModuleDependencies()
    // init ui module
    let uiModule = OSCAEventsUI.create(with: productionDependencies)
    return uiModule
  }// end public func makeProductionUIModule
}// end extension OSCAEventsUITests
#endif
