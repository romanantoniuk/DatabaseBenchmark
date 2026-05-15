//
//  MemoryStrategyOption.swift
//  DatabaseBenchmark
//
//  Created by Roman Antoniuk on 12.05.2026.
//

import Foundation
import MeasurementLayer

enum MemoryStrategyOption: String, CaseIterable, Identifiable {

    case delta = "Delta"
    case peak = "Sampled Peak"

    var id: Self { self }

    var helpText: String {
        switch self {
        case .delta:
            return "Signed before/after diff. Fast but may miss spikes."
        case .peak:
            return "Samples peak increase during execution."
        }
    }

    func toMeasurementStrategy(samplingIntervalMS: Int) -> MemoryStrategy {
        switch self {
        case .delta:
            return .delta
        case .peak:
            return .peak(samplingInterval: .milliseconds(samplingIntervalMS))
        }
    }

}
