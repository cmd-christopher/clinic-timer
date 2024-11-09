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
        NavigationView {
            VStack {
                HStack {
                    Button(action: {
                        showResetConfirmation = true
                    }) {
                        Text("Reset Timers")
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.red)
                            .cornerRadius(8)
                    }
                    .alert(isPresented: $showResetConfirmation) {
                        Alert(
                            title: Text("Confirm Reset"),
                            message: Text("Are you sure you want to reset all timers?"),
                            primaryButton: .destructive(Text("Reset")) {
                                timers.forEach { $0.stop() }
                            },
                            secondaryButton: .cancel()
                        )
                    }
                    Spacer()
                    Button(action: {
                        showAddTimerSheet = true
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                    .sheet(isPresented: $showAddTimerSheet) {
                        AddTimerSheet(newTimerName: $newTimerName, timers: $timers)
                    }
                }
                .padding(.horizontal)
                
                List {
                    ForEach(timers) { timer in
                        TimerRow(timer: timer)
                            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                Button(action: {
                                    if let index = timers.firstIndex(where: { $0.id == timer.id }) {
                                        timers[index].stop()
                                    }
                                }) {
                                    Label("Stop", systemImage: "stop.fill")
                                }
                                .tint(.red)
                            }
                    }
                    .onMove(perform: moveTimers)
                    .onDelete(perform: deleteTimers)
                }
                .listStyle(PlainListStyle())
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(true)
            .preferredColorScheme(.dark)
            .onDisappear {
                TimerModel.saveTimers(timers)
            }
        }
    }
    
    func moveTimers(from source: IndexSet, to destination: Int) {
        timers.move(fromOffsets: source, toOffset: destination)
    }
    
    func deleteTimers(at offsets: IndexSet) {
        timers.remove(atOffsets: offsets)
    }
}

struct TimerRow: View {
    @ObservedObject var timer: TimerModel
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(timer.name)
                    .font(.headline)
                Text(timer.elapsedTime.formattedTime)
                    .font(.subheadline)
            }
            Spacer()
            if timer.isRunning {
                if timer.isPaused {
                    Button(action: {
                        timer.pause()
                    }) {
                        Image(systemName: "play.fill")
                            .foregroundColor(.green)
                    }
                } else {
                    Button(action: {
                        timer.pause()
                    }) {
                        Image(systemName: "pause.fill")
                            .foregroundColor(.yellow)
                    }
                }
            } else {
                Button(action: {
                    timer.start()
                }) {
                    Image(systemName: "play.fill")
                        .foregroundColor(.green)
                }
            }
        }
    }
}

struct AddTimerSheet: View {
    @Binding var newTimerName: String
    @Binding var timers: [TimerModel]
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Timer Name", text: $newTimerName)
                Button(action: {
                    timers.append(TimerModel(name: newTimerName))
                    newTimerName = ""
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Add Timer")
                }
            }
            .navigationTitle("Add Timer")
        }
    }
}

#Preview {
    ContentView()
}

extension TimeInterval {
    var formattedTime: String {
        let hours = Int(self) / 3600
        let minutes = (Int(self) % 3600) / 60
        let seconds = Int(self) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
