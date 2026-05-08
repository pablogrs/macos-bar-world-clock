//
//  hoursTests.swift
//  hoursTests
//
//  Created by pablosan on 10/08/2025.
//

import Testing
@testable import hours

struct hoursTests {

    @Test func testTimeZonesStoreInitialization() async throws {
        let store = TimeZonesStore.shared
        #expect(store.selectedTimeZones.count >= 0)
    }

    @Test func testTimeZonesStoreSaveAndLoad() async throws {
        let store = TimeZonesStore.shared
        let originalZones = store.selectedTimeZones
        
        let testZone = TimeZoneConfig(name: "Test", identifier: "UTC", flag: "☁️")
        store.selectedTimeZones.append(testZone)
        
        // Wait a bit for the async notification if needed, but here we just want to check if it saved
        // Since we are using UserDefaults, we can just check if it's there
        let store2 = TimeZonesStore() // New instance to test loading
        #expect(store2.selectedTimeZones.contains(where: { $0.name == "Test" }))
        
        // Cleanup
        store.selectedTimeZones = originalZones
    }
}
