import Foundation

/// A selectable option that can be rendered in filter chips and option lists.
public struct FilterOption: Identifiable, Hashable, Sendable {
    public let id: String
    public let label: String
    public let secondaryLabel: String?

    public init(id: String, label: String, secondaryLabel: String? = nil) {
        self.id = id
        self.label = label
        self.secondaryLabel = secondaryLabel
    }
}
