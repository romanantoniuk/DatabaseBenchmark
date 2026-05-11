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
                if viewModel.results.isEmpty {
                    ContentUnavailableView("No results",
                                           systemImage: "chart.bar.xaxis",
                                           description: Text("Click the button below to start testing your databases."))
                } else {
                    List(viewModel.results) { result in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(result.databaseName)
                                .font(.headline)
                                .foregroundColor(.blue)
                            
                            HStack {
                                Text(result.operationName)
                                    .font(.subheadline)
                                Spacer()
                                Text(String(format: "%.4f сек", result.durationInSeconds))
                                    .font(.system(.subheadline, design: .monospaced))
                                    .bold()
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                Button(action: {
                    Task {
                        await viewModel.runCoreDataTest()
                    }
                }) {
                    if viewModel.isRunning {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .padding(.horizontal)
                    } else {
                        Text("Run Core Data Benchmark")
                    }
                }
                .disabled(viewModel.isRunning)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .padding()
            }
            .navigationTitle("DB Benchmark")
        }
    }
    
}
