//
//  PortainerStore+Preview.swift
//  Harbour
//
//  Created by royal on 10/04/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import Foundation

extension PortainerStore {
	static let preview: PortainerStore = {
		let portainerStore = PortainerStore()
		portainerStore.isSetup = true
		portainerStore.endpoints = [.init(id: 0, name: "Endpoint")]
		portainerStore.selectedEndpoint = portainerStore.endpoints.first
		portainerStore.endpointsTask?.cancel()
		portainerStore.containersTask?.cancel()
		portainerStore.stacksTask?.cancel()
		portainerStore.containers = [
			.preview(id: "1", name: "Container1"),
			.preview(id: "2", name: "Container2")
		]
		return portainerStore
	}()
}
