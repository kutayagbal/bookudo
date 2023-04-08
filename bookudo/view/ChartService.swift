//
//  ChartService.swift
//  bookudo
//
//  Created by Kutay Agbal on 25.02.2023.
//

import Foundation

struct ChartService{
    static func fillChart(chart: [ChartData], isPrefix: Bool, value: Double, date: Date) -> [ChartData]{
        var result:[ChartData] = []
        if isPrefix{
            var dayDiff = Calendar.current.dateComponents([.day], from: date, to: (chart.first?.date)!).day!
            
            if dayDiff > 0{
                var currentDate = Calendar.current.date(byAdding: .day, value: -1, to: chart.first!.date!)
                
                var idx = chart.count
                while dayDiff >= 0{
                    result.insert(ChartData(id: idx, date: currentDate!, pageNo: value), at: 0)
                    currentDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate!)!
                    dayDiff = Calendar.current.dateComponents([.day], from: date, to: currentDate!).day!
                    idx += 1
                }
                
                result += chart
            }else{
                result = chart
            }
        }else{
            var dayDiff = Calendar.current.dateComponents([.day], from: chart.last!.date!, to: date).day!
            if dayDiff > 0{
                result += chart
                var currentDate = Calendar.current.date(byAdding: .day, value: 1, to: chart.last!.date!)
                
                var idx = chart.count
                while dayDiff >= 0{
                    result.append(ChartData(id: idx, date: currentDate!, pageNo: value))
                    currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate!)!
                    dayDiff = Calendar.current.dateComponents([.day], from: currentDate!, to: date).day!
                    idx += 1
                }
            }else{
                result = chart
            }
        }
        
        return result
    }
    
    static func fillNoNConsequtive(chart: [ChartData]) -> [ChartData]{
        var prevDate = chart.first!.date!
        var prevPage = chart.first!.pageNo
        var result:[ChartData] = [chart.first!]
        
        for index in 1..<chart.count{
            let data = chart[index]
            
            var dayDiff = Calendar.current.dateComponents([.day], from: prevDate, to: data.date!).day!
            
            if dayDiff <= 1{
                result.append(data)
                prevDate = data.date!
                prevPage = data.pageNo
            }else{
                var idx = index + 1
                
                while dayDiff != 1{
                    result.append(ChartData(id: idx, date: Calendar.current.date(byAdding: .day, value: 1, to: prevDate)!, pageNo: prevPage!))
                    prevDate = Calendar.current.date(byAdding: .day, value: 1, to: prevDate)!
                    dayDiff = Calendar.current.dateComponents([.day], from: prevDate, to: data.date!).day!
                    idx += 1
                }
                result.append(ChartData(id: idx, date: data.date!, pageNo: data.pageNo!))
                prevDate = data.date!
                prevPage = data.pageNo
            }
        }
        
        return result
    }
    
    static func fillChartWithGoals(pivot: ChartData?, startPage: Double, week: Double, weekend: Double, start: Date, end: Date, totalPage: Double) -> [ChartData]{
        var result:[ChartData] = []
        
        var startDayDiff = -1
        if pivot == nil{
            startDayDiff = Calendar.current.dateComponents([.day], from: start, to: end).day!
        }else{
            startDayDiff = Calendar.current.dateComponents([.day], from: start, to: pivot!.date!).day!
        }
        
        var currentDate:Date
        var currentPage:Double
        if pivot == nil{
            currentDate = start
            currentPage = 0.0
        }else{
            currentDate = Calendar.current.date(byAdding: .day, value: -1, to: pivot!.date!)!
            currentPage = pivot!.pageNo!
        }
        
        var idx = (pivot == nil) ? 0 : 1
        while startDayDiff >= 0{
            if Calendar.current.isDateInWeekend(Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!){
                currentPage -= weekend
            }else{
                currentPage -= week
            }
            
            if currentPage < 0{
                break
            }
            result.insert(ChartData(id: idx, date: currentDate, pageNo: currentPage), at: 0)
            
            currentDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate)!
            startDayDiff = Calendar.current.dateComponents([.day], from: start, to: currentDate).day!
            idx += 1
        }
        
        if pivot != nil{
            result.append(pivot!)
        }
        
        var endDayDiff = -1
        if pivot == nil{
            endDayDiff = Calendar.current.dateComponents([.day], from: start, to: end).day!
        }else{
            endDayDiff = Calendar.current.dateComponents([.day], from: pivot!.date!, to: end).day!
        }
        if endDayDiff >= 0{
            var currentDate:Date
            var currentPage:Double
            if pivot == nil{
                currentDate = start
                currentPage = startPage
            }else{
                currentDate = Calendar.current.date(byAdding: .day, value: 1, to: pivot!.date!)!
                currentPage = pivot!.pageNo!
            }
            
            var idx = result.count
            while endDayDiff >= 0{
                if Calendar.current.isDateInWeekend(currentDate){
                    currentPage += weekend
                }else{
                    currentPage += week
                }
                if currentPage > totalPage{
                    break
                }
                result.append(ChartData(id: idx, date: currentDate, pageNo: currentPage))
                
                currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
                endDayDiff = Calendar.current.dateComponents([.day], from: currentDate, to: end).day!
                idx += 1
            }
        }

        return result
    }
}
