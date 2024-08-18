//
//  HarbourUserActivityIdentifier.swift
//  Harbour
//
//  Created by royal on 30/09/2022.
//  Copyright © 2023 shameful. All rights reserved.
//

import Foundation

// swiftlint:disable force_unwrapping

enum HarbourUserActivityIdentifier {
	static let containerDetails = "\(Bundle.main.mainBundleIdentifier ?? Bundle.main.bundleIdentifier!).ContainerDetailsActivity"
	static let stackDetails = "\(Bundle.main.mainBundleIdentifier ?? Bundle.main.bundleIdentifier!).StackDetailsActivity"
}

// swiftlint:enable force_unwrapping
