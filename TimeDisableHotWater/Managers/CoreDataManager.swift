//
//  CoreDataManager.swift
//  TimeDisableHotWater
//
//  Created by Vadim Denisov on 04.09.2020.
//  Copyright © 2020 Vadim Denisov. All rights reserved.
//

import Foundation
import CoreData

class CoreDataManager {
    
    static let shared = CoreDataManager()
    
    private init() { }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TimeDisableHotWater")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    var context: NSManagedObjectContext {
        get {
            return persistentContainer.viewContext
        }
    }

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func insert(schedules: [Schedule]) {
        for (index, schedule) in schedules.enumerated() {
            let scheduleEntity = ScheduleEntity(context: context)
            scheduleEntity.map(with: schedule)
            scheduleEntity.orderIndex = Int64(index)
        }
        
        saveContext()
    }
    
    func fetchSchedules() -> [Schedule]? {
        let request = ScheduleEntity.fetchRequest() as NSFetchRequest<ScheduleEntity>
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(ScheduleEntity.orderIndex), ascending: true)]
        let scheduleEntities = try? context.fetch(request)
        let schedules = scheduleEntities?.compactMap { Schedule(from: $0) }
        return schedules
    }
    
    func deleteAllSchedules() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ScheduleEntity")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        _ = try? context.execute(deleteRequest)
        saveContext()
    }
    
}
