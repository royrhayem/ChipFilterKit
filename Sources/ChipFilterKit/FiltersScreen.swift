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
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    ForEach(store.definitions) { definition in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(definition.title)
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(style.rowTitleColor)

                            if let subtitle = definition.subtitle {
                                Text(subtitle)
                                    .font(.body)
                                    .foregroundStyle(style.rowSubtitleColor)
                            }

                            NavigationLink {
                                FilterOptionsScreen(store: store, definition: definition, style: style)
                            } label: {
                                HStack {
                                    Text(store.summary(for: definition))
                                        .foregroundStyle(style.rowTitleColor)
                                    Spacer()
                                    if store.selectedOptionIDs(for: definition.id).isEmpty == false {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(style.chipActiveForeground)
                                    } else {
                                        Image(systemName: "chevron.right")
                                            .foregroundStyle(style.rowSubtitleColor)
                                    }
                                }
                                .font(.title3.weight(.medium))
                                .padding(.horizontal, 18)
                                .padding(.vertical, 16)
                                .background(style.cardColor)
                                .clipShape(RoundedRectangle(cornerRadius: style.cornerRadius, style: .continuous))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(20)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        if store.applyMode == .deferred {
                            store.discardStagedChanges()
                        }
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }

                ToolbarItem(placement: .principal) {
                    Text("Filters")
                        .font(.title3.weight(.semibold))
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
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        }
        .filterScreenBackground(style)
    }
}

#endif
