//
//  IntentContainer.swift
//  Harbour
//
//  Created by royal on 10/06/2023.
//  Copyright © 2023 shameful. All rights reserved.
//

import AppIntents
import CommonOSLog
import OSLog
import PortainerKit

private let logger = Logger(.intents(IntentContainer.self))

// MARK: - IntentContainer

// swiftlint:disable lower_acl_than_parent

struct IntentContainer: AppEntity {
	public static let typeDisplayRepresentation: TypeDisplayRepresentation = "IntentContainer.TypeDisplayRepresentation"
	public static let defaultQuery = IntentContainerQuery()

	public var displayRepresentation: DisplayRepresentation {
		DisplayRepresentation(title: .init(stringLiteral: name ?? ""), subtitle: .init(stringLiteral: _id))
	}

	@Property(title: "IntentContainer.ID")
	public var _id: Container.ID

	@Property(title: "IntentContainer.Name")
	public var name: String?

	@Property(title: "IntentContainer.Image")
	public var image: String?

	@Property(title: "IntentContainer.ContainerState")
	public var containerState: ContainerStateAppEnum?

	@Property(title: "IntentContainer.Status")
	public var status: String?

	@Property(title: "IntentContainer.AssociationID")
	public var associationID: String?

	init(
		id: Container.ID,
		name: String?,
		image: String?,
		containerState: Container.State? = nil,
		status: String? = nil,
		associationID: String?
	) {
		self._id = id
		self.name = name
		self.image = image
		if let containerState {
			self.containerState = .init(state: containerState)
		} else {
			self.containerState = nil
		}
		self.status = status
		self.associationID = associationID
	}

	init(container: Container) {
		self._id = container.id
		self.name = container.displayName
		self.image = container.image
		if let containerState = container.state {
			self.containerState = .init(state: containerState)
		} else {
			self.containerState = nil
		}
		self.status = container.status
		self.associationID = container.associationID
	}
}

// swiftlint:enable lower_acl_than_parent

// MARK: - IntentContainer+Identifiable

extension IntentContainer: Identifiable {
	private static let partJoiner = ";"

	var id: String {
		[_id, name ?? "", image ?? "", associationID ?? ""].joined(separator: Self.partJoiner)
	}

	init?(id: String) {
		let parts = id.split(separator: Self.partJoiner)

		let id: String? = if let id = parts[safe: 0] { String(id) } else { nil }
		guard let id else { return nil }

		let name: String? = if let name = parts[safe: 1] { String(name) } else { nil }
		let image: String? = if let image = parts[safe: 2] { String(image) } else { nil }
		let associationID: String? = if let associationID = parts[safe: 3] { String(associationID) } else { nil }

		self.init(
			id: id,
			name: name,
			image: image,
			associationID: associationID
		)
	}
}

// MARK: - IntentContainer+Equatable

extension IntentContainer: Equatable {
	static func == (lhs: IntentContainer, rhs: IntentContainer) -> Bool {
		lhs._id == rhs._id &&
		lhs.name == rhs.name &&
		lhs.image == rhs.image &&
		lhs.containerState == rhs.containerState &&
		lhs.status == rhs.status &&
		lhs.associationID == rhs.associationID
	}
}

// MARK: - IntentContainer+Static

extension IntentContainer {
	static func preview(
		id: String = "PreviewContainerID",
		name: String = String(localized: "IntentContainer.Preview.Name")
	) -> Self {
		.init(id: id, name: name, image: nil, associationID: nil)
	}
}

// MARK: - IntentContainer+matchesContainer

extension IntentContainer {
	func matchesContainer(_ container: Container) -> Bool {
		self._id == container.id ||
		(self.associationID != nil && self.associationID == container.associationID) ||
		self.image == container.image ||
		self.name == container.displayName
	}
}

// MARK: - IntentContainer+IntentContainerQuery

extension IntentContainer {
	struct IntentContainerQuery: EntityStringQuery {
		typealias Entity = IntentContainer

