//
//  ChartData.swift
//  bookkudo
//
//  Created by Kutay Agbal on 22.01.2023.
//

import Foundation
import Charts

struct ChartData: Identifiable{
    var id: Int?
    var date: Date?
    var pageNo: Double?
    var position: AnnotationPosition?
    
    init(id: Int?, date: Date, pageNo: Double){
        self.id = id
        self.date = date
        self.pageNo = pageNo
    }
}
