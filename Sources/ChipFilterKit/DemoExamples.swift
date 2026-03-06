#if canImport(SwiftUI)
import SwiftUI

#if DEBUG

private struct CrashFeedback: Identifiable {
    let id = UUID()
    let reporter: String
    let platform: String
    let appVersion: String
    let osVersion: String
    let device: String
}

private struct UserRecord: Identifiable {
    let id = UUID()
    let name: String
    let gender: String
    let country: String
    let role: String
}

private struct CrashFeedbackDemoView: View {
    @State private var store = FilterStore(
        items: [
            CrashFeedback(reporter: "Jessy Dahdouh", platform: "iOS", appVersion: "4.27.0", osVersion: "18.6.1", device: "iPhone 15 Pro Max"),
            CrashFeedback(reporter: "Alex Rivera", platform: "Android", appVersion: "4.27.0", osVersion: "15", device: "Pixel 8"),
            CrashFeedback(reporter: "Sam Lee", platform: "iOS", appVersion: "4.25.0", osVersion: "18.0", device: "iPad mini"),
            CrashFeedback(reporter: "Ivy Chen", platform: "iOS", appVersion: "4.23.0", osVersion: "18.3.2", device: "iPhone 14")
        ],
        definitions: CrashFeedbackDemoView.definitions,
        applyMode: .deferred
    )

    private static let definitions: [FilterDefinition<CrashFeedback>] = [
        FilterDefinition(
            id: "platform",
            title: "Platform",
            subtitle: "The platform the app was compiled for.",
            selectionMode: .single,
            optionsProvider: { items in
                Set(items.map(\.platform)).sorted().map { FilterOption(id: $0, label: $0) }
            },
            matcher: { item, selectedIDs in selectedIDs.contains(item.platform) }
        ),
        FilterDefinition(
            id: "appVersion",
            title: "App Version",
            selectionMode: .multiple,
            optionsProvider: { items in
                Set(items.map(\.appVersion)).sorted(by: >).map { FilterOption(id: $0, label: "iOS App \($0)") }
            },
            matcher: { item, selectedIDs in selectedIDs.contains(item.appVersion) },
            summaryFormatter: { title, selected in selected.isEmpty ? title : "\(title) (\(selected.count))" }
        ),
        FilterDefinition(
            id: "osVersion",
            title: "OS Version",
            subtitle: "The platform and version the app ran on.",
            selectionMode: .multiple,
            optionsProvider: { items in
                Set(items.map(\.osVersion)).sorted(by: >).map { FilterOption(id: $0, label: "iOS \($0)") }
            },
            matcher: { item, selectedIDs in selectedIDs.contains(item.osVersion) }
        ),
        FilterDefinition(
            id: "device",
            title: "Device",
            selectionMode: .multiple,
            optionsProvider: { items in
                Set(items.map(\.device)).sorted().map { FilterOption(id: $0, label: $0) }
            },
            matcher: { item, selectedIDs in selectedIDs.contains(item.device) }
        )
    ]

    var body: some View {
        VStack(spacing: 0) {
            ChipFilterBar(store: store)
            List(store.filteredItems) { feedback in
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(feedback.reporter).bold()
                        Spacer()
                        Text("\(feedback.platform) • \(feedback.osVersion)")
                            .foregroundStyle(.secondary)
                    }
                    Text("\(feedback.appVersion) • \(feedback.device)")
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }
            .listStyle(.plain)
        }
        .background(Color(.systemGray6))
    }
}

private struct UsersDemoView: View {
    @State private var store = FilterStore(
        items: [
            UserRecord(name: "Sofia", gender: "Female", country: "US", role: "Admin"),
            UserRecord(name: "Mason", gender: "Male", country: "CA", role: "Editor"),
            UserRecord(name: "Ari", gender: "Non-binary", country: "US", role: "Viewer"),
            UserRecord(name: "Luca", gender: "Male", country: "DE", role: "Admin")
        ],
        definitions: UsersDemoView.definitions,
        applyMode: .immediate
    )

    private static let definitions: [FilterDefinition<UserRecord>] = [
        FilterDefinition(
            id: "gender",
            title: "Gender",
            selectionMode: .multiple,
            optionsProvider: { items in Set(items.map(\.gender)).sorted().map { FilterOption(id: $0, label: $0) } },
            matcher: { item, selected in selected.contains(item.gender) }
        ),
        FilterDefinition(
            id: "country",
            title: "Country",
            selectionMode: .single,
            optionsProvider: { items in Set(items.map(\.country)).sorted().map { FilterOption(id: $0, label: $0) } },
            matcher: { item, selected in selected.contains(item.country) }
        ),
        FilterDefinition(
            id: "role",
            title: "Role",
            selectionMode: .multiple,
            optionsProvider: { items in Set(items.map(\.role)).sorted().map { FilterOption(id: $0, label: $0) } },
            matcher: { item, selected in selected.contains(item.role) }
        )
    ]

    var body: some View {
        VStack(spacing: 0) {
            ChipFilterBar(store: store)
            List(store.filteredItems) { user in
                VStack(alignment: .leading, spacing: 4) {
                    Text(user.name).bold()
                    Text("\(user.role) • \(user.country) • \(user.gender)")
                        .foregroundStyle(.secondary)
                }
            }
            .listStyle(.plain)
        }
    }
}

#Preview("Crash feedback demo") {
    CrashFeedbackDemoView()
}

#Preview("Users demo") {
    UsersDemoView()
}

#endif

#endif
