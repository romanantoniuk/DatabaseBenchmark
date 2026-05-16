//
//  FlowLayout.swift
//  DatabaseBenchmark
//
//  Created by Roman Antoniuk on 16.05.2026.
//

import SwiftUI

struct FlowLayout: Layout {
    
    var spacing: CGFloat = 8
    var rowSpacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? 0
        let rows = makeRows(subviews: subviews, maxWidth: maxWidth)
        let height = rows.enumerated().reduce(CGFloat.zero) { result, item in
            let rowHeight = item.element.height
            let spacing = item.offset == 0 ? CGFloat.zero : rowSpacing
            return result + spacing + rowHeight
        }
        return CGSize(width: maxWidth, height: height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = makeRows(subviews: subviews, maxWidth: bounds.width)
        var y = bounds.minY
        for row in rows {
            var x = bounds.minX
            for element in row.elements {
                element.subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(element.size))
                x += element.size.width + spacing
            }
            y += row.height + rowSpacing
        }
    }
    
    private func makeRows(subviews: Subviews, maxWidth: CGFloat) -> [Row] {
        guard maxWidth > 0 else {
            return []
        }
        var rows: [Row] = []
        var currentRow = Row()
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentRow.width + size.width > maxWidth, !currentRow.elements.isEmpty {
                rows.append(currentRow)
                currentRow = Row()
            }
            currentRow.elements.append(
                Row.Element(
                    subview: subview,
                    size: size
                )
            )
            currentRow.width += size.width + (currentRow.elements.count > 1 ? spacing : 0)
            currentRow.height = max(currentRow.height, size.height)
        }
        if !currentRow.elements.isEmpty {
            rows.append(currentRow)
        }
        return rows
    }
    
}

fileprivate struct Row {
    
    var elements: [Element] = []
    var width: CGFloat = 0
    var height: CGFloat = 0
    
    struct Element {
        let subview: LayoutSubview
        let size: CGSize
    }
    
}
