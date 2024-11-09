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
                        Image(systemName: "arrow.counterclockwise")
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.red)
                            .cornerRadius(8)
                    }
                    .alert(isPresented: $showResetConfirmation) {
                        Alert(
                            title: Text("Reset All Timers?"),
                            message: Text("This will reset all timers to zero. Are you sure?"),
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
                    .onDelete(perform: deleteTimers)
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Clinic Timer")
            .preferredColorScheme(.dark)
            .onDisappear {
                TimerModel.saveTimers(timers)
            }
            .sheet(isPresented: $showAddTimerSheet) {
                AddTimerSheet(newTimerName: $newTimerName, timers: $timers)
            }
        }
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
                Text("\(Int(timer.elapsedTime)) seconds")
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
