//
//  Persistence.swift
//  bookudo
//
//  Created by Kutay Agbal on 17.01.2023.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var selectedBook: Book? = nil
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        var book = Book(context: viewContext)
        book.title = "Test test test"
        book.currentPage = 0
        book.totalPage = 498
        
        let weekGoal = Goal(context: viewContext)
        weekGoal.title = "weekday"
        weekGoal.pageCount = 2
        
        let weekendGoal = Goal(context: viewContext)
        weekendGoal.title = "weekend"
        weekendGoal.pageCount = 4
        
        let unit1 = Unit(context: viewContext)
        unit1.title = "Unit Unit 1"
        unit1.endPage = 22
        
        let unit2 = Unit(context: viewContext)
        unit2.title = "Unit unit2"
        unit2.endPage = 44

        book.goals = [weekGoal, weekendGoal]
        book.units = [unit1, unit2]
        do {
            book.updateDate = Date()
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        
        selectedBook = book
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "bookudo")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
