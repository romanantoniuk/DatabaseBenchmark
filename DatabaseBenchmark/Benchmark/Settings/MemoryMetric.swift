//
//  MemoryMetric.swift
//  DatabaseBenchmark
//
//  Created by Roman Antoniuk on 12.05.2026.
//

import Foundation

enum MemoryMetric: String, CaseIterable, Identifiable, Sendable {
    
    case physFootprint = "Physical Footprint"
    case residentSize = "Resident Size"

    var id: Self { self }

    var systemImage: String {
        switch self {
        case .physFootprint:
            return "memorychip"
        case .residentSize:
            return "square.3.layers.3d"
        }
    }

    var explanation: String {
        switch self {
        case .physFootprint:
            return "Matches Instruments"
        case .residentSize:
            return "Includes mmap pages"
        }
    }

}
