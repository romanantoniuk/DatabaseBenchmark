//
//  BenchmarkDashboardView.swift
//  DatabaseBenchmark
//
//  Created by Roman Antoniuk on 11.05.2026.
//

import SwiftUI

struct BenchmarkDashboardView: View {
    
    @State private var viewModel = BenchmarkDashboardViewModel()
    @State private var showSettings = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                contentView
                runButton
            }
            .navigationTitle("DB Comparison")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .disabled(viewModel.isRunning)
                }
            }
            .sheet(isPresented: $showSettings) {
                BenchmarkSettingsView(settings: viewModel.settings)
                    .presentationDetents([.large])
            }
            .alert("Error", isPresented: $viewModel.hasError, actions: {
                Button("OK", role: .cancel) { }
            }, message: {
                Text(viewModel.errorMessage ?? "An unknown error occurred")
            })
        }
    }
    
    // MARK: - Content
    @ViewBuilder
    private var contentView: some View {
        if viewModel.showEmptyState {
            emptyStateView
        } else {
            resultsList
        }
    }
    
    private var emptyStateView: some View {
        ContentUnavailableView(
            "Ready for the test",
            systemImage: "chart.bar.xaxis",
            description: Text("Configure settings and tap Run benchmark")
        )
    }
    
    private var resultsList: some View {
        List {
            configurationHeader
            if !viewModel.results.isEmpty {
                Section {
                    BenchmarkChartView(results: viewModel.results)
                        .listRowInsets(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
                }
            }
            ForEach(viewModel.groupedResults, id: \.databaseName) { group in
                Section {
                    ForEach(group.results) { result in
                        BenchmarkDashboardResultRowView(result: result, activeMetrics: viewModel.activeMetrics)
                    }
                } header: {
                    Text(group.databaseName)
                        .font(.headline)
                        .foregroundStyle(.blue)
                }
            }
        }
        .listStyle(.insetGrouped)
    }
    
    private var configurationHeader: some View {
        Section {
            LabeledContent("Items", value: viewModel.itemsConfigText)
            LabeledContent("Iterations", value: viewModel.iterationsConfigText)
            LabeledContent("Memory", value: viewModel.memoryStrategyConfigText)
        } header: {
            Text("Configuration")
        }
    }
    
    // MARK: - Run button
    private var runButton: some View {
        Button {
            Task { await viewModel.runAllTests() }
        } label: {
            Group {
                if viewModel.isRunning {
                    HStack(spacing: 8) {
                        ProgressView()
                        Text("Analyzing...")
                    }
                } else {
                    Text("Run benchmark")
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .disabled(viewModel.isRunning)
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .padding()
    }
    
}
