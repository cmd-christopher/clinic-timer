//
//  clinic_timerApp.swift
//  clinic-timer
//
//  Created by Christopher Wilms on 11/7/24.
//

import SwiftUI

@main
struct clinic_timerApp: App {
    @StateObject private var appState = AppStateManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
                .tint(.blue)
                .environmentObject(appState)
        }
    }
}

class AppStateManager: ObservableObject {
    @Published var timers: [TimerModel] = TimerModel.loadTimers()
    
    init() {
        setupNotificationObservers()
    }
    
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.willResignActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.applicationWillResignActive()
        }
        
        NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.applicationDidBecomeActive()
        }
    }
    
    private func applicationWillResignActive() {
        timers.forEach { $0.applicationWillResignActive() }
        TimerModel.saveTimers(timers)
    }
    
    private func applicationDidBecomeActive() {
        timers.forEach { $0.applicationDidBecomeActive() }
    }
}
