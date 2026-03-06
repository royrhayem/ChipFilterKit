#if canImport(SwiftUI)
import SwiftUI

/// Horizontal chip bar that presents per-filter sheets and a full filters screen.
public struct ChipFilterBar<Item>: View {
    @Bindable private var store: FilterStore<Item>
    public let style: FilterStyle

    @State private var selectedDefinition: FilterDefinition<Item>?
    @State private var showsFullFilters = false

    public init(
        store: FilterStore<Item>,
        style: FilterStyle = .default
    ) {
        self.store = store
        self.style = style
    }

    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                FilterChip(
                    title: store.activeFilterCount > 0 ? "Filters (\(store.activeFilterCount))" : "Filters",
                    isActive: store.activeFilterCount > 0,
                    iconSystemName: "line.3.horizontal.decrease",
                    style: style
                ) {
                    showsFullFilters = true
                }

                ForEach(store.visibleDefinitions) { definition in
                    FilterChip(
                        title: store.summary(for: definition),
                        isActive: !store.selectedOptionIDs(for: definition.id).isEmpty,
                        style: style
                    ) {
                        selectedDefinition = definition
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .sheet(item: $selectedDefinition) { definition in
            FilterOptionsSheet(store: store, definition: definition, style: style) {
                selectedDefinition = nil
            }
        }
        .sheet(isPresented: $showsFullFilters, content: {
            FiltersScreen(store: store, style: style)
                .presentationDetents([.large])
        })
    }
}

#endif
