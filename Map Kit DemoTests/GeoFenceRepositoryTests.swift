//
//  GeoFenceRepositoryTests.swift
//  Map Kit DemoTests
//
//  Created by Abdullah-Shahid  on 28/04/2025.
//

import XCTest

import XCTest
@testable import Map_Kit_Demo

class GeoFenceRepositoryTests: XCTestCase {
    var repository: DefaultGeoFenceRepository!
    var coreDataManager: CoreDataManager!
    
    ///
    /// Setup method called before the invocation of each test method in the class.
    /// 
    override func setUp() {
        super.setUp()
        coreDataManager = CoreDataManager.shared
        repository = DefaultGeoFenceRepository()
    }
    
    ///
    /// Teardown method called after the invocation of each test method in the class.
    ///
    override func tearDown() {
        coreDataManager.clearDatabase()
        coreDataManager = nil
        repository = nil
        super.tearDown()
    }
    
    func testCreateGeoFence() {
        let id = UUID()
        let geoFence = Geofence(identifier: id, name: "Test", centerLatitude: 37.7749, centerLongitude: -122.4194, radius: 100.0, userNote: "Test note")
        
        let success = repository.create(geoFence: geoFence)
        
        XCTAssertTrue(success, "Creating a geo fence should succeed")
        let fetched = repository.get(byIdentifier: id)
        XCTAssertNotNil(fetched, "GeoFence should be retrievable after creation")
        XCTAssertEqual(fetched?.identifier, id)
        XCTAssertEqual(fetched?.name, "Test")
        XCTAssertEqual(fetched?.centerLatitude, 37.7749)
        XCTAssertEqual(fetched?.centerLongitude, -122.4194)
        XCTAssertEqual(fetched?.radius, 100.0)
        XCTAssertEqual(fetched?.userNote, "Test note")
    }
    
    func testGetAllGeoFences() {
        let id1 = UUID()
        let geoFence1 = Geofence(identifier: id1, name: "Test1", centerLatitude: 37.7749, centerLongitude: -122.4194, radius: 100.0, userNote: "Note 1")
        let id2 = UUID()
        let geoFence2 = Geofence(identifier: id2, name: "Test2", centerLatitude: 34.0522, centerLongitude: -118.2437, radius: 200.0, userNote: "Note 2")
        repository.create(geoFence: geoFence1)
        repository.create(geoFence: geoFence2)
        
        let allGeoFences = repository.getAll()
        
        XCTAssertNotNil(allGeoFences, "getAll should return an array")
        XCTAssertEqual(allGeoFences?.count, 2, "Should return exactly 2 geo fences")
        let identifiers = allGeoFences?.map { $0.identifier }
        XCTAssertTrue(identifiers?.contains(id1) ?? false, "Should contain first geo fence")
        XCTAssertTrue(identifiers?.contains(id2) ?? false, "Should contain second geo fence")
    }
    
    func testGetAllWhenEmpty() {
        let allGeoFences = repository.getAll()
        
        XCTAssertNotNil(allGeoFences, "getAll should return an array even when empty")
        XCTAssertTrue(allGeoFences?.isEmpty ?? false, "Should return an empty array when no geo fences exist")
    }
    
    func testGetByIdentifier() {
        let id = UUID()
        let geoFence = Geofence(identifier: id, name: "Test", centerLatitude: 37.7749, centerLongitude: -122.4194, radius: 100.0, userNote: "Test note")
        repository.create(geoFence: geoFence)
        
        let fetched = repository.get(byIdentifier: id)
        
        XCTAssertNotNil(fetched, "Should retrieve the created geo fence")
        XCTAssertEqual(fetched?.identifier, id)
    }
    
    func testGetNonExistentGeoFence() {
        let fetched = repository.get(byIdentifier: UUID())
        
        XCTAssertNil(fetched, "Should return nil for a non-existent geo fence")
    }
    
    func testUpdateGeoFence() {
        let id = UUID()
        let original = Geofence(identifier: id, name: "Original", centerLatitude: 37.7749, centerLongitude: -122.4194, radius: 100.0, userNote: "Original note")
        repository.create(geoFence: original)
        let updated = Geofence(identifier: id, name: "Updated", centerLatitude: 34.0522, centerLongitude: -118.2437, radius: 200.0, userNote: "Updated note")
        
        let success = repository.update(geoFence: updated)
        
        XCTAssertTrue(success, "Updating an existing geo fence should succeed")
        let fetched = repository.get(byIdentifier: id)
        XCTAssertNotNil(fetched)
        XCTAssertEqual(fetched?.name, "Updated")
        XCTAssertEqual(fetched?.centerLatitude, 34.0522)
        XCTAssertEqual(fetched?.centerLongitude, -118.2437)
        XCTAssertEqual(fetched?.radius, 200.0)
        XCTAssertEqual(fetched?.userNote, "Updated note")
    }
    
    func testUpdateNonExistentGeoFence() {
        let geoFence = Geofence(identifier: UUID(), name: "Non-existent", centerLatitude: 0.0, centerLongitude: 0.0, radius: 0.0, userNote: "")
        
        let success = repository.update(geoFence: geoFence)
        
        XCTAssertFalse(success, "Updating a non-existent geo fence should fail")
    }
    
    func testDeleteGeoFences() {
        let id1 = UUID()
        let geoFence1 = Geofence(identifier: id1, name: "Test1", centerLatitude: 37.7749, centerLongitude: -122.4194, radius: 100.0, userNote: "Note 1")
        let id2 = UUID()
        let geoFence2 = Geofence(identifier: id2, name: "Test2", centerLatitude: 34.0522, centerLongitude: -118.2437, radius: 200.0, userNote: "Note 2")
        repository.create(geoFence: geoFence1)
        repository.create(geoFence: geoFence2)
        let nonExistentId = UUID()
        
        let success = repository.delete(ids: [id1, nonExistentId])
        
        XCTAssertTrue(success, "Deleting should succeed even with non-existent IDs")
        let allGeoFences = repository.getAll()
        XCTAssertEqual(allGeoFences?.count, 1, "Only one geo fence should remain")
        XCTAssertEqual(allGeoFences?.first?.identifier, id2, "Remaining geo fence should be the undeleted one")
        XCTAssertNil(repository.get(byIdentifier: id1), "Deleted geo fence should not be retrievable")
    }
}
