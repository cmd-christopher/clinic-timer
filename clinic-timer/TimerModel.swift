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
    
    enum CodingKeys: String, CodingKey {
        case id, name, elapsedTime, isRunning, isPaused
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
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(elapsedTime, forKey: .elapsedTime)
        try container.encode(isRunning, forKey: .isRunning)
        try container.encode(isPaused, forKey: .isPaused)
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
}
