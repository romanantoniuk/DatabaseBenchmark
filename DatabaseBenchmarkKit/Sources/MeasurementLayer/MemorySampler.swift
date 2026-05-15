//
//  MemorySampler.swift
//  DatabaseBenchmarkKit
//
//  Created by Roman Antoniuk on 12.05.2026.
//

import Foundation

actor MemorySampler {

    private let baseline: MemorySnapshot
    private let interval: Duration
    private(set) var peak = MemorySnapshot(physFootprint: 0, residentSize: 0)

    init(baseline: MemorySnapshot, interval: Duration) {
        self.baseline = baseline
        self.interval = interval
    }

    func run() async {
        while !Task.isCancelled {
            sample()
            try? await Task.sleep(for: interval)
        }
    }

    func sample() {
        let delta = MemorySnapshot.current().peakDelta(from: baseline)
        if delta.physFootprint > peak.physFootprint || delta.residentSize > peak.residentSize {
            peak = MemorySnapshot(physFootprint: max(peak.physFootprint, delta.physFootprint), residentSize: max(peak.residentSize, delta.residentSize))
        }
    }

}
