import CoreData
import Foundation

@MainActor
final class DataController: ObservableObject {
    let container: NSPersistentCloudKitContainer
    @Published var storeError: ReflectionStoreError?

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "Reflectime")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        if let description = container.persistentStoreDescriptions.first {
            description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
            description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
            if !inMemory {
                description.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(
                    containerIdentifier: "iCloud.Reflectime"
                )
            }
        }

        container.loadPersistentStores { [weak self] _, error in
            Task { @MainActor in
                if let error {
                    self?.storeError = .storeLoadFailed(error.localizedDescription)
                }
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.transactionAuthor = "app"
        container.viewContext.name = "viewContext"
    }

    func save() throws {
        let context = container.viewContext
        guard context.hasChanges else { return }

        let changed = context.insertedObjects.union(context.updatedObjects).compactMap { $0 as? Reflection }
        let deletedIDs = context.deletedObjects.compactMap { ($0 as? Reflection)?.id }

        do {
            try context.save()
            for id in deletedIDs {
                SpotlightIndexer.remove(id: id)
            }
            for reflection in changed {
                SpotlightIndexer.index(reflection)
            }
        } catch {
            context.rollback()
            throw ReflectionStoreError.saveFailed(error.localizedDescription)
        }
    }

    func delete(_ object: NSManagedObject) throws {
        container.viewContext.delete(object)
        try save()
    }

    func seedDefaultPromptsIfNeeded() throws {
        let request = Motivations.fetchRequest()
        request.fetchLimit = 1
        let existing = try container.viewContext.count(for: request)
        guard existing == 0 else { return }

        for prompt in ReflectionDefaults.prompts {
            let item = Motivations(context: container.viewContext)
            item.item = prompt
            item.date = Date()
        }
        try save()
    }
}
