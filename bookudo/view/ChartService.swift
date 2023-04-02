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
    
    static func fillChartWithGoals(chart: [ChartData], isPrefix: Bool, week: Double, weekend: Double, date: Date, totalPage: Double) -> [ChartData]{
        var result:[ChartData] = []
        let today = Calendar.current.startOfDay(for: Date())
        
        if isPrefix{
            var dayDiff = -1
            if chart.isEmpty{
                dayDiff = Calendar.current.dateComponents([.day], from: date, to: today).day!
            }else{
                dayDiff = Calendar.current.dateComponents([.day], from: date, to: (chart.first?.date)!).day!
            }
            
            if dayDiff >= 0{
                var currentDate:Date
                var currentPage:Double
                if chart.isEmpty{
                    currentDate = today
                    currentPage = 0.0
                }else{
                    currentDate = Calendar.current.date(byAdding: .day, value: -1, to: chart.first!.date!)!
                    currentPage = chart.first!.pageNo!
                }
                
                var idx = chart.count
                while dayDiff >= 0{
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
                    dayDiff = Calendar.current.dateComponents([.day], from: date, to: currentDate).day!
                    idx += 1
                }
                
                result += chart
            }else{
                result = chart
            }
        }else{
            var dayDiff = -1
            if chart.isEmpty{
                dayDiff = Calendar.current.dateComponents([.day], from: today, to: date).day!
            }else{
                dayDiff = Calendar.current.dateComponents([.day], from: chart.last!.date!, to: date).day!
            }
            if dayDiff >= 0{
                result += chart
                
                var currentDate:Date
                var currentPage:Double
                if chart.isEmpty{
                    currentDate = today
                    currentPage = 0.0
                }else{
                    currentDate = Calendar.current.date(byAdding: .day, value: 1, to: chart.last!.date!)!
                    currentPage = chart.last!.pageNo!
                }
                
                var idx = chart.count
                while dayDiff >= 0{
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
                    dayDiff = Calendar.current.dateComponents([.day], from: currentDate, to: date).day!
                    idx += 1
                }
            }else{
                result = chart
            }
        }
        
        return result
    }
}
