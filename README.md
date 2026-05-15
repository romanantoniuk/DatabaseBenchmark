# iOS Database Benchmark

A practical R&D project to see how different local databases actually perform on iOS. Instead of just tracking time, it measures real memory footprint using Mach kernel APIs and tests thread safety under load.

## Frameworks tested
- **Core Data (Standard)** (classic NSManagedObject batch insert)
- **Core Data (Optimized)** (streaming SQLite writes via `NSBatchInsertRequest`)
- **SwiftData (Standard)** (default `@Model` overhead)
- **SwiftData (Optimized)** (memory-efficient batching using isolated `ModelContext` instances)
- **Realm (Standard)** (v20, local-only)
- **Realm (Optimized)** (actor-isolated Realm with async writes)
- **GRDB (Standard)** (SQLite via Swift structs)
- **GRDB (Optimized)** (DatabasePool, WAL mode, cached SQL statements)

## What it measures
- **Speed:** Time taken for bulk inserts, full reads, and mass updates.
- **Memory:** Signed delta or sampled peak increase for Physical Footprint (heap) and Resident Size (mmap pages).
- **Concurrency:** How databases handle multiple threads throwing data at them simultaneously (using `TaskGroup` stress tests).

## Under the hood
- **Swift 6:** Strict concurrency enabled (`actor`, `Sendable`).
- **Modular Architecture:** Built as an SPM umbrella package (`DatabaseBenchmarkKit`). Dependencies like Realm and GRDB are isolated and don't pollute the main app target.
- **Data-Driven UI:** SwiftUI + Charts to visualize the results dynamically. Databases, operations, and memory metrics can be toggled on/off to isolate specific tests.
- **Optimized Variants:** Each database can expose both an idiomatic baseline and a tuned implementation. The tuned path follows what the framework realistically offers, so the level of low-level control differs between Core Data, SwiftData, Realm, and GRDB.
- **Storage Contracts:** Standard and optimized adapters implement the same insert, fetch, update, and cleanup API for direct comparison.

## Key Observations
- **Optimized Core Data** bypasses the managed object context entirely using `NSBatchInsertRequest`, resulting in near-zero memory overhead and massive speed gains.
- **Standard SwiftData** can cause massive memory spikes during bulk inserts due to context retention.
- **Optimized SwiftData** (using batched inserts and scope-isolated contexts) drastically reduces the physical memory footprint, bringing it closer to lower-level solutions.
- **GRDB** maintains an incredibly flat heap footprint since it maps directly to SQLite via lightweight structs.
- **Optimized GRDB** uses SQLite WAL mode, cached prepared statements, and cursor-based reads to reduce record mapping overhead.
- **Optimized Realm** uses actor-isolated Realm access, chunked async writes, and a reused Realm instance while respecting Realm's thread confinement model.

## Testing
- **Swift Testing:** The project utilizes Apple's modern `Testing` framework, leveraging macros, parameterized tests, and concurrency-safe assertions.
- **Shared Storage Contracts:** To strictly enforce DRY principles, all databases (Realm, GRDB, Core Data, SwiftData) are tested against a single source of truth. A dedicated `StorageTestSupport` module exposes a unified contract test, ensuring every standard and optimized adapter behaves identically.
- **App Logic:** View model metadata, settings bindings, memory strategy mapping, and formatting helpers are covered in the app's dedicated test target.

## Setup
Just open the project in Xcode 16+, wait for SPM to resolve Realm and GRDB, and run it. You can tweak the number of items, iterations, measured operations, memory metrics, concurrent threads, and active databases directly in the app's settings UI.
