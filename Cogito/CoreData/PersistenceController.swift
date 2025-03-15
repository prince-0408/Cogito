import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "CogitoDataModel")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Error loading Core Data stores: \(error.localizedDescription)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    // MARK: - Helper Methods
    
    func save() {
        let context = container.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
                print("Successfully saved context")
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
    
    // Delete all data
    func deleteAllData() {
        let entities = container.managedObjectModel.entities
        entities.compactMap({ $0.name }).forEach(deleteAllEntities)
    }
    
    private func deleteAllEntities(_ entityName: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try container.viewContext.execute(batchDeleteRequest)
            save()
        } catch {
            print("Error deleting all entities for \(entityName): \(error)")
        }
    }
    
    // For testing and previews
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let context = controller.container.viewContext
        
        // Create sample tasks
        let sampleTasks = [
            Task(
                title: "Team Meeting",
                description: "Weekly team sync to discuss project progress",
                category: .work,
                priority: .medium,
                dueDate: Date().addingTimeInterval(3600)
            ),
            Task(
                title: "Gym Session",
                description: "Cardio and strength training",
                category: .health,
                priority: .low,
                dueDate: Date().addingTimeInterval(86400)
            ),
            Task(
                title: "Pay Rent",
                description: "Transfer monthly rent payment",
                category: .finance,
                priority: .high,
                dueDate: Date().addingTimeInterval(172800)
            )
        ]
        
        for task in sampleTasks {
            let _ = TaskEntity.create(from: task, in: context)
        }
        
        do {
            try context.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        
        return controller
    }()
}

