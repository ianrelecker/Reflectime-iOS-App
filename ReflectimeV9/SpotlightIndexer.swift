import CoreData
import CoreSpotlight
import Foundation
import UniformTypeIdentifiers

enum SpotlightIndexer {
    static let domain = "reflections"

    static func reindex(context: NSManagedObjectContext) {
        let request = Reflection.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Reflection.date, ascending: false)]
        let items = (try? context.fetch(request)) ?? []
        let searchable = items.map { reflection -> CSSearchableItem in
            let attributes = CSSearchableItemAttributeSet(contentType: .text)
            attributes.title = reflection.titleText
            attributes.displayName = reflection.titleText
            attributes.contentDescription = reflection.bodyText
            attributes.keywords = [reflection.categoryName, "journal", "reflection"]
            attributes.contentCreationDate = reflection.createdAt
            let identifier = reflection.id?.uuidString ?? reflection.objectID.uriRepresentation().absoluteString
            return CSSearchableItem(
                uniqueIdentifier: identifier,
                domainIdentifier: domain,
                attributeSet: attributes
            )
        }
        let index = CSSearchableIndex.default()
        index.deleteSearchableItems(withDomainIdentifiers: [domain]) { _ in
            guard !searchable.isEmpty else { return }
            index.indexSearchableItems(searchable, completionHandler: nil)
        }
    }

    static func remove(id: UUID) {
        CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: [id.uuidString], completionHandler: nil)
    }
}
