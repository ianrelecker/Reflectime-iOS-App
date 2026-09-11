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
        do {
            try context.save()
            SpotlightIndexer.reindex(context: context)
        } catch {
            context.rollback()
            throw ReflectionStoreError.saveFailed(error.localizedDescription)
        }
    }

    func delete(_ object: NSManagedObject) throws {
        if let reflection = object as? Reflection, let id = reflection.id {
            SpotlightIndexer.remove(id: id)
        }
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
