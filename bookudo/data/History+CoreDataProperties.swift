//
//  History+CoreDataProperties.swift
//  bookudo
//
//  Created by Kutay Agbal on 3.04.2023.
//
//

import Foundation
import CoreData


extension History {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<History> {
        return NSFetchRequest<History>(entityName: "History")
    }

    @NSManaged public var date: Date?
    @NSManaged public var pageNo: Double
    @NSManaged public var book: Book?

}

extension History : Identifiable {

}
