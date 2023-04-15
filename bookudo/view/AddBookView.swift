//
//  AddBookView.swift
//  bookudo
//
//  Created by Kutay Agbal on 20.01.2023.
//

import SwiftUI

struct AddBookView: View {
    @Environment(\.managedObjectContext) var viewContext
    
    @Binding var presentAddBookView: Bool
    @State var presentImagePicker: Bool = false
    @State var title = ""
    @State var subTitle = ""
    @State var unitIndex = 1
    @State var totalPageStr = ""
    @State var units: [Unit] = []
    @State var estimatedEndDate = Date()
    @State var unitTitle = ""
    @State var unitStartPageStr = ""
    @State var weekGoalStr = ""
    @State var weekendGoalStr = ""
    @State var images = [HashableImage]()
    @FocusState private var focusToUnitTitle: Bool
    @State var showMessage = false
    @State var message = ""
    
    var body: some View {
        VStack{
            VStack{
                Spacer()
                if images.isEmpty{
                    HStack{
                        Button("Cover Image"){
                            presentImagePicker.toggle()
                        }.foregroundColor(.green).cornerRadius(10).padding(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(.green, lineWidth: 1))
                    }.padding(.top)
                }else{
                    VStack{
                        VStack{
                            Image(uiImage: images[0].image).resizable().scaledToFit().cornerRadius(10.0)
                            .frame(maxHeight: 200)
                        }.padding(5).opacity(0.8)
                        Spacer()
                        HStack{
                            Button(action: removeCoverImage) {
                                Image(systemName: "minus").font(Font.title2).foregroundColor(.red).padding([.top,.bottom], 7)
                            }.padding(3).overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(.red, lineWidth: 1))
                        }.padding([.top, .leading], 3)
                    }
                }
                Spacer()
                HStack{
                    Text("Title :")
                    TextField(title, text: $title).autocapitalization(.words)
                }.padding(.top, 10).frame(height: 30)
                HStack{
                    Text("Sub Title :")
                    TextField(subTitle, text: $subTitle).autocapitalization(.words)
                }.frame(height: 20)
                HStack{
                    Text("Total Page :")
                    TextField(totalPageStr, text: $totalPageStr)
                        .keyboardType(.numberPad)
                }.frame(height: 20)
                
                HStack{
                    Text("Goals")
                    Spacer()
                }.frame(height: 15)

                VStack{
                    HStack{
                        Text("weekday :").padding(.leading, 50)
                        TextField(weekGoalStr, text: $weekGoalStr)
                            .keyboardType(.numberPad)
                    }.frame(height: 15)
                    HStack{
                        Text("weekend :").padding(.leading, 50)
                        TextField(weekendGoalStr, text: $weekendGoalStr)
                            .keyboardType(.numberPad)
                    }.frame(height: 15)
                }

                if !totalPageStr.isEmpty{
                    HStack{
                        Spacer()
                        Text("Estimated End Date :")
                        Text(getEstimatedEndDateStr())
                    }.frame(height: 10)
                }
                
                VStack{
                    HStack{
                        Text("Chapters")
                        Spacer()
                    }.frame(height: 10)
                    VStack{
                        HStack{
                            VStack{
                                HStack{
                                    Text("Title :").padding(.leading, 15)
                                    TextField(unitTitle, text: $unitTitle).autocapitalization(.words).focused($focusToUnitTitle)
                                }.frame(height: 15)
                                HStack{
                                    Text("Start Page :").padding(.leading, 15)
                                    TextField(unitStartPageStr, text: $unitStartPageStr)
                                        .keyboardType(.numberPad)
                                }.frame(height: 15).padding(.top, 2)
                            }
                            
                            Button(action: addUnit) {
                                Image(systemName: "plus").font(Font.title2)
                            }.padding(3).overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(.blue, lineWidth: 1))
                        }
                        ScrollView{
                            ForEach(units.reversed()){unit in
                                HStack{
                                    Text(unit.title!)
                                    Spacer()
                                    Text(String(unit.startPage))
                                }.padding([.leading, .trailing], 20).padding(.top, 1)
                            }.padding(.top, 2)
                        }.frame(minHeight: 20, maxHeight: 150).overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.blue, lineWidth: 1)).scrollContentBackground(.hidden).scrollIndicators(.hidden)
                    }.font(.system(size: 13))
                    
