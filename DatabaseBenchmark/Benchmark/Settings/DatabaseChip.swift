//
//  DatabaseChip.swift
//  DatabaseBenchmark
//
//  Created by Roman Antoniuk on 16.05.2026.
//

import SwiftUI

struct DatabaseChip: View {
    
    let title: String
    private var displayTitle: String {
        let isOptimized = title.localizedCaseInsensitiveContains("(Optimized)")
        let baseTitle = title
            .replacingOccurrences(of: "(Standard)", with: "")
            .replacingOccurrences(of: "(Optimized)", with: "")
            .replacingOccurrences(of: "(SQLite)", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        return isOptimized ? "\(baseTitle) Opt" : baseTitle
    }
    
    @Binding var isSelected: Bool
    
    var body: some View {
        Button {
            isSelected.toggle()
        } label: {
            Text(displayTitle)
                .font(.subheadline.weight(.semibold))
                .lineLimit(1)
                .foregroundStyle(isSelected ? .blue : .primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background {
                    Capsule()
                        .fill(isSelected ? Color.blue.opacity(0.18) : Color.secondary.opacity(0.18))
                }
        }
        .buttonStyle(.plain)
    }
    
}
