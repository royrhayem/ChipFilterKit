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
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                RoundedOptionsCard(
                    options: store.options(for: definition),
                    isSelected: { option in
                        store.isOptionSelected(filterID: definition.id, optionID: option.id)
                    },
                    onSelect: { option in
                        store.setSelection(filterID: definition.id, optionID: option.id, mode: definition.selectionMode)
                    },
                    style: style
                )

                Button("Reset \(definition.title)") {
                    store.reset(filterID: definition.id)
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(style.chipActiveForeground)
                .padding(.horizontal, 4)
            }
            .padding(.horizontal, 20)
            .padding(.top, 14)
        }
        .navigationTitle(definition.title)
        .navigationBarTitleDisplayMode(.inline)
        .filterScreenBackground(style)
    }
}

#endif
