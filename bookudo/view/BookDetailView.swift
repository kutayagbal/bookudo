//
//  BookDetailView.swift
//  bookudo
//
//  Created by Kutay Agbal on 31.12.2022.
//

import SwiftUI
import CoreData

struct BookDetailView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) var viewContext
    @State var book: Book
    @State var presentConfirmDelete = false
    @State var presentUpdateBookStatusView = false
    @State var presentAddImageView = false
    @State var presentPageImagesView = false
    @State var presentUpdateGoalsView = false
    @State var chartType: ChartType = .WEEKLY
    @State var refresh = false
    @State var weeklyChartData: [ChartData] = []
    @State var monthlyChartData: [ChartData] = []
    @State var weeklyChartXScale: [Date] = []
    @State var monthlyChartXScale: [Date] = []
    @State var weeklyGoalChartData: [ChartData] = []
    @State var monthlyGoalChartData: [ChartData] = []
    @State var weeklySpeedChartData: [ChartData] = []
    @State var weeklySpeedGoalChartData: [ChartData] = []
    @State var monthlySpeedChartData: [ChartData] = []
    @State var monthlySpeedGoalChartData: [ChartData] = []
    
    var body: some View {
        ScrollView{
        VStack{
            VStack{
                if book.cover != nil{
                    VStack{
                        Image(uiImage: UIImage(data: book.cover!)!).resizable().scaledToFit().cornerRadius(3.0).frame(maxWidth: 150)
                    }.opacity(0.8)
                }

                VStack{
                    Text(book.title ?? "").font(.system(size: 23)).padding(.top,3)
                    if book.subTitle != nil{
                        Text(book.subTitle!).font(.system(size: 16))
                    }
                }.multilineTextAlignment(.center)
                
                Divider().padding([.bottom, .leading, .trailing])
                HStack{
                    Button(action: openAddImageView) {
                        Image(systemName: "plus").font(Font.title2)
                    }.padding(16).overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.blue, lineWidth: 1))
                    

                    Spacer()
                    Button("Images") {
                        presentPageImagesView.toggle()
                            }.foregroundColor(.blue).cornerRadius(10).padding().overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(.blue, lineWidth: 1)
                        )
                    Spacer()
                    Button("Goals") {
                        presentUpdateGoalsView.toggle()
                            }.foregroundColor(.green).cornerRadius(10).padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.green, lineWidth: 1)
                    )
                    Spacer()
                    Button("Progress") {
                        presentUpdateBookStatusView.toggle()
                            }.foregroundColor(.green).cornerRadius(10).padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.green, lineWidth: 1)
                    )
                    
                }.padding([.leading, .trailing], 30)
            }
            Spacer()
                VStack{
                    Picker("", selection: $chartType) {
                        ForEach(ChartType.allCases, id: \.self) {
                            Text($0.rawValue)
                                    }
                    }.font(.caption)
                    if chartType == .WEEKLY{
                        VStack{
                            ProgressGoalChartView(showPoints: true, chartName: "Progress", chartData: weeklyChartData, goalData: weeklyGoalChartData, xAxisScale: weeklyChartXScale)
                            ProgressGoalChartView(showPoints: true, chartName: "Speed", chartData: weeklySpeedChartData, goalData: weeklySpeedGoalChartData, xAxisScale: weeklyChartXScale)
                        }.frame(minHeight: 500)
                    }else if chartType == .MONTHLY{
                        VStack{
                            ProgressGoalChartView(showPoints: false, chartName: "Progress", chartData: monthlyChartData, goalData: monthlyGoalChartData, xAxisScale: nil)
                            ProgressGoalChartView(showPoints: false, chartName: "Speed", chartData: monthlySpeedChartData, goalData: monthlySpeedGoalChartData, xAxisScale: nil)
                        }.frame(minHeight: 500)
                    }
                }.padding()
        }.toolbar {
            ToolbarItem {
                Button(action: presentConfirmation) {
                    Label("Delete Book", systemImage: "minus").foregroundColor(.red).font(Font.system(size: 25))
                }
            }
        }.onAppear(perform:createProgressData).sheet(isPresented: $presentUpdateBookStatusView, onDismiss: onDissmiss) {
            UpdateBookStatusView(presentUpdateBookStatusView: $presentUpdateBookStatusView, book: book)
        }.sheet(isPresented: $presentAddImageView, onDismiss: onDissmiss) {
            AddImageView(book: book, presentAddImageView: $presentAddImageView)
        }.sheet(isPresented: $presentPageImagesView, onDismiss: onDissmiss) {
            PageImagesView(book: book, presentPageImagesView: $presentPageImagesView)
        }.sheet(isPresented: $presentUpdateGoalsView, onDismiss: onDissmiss){
            UpdateGoalsView(book: book, presentUpdateGoalsView: $presentUpdateGoalsView)
        }.confirmationDialog("", isPresented: $presentConfirmDelete){
            Button("Delete book", role: .destructive) {
                deleteBook()
            }
        }
    }.scrollIndicators(.hidden)
    }
    
    private func presentConfirmation(){
        presentConfirmDelete = true
    }
    
    private func deleteBook(){
        viewContext.delete(book)
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        
        DispatchQueue.main.async {
            self.dismiss()
        }
    }
    
    private func openAddImageView(){
        presentAddImageView.toggle()
    }
    
    private func createProgressData(){
        for his in book.history!.array{
            let history = his as! History
            print(history.date!.formatted() + " -> " +  String(history.pageNo))
        }

        self.createChartData(length: 7)
        self.createGoalChartData(length: 7)
        weeklyChartXScale = self.createXScale()
        weeklySpeedChartData = self.createSpeedChartData(length: 7, chartData: weeklyChartData)
        weeklySpeedGoalChartData = self.createSpeedGoalChartData(length: 7, chartData: weeklyGoalChartData)
        setWeeklyChartAnnotationPositions()
        
        self.createChartData(length: 30)
        self.createGoalChartData(length: 30)
        monthlySpeedChartData = self.createSpeedChartData(length: 30, chartData: monthlyChartData)
        monthlySpeedGoalChartData = self.createSpeedGoalChartData(length: 30, chartData: monthlyGoalChartData)
    }
    
    private func setWeeklyChartAnnotationPositions(){
        for i in 0..<weeklyGoalChartData.count{
            var foundIndex = -1
            for j in 0..<weeklyChartData.count{
                if Calendar.current.compare(weeklyGoalChartData[i].date!, to: weeklyChartData[j].date!, toGranularity: .day) == .orderedSame{
                    foundIndex = j
                    break
                }
            }
            
            if foundIndex >= 0{
                if weeklyGoalChartData[i].pageNo! > weeklyChartData[foundIndex].pageNo!{
                    weeklyGoalChartData[i].position = .top
                    weeklyChartData[foundIndex].position = .bottom
                }else{
                    weeklyGoalChartData[i].position = .bottom
                    weeklyChartData[foundIndex].position = .top
                }
            }else{
                weeklyGoalChartData[i].position = .bottom
            }
        }
        
        for i in 0..<weeklySpeedGoalChartData.count{
            var foundIndex = -1
            for j in 0..<weeklySpeedChartData.count{
                if Calendar.current.compare(weeklySpeedGoalChartData[i].date!, to: weeklySpeedChartData[j].date!, toGranularity: .day) == .orderedSame{
                    foundIndex = j
                    break
                }
            }
            
            if foundIndex >= 0{
                if weeklySpeedGoalChartData[i].pageNo! > weeklySpeedChartData[foundIndex].pageNo!{
                    weeklySpeedGoalChartData[i].position = .top
                    weeklySpeedChartData[foundIndex].position = .bottom
                }else{
                    weeklySpeedGoalChartData[i].position = .bottom
                    weeklySpeedChartData[foundIndex].position = .top
                }
            }else{
                weeklySpeedGoalChartData[i].position = .bottom
            }
        }
    }

    private func createSpeedChartData(length: Int, chartData: [ChartData]) -> [ChartData]{
        if book.history == nil || book.history?.count == 0 || chartData.isEmpty{
            return []
        }
        
        var speedChartData: [ChartData] = []
        let prevHistory = book.history!.filter{
            let comparisonResult = Calendar.current.compare(($0 as! History).date!, to: chartData.first!.date!, toGranularity: .day)
            if comparisonResult == ComparisonResult.orderedSame || comparisonResult == ComparisonResult.orderedAscending{
                return true
            }
            return false
        }.last
        
        var prevPage:Double
        if prevHistory == nil{
            prevPage = 0.0
        }else{
            prevPage = (prevHistory as! History).pageNo
        }
            
        var currenDate = chartData.first!.date
        var idx = 0
        for data in chartData{
            speedChartData.append(ChartData(id: idx, date: currenDate!, pageNo: data.pageNo! - prevPage))
            currenDate = Calendar.current.date(byAdding: .day, value: 1, to: currenDate!)
            prevPage = data.pageNo!
            idx += 1
        }
        
        return speedChartData
    }
    
    private func createSpeedGoalChartData(length: Int, chartData: [ChartData]) -> [ChartData]{
        var speedGoalChartData: [ChartData] = []
        let weekGoal: Double = (book.goals!.filter({($0 as! Goal).title == "weekday"}).first! as! Goal).pageCount
        let weekendGoal: Double = (book.goals!.filter({($0 as! Goal).title == "weekend"}).first! as! Goal).pageCount
        
        var prevPage:Double
        if Calendar.current.isDateInWeekend(chartData.first!.date!){
            prevPage = chartData.first!.pageNo! - weekendGoal
        }else{
            prevPage = chartData.first!.pageNo! - weekGoal
        }
        
        var currenDate = chartData.first!.date
        
        var idx = 0
        for data in chartData{
            speedGoalChartData.append(ChartData(id: idx, date: currenDate!, pageNo: data.pageNo! - prevPage))
            currenDate = Calendar.current.date(byAdding: .day, value: 1, to: currenDate!)
            prevPage = data.pageNo!
            idx += 1
        }
        
        return speedGoalChartData
    }
    
    private func onDissmiss() {
        createProgressData()
    }
        
    private func createChartData(length: Int){
        if book.history == nil || book.history!.count == 0{
            if length == 7{
                weeklyChartData = []
            }else{
                monthlyChartData = []
            }
            return
        }
        
        let today = Calendar.current.startOfDay(for: Date())
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!

        let startDateOfChart = Calendar.current.date(byAdding: .day, value: -length, to: today)!
        
        var chartData = book.history!.filter{
            let elem = $0 as! History
            let comparisonResult = Calendar.current.compare(elem.date!, to: startDateOfChart, toGranularity: .day)
            if comparisonResult == ComparisonResult.orderedSame || comparisonResult == ComparisonResult.orderedDescending{
                return true
            }
            return false
        }.enumerated().map{ (index, element) in
            let elem = element as! History
            return ChartData(id: index, date: elem.date!, pageNo: elem.pageNo)
        }
        
        if chartData.count == 0{
            if length == 7{
                weeklyChartData = []
            }else{
                monthlyChartData = []
            }
            return
        }
        
        chartData = ChartService.fillNoNConsequtive(chart: chartData)
        chartData = ChartService.fillChart(chart: chartData, isPrefix: false, value: chartData.last!.pageNo!, date: yesterday)

        let prevHistory = book.history!.filter{
            let elem = $0 as! History
            let comparisonResult = Calendar.current.compare(elem.date!, to: startDateOfChart, toGranularity: .day)
            if comparisonResult == ComparisonResult.orderedAscending{
                return true
            }
            return false
        }
        
        if prevHistory.count > 0{
            chartData = ChartService.fillChart(chart: chartData, isPrefix: true, value: (prevHistory.last as! History).pageNo, date: startDateOfChart)
        }else{
            chartData.insert(ChartData(id: chartData.count, date: Calendar.current.date(byAdding: .day, value: -1, to: chartData.first!.date!)! , pageNo: 0.0), at: 0)
//            chartData = ChartService.fillChart(chart: chartData, isPrefix: true, value: 0.0, date: startDateOfChart)
        }
        
        
        if length == 7{
            weeklyChartData = chartData
        }else{
            monthlyChartData = chartData
        }
    }
    
    private func createGoalChartData(length: Int){
        var dataResult:[ChartData] = []
        
        let startDateOfChart = Calendar.current.date(byAdding: .day, value: -length, to: Calendar.current.startOfDay(for: Date()))!
        
        let chartData = book.history!.filter{
            let elem = $0 as! History
            let comparisonResult = Calendar.current.compare(elem.date!, to: startDateOfChart, toGranularity: .day)
            if comparisonResult == ComparisonResult.orderedSame || comparisonResult == ComparisonResult.orderedDescending{
                return true
            }
            return false
        }.enumerated().map{ (index, element) in
            let elem = element as! History
            return ChartData(id: index, date: elem.date!, pageNo: elem.pageNo)
        }
        
        let weekGoal: Double = (book.goals!.filter({($0 as! Goal).title == "weekday"}).first! as! Goal).pageCount
        let weekendGoal: Double = (book.goals!.filter({($0 as! Goal).title == "weekend"}).first! as! Goal).pageCount
        
        if chartData.isEmpty{
            let endDateOfChart = Calendar.current.date(byAdding: .day, value: length, to: Calendar.current.startOfDay(for: Date()))!
            if length == 7{
                weeklyGoalChartData = ChartService.fillChartWithGoals(chart: chartData, isPrefix: false, week: weekGoal, weekend: weekendGoal, date: endDateOfChart, totalPage: book.totalPage)
            }else{
                monthlyGoalChartData = ChartService.fillChartWithGoals(chart: chartData, isPrefix: false, week: weekGoal, weekend: weekendGoal, date: endDateOfChart, totalPage: book.totalPage)
            }
        }else{
            dataResult = ChartService.fillChartWithGoals(chart: chartData, isPrefix: true, week: weekGoal, weekend: weekendGoal, date: startDateOfChart, totalPage: book.totalPage)
            dataResult = ChartService.fillChartWithGoals(chart: dataResult, isPrefix: false, week: weekGoal, weekend: weekendGoal, date: Calendar.current.startOfDay(for: Date()), totalPage: book.totalPage)
            
            if length == 7{
                weeklyGoalChartData = dataResult
            }else{
                monthlyGoalChartData = dataResult
            }
        }
    }
    
    private func createXScale() -> [Date]{
        var scaleResult:[Date] = []
        let chartStartDate = weeklyChartData.first?.date
        let goalStartDate = weeklyGoalChartData.first?.date
        let chartEndDate = weeklyChartData.last?.date
        let goalEndDate = weeklyGoalChartData.last?.date
        var currDate = Date()
        var endDate = Date()
        if chartStartDate != nil{
            if goalStartDate != nil{
                currDate = min(chartStartDate!, goalStartDate!)
            }
        }else{
            currDate = goalStartDate!
        }
        
        if chartEndDate != nil{
            if goalEndDate != nil{
                endDate = max(chartEndDate!, goalEndDate!)
            }
        }else{
            endDate = goalEndDate!
        }
        
        var comparisonResult = Calendar.current.compare(currDate, to: endDate, toGranularity: .day)
        while comparisonResult != .orderedDescending{
            scaleResult.append(currDate)
            currDate = Calendar.current.date(byAdding: .day, value: 1, to: currDate)!
            comparisonResult = Calendar.current.compare(currDate, to: endDate, toGranularity: .day)
        }
        
        return scaleResult
    }
}

struct BookDetailView_Previews: PreviewProvider {
    static var previews: some View {
        BookDetailView(book:PersistenceController.selectedBook!).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        
        BookDetailView(book: PersistenceController.selectedBook!).previewDevice(PreviewDevice(rawValue: "iPhone 14 Plus"))
            .previewDisplayName("iPhone 14 Plus")
    }
}
