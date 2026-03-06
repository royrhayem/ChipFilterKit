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

    /// Cache for options to avoid re-calculating O(N) providers during UI updates.
    private var optionsCache: [String: [FilterOption]] = [:]

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

    /// In deferred mode, we distinguish between the "live" criteria (what the user sees in the list)
    /// and the "working" criteria (what the user is currently editing).
    public var activeCriteria: FilterCriteria {
        applyMode == .immediate ? selectedCriteria : stagedCriteria
    }

    /// Definitions that pass their `visibilityCondition` for the current active criteria.
    /// Definitions without a condition are always included.
    public var visibleDefinitions: [FilterDefinition<Item>] {
        definitions.filter { $0.visibilityCondition?(activeCriteria) ?? true }
    }

    public func options(for definition: FilterDefinition<Item>) -> [FilterOption] {
        if let cached = optionsCache[definition.id] {
            return cached
        }
        let options = definition.options(from: items)
        optionsCache[definition.id] = options
        return options
    }

    public func selectedOptionIDs(for definitionID: String) -> Set<String> {
        activeCriteria[definitionID].optionIDs
    }

    public func isOptionSelected(filterID: String, optionID: String) -> Bool {
        selectedOptionIDs(for: filterID).contains(optionID)
    }

    public func setSelection(filterID: String, optionID: String) {
        // Enforce the mode defined in the definition to prevent invalid state.
        guard let definition = definitions.first(where: { $0.id == filterID }) else { return }
        
        var criteria = activeCriteria
        var selection = criteria[filterID]

        switch definition.selectionMode {
        case .single:
            if selection.optionIDs.count == 1 && selection.optionIDs.contains(optionID) {
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
        // Fix crash by using uniquingKeysWith and improve performance by using cached options.
        let opts = options(for: definition)
        let optionLookup = Dictionary(opts.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        
        let selected = selectedCriteria[definition.id].optionIDs.compactMap { optionLookup[$0] }
        return definition.summary(for: selected)
    }

    private func updateActiveCriteria(_ criteria: FilterCriteria) {
        switch applyMode {
        case .immediate:
            selectedCriteria = clearHiddenSelections(from: criteria)
            stagedCriteria = selectedCriteria
            recalculateFilteredItems()
        case .deferred:
            stagedCriteria = clearHiddenSelections(from: criteria)
        }
    }

    /// Removes selections for any definitions that are hidden under the given criteria,
    /// so hidden filters never silently affect filtered results.
    private func clearHiddenSelections(from criteria: FilterCriteria) -> FilterCriteria {
        let hiddenIDs = definitions
            .filter { !($0.visibilityCondition?(criteria) ?? true) }
            .map(\.id)
        guard !hiddenIDs.isEmpty else { return criteria }
        var cleaned = criteria
        hiddenIDs.forEach { cleaned.reset(filterID: $0) }
        return cleaned
    }

    private func recalculateFilteredItems() {
        filteredItems = FilterEngine.filteredItems(
            items: items,
            definitions: definitions,
            criteria: selectedCriteria
        )
    }
}
