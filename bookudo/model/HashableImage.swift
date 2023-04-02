//
//  HashableImage.swift
//  bookudo
//
//  Created by Kutay Agbal on 4.02.2023.
//

import Foundation
import SwiftUI
import CoreData

struct HashableImage: Hashable{
    let image: UIImage
    let id: UUID
    var pageNo: Double?
    let objectID: NSManagedObjectID?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (img0: HashableImage, img1: HashableImage) -> Bool {
        return img0.id == img1.id
    }
}
