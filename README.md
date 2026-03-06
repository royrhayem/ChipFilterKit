# ChipFilterKit

ChipFilterKit is a reusable SwiftUI package for building chip-based filtering UX with a full filters flow.

It includes:
- A horizontal chip bar with a leading filters button
- Per-filter bottom sheet pickers
- A complete full-screen filters flow with drill-down screens
- Immediate and deferred apply modes
- A generic filtering engine for arbitrary `Item` models

## Requirements

- iOS 18+
- Swift Package Manager
- Swift 6 toolchain (or modern Swift supported by current Xcode)

## Installation (Swift Package Manager)

Add this package dependency in Xcode or `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/your-org/ChipFilterKit.git", from: "1.0.0")
]
```

Then add `ChipFilterKit` to your target dependencies.

## Quick Start

```swift
import SwiftUI
import ChipFilterKit

struct Product: Identifiable {
    let id = UUID()
    let category: String
    let brand: String
    let inStock: Bool
}

@MainActor
func makeStore(products: [Product]) -> FilterStore<Product> {
    let definitions: [FilterDefinition<Product>] = [
        FilterDefinition(
            id: "category",
            title: "Category",
            selectionMode: .single,
            optionsProvider: { items in
                Set(items.map(\.category)).sorted().map { FilterOption(id: $0, label: $0) }
            },
            matcher: { item, selected in selected.contains(item.category) }
        ),
        FilterDefinition(
            id: "brand",
            title: "Brand",
            selectionMode: .multiple,
            optionsProvider: { items in
                Set(items.map(\.brand)).sorted().map { FilterOption(id: $0, label: $0) }
            },
            matcher: { item, selected in selected.contains(item.brand) }
        )
    ]

    return FilterStore(items: products, definitions: definitions, applyMode: .deferred)
}

struct ProductsView: View {
    @State private var store = makeStore(products: sampleProducts)

    var body: some View {
        VStack(spacing: 0) {
            ChipFilterBar(store: store)
            List(store.filteredItems) { product in
                Text("\(product.category) • \(product.brand)")
            }
        }
    }
}
```

## Defining Filters

Each `FilterDefinition<Item>` includes:
- `id`, `title`, optional `subtitle`
- `selectionMode` (`.single` or `.multiple`)
- `optionsProvider` to generate options from your data
- `matcher` to evaluate if an item matches selected options
- optional `summaryFormatter`
- optional `optionsSorter`

## Rendering the Chip Bar

Use `ChipFilterBar(store:)` for the default experience. It automatically:
- shows a leading filters chip
- opens bottom sheets when category chips are tapped
- opens `FiltersScreen` from the leading chip

## Accessing State

`FilterStore<Item>` exposes:
- `filteredItems`: items after applying active criteria
- `selectedCriteria`: committed criteria
- `activeFilterCount`: active filters in current editing mode


## MVVM Integration (Store Owned by a ViewModel)

If your app follows MVVM, keep `FilterStore` in your `ObservableObject` (or `@Observable`) view model and bind the view to that model.

```swift
import SwiftUI
import Observation
import ChipFilterKit

struct User: Identifiable {
    let id = UUID()
    let name: String
    let gender: String
    let country: String
    let role: String
}

@MainActor
@Observable
final class UsersViewModel {
    private let allUsers: [User]
    let filterStore: FilterStore<User>

    init(users: [User]) {
        self.allUsers = users

        let definitions: [FilterDefinition<User>] = [
            FilterDefinition(
                id: "gender",
                title: "Gender",
                selectionMode: .multiple,
                optionsProvider: { items in
                    Set(items.map(\.gender)).sorted().map { FilterOption(id: $0, label: $0) }
                },
                matcher: { item, selected in selected.contains(item.gender) }
            ),
            FilterDefinition(
                id: "country",
                title: "Country",
                selectionMode: .single,
                optionsProvider: { items in
                    Set(items.map(\.country)).sorted().map { FilterOption(id: $0, label: $0) }
                },
                matcher: { item, selected in selected.contains(item.country) }
            ),
            FilterDefinition(
                id: "role",
                title: "Role",
                selectionMode: .multiple,
                optionsProvider: { items in
                    Set(items.map(\.role)).sorted().map { FilterOption(id: $0, label: $0) }
                },
                matcher: { item, selected in selected.contains(item.role) }
            )
        ]

        self.filterStore = FilterStore(
            items: allUsers,
            definitions: definitions,
            applyMode: .deferred
        )
    }

    var visibleUsers: [User] {
        filterStore.filteredItems
    }
}

struct UsersScreen: View {
    @State private var viewModel = UsersViewModel(users: mockUsers)

    var body: some View {
        VStack(spacing: 0) {
            ChipFilterBar(store: viewModel.filterStore)

            List(viewModel.visibleUsers) { user in
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
```

Notes:
- Use `.immediate` when the list should react instantly to each tap.
- Use `.deferred` when you want staged edits in sheets/screens and apply on confirmation.
- Read `viewModel.filterStore.selectedCriteria`, `viewModel.filterStore.filteredItems`, and `viewModel.filterStore.activeFilterCount` anywhere in your view model or view.

## Immediate vs Deferred

- `.immediate`: selecting options updates `filteredItems` instantly.
- `.deferred`: selections are staged until `applyStagedChanges()` (the full filters UI handles this with an Apply action).

## Demo / Previews

The package includes SwiftUI previews for:
- Crash feedback-style data (`platform`, `appVersion`, `osVersion`, `device`)
- User data (`gender`, `country`, `role`)
