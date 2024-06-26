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
    @State var pageStr = ""
    @State var date = Date()
    @State var book: Book
    @State var isError: Bool = false
    @State var showMessage = false
    @State var message = ""
    
    var body: some View {
        VStack{
            VStack{
                VStack{
                    Image(uiImage: UIImage(data: book.cover!)!).resizable().scaledToFit().cornerRadius(3.0).frame(maxWidth: 200)
                }.opacity(0.8)
                
                VStack{
                    Text(book.title!).font(.title2).padding(3)
                    if book.subTitle != nil{
                        Text(book.subTitle!).font(.caption).padding(2)
                    }
                }.multilineTextAlignment(.center)
                Spacer()
                HStack{
                    Text("Page :").padding(.leading)
                    TextField(String(book.currentPage), text: $pageStr)
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
        }.padding().alert(message, isPresented: $showMessage) {}
    }
    
    private func updateHistoryAndCurrentPage(){
        if pageStr.isEmpty{
            message = "Fill in 'Page'"
            showMessage.toggle()
            return
        }else if Double(pageStr)! > book.totalPage{
            message = "'Page' can not be bigger than total page number"
            showMessage.toggle()
            return
        }

        let page = Double(pageStr)!
        
        if page <= 0 {
            message = "'Page' should be a positive number"
            showMessage.toggle()
            return
        }

        if book.history == nil || book.history?.count == 0{
            book.currentPage = page
            let history = History(context: viewContext)
            history.date = Calendar.current.startOfDay(for: date)
            history.pageNo = page
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
                    if foundIndex < 0{
                        foundIndex = index
                        return true
                    }
                }
                return false
            }.first
            
            if foundIndex >= 0{
                if isReplace{
                    if (foundIndex + 1) < book.history!.count{
                        let laterHistory = (book.history?.object(at: foundIndex + 1) as! History)
                        if page < laterHistory.pageNo{
                            if (foundIndex - 1) >= 0{
                                let prevHistory = (book.history?.object(at: foundIndex - 1) as! History)
                                if page > prevHistory.pageNo{
                                    (book.history?.object(at: foundIndex) as! History).pageNo = page
                                }else{
                                    message = "'Page' should be bigger than a previous day's page"
                                    showMessage.toggle()
                                    return
                                }
                            }else{
                                (book.history?.object(at: foundIndex) as! History).pageNo = page
                            }
                        }else{
                            message = "'Page' should be smaller than a later day's page"
                            showMessage.toggle()
                            return
                        }
                    }else{
                        if (foundIndex - 1) >= 0{
                            let prevHistory = (book.history?.object(at: foundIndex - 1) as! History)
                            if page > prevHistory.pageNo{
                                (book.history?.object(at: foundIndex) as! History).pageNo = page
                            }else{
                                message = "'Page' should be bigger than a previous day's page"
                                showMessage.toggle()
                                return
                            }
                        }else{
                            (book.history?.object(at: foundIndex) as! History).pageNo = page
                        }
                        
                        book.currentPage = page
                    }
                }else{
                    if (foundIndex - 1) >= 0{
                        let prevHistory = (book.history?.object(at: foundIndex - 1) as! History)
                        if page > prevHistory.pageNo{
                            let history = History(context: viewContext)
                            history.pageNo = page
                            history.date = Calendar.current.startOfDay(for: date)
                            
                            var newHistory = book.history?.array
                            newHistory?.insert(history, at: foundIndex)
                            book.history = NSOrderedSet(array: newHistory!)
                        }else{
                            message = "'Page' should be bigger than a previous day's page"
                            showMessage.toggle()
                            return
                        }
                    }else{
                        let history = History(context: viewContext)
                        history.pageNo = page
                        history.date = Calendar.current.startOfDay(for: date)
                        
                        var newHistory = book.history?.array
                        newHistory?.insert(history, at: foundIndex)
                        book.history = NSOrderedSet(array: newHistory!)
                    }
                }
            }else{
                if page > book.currentPage{
                    let history = History(context: viewContext)
                    history.pageNo = page
                    history.date = Calendar.current.startOfDay(for: date)
                    
                    var newHistory = book.history?.array
                    newHistory?.append(history)
                    book.history = NSOrderedSet(array: newHistory!)
                    book.currentPage = page
                }else{
                    message = "'Page' should be bigger than the current page"
                    showMessage.toggle()
                    return
                }
            }
        }
        
        do {
            book.updateDate = Date()
            try viewContext.save()
            self.presentUpdateBookStatusView.toggle()
        } catch {
            message = (error as NSError).localizedDescription
            showMessage.toggle()
            return
        }
    }
}

struct UpdateBookStatusView_Previews: PreviewProvider {
    static var previews: some View {
        UpdateBookStatusView(presentUpdateBookStatusView: .constant(true), book: PersistenceController.selectedBook!)
    }
}
