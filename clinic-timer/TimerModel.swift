//
//  TimerModel.swift
//  clinic-timer
//
//  Created by Christopher Wilms on 11/7/24.
//

import Foundation

class TimerModel: ObservableObject {
    @Published var elapsedTime: TimeInterval = 0
    @Published var isRunning: Bool = false
    @Published var name: String = "Timer"
    
    private var timer: Timer?
    
    func start() {
        if !isRunning {
            isRunning = true
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                self?.elapsedTime += 1
            }
        }
    }
    
    func pause() {
        if isRunning {
            isRunning = false
            timer?.invalidate()
            timer = nil
        }
    }
    
    func reset() {
        pause()
        elapsedTime = 0
    }
    
    var formattedElapsedTime: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: elapsedTime) ?? "00:00:00"
    }
}
