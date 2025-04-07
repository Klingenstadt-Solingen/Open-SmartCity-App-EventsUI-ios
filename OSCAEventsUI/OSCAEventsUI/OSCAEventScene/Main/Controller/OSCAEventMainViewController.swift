//
//  OSCAEventMainViewController.swift
//  OSCAEventsUI
//
//  Created by MAMMUT Nithammer on 11.12.20.
//  Reviewed by Stephan Breidenbach on 11.02.22
//

import OSCAEssentials
import DeviceKit
import UIKit
import Combine
import OSCAEvents
import CoreLocation
import SwiftUI

public final class OSCAEventMainViewController: UIViewController, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()
    
    // MARK: - private
    /// controller's view model
    private var viewModel: OSCAEventMainViewModel!
    
    public override func viewDidLoad() -> Void {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestLocation()
        let eventViewController = UIHostingController(rootView: EventListScreen(viewModel: viewModel, locationManager: locationManager))
        eventViewController.view.backgroundColor = UIColor(Color("primaryColor", bundle: OSCAEventsUI.bundle))
        addChild(eventViewController)
        eventViewController.view.frame = view.bounds
        view.addSubview(eventViewController.view)
        // Making the subview fill the maximum available space
        eventViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            eventViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            eventViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            eventViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            eventViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)])
        eventViewController.didMove(toParent: self)
        self.navigationController?.setup(
            largeTitles: false,
            tintColor: UIColor.white,
            titleTextColor: UIColor.white,
            barColor: UIColor(Color("primaryColor", bundle: OSCAEventsUI.bundle)))
    }// end override func viewDidLoad
    
    private func setupViews() -> Void {
    }// end private func setupViews
    
    public override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setup(
            largeTitles: true,
            tintColor: UIColor.black,
            titleTextColor: UIColor.black,
            barColor: UIColor.white)
    }
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Must be implemented
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Must be implemented
    }
}// end final class OSCAEventMainViewController

// MARK: - view controller alerts
extension OSCAEventMainViewController: Alertable {
    
}// end extension final class OSCAEventMainViewController

// MARK: - instantiate view controller
extension OSCAEventMainViewController: StoryboardInstantiable {
    /// function call: var vc = OSCAEventMainViewController.create(viewModel)
    public static func create(with viewModel: OSCAEventMainViewModel) -> OSCAEventMainViewController {
#if DEBUG
        print("\(String(describing: self)): \(#function)")
#endif
        let vc: Self = Self.instantiateViewController(OSCAEventsUI.bundle)
        vc.viewModel = viewModel
        return vc
    }// end public static func create
}// end extension final class OSCAEventMainViewController

// MARK: - Deeplinking
extension OSCAEventMainViewController {
    func didReceiveDeeplink(with reference: String?) {
        self.viewModel.didReceiveDeeplink(with: reference)
    }
}
