//
//  PageImageView.swift
//  bookudo
//
//  Created by Kutay Agbal on 10.04.2023.
//

import SwiftUI

struct PageImageView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) var viewContext
    @State var book: Book
    @State var expandedImg: HashableImage?
    @State private var presentConfirmDelete = false
    @State private var showMessage = false
    @State private var message = ""
    
    var body: some View {
        VStack{
            VStack{
                Text(book.title!).font(.title2).padding(3)
                if book.subTitle != nil{
                    Text(book.subTitle!).font(.caption).padding(2)
                }
            }.multilineTextAlignment(.center).padding(.top)
            
            HStack{
                Text("Page: " + String(format: "%.2f", expandedImg!.pageNo!)).font(.title3).padding()
                Spacer()
                Button("DELETE") {
                    presentConfirmDelete.toggle()
                                        }.foregroundColor(.red).cornerRadius(10).padding().overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(.red, lineWidth: 1))
                                        .padding(.trailing)
            }.padding()
                .confirmationDialog("", isPresented: $presentConfirmDelete){
                Button("Delete image", role: .destructive) {
                    deleteImage()
                }
            }.alert(message, isPresented: $showMessage) {}
            
            Spacer()
            Image(uiImage: expandedImg!.image).resizable().scaledToFit().cornerRadius(10.0)
            Spacer()
        }.gesture(DragGesture(minimumDistance: 15, coordinateSpace: .local)
            .onEnded({ value in
                if value.translation.width > 0 {
                    withAnimation{
                        self.dismiss()
                    }
                }
            }))
    }
    
    
    private func deleteImage(){
        let delImg = book.images?.filter({($0 as! PageImage).objectID.isEqual(expandedImg!.objectID!)}).first as? PageImage
        
        if delImg != nil{
            do {
                book.updateDate = Date()
                viewContext.delete(delImg!)
                try viewContext.save()
                self.dismiss()
            } catch {
                message = (error as NSError).localizedDescription
                showMessage.toggle()
                return
            }
        }
    }
}


struct PageImageView_Previews: PreviewProvider {
    static var previews: some View {
        PageImageView(book: Book(), expandedImg: nil)
    }
}
