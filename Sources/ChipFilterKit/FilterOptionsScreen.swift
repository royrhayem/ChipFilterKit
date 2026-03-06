#if canImport(SwiftUI)
import SwiftUI

/// Full-page selector used by the complete filters flow.
public struct FilterOptionsScreen<Item>: View {
    @Bindable private var store: FilterStore<Item>
    public let definition: FilterDefinition<Item>
    public let style: FilterStyle

    public init(
        store: FilterStore<Item>,
        definition: FilterDefinition<Item>,
        style: FilterStyle = .default
    ) {
        self.store = store
        self.definition = definition
        self.style = style
    }

    public var body: some View {
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
            } footer: {
                Button("Reset \(definition.title)") {
                    store.reset(filterID: definition.id)
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(style.chipActiveForeground)
                .padding(.top, 8)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(definition.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#endif
