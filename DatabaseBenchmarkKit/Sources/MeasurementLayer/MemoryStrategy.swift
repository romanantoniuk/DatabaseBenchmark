//
//  MemoryStrategy.swift
//  DatabaseBenchmarkKit
//
//  Created by Roman Antoniuk on 12.05.2026.
//


import Foundation

public enum MemoryStrategy: Sendable {
    
    /// Signed before / after diff. Fast, but may miss short-lived allocations.
    case delta
    /// Sampled peak increase over baseline. Slightly slower, but catches more spikes.
    case peak(samplingInterval: Duration)
    
}
