#if canImport(SwiftUI)
import SwiftUI

/// Reusable capsule chip used by the filter bar.
public struct FilterChip: View {
    public let title: String
    public let isActive: Bool
    public let iconSystemName: String?
    public let style: FilterStyle
    public let action: () -> Void

    public init(
        title: String,
        isActive: Bool = false,
        iconSystemName: String? = nil,
        style: FilterStyle = .default,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.isActive = isActive
        self.iconSystemName = iconSystemName
        self.style = style
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let iconSystemName {
                    Image(systemName: iconSystemName)
                }
                Text(title)
                    .lineLimit(1)
                    .font(.subheadline.weight(.medium))
            }
            .foregroundStyle(isActive ? style.chipActiveForeground : style.chipInactiveForeground)
            .padding(.horizontal, style.chipHorizontalPadding)
            .padding(.vertical, style.chipVerticalPadding)
            .background(isActive ? style.chipActiveBackground : style.chipInactiveBackground)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

#endif
