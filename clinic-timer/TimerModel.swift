//
//  TimerModel.swift
//  clinic-timer
//
//  Created by Christopher Wilms on 11/7/24.
//

import Foundation

class TimerModel: ObservableObject, Identifiable, Codable {
    var id = UUID()
    @Published var name: String
    @Published var elapsedTime: TimeInterval = 0
    @Published var isRunning: Bool = false
    @Published var isPaused: Bool = false
    private var timer: Timer?
    private var lastActiveDate: Date?
    private var backgroundDate: Date?
    
    enum CodingKeys: String, CodingKey {
        case id, name, elapsedTime, isRunning, isPaused, lastActiveDate, backgroundDate
    }
    
    init(name: String) {
        self.name = name
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        elapsedTime = try container.decode(TimeInterval.self, forKey: .elapsedTime)
        isRunning = try container.decode(Bool.self, forKey: .isRunning)
        isPaused = try container.decode(Bool.self, forKey: .isPaused)
        lastActiveDate = try container.decodeIfPresent(Date.self, forKey: .lastActiveDate)
        backgroundDate = try container.decodeIfPresent(Date.self, forKey: .backgroundDate)
        
        // If the timer was running when the app was closed, update the elapsed time
        if isRunning && !isPaused, let lastActive = lastActiveDate {
            let timeSinceLastActive = Date().timeIntervalSince(lastActive)
            elapsedTime += timeSinceLastActive
        }
        
        // Don't automatically start the timer on init, let the UI handle that
        isRunning = false
        isPaused = false
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(elapsedTime, forKey: .elapsedTime)
        try container.encode(isRunning, forKey: .isRunning)
        try container.encode(isPaused, forKey: .isPaused)
        try container.encode(Date(), forKey: .lastActiveDate)
        try container.encode(backgroundDate, forKey: .backgroundDate)
    }
    
    func start() {
        if !isRunning {
            objectWillChange.send()
            isRunning = true
            isPaused = false
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                if !self.isPaused {
                    self.elapsedTime += 1
                }
            }
            
            // Make sure the timer stays active even when scrolling
            RunLoop.current.add(timer!, forMode: .common)
        }
    }
    
    func pause() {
        objectWillChange.send()
        isPaused.toggle()
    }
    
    func stop() {
        objectWillChange.send()  // Explicitly notify observers before changes
        timer?.invalidate()
        timer = nil
        elapsedTime = 0
        isRunning = false
        isPaused = false
    }
    
    func rename(to newName: String) {
        objectWillChange.send()
        name = newName
    }
    
    func applicationWillResignActive() {
        if isRunning && !isPaused {
            backgroundDate = Date()
            timer?.invalidate()
            timer = nil
        }
    }
    
    func applicationDidBecomeActive() {
        if isRunning && !isPaused {
            if let backgroundDate = backgroundDate {
                let timeInBackground = Date().timeIntervalSince(backgroundDate)
                elapsedTime += timeInBackground
            }
            
            // Restart the timer
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                if !self.isPaused {
                    self.elapsedTime += 1
                }
            }
            RunLoop.current.add(timer!, forMode: .common)
            
            backgroundDate = nil
        }
    }
    
    static func saveTimers(_ timers: [TimerModel]) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(timers) {
            UserDefaults.standard.set(encoded, forKey: "SavedTimers")
        }
    }
    
    static func loadTimers() -> [TimerModel] {
        if let savedTimers = UserDefaults.standard.data(forKey: "SavedTimers") {
            let decoder = JSONDecoder()
            if let loadedTimers = try? decoder.decode([TimerModel].self, from: savedTimers) {
                return loadedTimers
            }
        }
        return []
    }
    
    enum VisitType {
        case established
        case new
    }
    
    func complexityCode(for visitType: VisitType) -> Int {
        let minutes = Int(elapsedTime / 60)
        
        switch visitType {
        case .established:
            if minutes <= 10 { return 1 }
            else if minutes <= 20 { return 2 }
            else if minutes <= 30 { return 3 }
            else if minutes <= 40 { return 4 }
            else { return 5 }
            
        case .new:
            if minutes <= 20 { return 1 }
            else if minutes <= 30 { return 2 }
            else if minutes <= 45 { return 3 }
            else if minutes <= 60 { return 4 }
            else { return 5 }
        }
    }
}
