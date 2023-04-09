//
//  PageImagesView.swift
//  bookudo
//
//  Created by Kutay Agbal on 4.02.2023.
//

import SwiftUI

struct PageImagesView: View {
    @Environment(\.managedObjectContext) var viewContext
    @State var book: Book
    @Binding var presentPageImagesView: Bool
    @State private var expandedUnit: Unit?
    @State var presentConfirmDelete = false
    @State private var expandedImg: HashableImage?
    @State var showMessage = false
    @State var message = ""
    
    var body: some View {
        VStack{
            if expandedImg != nil{
                VStack{
                    Text(book.title!).font(.title2).padding(3)
                    if book.subTitle != nil{
                        Text(book.subTitle!).font(.caption).padding(2)
                    }
                }.multilineTextAlignment(.center).padding(.top, 40)
                
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
                }
                
                Image(uiImage: expandedImg!.image).resizable().scaledToFit().onTapGesture {
                    withAnimation{
                        expandedImg = nil
                    }
                }.cornerRadius(10.0)
                Spacer()
            }else{
                VStack{
                    HStack{
                        VStack{
                            Text(book.title!).font(.title2).padding(3)
                            if book.subTitle != nil{
                                Text(book.subTitle!).font(.caption).padding(2)
                            }
                        }.multilineTextAlignment(.center).padding(.top, 40).padding([.leading, .trailing])
                    }.padding()
                    
                    List(book.units?.array as! [Unit], id: \.id) { unit in
                        if expandedUnit == unit{
                            VStack{
                                HStack{
                                    Text(unit.title!)
                                    Spacer()
                                    Text(String(getImageCount(unit: unit)))
                                }.padding(5).padding(.top, 7).contentShape(Rectangle()).onTapGesture {
                                    withAnimation{
                                        expandedUnit = nil
                                    }
                                }
                                
                                ScrollView(.horizontal){
                                    LazyHStack{
                                        ForEach(getUnitImages(unit: unit), id: \.id){ img in
                                            HStack{
                                                Spacer()
                                                VStack{
                                                    Text("Page: " + String(format: "%.2f", img.pageNo!)).font(.system(size: 11))
                                                    Image(uiImage: img.image).resizable().scaledToFit().onTapGesture {
                                                        withAnimation{
                                                            expandedImg = img
                                                        }
                                                    }.cornerRadius(10.0).frame(maxHeight: 100)
                                                }.padding(5).overlay(
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .stroke(.yellow, lineWidth: 0.5))
                                                Spacer()
                                            }
                                        }.scrollContentBackground(.hidden).scrollIndicators(.hidden)
                                    }
                                }
                            }.frame(minHeight: 150).alignmentGuide(.listRowSeparatorTrailing) { d in
                                d[.trailing]
                            }
                        }else{
                            HStack{
                                Text(unit.title!)
                                Spacer()
                                Text(String(getImageCount(unit: unit)))
                            }.padding(5).contentShape(Rectangle()).onTapGesture {
                                if getImageCount(unit: unit) > 0{
                                    withAnimation{
                                        expandedUnit = unit
                                    }
                                }
                            }.alignmentGuide(.listRowSeparatorTrailing) { d in
                                d[.trailing]
                            }
                        }
                    }.scrollContentBackground(.hidden).scrollIndicators(.hidden)
                }
            }
        }.transition(.scale).alert(message, isPresented: $showMessage) {}
    }
    
    
    private func deleteImage(){
        if expandedImg != nil{
            let delImg = book.images?.filter({($0 as! PageImage).objectID.isEqual(expandedImg!.objectID!)}).first as? PageImage
            
            if delImg != nil{
                do {
                    book.updateDate = Date()
                    viewContext.delete(delImg!)
                    try viewContext.save()
                    withAnimation{
                        expandedImg = nil
                        expandedUnit = nil
                    }
                    presentConfirmDelete.toggle()
                } catch {
                    message = (error as NSError).localizedDescription
                    showMessage.toggle()
                    return
                }
            }
        }
    }
    
    private func getImageCount(unit: Unit) -> Int{
        if book.images == nil || book.images?.count == 0{
            return 0
        }
        
        var total = 0

        for image in book.images!.allObjects{
            let img  = image as! PageImage
            if img.pageNo <= unit.endPage && img.pageNo >= unit.startPage{
                total += 1
            }
        }
        
        return total
    }
    
    private func getUnitImages(unit: Unit) -> [HashableImage]{
        if book.images == nil || book.images?.count == 0{
            return []
        }
        
        var images:[HashableImage] = []
        let sortDescriptor = NSSortDescriptor(key: "pageNo", ascending: true)
        
        for image in book.images!.sortedArray(using: [sortDescriptor]){
            let img  = image as! PageImage
            if img.pageNo <= unit.endPage && img.pageNo >= unit.startPage{
                images.append(HashableImage(image: UIImage(data: img.data!)!, id: UUID(), pageNo: img.pageNo, objectID: img.objectID))
            }
        }
        
        return images
    }
}

struct PageImagesView_Previews: PreviewProvider {
    static var previews: some View {
        PageImagesView(book: PersistenceController.selectedBook!, presentPageImagesView: .constant(true))
    }
}
