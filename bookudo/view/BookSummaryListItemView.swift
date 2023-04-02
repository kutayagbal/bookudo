//
//  BookSummaryListItemView.swift
//  bookudo
//
//  Created by Kutay Agbal on 1.01.2023.
//

import SwiftUI

struct BookSummaryListItemView: View {
    @ObservedObject var book: Book
    @State var avgSpeedGoal: Double = 0
    
    var body: some View {
        let currentPage = book.currentPage
        let currentPageGoal: Double = getCurrentPageGoal()
        let totalPage = book.totalPage
        let avgSpeed = getAvarageSpeed()
        
        VStack{
            if book.title != nil{
                Text(book.title!).font(Font.headline)
                if book.subTitle != nil{
                    Text(book.subTitle!).font(Font.subheadline)
                }
                
                Divider().frame(minHeight: 1)
                    .background(.yellow)
                
                HStack{
                    VStack{
                        Image(uiImage: UIImage(data: book.cover!)!).resizable().scaledToFit().cornerRadius(3.0).frame(maxWidth: 135)
                    }.opacity(0.7)
                    VStack{
                        HStack{
                            VStack{
                                HStack{
                                    Text("Progress :").font(Font.caption2.bold()).padding(.leading, 3)
                                    Spacer()
                                }.frame(height: 10)
                                Text(String(format:"%.2f", currentPage)).font(Font.system(size: 14).bold()).frame(height: 10)
                                Text(String(format:"%.2f", totalPage)).font(Font.system(size: 14).bold()).padding(.top, 1).frame(height: 10)
                            }
                            
                            if currentPage > currentPageGoal{
                                Text(getPercentStr()).font(Font.system(size: 15).bold()).foregroundColor(.green).padding(.top)
                            }else if currentPage < currentPageGoal{
                                Text(getPercentStr()).font(Font.system(size: 15).bold()).foregroundColor(.red).padding(.top)
                            }else{
                                Text(getPercentStr()).font(Font.system(size: 15).bold()).padding(.top)
                            }
                        }
                        
                        HStack{
                            Text("Speed :").font(Font.caption2.bold()).padding(.leading, 3)
                            Spacer()
                            if currentPage > 0 {
                                if avgSpeed > avgSpeedGoal{
                                    Text(String(format: "%.2f", avgSpeed)).font(Font.body.bold()).foregroundColor(.green)
                                }else if avgSpeed < avgSpeedGoal{
                                    Text(String(format: "%.2f", avgSpeed)).font(Font.body.bold()).foregroundColor(.red)
                                }else{
                                    Text(String(format: "%.2f", avgSpeed)).font(Font.body.bold())
                                }
                            }else{
                                Text(String(format: "%.2f", avgSpeed)).font(Font.body.bold())
                            }
                        }.padding(.bottom, 1).frame(height: 10)
                        
                        GoalsView(goals: book.goals!, avgSpeedGoal: avgSpeedGoal).padding(.bottom, 1).padding(.leading, 3)
                        
                        HStack{
                            Text("Last :").font(Font.caption2.bold()).padding(.leading, 3)
                            Spacer()
                            Text(getLastProgressDateStr()).font(Font.body.bold())
                        }.padding(.bottom, 2).frame(height: 10)
                        
                        HStack{
                            Text("End :").font(Font.caption2.bold()).padding(.leading, 3)
                            Spacer()
                            Text(getEstimatedEndDateStr()).font(Font.body.bold())
                        }.padding(.bottom, 2).frame(height: 10)
                    }
                }.padding([.top, .bottom], 5).padding([.leading, .trailing], 3)
            }
        }.padding().overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.yellow, lineWidth: 2)
        ).background(
            RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Color(UIColor.systemGray6))
        ).onAppear(perform: setAvgSpeedGoal).padding()
    }
    
    private func getCurrentPageGoal() -> Double{
        if book.history == nil || book.history?.count == 0{
            return 0
        }
        
        let weekGoal: Double = (book.goals!.filter({($0 as! Goal).title == "weekday"}).first! as! Goal).pageCount
        let weekendGoal: Double = (book.goals!.filter({($0 as! Goal).title == "weekend"}).first! as! Goal).pageCount
        
        var progressDate = (book.history?.array.first as! History).date!
        
        var page = 0.0
        while progressDate.compare(Date()) == .orderedAscending{
            if Calendar.current.isDateInWeekend(progressDate){
                page += weekendGoal
            }else{
                page += weekGoal
            }
            progressDate = Calendar.current.date(byAdding: .day,value: 1, to: progressDate)!
        }
        
        return page
    }
    
    private func getAvarageSpeed() -> Double{
        if book.history == nil || book.history?.count == 0{
            return 0
        }
        
        let firstProgressDate = (book.history?.array.first as! History).date
        let dayDiff = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: firstProgressDate!), to: Date()).day
        if dayDiff == 0{
            return book.currentPage
        }
        
        return  book.currentPage / (Double(dayDiff!) + 1)
    }
    
    private func getPercentStr() -> String{
        return "% " + String(format:"%.2f", book.currentPage  * 100 / book.totalPage)
    }
    
    private func setAvgSpeedGoal(){
        if book.goals != nil && book.goals!.count > 0{
            let weekGoal: Double = (book.goals!.filter({($0 as! Goal).title == "weekday"}).first! as! Goal).pageCount
            let weekendGoal: Double = (book.goals!.filter({($0 as! Goal).title == "weekend"}).first! as! Goal).pageCount
            avgSpeedGoal = ((5 * weekGoal) + (2 * weekendGoal)) / 7
        }
    }
    
    private func getLastProgressDateStr() -> String{
        if book.history != nil{
            if book.history!.count > 0{
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .medium
                return dateFormatter.string(from: ((book.history?.lastObject as! History).date)!)
            }
        }
        return ""
    }

    private func getEstimatedEndDateStr() -> String{
        let weekGoal: Goal = book.goals?.allObjects.filter({($0 as! Goal).title == "weekday"}).first as! Goal
        let weekendGoal: Goal = book.goals?.allObjects.filter({($0 as! Goal).title == "weekend"}).first as! Goal
        
        if weekGoal.pageCount > 0 || weekendGoal.pageCount > 0{
            var currDate = Date()
            var totalPage = book.totalPage
            while totalPage > book.currentPage{
                if(Calendar.current.isDateInWeekend(currDate)){
                    totalPage -= weekendGoal.pageCount
                }else{
                    totalPage -= weekGoal.pageCount
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

struct BookSummaryListItemView_Previews: PreviewProvider {
    static var previews: some View {
        BookSummaryListItemView(book: PersistenceController.selectedBook!)
        
        BookSummaryListItemView(book: PersistenceController.selectedBook!).previewDevice(PreviewDevice(rawValue: "iPhone 14 Plus"))
            .previewDisplayName("iPhone 14 Plus")
    }
}
