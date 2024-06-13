//
//  AppDelegate+UNUserNotificationCenterDelegate.swift
//  Harbour
//
//  Created by royal on 30/03/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import PortainerKit
@preconcurrency import UserNotifications

extension AppDelegate: UNUserNotificationCenterDelegate {
	nonisolated func userNotificationCenter(
		_ center: UNUserNotificationCenter,
		willPresent notification: UNNotification,
		withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
	) {
		completionHandler([.banner, .list, .sound])
	}

	nonisolated func userNotificationCenter(
		_ center: UNUserNotificationCenter,
		didReceive response: UNNotificationResponse,
		withCompletionHandler completionHandler: @escaping () -> Void
	) {
		Task { @MainActor in
			AppState.shared.handleNotification(response)
		}

		completionHandler()
	}
}
