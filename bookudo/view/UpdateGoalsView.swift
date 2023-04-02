//
//  UpdateGoalsView.swift
//  bookudo
//
//  Created by Kutay Agbal on 24.02.2023.
//

import SwiftUI

struct UpdateGoalsView: View {
    @Environment(\.managedObjectContext) var viewContext
    @State var weekGoalStr: String = ""
    @State var weekendGoalStr: String = ""
    @State var book: Book
    @Binding var presentUpdateGoalsView: Bool
    
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
                }
                Spacer()
                
                HStack{
                    Text("Weekday :").padding(.leading)
                    TextField(String(getWeekdayGoal()), text: $weekGoalStr)
                        .keyboardType(.numberPad)
                        .autocapitalization(.none)
                        .padding(.leading)
                }
                HStack{
                    Text("Weekend :").padding()
                    TextField(String(getWeekendGoal()), text: $weekendGoalStr)
                        .keyboardType(.numberPad)
                        .autocapitalization(.none)
                        .padding(.leading)
                }
                
                HStack{
                    Text("Estimated End :").padding()
                    Text(getEstimatedEndDateStr()).padding()
                }.font(Font.body.bold())
            }.padding()
            
            HStack{
                Spacer()
                Button("Save      "){
                    updateGoals()
                    self.presentUpdateGoalsView.toggle()
                }.foregroundColor(.green).cornerRadius(10).padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.green, lineWidth: 1)
                )
                Spacer()
                Button("Cancel"){
                    self.presentUpdateGoalsView.toggle()
                }.foregroundColor(.red).cornerRadius(10).padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.red, lineWidth: 1)
                )
                Spacer()
            }.padding()
        }.padding()
    }
    
    private func getWeekdayGoal() -> Double{
        let weekdayGoal = book.goals!.filter({($0 as! Goal).title == "weekday"}).first
        if weekdayGoal != nil{
            return (weekdayGoal as! Goal).pageCount
        }
        
        return 0.0
    }
    
    private func getWeekendGoal() -> Double{
        let weekendGoal = book.goals!.filter({($0 as! Goal).title == "weekend"}).first
        if weekendGoal != nil{
            return (weekendGoal as! Goal).pageCount
        }
        
        return 0.0
    }
    private func updateGoals(){
        let weekGoal = Goal(context: viewContext)
        weekGoal.title = "weekday"
        weekGoal.pageCount = Double(weekGoalStr) ?? getWeekdayGoal()
        let weekendGoal = Goal(context: viewContext)
        weekendGoal.title = "weekend"
        weekendGoal.pageCount = Double(weekendGoalStr) ?? getWeekendGoal()
        book.goals = [weekGoal, weekendGoal]
        do {
            book.updateDate = Date()
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    
    private func getEstimatedEndDateStr() -> String{
        let weekGoal = Double(weekGoalStr) ?? getWeekdayGoal()
        let weekendGoal = Double(weekendGoalStr) ?? getWeekendGoal()
        
        if weekGoal > 0 || weekendGoal > 0{
            var currDate = Date()
            var totalPage = book.totalPage
            while totalPage > book.currentPage{
                if(Calendar.current.isDateInWeekend(currDate)){
                    totalPage -= weekendGoal
                }else{
                    totalPage -= weekGoal
                }
                
                if(totalPage > book.currentPage){
                    currDate = Calendar.current.date(byAdding: .day, value: 1, to: currDate)!
                }
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            return dateFormatter.string(from: currDate)
        }
        
        return ""
    }
}

struct UpdateGoalsView_Previews: PreviewProvider {
    static var previews: some View {
        UpdateGoalsView(book: PersistenceController.selectedBook!, presentUpdateGoalsView: .constant(true))
    }
}
