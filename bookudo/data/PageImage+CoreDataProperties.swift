//
//  PageImage+CoreDataProperties.swift
//  bookudo
//
//  Created by Kutay Agbal on 3.04.2023.
//
//

import Foundation
import CoreData


extension PageImage {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PageImage> {
        return NSFetchRequest<PageImage>(entityName: "PageImage")
    }

    @NSManaged public var data: Data?
    @NSManaged public var pageNo: Double
    @NSManaged public var book: Book?

}

extension PageImage : Identifiable {

}
