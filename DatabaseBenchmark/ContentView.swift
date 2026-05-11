//
//  ContentView.swift
//  DatabaseBenchmark
//
//  Created by Roman Antoniuk on 11.05.2026.
//

import SwiftUI
import MeasurementLayer

struct ContentView: View {
    
    @State private var viewModel = BenchmarkViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.results.isEmpty && !viewModel.isRunning {
                    ContentUnavailableView("Ready for the test",
                                           systemImage: "chart.bar.xaxis",
                                           description: Text("A comparison will be made between Core Data and SwiftData (10,000 records)"))
                } else {
                    List {
                        ForEach(viewModel.databaseNames, id: \.self) { dbName in
                            let dbResults = viewModel.results.filter { $0.databaseName == dbName }
                            if !dbResults.isEmpty {
                                Section(header: Text(dbName).font(.headline).foregroundColor(.blue)) {
                                    ForEach(dbResults) { result in
                                        HStack {
                                            Text(result.operationName)
                                            Spacer()
                                            Text(String(format: "%.4f sec", result.durationInSeconds))
                                                .font(.system(.subheadline, design: .monospaced))
                                                .bold()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                Button(action: {
                    Task { await viewModel.runAllTests() }
                }) {
                    if viewModel.isRunning {
                        HStack {
                            ProgressView()
                            Text("Analyzing...")
                        }
                        .padding(.horizontal)
                    } else {
                        Text("Run benchmark")
                            .frame(maxWidth: .infinity)
                    }
                }
                .disabled(viewModel.isRunning)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .padding()
            }
            .navigationTitle("DB Comparison")
        }
    }
    
}
