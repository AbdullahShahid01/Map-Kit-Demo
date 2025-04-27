//
//  CoreDataManager.swift
//  Map Kit Demo
//
//  Created by Abdullah-Shahid  on 27/04/2025.
//

import CoreData

final class CoreDataManager {
    enum CDEntities: String, CaseIterable {
        case GeoFence = "GeoFence"
    }
    
    static let shared = CoreDataManager()
    let persistentContainer: NSPersistentContainer
    let context: NSManagedObjectContext
    
    private init(){
        persistentContainer = NSPersistentContainer(name: "MapKitData")
        persistentContainer.loadPersistentStores { description, error in
            if let error {
                fatalError("Error Initializing DataModel \(error)")
            }
        }
        context = persistentContainer.viewContext
    }
    
    func saveContext () -> Bool {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                debugPrint("Unresolved error \(nserror), \(nserror.userInfo)")
                return false
            }
        }
        return true
    }
    
    func fetchManagedObject<T: NSManagedObject>(managedObject: T.Type) -> [T]? {
        do {
            guard let result = try context.fetch(managedObject.fetchRequest()) as? [T] else {return nil}
            
            return result
            
        } catch let error {
            debugPrint(error)
        }
        
        return nil
    }
    
    func deleteAllDataFor(_ entity: CDEntities) {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity.rawValue)
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(batchDeleteRequest)
        } catch {
            print("Detele all data in \(entity) error :", error)
        }
    }
    
    func clearDatabase() {
        CDEntities.allCases.forEach { entity in
            deleteAllDataFor(entity)
        }
    }
}

