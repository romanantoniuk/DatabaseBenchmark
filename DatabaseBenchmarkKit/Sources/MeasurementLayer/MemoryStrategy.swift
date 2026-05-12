//
//  MemoryStrategy.swift
//  DatabaseBenchmarkKit
//
//  Created by Roman Antoniuk on 12.05.2026.
//


import Foundation

public enum MemoryStrategy: Sendable {
    
    /// Before / after diff. Fast, but may miss short-lived allocations.
    case delta
    /// Background sampling. Slightly slower, but catches spikes.
    case peak(samplingInterval: Duration)
    
}
