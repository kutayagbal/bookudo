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
    @State var showMessage = false
    @State var message = ""
    @State var expandedUnitImages: [HashableImage] = []
    
    var body: some View {
        VStack{
            NavigationStack {
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
                                    Text(String(getUnitImageCount(unit: unit)))
                                }.padding(5).padding(.top, 7).contentShape(Rectangle()).onTapGesture {
                                    withAnimation{
                                        expandedUnit = nil
                                    }
                                }
                                
                                ScrollView(.horizontal){
                                    LazyHStack{
                                        ForEach(expandedUnitImages, id: \.id){ img in
                                            NavigationLink(destination: PageImageView(book: book, expandedImg: img, unitTitle: unit.title!)){
                                                HStack{
                                                    Spacer()
                                                    VStack{
                                                        Text("Page: " + String(format: "%.2f", img.pageNo!)).font(.system(size: 11)).foregroundColor(Color(UIColor.systemGray))
                                                        Image(uiImage: img.image).resizable().scaledToFit().cornerRadius(10.0).frame(maxHeight: 100)
                                                    }.padding(5).background(
                                                        RoundedRectangle(cornerRadius: 10)
                                                            .fill(Color(UIColor.systemGray6)))
                                                    Spacer()
                                                }
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
                                Text(String(getUnitImageCount(unit: unit)))
                            }.padding(5).contentShape(Rectangle()).onTapGesture {
                                if getUnitImageCount(unit: unit) > 0{
                                    withAnimation{
                                        expandedUnit = unit
                                        setExpandedUnitImages()
                                    }
                                }
                            }.alignmentGuide(.listRowSeparatorTrailing) { d in
                                d[.trailing]
                            }
                        }
                    }.scrollContentBackground(.hidden).scrollIndicators(.hidden)
                }.background(Color(UIColor.systemGray6)).onAppear(perform: setExpandedUnitImages)
            }
        }
    }

    private func getUnitImageCount(unit: Unit) -> Int{
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
    
    private func setExpandedUnitImages(){
        if expandedUnit == nil{
            expandedUnitImages = []
            return
        }
        
        var images:[HashableImage] = []
        let sortDescriptor = NSSortDescriptor(key: "pageNo", ascending: true)
        
        for image in book.images!.sortedArray(using: [sortDescriptor]){
            let img  = image as! PageImage
            if img.pageNo <= expandedUnit!.endPage && img.pageNo >= expandedUnit!.startPage{
                images.append(HashableImage(image: UIImage(data: img.data!)!, id: UUID(), pageNo: img.pageNo, objectID: img.objectID))
            }
        }
        
        if images.isEmpty{
            expandedUnit = nil
        }
        expandedUnitImages = images
    }
}

struct PageImagesView_Previews: PreviewProvider {
    static var previews: some View {
        PageImagesView(book: PersistenceController.selectedBook!, presentPageImagesView: .constant(true))
    }
}
