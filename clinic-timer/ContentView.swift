//
//  ContentView.swift
//  clinic-timer
//
//  Created by Christopher Wilms on 11/7/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var timerModel = TimerModel()
    
    var body: some View {
        VStack {
            Text(timerModel.formattedElapsedTime)
                .font(.largeTitle)
                .padding()
            
            HStack {
                Button(action: {
                    if timerModel.isRunning {
                        timerModel.pause()
                    } else {
                        timerModel.start()
                    }
                }) {
                    Text(timerModel.isRunning ? "Pause" : "Start")
                        .padding()
                        .background(timerModel.isRunning ? Color.red : Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Button(action: timerModel.reset) {
                    Text("Reset")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
