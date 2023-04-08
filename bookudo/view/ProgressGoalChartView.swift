//
//  ProgressGoalChartView.swift
//  bookudo
//
//  Created by Kutay Agbal on 5.02.2023.
//

import SwiftUI
import Charts

struct ProgressGoalChartView: View {
    let showPoints: Bool
    let chartName: String
    var chartData: [ChartData]
    var goalData: [ChartData]
    let xAxisScale: [Date]?
    
    var body: some View {
        GroupBox{
            Text(chartName)
            if showPoints{
                Chart(){
                    ForEach(goalData) { goal in
                        LineMark(
                            x: .value("Date", goal.date!),
                            y: .value("PageNo", goal.pageNo!),
                            series: .value("Data", "Goal")
                        ).foregroundStyle(.red)
                        
                        PointMark(
                            x: .value("Date", goal.date!),
                            y: .value("PageNo", goal.pageNo!)
                        ).foregroundStyle(.red)
                            .annotation(position: goal.position ?? .bottom){
                                Text(String(format: "%.1f", goal.pageNo!)).foregroundColor(.red).font(.system(size: 10))
                            }.foregroundStyle(by: .value("ChartType", "Goal"))
                    }
                    
                    ForEach(chartData) { data in
                        LineMark(
                            x: .value("Date", data.date!),
                            y: .value("PageNo", data.pageNo!),
                            series: .value("Data", "Weekly")
                        ).foregroundStyle(.blue)
                        
                        PointMark(
                            x: .value("Date", data.date!),
                            y: .value("PageNo", data.pageNo!)
                        ).foregroundStyle(.blue)
                            .annotation(position: data.position ?? .top){
                                Text(String(format: "%.1f", data.pageNo!)).foregroundColor(.blue).font(.system(size: 10))
                            }.foregroundStyle(by: .value("ChartType", "Progress"))
                    }
                }.chartForegroundStyleScale(["Goal": .red, "Progress": .blue])
                    .chartXAxis {
                    if xAxisScale != nil{
                        AxisMarks(values: xAxisScale!) { _ in
                            AxisGridLine()
                            AxisValueLabel(
                                format: .dateTime.day()
                            )
                        }
                    }else{
                        AxisMarks() { _ in
                            AxisGridLine()
                            AxisValueLabel(
                                format: .dateTime.day()
                            )
                        }
                    }
                }.padding()
            }else{
                Chart(){
                    ForEach(goalData) { goal in
                        LineMark(
                            x: .value("Date", goal.date!),
                            y: .value("PageNo", goal.pageNo!),
                            series: .value("Data", "Goal")
                        ).foregroundStyle(.red).foregroundStyle(by: .value("ChartType", "Goal"))
                    }
                    
                    ForEach(chartData) { data in
                        LineMark(
                            x: .value("Date", data.date!),
                            y: .value("PageNo", data.pageNo!),
                            series: .value("Data", "Weekly")
                        ).foregroundStyle(.blue).foregroundStyle(by: .value("ChartType", "Progress"))
                    }
                }.chartForegroundStyleScale(["Goal": .red, "Progress": .blue])
                    .chartXAxis {
                    if xAxisScale != nil{
                        AxisMarks(values: xAxisScale!) { _ in
                            AxisGridLine()
                            AxisValueLabel(
                                format: .dateTime.day()
                            )
                        }
                    }else{
                        AxisMarks() { _ in
                            AxisGridLine()
                            AxisValueLabel(
                                format: .dateTime.day()
                            )
                        }
                    }
                }.padding()
            }
        }
    }
}

struct ProgressGoalChartView_Previews: PreviewProvider {
    static let prev = Calendar.current.date(byAdding: .day, value: -8, to: Date())!
    static let first = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
    static let second = Calendar.current.date(byAdding: .day, value: 1, to: first)!
    static let third = Calendar.current.date(byAdding: .day, value: 1, to: second)!
    static let forth = Calendar.current.date(byAdding: .day, value: 1, to: third)!
    static let fifth = Calendar.current.date(byAdding: .day, value: 1, to: forth)!
    static let sixth = Calendar.current.date(byAdding: .day, value: 1, to: fifth)!
    static let seventh = Calendar.current.date(byAdding: .day, value: 1, to: sixth)!
    
    static var previews: some View {
        ProgressGoalChartView(showPoints: true, chartName: "Progress", chartData: [ChartData(id: 0, date: first, pageNo: 2), ChartData(id: 1, date: second, pageNo: 3), ChartData(id: 2, date: third, pageNo: 6), ChartData(id: 3, date: forth, pageNo: 6), ChartData(id: 4, date: fifth, pageNo: 8), ChartData(id: 5, date: sixth, pageNo: 10), ChartData(id: 6, date: seventh, pageNo: 16)], goalData: [ChartData(id: 0, date: first, pageNo: 2), ChartData(id: 1, date: second, pageNo: 4), ChartData(id: 2, date: third, pageNo: 6), ChartData(id: 3, date: forth, pageNo: 8), ChartData(id: 4, date: fifth, pageNo: 10), ChartData(id: 5, date: sixth, pageNo: 14), ChartData(id: 6, date: seventh, pageNo: 18)], xAxisScale: [first, second, third, forth, fifth, sixth, seventh]).previewDevice(PreviewDevice(rawValue: "iPhone 12 mini"))
        
        ProgressGoalChartView(showPoints: false, chartName: "Speed", chartData: [ChartData(id: 0, date: first, pageNo: 2), ChartData(id: 1, date: second, pageNo: 3), ChartData(id: 2, date: third, pageNo: 6), ChartData(id: 3, date: forth, pageNo: 6), ChartData(id: 4, date: fifth, pageNo: 8), ChartData(id: 5, date: sixth, pageNo: 10), ChartData(id: 6, date: seventh, pageNo: 16)], goalData: [ChartData(id: 0, date: first, pageNo: 2), ChartData(id: 1, date: second, pageNo: 4), ChartData(id: 2, date: third, pageNo: 6), ChartData(id: 3, date: forth, pageNo: 8), ChartData(id: 4, date: fifth, pageNo: 10), ChartData(id: 5, date: sixth, pageNo: 14), ChartData(id: 6, date: seventh, pageNo: 18)], xAxisScale: [first, second, third, forth, fifth, sixth, seventh]).previewDevice(PreviewDevice(rawValue: "iPhone 14 Plus"))
    }
}
