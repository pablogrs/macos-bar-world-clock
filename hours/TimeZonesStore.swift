import Foundation

struct TimeZoneConfig: Codable, Identifiable, Equatable {
    var id: String { identifier }
    var name: String
    var identifier: String
    var flag: String
}

class TimeZonesStore: ObservableObject {
    @Published var selectedTimeZones: [TimeZoneConfig] = [] {
        didSet {
            save()
        }
    }
    @Published var showLocal: Bool = true {
        didSet {
            save()
        }
    }
    
    private let saveKey = "selectedTimeZones_v2"
    private let showLocalKey = "showLocal_v2"
    
    static let shared = TimeZonesStore()
    
    init() {
        let saveKey = "selectedTimeZones_v2"
        let showLocalKey = "showLocal_v2"
        
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([TimeZoneConfig].self, from: data) {
            self.selectedTimeZones = decoded
        } else {
            self.selectedTimeZones = [
                TimeZoneConfig(name: "London", identifier: "Europe/London", flag: "🇬🇧"),
                TimeZoneConfig(name: "New York", identifier: "America/New_York", flag: "🇺🇸"),
                TimeZoneConfig(name: "Tokyo", identifier: "Asia/Tokyo", flag: "🇯🇵")
            ]
        }
        
        if UserDefaults.standard.object(forKey: showLocalKey) != nil {
            self.showLocal = UserDefaults.standard.bool(forKey: showLocalKey)
        } else {
            self.showLocal = true
        }
    }
    
    func save() {
        if let encoded = try? JSONEncoder().encode(selectedTimeZones) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
        UserDefaults.standard.set(showLocal, forKey: showLocalKey)
        
        // Post notification to update UI. Use async to avoid re-entrancy issues during initialization.
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name("TimeZonesChanged"), object: nil)
        }
    }
}