		#if TARGET_WIDGETS
		@IntentParameterDependency<ContainerStatusWidget.Intent>(\.$endpoint, \.$resolveByName)
		var containerStatusWidgetIntent
		#else
		@IntentParameterDependency<ContainerActionIntent>(\.$endpoint)
		var containerActionIntent

		@IntentParameterDependency<ContainerStatusIntent>(\.$endpoint, \.$resolveByName)
		var containerStatusIntent
		#endif

		private var endpoint: IntentEndpoint? {
			#if TARGET_WIDGETS
			containerStatusWidgetIntent?.endpoint
			#else
			containerActionIntent?.endpoint ?? containerStatusIntent?.endpoint
			#endif
		}

		private var resolveByName: Bool {
			#if TARGET_WIDGETS
			containerStatusWidgetIntent?.resolveByName ?? true
			#else
			containerStatusIntent?.resolveByName ?? true
			#endif
		}

		private var requiresOnline: Bool {
			#if TARGET_WIDGETS
			false
			#else
			containerActionIntent != nil
			#endif
		}

		func suggestedEntities() async throws -> [Entity] {
			logger.info("Getting suggested entities...")

			do {
				guard let endpoint else {
					logger.notice("Returning empty (no endpoint)")
					return []
				}

				let portainerStore = IntentPortainerStore.shared
				try portainerStore.setupIfNeeded()
				let entities = try await portainerStore.portainer.fetchContainers(endpointID: endpoint.id)
					.map { Entity(container: $0) }
					.localizedSorted(by: \.name)

				logger.notice("Returning \(entities.count) entities (\(requiresOnline ? "live" : "parsed"))")
				return entities
			} catch {
				logger.error("Error getting suggested entities: \(error.localizedDescription, privacy: .public)")
				throw error
			}
		}

		func entities(matching string: String) async throws -> [Entity] {
			logger.info("Getting entities matching \"\(string, privacy: .sensitive)\"...")

			do {
				guard let endpoint else {
					logger.notice("Returning empty (no endpoint)")
					return []
				}

				let portainerStore = IntentPortainerStore.shared
				try portainerStore.setupIfNeeded()
				let entities = try await portainerStore.portainer.fetchContainers(endpointID: endpoint.id)
					.filter(string)
					.map { Entity(container: $0) }
					.localizedSorted(by: \.name)

				logger.notice("Returning \(entities.count) entities (\(requiresOnline ? "live" : "parsed"))")
				return entities
			} catch {
				logger.error("Error getting matching entities: \(error.localizedDescription, privacy: .public)")
				throw error
			}
		}

		func entities(for identifiers: [Entity.ID]) async throws -> [Entity] {
			logger.info("Getting entities for identifiers: \(String(describing: identifiers), privacy: .sensitive)...")

			guard let endpoint else {
				logger.notice("Returning empty (no endpoint)")
				return []
			}

			let parsedContainers = identifiers.compactMap { Entity(id: $0) }

			do {
				let entities: [Entity] = try await {
					if requiresOnline {
						let portainerStore = IntentPortainerStore.shared
						try portainerStore.setupIfNeeded()

						let filters = FetchFilters(
							id: resolveByName ? nil : parsedContainers.map(\._id)
						)
						return try await portainerStore.portainer.fetchContainers(endpointID: endpoint.id, filters: filters)
							.filter { container in
								if resolveByName {
									return parsedContainers.contains { $0.matchesContainer(container) }
								} else {
									return parsedContainers.contains { $0._id == container.id }
								}
							}
							.compactMap { container in
								let entity = Entity(container: container)
								return entity
							}
					} else {
						return parsedContainers
					}
				}()

				logger.notice("Returning \(entities.count) entities (\(requiresOnline ? "live" : "parsed"))")
				return entities
					.localizedSorted(by: \.name)
			} catch {
				logger.error("Error getting entities: \(error.localizedDescription, privacy: .public)")

				if !requiresOnline && error is URLError {
					logger.notice("Returning \(String(describing: parsedContainers), privacy: .sensitive) (offline)")
					return parsedContainers
				}

				throw error
			}
		}
	}
}
