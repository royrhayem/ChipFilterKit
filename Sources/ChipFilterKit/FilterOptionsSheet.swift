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
        VStack(spacing: 16) {
            Capsule()
                .fill(Color.secondary.opacity(0.35))
                .frame(width: 48, height: 6)
                .padding(.top, 8)

            CenteredHeaderBar(title: definition.title) {
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.title3)
                        .frame(width: 42, height: 42)
                        .background(style.chipInactiveBackground)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            } trailing: {
                Button {
                    store.reset(filterID: definition.id)
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.title3)
                        .frame(width: 42, height: 42)
                        .background(style.chipInactiveBackground)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)

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
            .padding(.horizontal, 20)

            Spacer(minLength: 0)
        }
        .padding(.bottom, 20)
        .filterScreenBackground(style)
        .presentationDetents([.fraction(0.46), .large])
    }
}

#endif
