import Foundation

/// Describes one reusable filter category for an arbitrary `Item` type.
public struct FilterDefinition<Item>: Identifiable {
    public typealias OptionsProvider = @Sendable ([Item]) -> [FilterOption]
    public typealias Matcher = @Sendable (_ item: Item, _ selectedOptionIDs: Set<String>) -> Bool
    public typealias SummaryFormatter = @Sendable (_ title: String, _ selectedOptions: [FilterOption]) -> String
    public typealias OptionsSorter = @Sendable (_ lhs: FilterOption, _ rhs: FilterOption) -> Bool
    /// Returns whether this filter should be visible given the current criteria.
    /// When `nil`, the filter is always visible.
    public typealias VisibilityCondition = @Sendable (_ criteria: FilterCriteria) -> Bool

    public let id: String
    public let title: String
    public let subtitle: String?
    public let selectionMode: FilterSelectionMode
    public let optionsProvider: OptionsProvider
    public let matcher: Matcher
    public let summaryFormatter: SummaryFormatter?
    public let optionsSorter: OptionsSorter?
    public let visibilityCondition: VisibilityCondition?

    public init(
        id: String,
        title: String,
        subtitle: String? = nil,
        selectionMode: FilterSelectionMode,
        optionsProvider: @escaping OptionsProvider,
        matcher: @escaping Matcher,
        summaryFormatter: SummaryFormatter? = nil,
        optionsSorter: OptionsSorter? = nil,
        visibilityCondition: VisibilityCondition? = nil
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.selectionMode = selectionMode
        self.optionsProvider = optionsProvider
        self.matcher = matcher
        self.summaryFormatter = summaryFormatter
        self.optionsSorter = optionsSorter
        self.visibilityCondition = visibilityCondition
    }

    public func options(from items: [Item]) -> [FilterOption] {
        let options = optionsProvider(items)
        if let optionsSorter {
            return options.sorted(by: optionsSorter)
        }
        return options
    }

    public func summary(for selectedOptions: [FilterOption]) -> String {
        if let summaryFormatter {
            return summaryFormatter(title, selectedOptions)
        }

        guard !selectedOptions.isEmpty else {
            return title
        }

        switch selectionMode {
        case .single:
            return selectedOptions.first?.label ?? title
        case .multiple:
            return "\(title) (\(selectedOptions.count))"
        }
    }
}
