//
//  timerView.swift
//  Timer
//
//  Created by David on 14.07.24.
//

import SwiftUI
import AppKit

struct timerView: View {
    static let minimumFontSize: CGFloat = 24
    static let contentInset: CGFloat = 10

    static var minimumContentSize: NSSize {
        let textBounds = measuredTextBounds(
            for: "00:00",
            fontSize: minimumFontSize
        )
        let extraSpace: CGFloat = 5

        return NSSize(
            width: ceil(
                textBounds.width
                + contentInset * 2
                + extraSpace
            ),
            height: ceil(
                textBounds.height
                + contentInset * 2
                + extraSpace
            )
        )
    }

    @ObservedObject var viewModel: TimerViewModel

    var body: some View {
        GeometryReader { proxy in
            let timerText = viewModel.timeString(
                from: viewModel.remainingTime
            )
            let fontSize = fittingFontSize(
                for: timerText,
                in: proxy.size
            )

            Text(timerText)
                .font(
                    .system(
                        size: fontSize,
                        weight: .medium,
                        design: .rounded
                    )
                )
                .monospacedDigit()
                .contentTransition(.numericText())
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity
                )
                .padding(Self.contentInset)
        }
    }

    private func fittingFontSize(
        for text: String,
        in containerSize: CGSize
    ) -> CGFloat {
        let availableSize = CGSize(
            width: max(
                containerSize.width - Self.contentInset * 2,
                1
            ),
            height: max(
                containerSize.height - Self.contentInset * 2,
                1
            )
        )

        let referenceSize: CGFloat = 100
        let textBounds = Self.measuredTextBounds(
            for: text,
            fontSize: referenceSize
        )

        guard textBounds.width > 0, textBounds.height > 0 else {
            return 54
        }

        let scale = min(
            availableSize.width / textBounds.width,
            availableSize.height / textBounds.height
        )

        return max(Self.minimumFontSize, referenceSize * scale)
    }

    private static func measuredTextBounds(
        for text: String,
        fontSize: CGFloat
    ) -> NSRect {
        let systemFont = NSFont.systemFont(
            ofSize: fontSize,
            weight: .medium
        )
        let roundedFont: NSFont

        if let descriptor = systemFont.fontDescriptor.withDesign(.rounded),
           let font = NSFont(
               descriptor: descriptor,
               size: fontSize
           ) {
            roundedFont = font
        } else {
            roundedFont = systemFont
        }

        return (text as NSString).boundingRect(
            with: NSSize(
                width: CGFloat.greatestFiniteMagnitude,
                height: CGFloat.greatestFiniteMagnitude
            ),
            options: [
                .usesLineFragmentOrigin,
                .usesFontLeading
            ],
            attributes: [.font: roundedFont]
        )
    }
}

#Preview {
    timerView(viewModel: TimerViewModel(duration: 25))
}
