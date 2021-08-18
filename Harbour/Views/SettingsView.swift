//
//  SettingsView.swift
//  Harbour
//
//  Created by unitears on 11/06/2021.
//

import SwiftUI

struct SettingsView: View {
	@EnvironmentObject var portainer: Portainer
	@EnvironmentObject var preferences: Preferences
	@State private var isLogoutWarningPresented: Bool = false
	@State private var isLoginSheetPresented: Bool = false
	
	var portainerSection: some View {
		Section(header: Text("Portainer")) {
			if let endpointURL = portainer.endpointURL {
				Labeled(label: "URL", content: endpointURL, monospace: true)
			}
			
			if portainer.isLoggedIn {
				Button("Log out", role: .destructive) {
					UIDevice.current.generateHaptic(.warning)
					isLogoutWarningPresented = true
				}
				.alert(isPresented: $isLogoutWarningPresented) {
					Alert(
						title: Text("Are you sure?"),
						primaryButton: .destructive(Text("Yes"), action: {
							UIDevice.current.generateHaptic(.heavy)
							withAnimation { portainer.logOut() }
						}),
						secondaryButton: .cancel()
					)
				}
			} else {
				Button("Log in") {
					UIDevice.current.generateHaptic(.soft)
					isLoginSheetPresented = true
				}
			}
		}
		.animation(.easeInOut, value: portainer.isLoggedIn)
		.animation(.easeInOut, value: portainer.endpointURL)
		.transition(.opacity)
	}
	
	var interfaceSection: some View {
		Section(header: Text("Interface")) {
			ToggleOption(label: "%SETTINGS_CONTAINER_DISCONNECTED_PROMPT_TITLE%", description: "%SETTINGS_CONTAINER_DISCONNECTED_PROMPT_DESCRIPTION%", isOn: $preferences.displayContainerDismissedPrompt)
			ToggleOption(label: "%SETTINGS_ENABLE_HAPTICS_TITLE%", description: "%SETTINGS_ENABLE_HAPTICS_DESCRIPTION%", isOn: $preferences.enableHaptics)
		}
	}
	
	var madeWithLove: some View {
		VStack(spacing: 3) {
			Text("Harbour v\(Bundle.main.buildVersion) (#\(Bundle.main.buildNumber))")
				.font(.subheadline.weight(.semibold))
				.foregroundColor(.secondary)
				.opacity(Globals.Views.secondaryOpacity)
			
			Link(destination: URL(string: "https://github.com/rrunitears/Harbour")!) {
				Text("Made with ❤️ (and ☕️) by @rrunitears")
					.font(.subheadline.weight(.semibold))
					.foregroundColor(.secondary)
					.opacity(Globals.Views.secondaryOpacity)
			}
		}
		.frame(maxWidth: .infinity, alignment: .center)
		.padding(.vertical)
	}
	
	var otherSection: some View {
		Section(header: Text("Other"), footer: madeWithLove) {
			NavigationLink("🤫") {
				DebugView()
			}
		}
	}
	
	var body: some View {
		NavigationView {
			Form {
				portainerSection
				interfaceSection
				otherSection
			}
			.navigationTitle("Settings")
		}
		.sheet(isPresented: $isLoginSheetPresented) {
			LoginView()
		}
	}
}

fileprivate extension SettingsView {
	struct ToggleOption: View {
		let label: String
		let description: String?
		@Binding var isOn: Bool
		
		var body: some View {
			Toggle(isOn: $isOn) {
				VStack(alignment: .leading, spacing: 4) {
					Text(LocalizedStringKey(label))
						.font(.headline)
						.frame(maxWidth: .infinity, alignment: .leading)
					
					if let description = description {
						Text(LocalizedStringKey(description))
							.font(.subheadline)
							.foregroundStyle(.secondary)
							.frame(maxWidth: .infinity, alignment: .leading)
					}
				}
			}
			.toggleStyle(SwitchToggleStyle(tint: .accentColor))
			.padding(.vertical, .small)
		}
	}
}

struct SettingsView_Previews: PreviewProvider {
	static var previews: some View {
		SettingsView()
	}
}
