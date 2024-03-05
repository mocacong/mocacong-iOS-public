//
//  ImageEditModal.swift
//  mocacong
//
//  Created by Suji Lee on 2023/05/10.
//

import SwiftUI
import PhotosUI
import SDWebImageSwiftUI

struct CafeImageEditModal: View {
    
    @ObservedObject var memberVM: MemberViewModel
    @ObservedObject var cafeVM: CafeViewModel
    @ObservedObject var imageVM: ImageViewModel
    @State var reviewImageToUpdate: CafeImage
    @State var reviewImageData: Data?
    @State var selectedPhotos: [PhotosPickerItem] = []
    @Environment(\.dismiss) private var dismiss
    @State var showAlert = false
    
    var body: some View {
        NavigationView {
            VStack {
                if let imageData = reviewImageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: screenWidth / 1.5, height: screenWidth / 1.5)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .clipped()
                        .overlay(
                            PhotosPicker(selection: $selectedPhotos, maxSelectionCount: 1, matching: .images) {
                                Circle()
                                    .foregroundColor(.clear)
                                    .frame(width: 300)
                                    .offset(y: -30)
                            }
                                .onChange(of: selectedPhotos) { newItem in
                                    guard let item = selectedPhotos.first else {
                                        return
                                    }
                                    item.loadTransferable(type: Data.self) { result in
                                        switch result {
                                        case .success(let data):
                                            if let data = data {
                                                self.reviewImageData = data
                                            } else {
                                                print("data is nil")
                                            }
                                        case .failure(let failure):
                                            fatalError("\(failure)")
                                        }
                                    }
                                }
                        )
                } else {
                    WebImage(url: URL(string: reviewImageToUpdate.imageUrl ))
                        .resizable()
                        .scaledToFill()
                        .frame(width: screenWidth / 1.5, height: screenWidth / 1.5)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .clipped()
                        .overlay(
                            PhotosPicker(selection: $selectedPhotos, maxSelectionCount: 1, matching: .images) {
                                Circle()
                                    .foregroundColor(.clear)
                                    .frame(width: 300)
                                    .offset(y: -30)
                            }
                                .onChange(of: selectedPhotos) { newItem in
                                    guard let item = selectedPhotos.first else {
                                        return
                                    }
                                    item.loadTransferable(type: Data.self) { result in
                                        switch result {
                                        case .success(let data):
                                            if let data = data {
                                                self.reviewImageData = data
                                            } else {
                                                print("data is nil")
                                            }
                                        case .failure(let failure):
                                            fatalError("\(failure)")
                                        }
                                    }
                                }
                        )
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: {
                        dismiss()
                    }, label: {
                        Text("취소")
                            .foregroundStyle(Color.hex_483F30)
                    })
                }
                ToolbarItem(placement: .confirmationAction) {
                    if imageVM.isPosting == false {
                        Button(action: {
                            if TokenManager.shared.getToken() != nil {
                                uploadImage()
                            }
                        }, label: {
                            Text("저장")
                                .foregroundStyle(Color.hex_627D41)
                        })
                    } else {
                        ProgressView()
                    }
                }
            }
        }
        .background(Color.hex_FEFCF6)
        .alert(isPresented: $imageVM.showAlert) {
            Alert(
                title: Text("알림"),
                message: Text("이미지가 저장되었습니다"),
                dismissButton: .default(Text("확인")) {
                    imageVM.showAlert = false
                    dismiss()
                }
            )
        }
    }
    func resizeImageMaintainingAspectRatio(image: UIImage, newWidth: CGFloat) -> UIImage {
        let aspectRatio = image.size.height / image.size.width
        let newHeight = newWidth * aspectRatio
        
        let size = CGSize(width: newWidth, height: newHeight)
        let renderer = UIGraphicsImageRenderer(size: size)
        let newImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
        return newImage
    }
    
    func uploadImage() {
        if let imageDataToResize = reviewImageData, let imageToResize = UIImage(data: imageDataToResize) {
            let resizedImage = resizeImageMaintainingAspectRatio(image: imageToResize, newWidth: 200)
            let compressedImageData = resizedImage.jpegData(compressionQuality: 1.0)
            if let token = TokenManager.shared.getToken(), let reviewImageDataToUpdate = reviewImageData {
                imageVM.updateReivewImage(accessToken: token, mapId: cafeVM.cafeMapId, reviewImageToUpdate: reviewImageToUpdate, imageDataToUpdate: reviewImageDataToUpdate)
            }
        }
    }
}
