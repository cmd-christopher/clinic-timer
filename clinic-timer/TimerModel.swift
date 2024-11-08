//
//  TimerModel.swift
//  clinic-timer
//
//  Created by Christopher Wilms on 11/7/24.
//

import Foundation

class TimerModel: ObservableObject, Identifiable {
    let id = UUID()
    @Published var name: String
    @Published var elapsedTime: TimeInterval = 0
    @Published var isRunning: Bool = false
    @Published var isPaused: Bool = false
    private var timer: Timer?
    
    init(name: String) {
        self.name = name
    }
    
    func start() {
        if !isRunning {
            isRunning = true
            isPaused = false
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                if !self.isPaused {
                    self.elapsedTime += 1
                }
            }
        }
    }
    
    func pause() {
        isPaused.toggle()
    }
    
    func stop() {
        isRunning = false
        isPaused = false
        elapsedTime = 0
        timer?.invalidate()
    }
    
    func rename(to newName: String) {
        name = newName
    }
}
