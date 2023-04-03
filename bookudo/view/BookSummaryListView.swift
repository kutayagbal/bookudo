//
//  ContentView.swift
//  bookudo
//
//  Created by Kutay Agbal on 17.01.2023.
//

import SwiftUI
import CoreData

struct BookSummaryListView: View {
    @Environment(\.managedObjectContext) var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(key: "updateDate", ascending: false)]
    ) var books: FetchedResults<Book>
    
    @State var presentAddBookView = false
    @State var openDetail = false
    @State var selectedBook: Book?
    
    var body: some View {
        NavigationStack {
            if books.count == 0{
                VStack{
                    Text("Add Book")
                }.foregroundColor(.blue).font(Font.title).onTapGesture {
                    presentAddBookView.toggle()
                }.toolbar {
                    ToolbarItem {
                        Button(action: openAddBookView) {
                            Label("Add Book", systemImage: "plus").font(Font.system(size: 25))
                        }
                    }
                }.sheet(isPresented: $presentAddBookView) {
                    AddBookView(presentAddBookView: $presentAddBookView)
                }
            }else{
                ScrollView{
                    ForEach(books) {book in
                        NavigationLink(destination: BookDetailView(book: book)){
                            BookSummaryListItemView(book: book)
                                .navigationTitle("BOOKS").contentShape(Rectangle())
                        }.buttonStyle(PlainButtonStyle())
                    }.toolbar {
                            ToolbarItem {
                                Button(action: openAddBookView) {
                                    Label("Add Book", systemImage: "plus").font(Font.system(size: 25))
                                }
                            }
                        }.sheet(isPresented: $presentAddBookView) {
                            AddBookView(presentAddBookView: $presentAddBookView)
                        }
                }.scrollContentBackground(.hidden).scrollIndicators(.hidden).padding()
            }
        }
        
    }
    
    private func openAddBookView(){
        presentAddBookView.toggle()
    }
}

struct BookSummaryListView_Previews: PreviewProvider {
    
    static var previews: some View {
        BookSummaryListView(selectedBook: PersistenceController.selectedBook).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

