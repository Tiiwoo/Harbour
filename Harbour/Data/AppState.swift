//
//  AppState.swift
//  Harbour
//
//  Created by royal on 11/06/2021.
//

import Foundation
import Combine
import os.log
import UIKit
import Indicators

class AppState: ObservableObject {
	public static let shared: AppState = AppState()
	
	@Published public var isSettingsSheetPresented: Bool = false
	@Published public var isSetupSheetPresented: Bool = false
	@Published public var isContainerConsoleSheetPresented: Bool = false
	
	@Published public var fetchingMainScreenData: Bool = false
	
	public let indicators: Indicators = Indicators()

	private let logger: PseudoLogger = PseudoLogger(subsystem: Bundle.main.bundleIdentifier!, category: "AppState")
	
	private var autoRefreshTimer: AnyCancellable? = nil

	private init() {
		#if DEBUG
		UserDefaults.standard.set(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
		#endif
		
		if !Preferences.shared.finishedSetup {
			isSetupSheetPresented = true
		}
		
		if Preferences.shared.endpointURL != nil && Preferences.shared.autoRefreshInterval > 0 {
			setupAutoRefreshTimer()
		}
	}
	
	// MARK: - Auto refresh
	
	public func setupAutoRefreshTimer(interval: Double = Preferences.shared.autoRefreshInterval) {
		self.logger.debug("(Auto refresh) Interval: \(interval)")
		
		autoRefreshTimer?.cancel()

		guard interval > 0 else { return }
		
		autoRefreshTimer = Timer.publish(every: interval, on: .current, in: .common)
			.autoconnect()
			.sink { [weak self] _ in
				DispatchQueue.main.async { [weak self] in
					self?.fetchingMainScreenData = true
				}
				
				guard let selectedEndpointID = Portainer.shared.selectedEndpoint?.id else {
					return
				}
				
				Portainer.shared.getContainers(endpointID: selectedEndpointID)
				
				DispatchQueue.main.async { [weak self] in
					self?.fetchingMainScreenData = false
				}
			}
	}
	
	// MARK: - Error handling
	
	public func handle(_ error: Error, indicator: Indicators.Indicator, _fileID: StaticString = #fileID, _line: Int = #line) {
		handle(error, displayIndicator: false, _fileID: _fileID, _line: _line)
		
		DispatchQueue.main.async {
			self.indicators.display(indicator)
		}
	}

	public func handle(_ error: Error, displayIndicator: Bool = true, _fileID: StaticString = #fileID, _line: Int = #line) {
		UIDevice.current.generateHaptic(.error)
		logger.error("\(String(describing: error)) [\(_fileID):\(_line)]")
		
		if displayIndicator {
			let style: Indicators.Indicator.Style = .init(subheadlineColor: .red, iconColor: .red)
			let indicator: Indicators.Indicator = .init(id: UUID().uuidString, icon: "exclamationmark.triangle.fill", headline: "Error!", subheadline: error.localizedDescription, expandedText: error.localizedDescription, dismissType: .after(5), style: style)
			DispatchQueue.main.async {
				self.indicators.display(indicator)
			}
		}
	}
}
