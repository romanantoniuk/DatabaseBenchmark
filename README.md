# iOS Database Benchmark

A practical R&D project to see how different local databases actually perform on iOS. Instead of just tracking time, it measures real memory footprint using Mach kernel APIs and tests thread safety under load.

## Frameworks tested
- **Core Data (Standard)** (classic NSManagedObject batch insert)
- **Core Data (Optimized)** (streaming SQLite writes via `NSBatchInsertRequest`)
- **SwiftData (Standard)** (default `@Model` overhead)
- **SwiftData (Optimized)** (memory-efficient batching using isolated `ModelContext`s)
- **Realm** (v20, local-only)
- **GRDB** (SQLite via Swift structs)

## What it measures
- **Speed:** Time taken for bulk inserts and fetches.
- **Memory:** Delta for Physical Footprint (heap) and Resident Size (mmap pages).
- **Concurrency:** How databases handle multiple threads throwing data at them simultaneously (using `TaskGroup` stress tests).

## Under the hood
- **Swift 6:** Strict concurrency enabled (`actor`, `Sendable`).
- **Modular Architecture:** Built as an SPM umbrella package (`DatabaseBenchmarkKit`). Dependencies like Realm and GRDB are isolated and don't pollute the main app target.
- **Data-Driven UI:** SwiftUI + Charts to visualize the results dynamically. Target databases can be toggled on/off on the fly to isolate specific tests.

## Key Observations
- **Optimized Core Data** bypasses the managed object context entirely using `NSBatchInsertRequest`, resulting in near-zero memory overhead and massive speed gains.
- **Standard SwiftData** can cause massive memory spikes during bulk inserts due to context retention.
- **Optimized SwiftData** (using batched inserts and scope-isolated contexts) drastically reduces the physical memory footprint, bringing it closer to lower-level solutions.
- **GRDB** maintains an incredibly flat heap footprint since it maps directly to SQLite via lightweight structs.

## Setup
Just open the project in Xcode 16+, wait for SPM to resolve Realm and GRDB, and run it. You can tweak the number of items, iterations, concurrent threads, and active databases directly in the app's settings UI.
