#if canImport(SwiftUI)
import SwiftUI

/// Bottom sheet for selecting options for a single filter definition.
public struct FilterOptionsSheet<Item>: View {
    @Bindable private var store: FilterStore<Item>
    public let definition: FilterDefinition<Item>
    public let style: FilterStyle
    public let onClose: () -> Void

    public init(
        store: FilterStore<Item>,
        definition: FilterDefinition<Item>,
        style: FilterStyle = .default,
        onClose: @escaping () -> Void
    ) {
        self.store = store
        self.definition = definition
        self.style = style
        self.onClose = onClose
    }

    public var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(store.options(for: definition)) { option in
                        Button {
                            store.setSelection(
                                filterID: definition.id,
                                optionID: option.id,
                                mode: definition.selectionMode
                            )
                        } label: {
                            HStack(spacing: 10) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(option.label)
                                        .foregroundStyle(style.rowTitleColor)
                                        .font(.body)
                                    if let secondary = option.secondaryLabel {
                                        Text(secondary)
                                            .foregroundStyle(style.rowSubtitleColor)
                                            .font(.footnote)
                                    }
                                }
                                Spacer()
                                if store.isOptionSelected(filterID: definition.id, optionID: option.id) {
                                    Image(systemName: "checkmark")
                                        .font(.headline)
                                        .foregroundStyle(style.chipActiveForeground)
                                }
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(.ultraThinMaterial)
            .navigationTitle(definition.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        onClose()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.secondary)
                            .font(.title2)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        store.reset(filterID: definition.id)
                    } label: {
                        Text("Reset")
                            .font(.subheadline)
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(20)
        .presentationBackground(.ultraThinMaterial)
    }
}

#endif
