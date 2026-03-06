#if canImport(SwiftUI)
import SwiftUI

/// Full-page filter management experience with drill-down screens.
public struct FiltersScreen<Item>: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable private var store: FilterStore<Item>
    public let style: FilterStyle

    public init(
        store: FilterStore<Item>,
        style: FilterStyle = .default
    ) {
        self.store = store
        self.style = style
    }

    public var body: some View {
        NavigationStack {
            List {
                ForEach(store.definitions) { definition in
                    Section {
                        NavigationLink {
                            FilterOptionsScreen(store: store, definition: definition, style: style)
                        } label: {
                            LabeledContent {
                                Text(store.summary(for: definition))
                                    .foregroundStyle(style.rowSubtitleColor)
                            } label: {
                                Text(definition.title)
                                    .font(.body)
                                    .foregroundStyle(style.rowTitleColor)
                            }
                        }
                    } header: {
                        if let subtitle = definition.subtitle {
                            Text(subtitle)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        if store.applyMode == .deferred {
                            store.discardStagedChanges()
                        }
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }

                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button {
                        store.resetAll()
                        if store.applyMode == .deferred {
                            store.applyStagedChanges()
                        }
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                    }

                    if store.applyMode == .deferred {
                        Button {
                            store.applyStagedChanges()
                            dismiss()
                        } label: {
                            Text("Apply")
                                .font(.subheadline.weight(.semibold))
                        }
                    }
                }
            }
        }
    }
}

#endif
