//
//  Goal+CoreDataProperties.swift
//  bookudo
//
//  Created by Kutay Agbal on 2.04.2023.
//
//

import Foundation
import CoreData


extension Goal {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Goal> {
        return NSFetchRequest<Goal>(entityName: "Goal")
    }

    @NSManaged public var pageCount: Double
    @NSManaged public var title: String?
    @NSManaged public var book: Book?

}

extension Goal : Identifiable {

}
