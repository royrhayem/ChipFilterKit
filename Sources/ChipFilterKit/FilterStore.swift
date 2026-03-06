import Foundation
import Observation

/// Observable state and actions for reusable chip-based filtering.
@Observable
public final class FilterStore<Item> {
    public let items: [Item]
    public let definitions: [FilterDefinition<Item>]
    public let applyMode: FilterApplyMode

    public private(set) var selectedCriteria: FilterCriteria
    public private(set) var stagedCriteria: FilterCriteria
    public private(set) var filteredItems: [Item]

    public init(
        items: [Item],
        definitions: [FilterDefinition<Item>],
        applyMode: FilterApplyMode = .immediate,
        initialCriteria: FilterCriteria = .empty
    ) {
        self.items = items
        self.definitions = definitions
        self.applyMode = applyMode
        self.selectedCriteria = initialCriteria
        self.stagedCriteria = initialCriteria
        self.filteredItems = FilterEngine.filteredItems(
            items: items,
            definitions: definitions,
            criteria: initialCriteria
        )
    }

    public var activeFilterCount: Int {
        activeCriteria.activeFiltersCount
    }

    public var activeCriteria: FilterCriteria {
        applyMode == .immediate ? selectedCriteria : stagedCriteria
    }

    public func options(for definition: FilterDefinition<Item>) -> [FilterOption] {
        definition.options(from: items)
    }

    public func selectedOptionIDs(for definitionID: String) -> Set<String> {
        activeCriteria[definitionID].optionIDs
    }

    public func isOptionSelected(filterID: String, optionID: String) -> Bool {
        selectedOptionIDs(for: filterID).contains(optionID)
    }

    public func setSelection(filterID: String, optionID: String, mode: FilterSelectionMode) {
        var criteria = activeCriteria
        var selection = criteria[filterID]

        switch mode {
        case .single:
            if selection.optionIDs == [optionID] {
                selection.optionIDs.removeAll()
            } else {
                selection.optionIDs = [optionID]
            }
        case .multiple:
            if selection.optionIDs.contains(optionID) {
                selection.optionIDs.remove(optionID)
            } else {
                selection.optionIDs.insert(optionID)
            }
        }

        criteria[filterID] = selection
        updateActiveCriteria(criteria)
    }

    public func reset(filterID: String) {
        var criteria = activeCriteria
        criteria.reset(filterID: filterID)
        updateActiveCriteria(criteria)
    }

    public func resetAll() {
        updateActiveCriteria(.empty)
    }

    public func applyStagedChanges() {
        guard applyMode == .deferred else { return }
        selectedCriteria = stagedCriteria
        recalculateFilteredItems()
    }

    public func discardStagedChanges() {
        guard applyMode == .deferred else { return }
        stagedCriteria = selectedCriteria
    }

    public func summary(for definition: FilterDefinition<Item>) -> String {
        let optionLookup = Dictionary(uniqueKeysWithValues: options(for: definition).map { ($0.id, $0) })
        let selected = selectedOptionIDs(for: definition.id).compactMap { optionLookup[$0] }
        return definition.summary(for: selected)
    }

    private func updateActiveCriteria(_ criteria: FilterCriteria) {
        switch applyMode {
        case .immediate:
            selectedCriteria = criteria
            stagedCriteria = criteria
            recalculateFilteredItems()
        case .deferred:
            stagedCriteria = criteria
        }
    }

    private func recalculateFilteredItems() {
        filteredItems = FilterEngine.filteredItems(
            items: items,
            definitions: definitions,
            criteria: selectedCriteria
        )
    }
}
