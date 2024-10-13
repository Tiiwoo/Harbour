//
//  PortainerError.swift
//  Harbour
//
//  Created by royal on 23/09/2022.
//  Copyright © 2023 shameful. All rights reserved.
//

import Foundation
import PortainerKit

// MARK: - PortainerError

enum PortainerError: Error {
	/// `Portainer` isn't setup.
	case notSetup

	/// No server is stored.
	case noServer

	/// No endpoint is selected.
	case noSelectedEndpoint

	/// Container with specified ID hasn't been found
	case containerNotFound(Container.ID)
}

// MARK: - PortainerError+LocalizedError

extension PortainerError: LocalizedError {
	var errorDescription: String? {
		switch self {
		case .notSetup:
			String(localized: "Error.Portainer.NotSetup.ErrorDescription")
		case .noServer:
			String(localized: "Error.Portainer.NoServer.ErrorDescription")
		case .noSelectedEndpoint:
			String(localized: "Error.Portainer.NoSelectedEndpoint.ErrorDescription")
		case .containerNotFound(let containerID):
			String(localized: "Error.Portainer.ContainerNotFound ID:\(containerID)")
		}
	}

	var recoverySuggestion: String? {
		switch self {
		case .notSetup:
			String(localized: "Error.Portainer.NotSetup.RecoverySuggestion")
		case .noServer:
			String(localized: "Error.Portainer.NoServer.RecoverySuggestion")
		case .noSelectedEndpoint:
			String(localized: "Error.Portainer.NoSelectedEndpoint.RecoverySuggestion")
		case .containerNotFound:
			nil
		}
	}
}
