# iOS Database Benchmark

A practical R&D project to see how different local databases actually perform on iOS. Instead of just tracking time, it measures real memory footprint using Mach kernel APIs and tests thread safety under load.

## Frameworks tested
- **Core Data** (classic batch insert)
- **SwiftData** (`@Model` overhead)
- **Realm** (v20, local-only)
- **GRDB** (SQLite via Swift structs)

## What it measures
- **Speed:** Time taken for bulk inserts and fetches.
- **Memory:** Delta for Physical Footprint (heap) and Resident Size (mmap pages).
- **Concurrency:** How databases handle multiple threads throwing data at them simultaneously (using `TaskGroup` stress tests).

## Under the hood
- **Swift 6:** Strict concurrency enabled (`actor`, `Sendable`).
- **Modular Architecture:** Built as an SPM umbrella package (`DatabaseBenchmarkKit`). Dependencies like Realm and GRDB are isolated and don't pollute the main app target.
- **UI:** SwiftUI + Charts to visualize the results dynamically.

## Setup
Just open the project in Xcode 16+, wait for SPM to resolve Realm and GRDB, and run it. You can tweak the number of items, iterations, and concurrent threads directly in the app's settings UI.
