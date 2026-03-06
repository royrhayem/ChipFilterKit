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
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(definition.title)
                                        .font(.body.weight(.medium))
                                        .foregroundStyle(style.rowTitleColor)
                                    Text(store.summary(for: definition))
                                        .font(.subheadline)
                                        .foregroundStyle(style.rowSubtitleColor)
                                }
                                Spacer()
                                if !store.selectedOptionIDs(for: definition.id).isEmpty {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(style.chipActiveForeground)
                                }
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
            .scrollContentBackground(.hidden)
            .background(.ultraThinMaterial)
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
                        Image(systemName: "xmark.circle.fill")
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.secondary)
                            .font(.title2)
                    }
                }

                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button {
                        store.resetAll()
                        if store.applyMode == .deferred {
                            store.applyStagedChanges()
                        }
                    } label: {
                        Text("Reset")
                            .font(.subheadline)
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
