//
//  PageImageView.swift
//  bookudo
//
//  Created by Kutay Agbal on 10.04.2023.
//

import SwiftUI
//import Vision

struct PageImageView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) var viewContext
    @State var book: Book
    @State var expandedImg: HashableImage?
    @State private var presentConfirmDelete = false
    @State private var showMessage = false
    @State private var message = ""
    let unitTitle: String
//    @State private var recognizedText = ""
    
    var body: some View {
        VStack{
            VStack{
                Text(unitTitle).font(.title2).padding(3)
            }.multilineTextAlignment(.center).padding(.top)
            
            HStack{
                Spacer()
                Text("Page: " + String(format: "%.2f", expandedImg!.pageNo!)).font(.body).padding()
                Spacer()
                Button("Delete") {
                    presentConfirmDelete.toggle()
                                        }.foregroundColor(.red).cornerRadius(10).padding(10).overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(.red, lineWidth: 1))
                                        .padding(.trailing)
                Spacer()
            }
            
            Spacer()
            
            Image(uiImage: expandedImg!.image).resizable().scaledToFit().cornerRadius(10.0)
//            Text(recognizedText).font(.caption2)
        }//.onAppear(perform: recognizeText)
            .gesture(DragGesture(minimumDistance: 5, coordinateSpace: .local)
            .onEnded({ value in
                if value.translation.width > 0 {
                    withAnimation{
                        self.dismiss()
                    }
                }
            })).confirmationDialog("", isPresented: $presentConfirmDelete){
                Button("Delete image", role: .destructive) {
                    deleteImage()
                }
            }.alert(message, isPresented: $showMessage) {}
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
    
//    private func recognizeText(){
//        guard let cgImage = expandedImg?.image.cgImage else { return }
//
//        // Create a new image-request handler.
//        let requestHandler = VNImageRequestHandler(cgImage: cgImage)
//
//        // Create a new request to recognize text.
//        let request = VNRecognizeTextRequest(completionHandler: recognizeTextHandler)
//
//        do {
//            // Perform the text-recognition request.
//            try requestHandler.perform([request])
//        } catch {
//            print("Unable to perform the requests: \(error).")
//        }
//    }
//
//    private func recognizeTextHandler(request: VNRequest, error: Error?) {
//        guard let observations =
//                request.results as? [VNRecognizedTextObservation] else {
//            return
//        }
//        let recognizedStrings = observations.compactMap { observation in
//            // Return the string of the top VNRecognizedText instance.
//            return observation.topCandidates(1).first?.string
//        }
//
//        // Process the recognized strings.
//        recognizedText = recognizedStrings.joined()
//    }
}


struct PageImageView_Previews: PreviewProvider {
    static var previews: some View {
        PageImageView(book: Book(), expandedImg: nil, unitTitle: "")
    }
}
