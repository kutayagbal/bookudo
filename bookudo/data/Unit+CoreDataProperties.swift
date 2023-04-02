//
//  Unit+CoreDataProperties.swift
//  bookudo
//
//  Created by Kutay Agbal on 3.04.2023.
//
//

import Foundation
import CoreData


extension Unit {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Unit> {
        return NSFetchRequest<Unit>(entityName: "Unit")
    }

    @NSManaged public var endPage: Double
    @NSManaged public var startPage: Double
    @NSManaged public var title: String?
    @NSManaged public var book: Book?

}

extension Unit : Identifiable {

}
