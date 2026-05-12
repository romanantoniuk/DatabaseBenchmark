//
//  Int+Formatting.swift
//  DatabaseBenchmark
//
//  Created by Roman Antoniuk on 12.05.2026.
//

import Foundation

extension Int {

    var millisecondsDescription: String {
        if self == 0 {
            return "None"
        }
        if self < 1000 {
            return "\(self) ms"
        }
        return "\(self / 1000) s"
    }

}
