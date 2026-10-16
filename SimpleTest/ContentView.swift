import SwiftUI
import UIKit

/// Temporary preview sheet to display share text content
struct SharePreviewSheet: View {
    let shareText: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Share Results")
                        .font(.headline)
                    Spacer()
                }
                .padding(.horizontal)

                Text("Preview of text that would be shared:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)

                ScrollView {
                    Text(shareText)
                        .font(.body)
                        .padding()
                }
                .background(Color(.systemGroupedBackground))
                .cornerRadius(10)
                .padding()

                Button(action: {
                    UIPasteboard.general.string = shareText
                }) {
                    Label("Copy to Clipboard", systemImage: "doc.on.doc")
                }
                .buttonStyle(.borderedProminent)
                .padding()
            }
            .navigationTitle("Share Results")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

/// SwiftUI wrapper for UIActivityViewController
struct ActivityView: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)

        // Exclude activities that don't make sense for calculation results
        // Messages, Mail, Notes, Save to Files, and Copy to Clipboard appear by default
        activityVC.excludedActivityTypes = [
            .print,
            .assignToContact,
            .openInIBooks,
            .postToVimeo,
            .postToFacebook,
            .postToTwitter,
            .postToWeibo,
            .saveToCameraRoll
        ]

        return activityVC
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No updates needed - items are set on creation
    }
}

struct ContentView: View {

    @State private var path: [AppRoute] = []

    // Use dependency injection for profile - @State for reference types with @Observable
    @State private var profile: ProfileViewModel

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var isShareSheetPresented = false
    @State private var shareText: String = ""

    init() {
        // Initialize with the shared repository for persistence
        let repository = SwiftDataContainer.shared.profileRepository
        self._profile = State(initialValue: ProfileViewModel(profileRepository: repository))
    }

    var body: some View {

        NavigationStack(path: $path) {

            UIMainView(profile: $profile, path: $path) { shareText in
                self.shareText = shareText
                isShareSheetPresented = true
            }

                .navigationTitle(
                    horizontalSizeClass == .compact
                        ? "TDEE"
                        : "Total Daily Energy Expenditure"
                )

                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            path.append(.system)
                        } label: {
                            Image(systemName: "line.3.horizontal")
                        }
                        .accessibilityLabel("Open navigation menu")
                    }
                }

                .toolbarBackground(.visible, for: .navigationBar)
                .toolbarTitleDisplayMode(.inline)
                .navigationBarTitleDisplayMode(.inline)

                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .system:
                        UISystemPageView(path: $path)
                    case .maintainMacroConfig:
                        MacroOptionsListViewPage(path: $path, selectedMacroId: $profile.selectedMacroId)
                    case .theme:
                        ThemeView()
                    case .about:
                        AboutPage()
                    case .macroEditorCreate:
                        MacroEditViewPage(item: nil, onDismissAll: nil)
                    case .macroEditorEdit(let item):
                        // For editing, clear the path to go back to main screen
                        MacroEditViewPage(item: item, onDismissAll: { path.removeAll() })
                    }
                }
        }
        // Inject the global macro collection for environment access
        .environment(MacroSplitOptionsModelCollection(items: FactoryMacroSplits.get()))
        .sheet(isPresented: $isShareSheetPresented) {
            SharePreviewSheet(shareText: shareText)
        }
    }
}

#Preview {
    ContentView()
}
