//
//  SplashView.swift
//  bookudo
//
//  Created by Kutay Agbal on 2.04.2023.
//

import SwiftUI

struct SplashView: View {
    @State var isActive: Bool = false
    
    var body: some View {
        ZStack {
            if self.isActive {
                BookSummaryListView()
            } else {
                Image(uiImage: UIImage(named: "SplashImage")!)
            }
        }.onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation {
                        self.isActive = true
                    }
                }
            }
        }
    }

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
    }
}
