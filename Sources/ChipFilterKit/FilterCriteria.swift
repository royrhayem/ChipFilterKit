import Foundation

/// The selected options keyed by filter definition identifier.
public struct FilterCriteria: Equatable, Sendable {
    public var selectionsByFilterID: [String: FilterSelection]

    public init(selectionsByFilterID: [String: FilterSelection] = [:]) {
        self.selectionsByFilterID = selectionsByFilterID
    }

    public static let empty = FilterCriteria()

    public subscript(filterID: String) -> FilterSelection {
        get { selectionsByFilterID[filterID] ?? FilterSelection() }
        set {
            if newValue.isEmpty {
                selectionsByFilterID.removeValue(forKey: filterID)
            } else {
                selectionsByFilterID[filterID] = newValue
            }
        }
    }

    public var activeFiltersCount: Int {
        selectionsByFilterID.values.filter { !$0.isEmpty }.count
    }

    public mutating func reset(filterID: String) {
        selectionsByFilterID.removeValue(forKey: filterID)
    }

    public mutating func resetAll() {
        selectionsByFilterID.removeAll()
    }
}