                    HStack{
                        Button(action: removeLastUnit) {
                            Image(systemName: "minus").font(Font.title2).foregroundColor(.red).padding([.top,.bottom], 7)
                        }.padding(3).overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.red, lineWidth: 1))
                        Spacer()
                    }.padding(.top, 3)
                    Spacer()
                }
            }.transition(.scale).padding([.leading,.trailing], 25)
                .sheet(isPresented: $presentImagePicker){
                    ImagePicker(images: self.$images)
            }
            
            HStack{
                Spacer()
                Button("Save      "){
                    saveBook()
                }.foregroundColor(.green).cornerRadius(10).padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.green, lineWidth: 1)
                )
                Spacer()
                Button("Cancel"){
                    self.presentAddBookView.toggle()
                }.foregroundColor(.red).cornerRadius(10).padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.red, lineWidth: 1)
                )
                Spacer()
            }.padding()
            
            Spacer()
        }.alert(message, isPresented: $showMessage) {}
    }
    
    private func removeCoverImage(){
        withAnimation {
            images = []
        }
    }
    
    private func saveBook(){
        if images.isEmpty{
            message = "Add a 'Cover Image'"
            showMessage.toggle()
            return
        }else if title.isEmpty{
            message = "Fill in 'Title' for book"
            showMessage.toggle()
            return
        }else if totalPageStr.isEmpty{
            message = "Fill in 'Total Page'"
            showMessage.toggle()
            return
        }
        
        let totalPage = Double(totalPageStr) ?? 0
        
        if totalPage > 0{
            let book = Book(context: viewContext)
            book.cover = images[0].image.jpegData(compressionQuality: 0.0)
            book.title = title
            book.subTitle = subTitle
            book.totalPage = totalPage
            book.currentPage = 0
            book.units = NSOrderedSet(array: units.sorted{
                $0.startPage < $1.startPage
            })
            
            let weekGoal = Goal(context: viewContext)
            weekGoal.title = "weekday"
            weekGoal.pageCount = Double(weekGoalStr) ?? 0
            let weekendGoal = Goal(context: viewContext)
            weekendGoal.title = "weekend"
            weekendGoal.pageCount = Double(weekendGoalStr) ?? 0
            book.goals = [weekGoal, weekendGoal]
            do {
                book.updateDate = Date()
                try viewContext.save()
            } catch {
                message = (error as NSError).localizedDescription
                showMessage.toggle()
                return
            }
        }else{
            message = "'Total Page' should be a positive number"
            showMessage.toggle()
            return
        }
        
        self.presentAddBookView.toggle()
    }
    
    private func addUnit(){
        if totalPageStr.isEmpty{
            message = "Fill in 'Total Page'"
            showMessage.toggle()
            return
        }else if unitTitle.isEmpty{
            message = "Fill in 'Title' for chapter"
            showMessage.toggle()
            return
        }else if unitStartPageStr.isEmpty{
            message = "Fill in 'Start Page'"
            showMessage.toggle()
            return
        }
        
        let startPage = Double(unitStartPageStr) ?? 0
        
        if startPage > 0{
            if units.isEmpty{
                let preface = Unit(context: viewContext)
                preface.title = "0. " + "Preface"
                preface.startPage = 0
                preface.endPage = startPage
                units.append(preface)
            }
            
            let unit = Unit(context: viewContext)
            unit.title = String(unitIndex) + ". " + unitTitle
            unit.startPage = startPage
            unit.endPage = Double(totalPageStr)!
            
            if units.count > 1{
                units.last?.endPage = startPage - 1
            }
            self.units.append(unit)
            
            unitIndex += 1
            unitTitle = ""
            unitStartPageStr = ""
            focusToUnitTitle = true
        }else{
            message = "'Start Page' should be a positive number"
            showMessage.toggle()
            return
        }
    }
    
    private func removeLastUnit(){
        if !units.isEmpty{
            units.removeLast()
            unitIndex -= 1
        }
    }
    
    
    private func getEstimatedEndDateStr() -> String{
        if !totalPageStr.isEmpty{
            var totalPage = Double(totalPageStr) ?? 0
            if totalPage > 0{
                let weekGoal = Double(weekGoalStr) ?? 0
                let weekendGoal = Double(weekendGoalStr) ?? 0
                
                if weekGoal > 0 || weekendGoal > 0{
                    var currDate = Date()
                    while totalPage > 0{
                        if(Calendar.current.isDateInWeekend(currDate)){
                            totalPage -= weekendGoal
                        }else{
                            totalPage -= weekGoal
                        }
                        
                        if(totalPage > 0){
                            currDate = Calendar.current.date(byAdding: .day, value: 1, to: currDate)!
                        }
                    }
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateStyle = .medium
                    return dateFormatter.string(from: currDate)
                }
            }
        }
        
        return ""
    }
}

struct AddBookView_Previews: PreviewProvider {
    static var previews: some View {
        AddBookView(presentAddBookView: .constant(true)).previewDevice(PreviewDevice(rawValue: "iPhone 12 mini"))
        
        AddBookView(presentAddBookView: .constant(true)).previewDevice(PreviewDevice(rawValue: "iPhone 14 Plus"))
    }
}
