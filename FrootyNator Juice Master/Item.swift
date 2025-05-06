import Foundation
import CoreData

@objc(Item)
public class Item: NSManagedObject {
}
import Foundation
import CoreData

extension Item {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Item> {
        return NSFetchRequest<Item>(entityName: "Item")
    }

    @NSManaged public var timestamp: Date?
}

extension Item: Identifiable {
}
