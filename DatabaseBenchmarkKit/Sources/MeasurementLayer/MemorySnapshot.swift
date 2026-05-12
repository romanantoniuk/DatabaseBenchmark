//
//  MemorySnapshot.swift
//  DatabaseBenchmarkKit
//
//  Created by Roman Antoniuk on 12.05.2026.
//

import Foundation
import Darwin

struct MemorySnapshot {
    
    let physFootprint: Double
    let residentSize: Double

    static func current() -> MemorySnapshot {
        MemorySnapshot(physFootprint: physFootprintMB(), residentSize: residentSizeMB())
    }

    func delta(from baseline: MemorySnapshot) -> MemorySnapshot {
        MemorySnapshot(physFootprint: max(0, physFootprint - baseline.physFootprint), residentSize:  max(0, residentSize  - baseline.residentSize))
    }

    // phys_footprint: heap + anonymous. Does not count file-backed mmap.
    private static func physFootprintMB() -> Double {
        var info = task_vm_info_data_t()
        var count = mach_msg_type_number_t(MemoryLayout<task_vm_info_data_t>.size / 4)
        let kr = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), $0, &count)
            }
        }
        guard kr == KERN_SUCCESS else { return 0 }
        return Double(info.phys_footprint) / 1_048_576
    }

    // resident_size: all pages in RAM including mmap.
    private static func residentSizeMB() -> Double {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size / 4)
        let kr = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        guard kr == KERN_SUCCESS else { return 0 }
        return Double(info.resident_size) / 1_048_576
    }
    
}
