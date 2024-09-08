//
//  ContainersView+ViewModel.swift
//  Harbour
//
//  Created by royal on 30/01/2023.
//  Copyright © 2023 shameful. All rights reserved.
//

import CoreSpotlight
import PortainerKit
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

// MARK: - ContainersView+ViewModel

extension ContainersView {
	@Observable @MainActor
	final class ViewModel {
		private let portainerStore: PortainerStore
		private let preferences = Preferences.shared

		@ObservationIgnored
		private var fetchTask: Task<Void, Error>?
		private var fetchError: Error?

		private(set) var suggestedSearchTokens: [SearchToken] = []

		var searchText = ""
		var searchTokens: [SearchToken] = []
		var isSearchActive = false

		var scrollViewIsRefreshing = false

		var viewState: ViewState<[Container], Error> {
			let containers = portainerStore.containers

			if !(fetchTask?.isCancelled ?? true) || !(portainerStore.containersTask?.isCancelled ?? true) || !(portainerStore.endpointsTask?.isCancelled ?? true) {
				return containers.isEmpty ? .loading : .reloading(containers)
			}

			if let fetchError {
				return .failure(fetchError)
			}

			return .success(containers)
		}

		var containers: [Container] {
			portainerStore.containers
				.filter { container in
					for token in searchTokens {
						let matches = token.matchesContainer(container)
						if !matches { return false }
					}

					return true
				}
				.filter(searchText)
		}

		var isStatusProgressViewVisible: Bool {
			!scrollViewIsRefreshing && viewState.showAdditionalLoadingView && !(fetchTask?.isCancelled ?? true)
		}

		var canUseEndpointsMenu: Bool {
			portainerStore.selectedEndpoint != nil || !portainerStore.endpoints.isEmpty
		}

		init() {
			let portainerStore = PortainerStore.shared
			self.portainerStore = portainerStore
		}

		func fetch() async throws {
			fetchTask?.cancel()
			self.fetchTask = Task { @MainActor in
				defer { self.fetchTask = nil }
				fetchError = nil

				do {
					if portainerStore.selectedEndpoint != nil {
						async let endpointsTask = portainerStore.refreshEndpoints()
						async let containersTask = portainerStore.refreshContainers()

						_ = try await (endpointsTask.value, containersTask.value)
					} else {
						_ = try await portainerStore.refreshEndpoints().value
						_ = try await portainerStore.refreshContainers().value
					}

					let staticTokens: [SearchToken] = [
						.status(isOn: true),
						.status(isOn: false)
					]

					let stacks = Set(portainerStore.containers.compactMap(\.stack))
					let stacksTokens = stacks
						.sorted()
						.map { SearchToken.stack($0) }

					self.suggestedSearchTokens = staticTokens + stacksTokens
				} catch {
					fetchError = error
					throw error
				}
			}
			try await fetchTask?.value
		}

		func filterByStackName(_ stackName: String?) {
			if let stackName {
				searchTokens = [.stack(stackName)]
			} else {
				searchTokens = []
			}
		}

		func onLandingDismissed() {
			preferences.landingDisplayed = true
		}
	}
}

// MARK: - ContainersView.ViewModel+UserActivity

extension ContainersView.ViewModel {
	func handleSpotlightSearchContinuation(_ userActivity: NSUserActivity) {
		guard let queryString = userActivity.userInfo?[CSSearchQueryString] as? String else { return }
		searchText = queryString
//		isSearchActive = true
	}
}

// MARK: - ContainersView.ViewModel+SearchToken

extension ContainersView.ViewModel {
	enum SearchToken: Identifiable, Equatable {
		case stack(String)
		case status(isOn: Bool)

		var id: String {
			switch self {
			case .stack(let stackName):
				"stack.\(stackName)"
			case .status(let isOn):
				"status.\(isOn)"
			}
		}

		var title: String {
			switch self {
			case .stack(let stackName):
				stackName
			case .status(let isOn):
				String(localized: isOn ? "ContainersView.SearchToken.Status.On" : "ContainersView.SearchToken.Status.Off")
			}
		}

		var icon: String {
			switch self {
			case .stack:
				SFSymbol.stack
			case .status(let isOn):
				isOn ? SFSymbol.start : SFSymbol.stop
			}
		}

		func matchesContainer(_ container: Container) -> Bool {
			switch self {
			case .stack(let stackName):
				return container.stack == stackName
			case .status(let isOn):
				return container.state.isRunning == isOn ? true : false
			}
		}
	}
}
