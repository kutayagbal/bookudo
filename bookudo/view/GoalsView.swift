//
//  GoalsView.swift
//  bookudo
//
//  Created by Kutay Agbal on 29.12.2022.
//

import SwiftUI

struct GoalsView: View {
    let goals: NSSet
    @State var goalsArray: [Goal] = []
    let avgSpeedGoal: Double
    let today = Calendar.current.component(.weekday, from: Date())
    
    var body: some View {
        VStack{
            HStack{
                Text("Goals :").font(Font.caption2.bold())
                Spacer()
            }
            
            HStack(alignment: .firstTextBaseline){
                VStack(alignment: .leading){
                    ForEach(goalsArray) { goal in
                        HStack{
                            Spacer()
                            Text(goal.title!).font(Font.footnote.bold())
                            Spacer()
                            Text(String(goal.pageCount)).font(Font.body.bold())
                        }
                    }
                    HStack{
                        Spacer()
                        Text("avg").font(Font.footnote.bold())
                        Spacer()
                        Text(String(format:"%.2f", avgSpeedGoal)).font(Font.body.bold())
                    }
                }
                Spacer()
            }
        }.onAppear(perform: createGoalsArray)
        
    }
    
    private func createGoalsArray(){
        self.goalsArray = Array(goals as! Set<Goal>).sorted{
            $0.title! < $1.title!
        }
    }
}

struct GoalsView_Previews: PreviewProvider {
    static var previews: some View {
        GoalsView(goals: [], avgSpeedGoal: 0).previewDevice("iPhone 12 mini").previewDisplayName("iPhone 12 mini")
        
        GoalsView(goals: [], avgSpeedGoal: 0).previewDevice("iPhone 14 Plus").previewDisplayName("iPhone 14 Plus")
    }
}
