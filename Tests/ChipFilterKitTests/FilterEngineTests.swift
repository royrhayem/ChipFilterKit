import XCTest
@testable import ChipFilterKit

final class FilterEngineTests: XCTestCase {
    struct Product: Equatable {
        let category: String
        let brand: String
        let inStock: Bool
    }

    let products: [Product] = [
        Product(category: "Phone", brand: "Acme", inStock: true),
        Product(category: "Phone", brand: "Globex", inStock: false),
        Product(category: "Laptop", brand: "Acme", inStock: true),
        Product(category: "Tablet", brand: "Initech", inStock: true)
    ]

    lazy var definitions: [FilterDefinition<Product>] = [
        FilterDefinition(
            id: "category",
            title: "Category",
            selectionMode: .single,
            optionsProvider: { items in
                Set(items.map(\.category)).map { FilterOption(id: $0, label: $0) }
            },
            matcher: { item, selected in selected.contains(item.category) }
        ),
        FilterDefinition(
            id: "brand",
            title: "Brand",
            selectionMode: .multiple,
            optionsProvider: { items in
                Set(items.map(\.brand)).map { FilterOption(id: $0, label: $0) }
            },
            matcher: { item, selected in selected.contains(item.brand) }
        )
    ]

    func testNoFiltersSelectedReturnsAllItems() {
        let output = FilterEngine.filteredItems(items: products, definitions: definitions, criteria: .empty)
        XCTAssertEqual(output, products)
    }

    func testSingleFilterSingleSelect() {
        var criteria = FilterCriteria.empty
        criteria["category"] = FilterSelection(optionIDs: ["Phone"])

        let output = FilterEngine.filteredItems(items: products, definitions: definitions, criteria: criteria)
        XCTAssertEqual(output.count, 2)
        XCTAssertTrue(output.allSatisfy { $0.category == "Phone" })
    }

    func testSingleFilterMultiSelect() {
        var criteria = FilterCriteria.empty
        criteria["brand"] = FilterSelection(optionIDs: ["Acme", "Initech"])

        let output = FilterEngine.filteredItems(items: products, definitions: definitions, criteria: criteria)
        XCTAssertEqual(output.count, 3)
        XCTAssertTrue(output.allSatisfy { ["Acme", "Initech"].contains($0.brand) })
    }

    func testMultipleFiltersCombinedWithAndLogic() {
        var criteria = FilterCriteria.empty
        criteria["category"] = FilterSelection(optionIDs: ["Phone"])
        criteria["brand"] = FilterSelection(optionIDs: ["Acme"])

        let output = FilterEngine.filteredItems(items: products, definitions: definitions, criteria: criteria)
        XCTAssertEqual(output, [products[0]])
    }

    func testResetOneFilter() {
        let store = FilterStore(items: products, definitions: definitions)
        store.setSelection(filterID: "category", optionID: "Phone", mode: .single)
        store.setSelection(filterID: "brand", optionID: "Acme", mode: .multiple)

        store.reset(filterID: "brand")

        XCTAssertEqual(store.selectedOptionIDs(for: "brand"), [])
        XCTAssertEqual(store.filteredItems.count, 2)
    }

    func testResetAllFilters() {
        let store = FilterStore(items: products, definitions: definitions)
        store.setSelection(filterID: "category", optionID: "Phone", mode: .single)
        store.setSelection(filterID: "brand", optionID: "Acme", mode: .multiple)

        store.resetAll()

        XCTAssertEqual(store.filteredItems, products)
        XCTAssertEqual(store.activeFilterCount, 0)
    }

    func testImmediateModeUpdatesResults() {
        let store = FilterStore(items: products, definitions: definitions, applyMode: .immediate)

        store.setSelection(filterID: "category", optionID: "Laptop", mode: .single)

        XCTAssertEqual(store.filteredItems, [products[2]])
    }

    func testDeferredModeStagesUntilApply() {
        let store = FilterStore(items: products, definitions: definitions, applyMode: .deferred)

        store.setSelection(filterID: "category", optionID: "Laptop", mode: .single)
        XCTAssertEqual(store.filteredItems, products)

        store.applyStagedChanges()
        XCTAssertEqual(store.filteredItems, [products[2]])

        store.setSelection(filterID: "category", optionID: "Phone", mode: .single)
        store.discardStagedChanges()
        XCTAssertEqual(store.selectedOptionIDs(for: "category"), ["Laptop"])
    }
}
