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
    
    var body: some View {
        NavigationView {
            VStack {
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
                    .onMove(perform: move)
                    .moveDisabled(false)
                }
                .listStyle(PlainListStyle())
                
                Button(action: {
                    showAddTimerSheet = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                }
                .padding()
                .background(Color.blue)
                .cornerRadius(15)
                .sheet(isPresented: $showAddTimerSheet) {
                    AddTimerSheet(newTimerName: $newTimerName, timers: $timers)
                }
                
                Button(action: {
                    timers.forEach { $0.stop() }
                }) {
                    Text("Reset All")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(10)
                }
            }
            .navigationTitle("Clinic Timer")
            .preferredColorScheme(.dark)
            .onDisappear {
                TimerModel.saveTimers(timers)
            }
        }
    }
    
    func deleteTimers(at offsets: IndexSet) {
        timers.remove(atOffsets: offsets)
    }
    
    func move(from source: IndexSet, to destination: Int) {
        timers.move(fromOffsets: source, toOffset: destination)
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
