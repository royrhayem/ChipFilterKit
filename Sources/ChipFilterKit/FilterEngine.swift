import Foundation

/// Pure filtering logic used by `FilterStore` and tests.
public enum FilterEngine {
    public static func filteredItems<Item>(
        items: [Item],
        definitions: [FilterDefinition<Item>],
        criteria: FilterCriteria
    ) -> [Item] {
        let activeDefinitions = definitions.filter { !criteria[$0.id].isEmpty }
        guard !activeDefinitions.isEmpty else {
            return items
        }

        return items.filter { item in
            activeDefinitions.allSatisfy { definition in
                let selection = criteria[definition.id]
                return definition.matcher(item, selection.optionIDs)
            }
        }
    }
}
