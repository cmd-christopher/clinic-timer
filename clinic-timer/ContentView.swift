//
//  ContentView.swift
//  clinic-timer
//
//  Created by Christopher Wilms on 11/7/24.
//

import SwiftUI

struct ContentView: View {
    @State private var timers: [TimerModel] = TimerModel.loadTimers()
    @State private var newTimerName: String = ""
    @State private var showAddTimerSheet: Bool = false
    @State private var showResetConfirmation: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(timers) { timer in
                    TimerRow(timer: timer)
                        .swipeActions(edge: .leading) {
                            Button(role: .destructive) {
                                if let index = timers.firstIndex(where: { $0.id == timer.id }) {
                                    timers[index].stop()
                                }
                            } label: {
                                Label("Reset", systemImage: "arrow.counterclockwise")
                            }
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                if let index = timers.firstIndex(where: { $0.id == timer.id }) {
                                    timers.remove(at: index)
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
                .onMove(perform: moveTimers)
            }
            .listStyle(.insetGrouped)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        showResetConfirmation = true
                    }) {
                        Text("Reset All")
                            .foregroundStyle(.red)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        showAddTimerSheet = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    EditButton()
                }
            }
        }
        .sheet(isPresented: $showAddTimerSheet) {
            AddTimerSheet(newTimerName: $newTimerName, timers: $timers)
        }
        .alert("Reset All Timers?", isPresented: $showResetConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                timers.forEach { $0.stop() }
            }
        } message: {
            Text("This will reset all active timers to zero. This action cannot be undone.")
        }
        .onDisappear {
            TimerModel.saveTimers(timers)
        }
    }
    
    func moveTimers(from source: IndexSet, to destination: Int) {
        timers.move(fromOffsets: source, toOffset: destination)
    }
}

struct TimerRow: View {
    @ObservedObject var timer: TimerModel
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text(timer.name)
                    .font(.headline)
                Spacer()
                StatusBadge(isRunning: timer.isRunning, isPaused: timer.isPaused)
            }
            
            HStack(alignment: .center) {
                Text(timer.elapsedTime.formattedTime)
                    .font(.largeTitle)
                    .foregroundStyle(timer.isRunning && !timer.isPaused ? .primary : .secondary)
                
                Spacer()
                
                ComplexityIndicator(
                    established: timer.complexityCode(for: .established),
                    new: timer.complexityCode(for: .new)
                )
                
                Button(action: {
                    if timer.isRunning {
                        timer.pause()
                    } else {
                        timer.start()
                    }
                }) {
                    Image(systemName: timer.isRunning && !timer.isPaused ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(timer.isRunning && !timer.isPaused ? .yellow : .green)
                }
            }
        }
        .padding(.vertical, 8)
    }
}
import Foundation

extension TimeInterval {
    var formattedTime: String {
        let hours = Int(self) / 3600
        let minutes = (Int(self) % 3600) / 60
        let seconds = Int(self) % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}


struct ComplexityIndicator: View {
    let established: Int
    let new: Int
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 4) {
            HStack(spacing: 4) {
                Text("EST")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text("\(established)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            
            HStack(spacing: 4) {
                Text("NEW")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text("\(new)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
        }
        .padding(.horizontal, 12)
    }
}

struct StatusBadge: View {
    let isRunning: Bool
    let isPaused: Bool
    
    var body: some View {
        Text(statusText)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor.opacity(0.2))
            .foregroundStyle(statusColor)
            .clipShape(Capsule())
    }
    
    private var statusText: String {
        if !isRunning {
            return "Ready"
        } else if isPaused {
            return "Paused"
        } else {
            return "Running"
        }
    }
    
    private var statusColor: Color {
        if !isRunning {
            return .gray
        } else if isPaused {
            return .yellow
        } else {
            return .green
        }
    }
}



struct AddTimerSheet: View {
    @Binding var newTimerName: String
    @Binding var timers: [TimerModel]
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Timer Name", text: $newTimerName)
                        .autocorrectionDisabled()
                } footer: {
                    Text("Enter an identifier for the timer.")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("New Timer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        if !newTimerName.isEmpty {
                            timers.append(TimerModel(name: newTimerName))
                            newTimerName = ""
                            dismiss()
                        }
                    }
                    .disabled(newTimerName.isEmpty)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
