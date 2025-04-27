//
//  GeoFenceRepository.swift
//  Map Kit Demo
//
//  Created by Abdullah-Shahid  on 27/04/2025.
//

import Foundation
import CoreData

protocol GeoFenceRepository {
    func create(geoFence: Geofence) -> Bool
    func getAll() -> [GeoFence]?
    func get(byIdentifier id: UUID) -> GeoFence?
    func update(geoFence: Geofence) -> Bool
    func delete(ids: [UUID]) -> Bool
}

final class DefaultGeoFenceRepository: GeoFenceRepository {
    
    func create(geoFence: Geofence) -> Bool {
        let a = GeoFence(context: CoreDataManager.shared.context)
        a.identifier = geoFence.identifier
        a.name = geoFence.name
        a.centerLatitude = geoFence.centerLatitude
        a.centerLongitude = geoFence.centerLongitude
        a.radius = geoFence.radius
        a.userNote = geoFence.userNote
        return CoreDataManager.shared.saveContext()
    }
    
    func getAll() -> [GeoFence]? {
        guard let result = CoreDataManager.shared.fetchManagedObject(managedObject: GeoFence.self) else { return nil }
        
        print("result.count:  \(result.count)")
        
        return result
    }
    
    func get(byIdentifier id: UUID) -> GeoFence? {
        let fetchRequest = NSFetchRequest<GeoFence>(entityName: "GeoFence")
        let predicate = NSPredicate(format: "identifier==%@", id as CVarArg)

        fetchRequest.predicate = predicate
        do {
            let result = try CoreDataManager.shared.context.fetch(fetchRequest).first

            guard result != nil else {return nil}

            return result

        } catch let error {
            debugPrint(error)
        }

        return nil
    }
    
    func update(geoFence: Geofence) -> Bool {
        guard let geoFence = get(byIdentifier: geoFence.identifier) else { return false }
        
        geoFence.identifier = geoFence.identifier
        geoFence.name = geoFence.name
        geoFence.centerLatitude = geoFence.centerLatitude
        geoFence.centerLongitude = geoFence.centerLongitude
        geoFence.radius = geoFence.radius
        geoFence.userNote = geoFence.userNote
        
        return CoreDataManager.shared.saveContext()
    }
    
    func delete(ids: [UUID]) -> Bool {
        ids.forEach { id in
            if let record = get(byIdentifier: id) {
                CoreDataManager.shared.context.delete(record)
            } else {
                print(">>>> ID not found: \(id)")
            }
        }
        return CoreDataManager.shared.saveContext()
    }
}
