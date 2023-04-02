//
//  Book+CoreDataProperties.swift
//  bookudo
//
//  Created by Kutay Agbal on 2.04.2023.
//
//

import Foundation
import CoreData


extension Book {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Book> {
        return NSFetchRequest<Book>(entityName: "Book")
    }

    @NSManaged public var title: String?
    @NSManaged public var subTitle: String?
    @NSManaged public var totalPage: Double
    @NSManaged public var currentPage: Double
    @NSManaged public var cover: Data?
    @NSManaged public var updateDate: Date?
    @NSManaged public var goals: NSSet?
    @NSManaged public var history: NSOrderedSet?
    @NSManaged public var images: NSSet?
    @NSManaged public var units: NSOrderedSet?

}

// MARK: Generated accessors for goals
extension Book {

    @objc(addGoalsObject:)
    @NSManaged public func addToGoals(_ value: Goal)

    @objc(removeGoalsObject:)
    @NSManaged public func removeFromGoals(_ value: Goal)

    @objc(addGoals:)
    @NSManaged public func addToGoals(_ values: NSSet)

    @objc(removeGoals:)
    @NSManaged public func removeFromGoals(_ values: NSSet)

}

// MARK: Generated accessors for history
extension Book {

    @objc(insertObject:inHistoryAtIndex:)
    @NSManaged public func insertIntoHistory(_ value: History, at idx: Int)

    @objc(removeObjectFromHistoryAtIndex:)
    @NSManaged public func removeFromHistory(at idx: Int)

    @objc(insertHistory:atIndexes:)
    @NSManaged public func insertIntoHistory(_ values: [History], at indexes: NSIndexSet)

    @objc(removeHistoryAtIndexes:)
    @NSManaged public func removeFromHistory(at indexes: NSIndexSet)

    @objc(replaceObjectInHistoryAtIndex:withObject:)
    @NSManaged public func replaceHistory(at idx: Int, with value: History)

    @objc(replaceHistoryAtIndexes:withHistory:)
    @NSManaged public func replaceHistory(at indexes: NSIndexSet, with values: [History])

    @objc(addHistoryObject:)
    @NSManaged public func addToHistory(_ value: History)

    @objc(removeHistoryObject:)
    @NSManaged public func removeFromHistory(_ value: History)

    @objc(addHistory:)
    @NSManaged public func addToHistory(_ values: NSOrderedSet)

    @objc(removeHistory:)
    @NSManaged public func removeFromHistory(_ values: NSOrderedSet)

}

// MARK: Generated accessors for images
extension Book {

    @objc(addImagesObject:)
    @NSManaged public func addToImages(_ value: PageImage)

    @objc(removeImagesObject:)
    @NSManaged public func removeFromImages(_ value: PageImage)

    @objc(addImages:)
    @NSManaged public func addToImages(_ values: NSSet)

    @objc(removeImages:)
    @NSManaged public func removeFromImages(_ values: NSSet)

}

// MARK: Generated accessors for units
extension Book {

    @objc(insertObject:inUnitsAtIndex:)
    @NSManaged public func insertIntoUnits(_ value: Unit, at idx: Int)

    @objc(removeObjectFromUnitsAtIndex:)
    @NSManaged public func removeFromUnits(at idx: Int)

    @objc(insertUnits:atIndexes:)
    @NSManaged public func insertIntoUnits(_ values: [Unit], at indexes: NSIndexSet)

    @objc(removeUnitsAtIndexes:)
    @NSManaged public func removeFromUnits(at indexes: NSIndexSet)

    @objc(replaceObjectInUnitsAtIndex:withObject:)
    @NSManaged public func replaceUnits(at idx: Int, with value: Unit)

    @objc(replaceUnitsAtIndexes:withUnits:)
    @NSManaged public func replaceUnits(at indexes: NSIndexSet, with values: [Unit])

    @objc(addUnitsObject:)
    @NSManaged public func addToUnits(_ value: Unit)

    @objc(removeUnitsObject:)
    @NSManaged public func removeFromUnits(_ value: Unit)

    @objc(addUnits:)
    @NSManaged public func addToUnits(_ values: NSOrderedSet)

    @objc(removeUnits:)
    @NSManaged public func removeFromUnits(_ values: NSOrderedSet)

}

extension Book : Identifiable {

}
