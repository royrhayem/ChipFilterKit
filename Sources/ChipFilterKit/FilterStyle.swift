#if canImport(SwiftUI)
import SwiftUI

/// Styling values used by chip and filter screens.
public struct FilterStyle: Sendable {
    public var backgroundColor: Color
    public var cardColor: Color
    public var chipInactiveBackground: Color
    public var chipInactiveForeground: Color
    public var chipActiveBackground: Color
    public var chipActiveForeground: Color
    public var separatorColor: Color
    public var rowTitleColor: Color
    public var rowSubtitleColor: Color
    public var cornerRadius: CGFloat
    public var chipHorizontalPadding: CGFloat
    public var chipVerticalPadding: CGFloat
    public var verticalSpacing: CGFloat

    public init(
        backgroundColor: Color = Color(.systemGray6),
        cardColor: Color = Color(.systemGray5),
        chipInactiveBackground: Color = Color(.systemGray5),
        chipInactiveForeground: Color = Color.primary,
        chipActiveBackground: Color = Color.accentColor.opacity(0.2),
        chipActiveForeground: Color = Color.accentColor,
        separatorColor: Color = Color.primary.opacity(0.12),
        rowTitleColor: Color = Color.primary,
        rowSubtitleColor: Color = Color.secondary,
        cornerRadius: CGFloat = 22,
        chipHorizontalPadding: CGFloat = 14,
        chipVerticalPadding: CGFloat = 10,
        verticalSpacing: CGFloat = 12
    ) {
        self.backgroundColor = backgroundColor
        self.cardColor = cardColor
        self.chipInactiveBackground = chipInactiveBackground
        self.chipInactiveForeground = chipInactiveForeground
        self.chipActiveBackground = chipActiveBackground
        self.chipActiveForeground = chipActiveForeground
        self.separatorColor = separatorColor
        self.rowTitleColor = rowTitleColor
        self.rowSubtitleColor = rowSubtitleColor
        self.cornerRadius = cornerRadius
        self.chipHorizontalPadding = chipHorizontalPadding
        self.chipVerticalPadding = chipVerticalPadding
        self.verticalSpacing = verticalSpacing
    }

    public static let `default` = FilterStyle()
}

#endif
