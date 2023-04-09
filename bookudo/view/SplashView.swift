//
//  SplashView.swift
//  bookudo
//
//  Created by Kutay Agbal on 2.04.2023.
//

import SwiftUI

struct SplashView: View {
    @State var openView: Bool = false
    
    var body: some View {
        ZStack {
            if openView {
                BookSummaryListView()
            } else {
                Image(uiImage: UIImage(named: "SplashImage")!)
            }
        }.onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation {
                        self.openView = true
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
