//
//  ErrorView.swift
//  HarbourWidgets
//
//  Created by royal on 11/06/2023.
//  Copyright © 2023 shameful. All rights reserved.
//

import SwiftUI
import WidgetKit

// MARK: - ErrorView

struct ErrorView: View {
	let error: Error

	var body: some View {
		Text(verbatim: error.localizedDescription)
			.font(.body)
			.fontDesign(.monospaced)
			.foregroundStyle(.secondary)
			.multilineTextAlignment(.center)
			.lineLimit(nil)
			.minimumScaleFactor(0.7)
			.frame(maxWidth: .infinity, maxHeight: .infinity)
			.padding()
			.containerBackground(for: .widget) {
				Color.widgetBackground
			}
	}
}

// MARK: - Previews

#Preview {
	ErrorView(error: GenericError.invalidURL)
}
