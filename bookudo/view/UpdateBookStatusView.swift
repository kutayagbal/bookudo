//
//  UpdateBookStatusView.swift
//  bookudo
//
//  Created by Kutay Agbal on 1.01.2023.
//

import SwiftUI

struct UpdateBookStatusView: View {
    @Environment(\.managedObjectContext) var viewContext
    @Binding var presentUpdateBookStatusView: Bool
    @State var currentPageStr = ""
    @State var date = Date()
    @State var book: Book
    @State var isError: Bool = false
    
    var body: some View {
        VStack{
            VStack{
                VStack{
                    Image(uiImage: UIImage(data: book.cover!)!).resizable().scaledToFit().cornerRadius(3.0).frame(maxWidth: 200)
                }.opacity(0.5)
                
                VStack{
                    Text(book.title!).font(.title2).padding(3)
                    if book.subTitle != nil{
                        Text(book.subTitle!).font(.caption).padding(2)
                    }
                }.multilineTextAlignment(.center)
                Spacer()
                HStack{
                    Text("Page :").padding(.leading)
                    TextField(String(book.currentPage), text: $currentPageStr)
                            .keyboardType(.numberPad)
                            .autocapitalization(.none)
                            .padding(.leading)
                }
                
                DatePicker("Date :", selection: $date, in: ...Date.now, displayedComponents: [.date]).padding()
            }.padding()
            
            HStack{
                Spacer()
                Button("Save      "){
                    updateHistoryAndCurrentPage()
                    self.presentUpdateBookStatusView.toggle()
                }.foregroundColor(.green).cornerRadius(10).padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.green, lineWidth: 1)
                )
                Spacer()
                Button("Cancel"){
                    self.presentUpdateBookStatusView.toggle()
                }.foregroundColor(.red).cornerRadius(10).padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.red, lineWidth: 1)
                )
                Spacer()
            }.padding()
        }.padding()
    }
    
    private func updateHistoryAndCurrentPage(){
        if Double(currentPageStr)! > book.totalPage{
            return
        }

        if book.history == nil || book.history?.count == 0{
            book.currentPage = Double(currentPageStr)!
            let history = History(context: viewContext)
            history.date = Calendar.current.startOfDay(for: date)
            history.pageNo = Double(currentPageStr)!
            book.history = NSOrderedSet(set: [history])
        }else{
            var foundIndex = -1
            var isReplace = false
            let _ = book.history?.array.enumerated().filter{(index, element) in
                let comparisonResult = Calendar.current.compare((element as! History).date!, to: date, toGranularity: .day)
                if comparisonResult == ComparisonResult.orderedSame{
                    foundIndex = index
                    isReplace = true
                    return true
                }else if comparisonResult == ComparisonResult.orderedDescending{
                    foundIndex = index
                    return true
                }
                    return false
            }.first
            
            if foundIndex >= 0{
                if ((book.history?.object(at: foundIndex) as! History).pageNo) > Double(currentPageStr)!{
                    if isReplace{
                        (book.history?.object(at: foundIndex) as! History).pageNo = Double(currentPageStr)!
                    }else{
                        let history = History(context: viewContext)
                        history.pageNo = Double(currentPageStr)!
                        history.date = Calendar.current.startOfDay(for: date)
                        
                        var newHistory = book.history?.array
                        newHistory?.insert(history, at: foundIndex)
                        book.history = NSOrderedSet(array: newHistory!)
                    }
                }
            }else{
                let history = History(context: viewContext)
                history.pageNo = Double(currentPageStr)!
                history.date = Calendar.current.startOfDay(for: date)
                
                var newHistory = book.history?.array
                newHistory?.append(history)
                book.history = NSOrderedSet(array: newHistory!)
                book.currentPage = Double(currentPageStr)!
            }
        }
        
        do {
            book.updateDate = Date()
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

struct UpdateBookStatusView_Previews: PreviewProvider {
    static var previews: some View {
        UpdateBookStatusView(presentUpdateBookStatusView: .constant(true), book: PersistenceController.selectedBook!)
    }
}
