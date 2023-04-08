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
    @State var chartScaleValue: Int = 1
    @State var chartScaleRange: ChartScaleRange = .WEEK
    @State var refresh = false
    @State var chartData: [ChartData] = []
    @State var chartXScale: [Date]? = []
    @State var goalChartData: [ChartData] = []
    @State var speedChartData: [ChartData] = []
    @State var speedGoalChartData: [ChartData] = []
    @State var showMessage = false
    @State var message = ""
    
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
                        VStack{
                            ProgressGoalChartView(showPoints: chartXScale != nil ? true : false, chartName: "Progress", chartData: chartData, goalData: goalChartData, xAxisScale: chartXScale)
                            ProgressGoalChartView(showPoints: chartXScale != nil ? true : false, chartName: "Speed", chartData: speedChartData, goalData: speedGoalChartData, xAxisScale: chartXScale)
                        }.padding([.leading, .trailing, .top]).frame(minHeight: 500)
                        
                        HStack{
                            Picker("", selection: $chartScaleValue) {
                                ForEach(1 ..< 61, id: \.self) {
                                    Text(String($0)).font(Font.subheadline.bold())
                                }
                            }.onChange(of: chartScaleValue) { newValue in
                                withAnimation{
                                    updateProgressData(newScaleRange: chartScaleRange, newScaleValue: newValue)
                                }
                            }.pickerStyle(.wheel)
                            Spacer()
                            Picker("", selection: $chartScaleRange) {
                                ForEach(ChartScaleRange.allCases, id: \.self) {
                                    Text($0.rawValue).font(Font.subheadline.bold())
                                }
                            }.onChange(of: chartScaleRange) { newValue in
                                withAnimation{
                                    updateProgressData(newScaleRange: newValue, newScaleValue: chartScaleValue)
                                }
                            }.pickerStyle(.wheel)
                        }.frame(maxWidth: 350, maxHeight: 100)
                    }
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
        }.scrollIndicators(.hidden).alert(message, isPresented: $showMessage) {}
    }
    
    private func presentConfirmation(){
        presentConfirmDelete = true
    }
    
    private func deleteBook(){
        viewContext.delete(book)
        do {
            try viewContext.save()
        } catch {
            message = (error as NSError).localizedDescription
            showMessage.toggle()
            return
        }
        
        DispatchQueue.main.async {
            self.dismiss()
        }
    }
    
    private func openAddImageView(){
        presentAddImageView.toggle()
    }
    
    private func updateProgressData(newScaleRange: ChartScaleRange, newScaleValue: Int){
        var length = 0
        if newScaleRange == .MONTH{
            length = 30 * newScaleValue
        }else if newScaleRange == .WEEK{
            length = 7 * newScaleValue
        }
        
        self.createChartData(length: length)
        self.createGoalChartData(length: length)
        
        if length <= 15{
            chartXScale = self.createXScale()
        }else{
            chartXScale = nil
        }
        
        speedChartData = self.createSpeedChartData(length: length, chartData: chartData)
        speedGoalChartData = self.createSpeedGoalChartData(length: length, chartData: goalChartData)
        
        if length <= 15{
            setChartAnnotationPositions()
        }
    }
    
    private func createProgressData(){
        print("HISTORY:")
        for his in book.history!.array{
            let history = his as! History
            print(history.date!.formatted() + " -> " +  String(history.pageNo))
        }

        var length = 0
        if chartScaleRange == .MONTH{
            length = 30 * chartScaleValue
        }else if chartScaleRange == .WEEK{
            length = 7 * chartScaleValue
        }
        
        self.createChartData(length: length)
        self.createGoalChartData(length: length)
        
        if length <= 15{
            chartXScale = self.createXScale()
        }else{
            chartXScale = nil
        }
        
        speedChartData = self.createSpeedChartData(length: length, chartData: chartData)
        speedGoalChartData = self.createSpeedGoalChartData(length: length, chartData: goalChartData)
        
        if length <= 15{
            setChartAnnotationPositions()
        }
    }
    
    private func setChartAnnotationPositions(){
        for i in 0..<goalChartData.count{
            var foundIndex = -1
            for j in 0..<chartData.count{
                if Calendar.current.compare(goalChartData[i].date!, to: chartData[j].date!, toGranularity: .day) == .orderedSame{
                    foundIndex = j
                    break
                }
            }
            
            if foundIndex >= 0{
                if goalChartData[i].pageNo! > chartData[foundIndex].pageNo!{
                    goalChartData[i].position = .top
                    chartData[foundIndex].position = .bottom
                }else{
                    goalChartData[i].position = .bottom
                    chartData[foundIndex].position = .top
                }
            }else{
                goalChartData[i].position = .bottom
            }
        }
        
        for i in 0..<speedGoalChartData.count{
            var foundIndex = -1
            for j in 0..<speedChartData.count{
                if Calendar.current.compare(speedGoalChartData[i].date!, to: speedChartData[j].date!, toGranularity: .day) == .orderedSame{
                    foundIndex = j
                    break
                }
            }
            
            if foundIndex >= 0{
                if speedGoalChartData[i].pageNo! > speedChartData[foundIndex].pageNo!{
                    speedGoalChartData[i].position = .top
                    speedChartData[foundIndex].position = .bottom
                }else{
                    speedGoalChartData[i].position = .bottom
                    speedChartData[foundIndex].position = .top
                }
            }else{
                speedGoalChartData[i].position = .bottom
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
            chartData = []
            return
        }
        
        let today = Calendar.current.startOfDay(for: Date())
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!

        let startDateOfChart = Calendar.current.date(byAdding: .day, value: -length, to: today)!
        
        var chart = book.history!.filter{
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
        
        if chart.count == 0{
            chartData = []
            return
        }
        
        chart = ChartService.fillNoNConsequtive(chart: chart)
        chart = ChartService.fillChart(chart: chart, isPrefix: false, value: chart.last!.pageNo!, date: yesterday)

        let prevHistory = book.history!.filter{
            let elem = $0 as! History
            let comparisonResult = Calendar.current.compare(elem.date!, to: startDateOfChart, toGranularity: .day)
            if comparisonResult == ComparisonResult.orderedAscending{
                return true
            }
            return false
        }
        
        if prevHistory.count > 0{
            chart = ChartService.fillChart(chart: chart, isPrefix: true, value: (prevHistory.last as! History).pageNo, date: startDateOfChart)
        }else{
            chart.insert(ChartData(id: chart.count, date: Calendar.current.date(byAdding: .day, value: -1, to: chart.first!.date!)! , pageNo: 0.0), at: 0)
        }
        
        chartData = chart
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
            
            goalChartData = ChartService.fillChartWithGoals(pivot: nil, startPage: book.currentPage, week: weekGoal, weekend: weekendGoal, start: Calendar.current.startOfDay(for: Date()), end: endDateOfChart, totalPage: book.totalPage)
        }else{
            dataResult = ChartService.fillChartWithGoals(pivot: chartData.first, startPage: book.currentPage, week: weekGoal, weekend: weekendGoal, start: startDateOfChart, end: Calendar.current.startOfDay(for: Date()), totalPage: book.totalPage)
            
            goalChartData = dataResult
        }
    }
    
    private func createXScale() -> [Date]{
        var scaleResult:[Date] = []
        let chartStartDate = chartData.first?.date
        let goalStartDate = goalChartData.first?.date
        let chartEndDate = chartData.last?.date
        let goalEndDate = goalChartData.last?.date
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
