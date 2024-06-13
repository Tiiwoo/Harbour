//
//  Keychain+shared.swift
//  Harbour
//
//  Created by royal on 25/05/2023.
//  Copyright © 2023 shameful. All rights reserved.
//

import Foundation
@preconcurrency import KeychainKit

// MARK: - Keychain+shared

extension Keychain {
	static let shared: Keychain = {
		// swiftlint:disable:next force_unwrapping
		let keychain = Keychain(accessGroup: Bundle.main.groupIdentifier!)
//		keychain.applicationTagPrefix = Bundle.main.mainBundleIdentifier
		return keychain
	}()
}

// MARK: - Keychain+itemDescription

extension Keychain {
	static let tokenItemDescription = "Harbour - Token"
}

// MARK: - Keychain+URL

extension Keychain {
	@inlinable
	func setString(_ string: String, for url: URL, itemDescription: String? = nil) throws {
		try setString(string, for: url.absoluteString, itemDescription: itemDescription)
	}

	@inlinable
	func getString(for url: URL) throws -> String {
		try getString(for: url.absoluteString)
	}

	@inlinable
	func removeContent(for url: URL) throws {
		try removeContent(for: url.absoluteString)
	}
}
