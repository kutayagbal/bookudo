//
//  AddImageView.swift
//  bookudo
//
//  Created by Kutay Agbal on 7.01.2023.
//

import SwiftUI

struct AddImageView: View {
    @Environment(\.managedObjectContext) var viewContext
    @State var book: Book
    @Binding var presentAddImageView: Bool
    @State var pageStr = ""
    @State var presentImagePicker: Bool
    @State var images = [HashableImage]()
    @State var showMessage = false
    @State var message = ""
    
    var body: some View {
        VStack{
                VStack{
                    VStack{
                        Text(book.title!).font(.title2).padding(3)
                        if book.subTitle != nil{
                            Text(book.subTitle!).font(.caption).padding(2)
                        }
                    }.multilineTextAlignment(.center).padding(.top, 40)
                    Spacer()
                    HStack{
                        if images.isEmpty{
                            Spacer()
                            Button("Add Image"){
                                showImagePicker()
                            }.padding().overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(.blue, lineWidth: 1))
                            Spacer()
                        }else{
                            ForEach(images, id: \.id) { img in
                                Image(uiImage: img.image)
                                    .resizable()
                                    .scaledToFit()
                            }
                            
                            Spacer()
                            Button(action: showImagePicker) {
                                Image(systemName: "plus").font(Font.title2)
                            }.padding(7).overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(.blue, lineWidth: 1))
                        }
                        
                    }
                    Spacer()
                    HStack{
                        Text("Page No :").padding(.leading)
                        TextField(String(book.currentPage), text: $pageStr)
                            .keyboardType(.numberPad)
                            .autocapitalization(.none)
                            .padding(.leading)
                    }.padding(.top)
                    Spacer()
                }.padding()
                
                HStack{
                    Spacer()
                    Button("Save      "){
                        saveImages()
                    }.foregroundColor(.green).cornerRadius(10).padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.green, lineWidth: 1)
                    )
                    Spacer()
                    Button("Cancel"){
                        self.presentAddImageView.toggle()
                    }.foregroundColor(.red).cornerRadius(10).padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.red, lineWidth: 1)
                    )
                    Spacer()
                }.padding()
            
        }.disabled(presentImagePicker).padding().sheet(isPresented: $presentImagePicker){
            ImagePicker(images: self.$images)
        }.alert(message, isPresented: $showMessage) {}
    }
    
    private func showImagePicker(){
        presentImagePicker.toggle()
    }
    
    private func saveImages(){
        if images.isEmpty{
            message = "Tap to Add Image button to add an image"
            showMessage.toggle()
            return
        }
        
        var page = Double(pageStr) ?? nil
        
        let sortDescriptor = NSSortDescriptor(key: "pageNo", ascending: true)
        
        if page != nil{
            if page! < 1{
                let latestImage = book.images!.sortedArray(using: [sortDescriptor]).filter{
                    if ($0 as! PageImage).pageNo < 1{
                        return true
                    }
                    return false
                }.last as? PageImage
                
                page = 0.01
                if latestImage != nil{
                    page = latestImage!.pageNo + 0.01
                }
                
                book.images = book.images?.addingObjects(from: (NSSet(array: images.enumerated().map{ (index, element) in
                    let pageImg = PageImage(context: viewContext)
                    pageImg.pageNo = page!
                    pageImg.data = element.image.jpegData(compressionQuality: 0.0)
                    page! += 0.01
                    return pageImg
                }) as! Set<AnyHashable>)) as NSSet?
            }else{
                book.images = book.images?.addingObjects(from: (NSSet(array: images.enumerated().map{ (index, element) in
                    let pageImg = PageImage(context: viewContext)
                    pageImg.pageNo = page!
                    pageImg.data = element.image.jpegData(compressionQuality: 0.0)
                    page! += 1
                    return pageImg
                }) as! Set<AnyHashable>)) as NSSet?
            }
            
            do {
                book.updateDate = Date()
                try viewContext.save()
            } catch {
                message = (error as NSError).localizedDescription
                showMessage.toggle()
                return
            }
            self.presentAddImageView.toggle()
        }else{
            message = "'Page No' should be a number"
            showMessage.toggle()
            return
        }
    }
}

struct AddImageView_Previews: PreviewProvider {
    static var previews: some View {
        AddImageView(book: PersistenceController.selectedBook!, presentAddImageView: .constant(true), presentImagePicker: true)
        
        AddImageView(book: PersistenceController.selectedBook!, presentAddImageView: .constant(true), presentImagePicker: true).previewDevice(PreviewDevice(rawValue: "iPhone 14 Plus"))
            .previewDisplayName("iPhone 14 Plus")
    }
}
