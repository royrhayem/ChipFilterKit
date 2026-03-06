#if canImport(SwiftUI)
import SwiftUI

struct CenteredHeaderBar<Leading: View, Trailing: View>: View {
    let title: String
    @ViewBuilder let leading: () -> Leading
    @ViewBuilder let trailing: () -> Trailing

    var body: some View {
        ZStack {
            Text(title)
                .font(.title3.weight(.semibold))
            HStack {
                leading()
                Spacer()
                trailing()
            }
        }
    }
}

struct RoundedOptionsCard: View {
    let options: [FilterOption]
    let isSelected: (FilterOption) -> Bool
    let onSelect: (FilterOption) -> Void
    let style: FilterStyle

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(options.enumerated()), id: \.element.id) { index, option in
                Button {
                    onSelect(option)
                } label: {
                    HStack(spacing: 10) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(option.label)
                                .foregroundStyle(style.rowTitleColor)
                                .font(.body)
                            if let secondary = option.secondaryLabel {
                                Text(secondary)
                                    .foregroundStyle(style.rowSubtitleColor)
                                    .font(.footnote)
                            }
                        }
                        Spacer()
                        if isSelected(option) {
                            Image(systemName: "checkmark")
                                .font(.headline)
                                .foregroundStyle(style.chipActiveForeground)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                if index != options.count - 1 {
                    Divider()
                        .overlay(style.separatorColor)
                        .padding(.leading, 16)
                }
            }
        }
        .background(style.cardColor)
        .clipShape(RoundedRectangle(cornerRadius: style.cornerRadius, style: .continuous))
    }
}

extension View {
    func filterScreenBackground(_ style: FilterStyle) -> some View {
        background(style.backgroundColor.ignoresSafeArea())
    }
}

#endif
