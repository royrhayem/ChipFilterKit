import Foundation

/// The selected option identifiers for one filter.
public struct FilterSelection: Equatable, Sendable {
    public var optionIDs: Set<String>

    public init(optionIDs: Set<String> = []) {
        self.optionIDs = optionIDs
    }

    public var isEmpty: Bool {
        optionIDs.isEmpty
    }
}
