import CoreData
import CoreSpotlight
import Foundation
import UniformTypeIdentifiers

enum SpotlightIndexer {
    static let domain = "reflections"

    static func index(_ reflection: Reflection) {
        let attributes = CSSearchableItemAttributeSet(contentType: .text)
        attributes.title = reflection.titleText
        attributes.displayName = reflection.titleText
        attributes.contentDescription = reflection.bodyText
        attributes.keywords = [reflection.categoryName, "journal", "reflection"]
        attributes.contentCreationDate = reflection.createdAt
        let identifier = reflection.id?.uuidString ?? reflection.objectID.uriRepresentation().absoluteString
        let item = CSSearchableItem(
            uniqueIdentifier: identifier,
            domainIdentifier: domain,
            attributeSet: attributes
        )
        CSSearchableIndex.default().indexSearchableItems([item], completionHandler: nil)
    }

    static func remove(id: UUID) {
        CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: [id.uuidString], completionHandler: nil)
    }
}
