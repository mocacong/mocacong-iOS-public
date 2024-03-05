//
//  CafeImageModal.swift
//  mocacong
//
//  Created by Suji Lee on 2023/06/06.
//

import SwiftUI
import PhotosUI
import Combine

enum AlertType {
    case noError
    case exceedMaxImageCount
    case imageVolumeOver10MB
    case wrongImageFormat
    case emptyImageData
}

struct CafeImageModal: View {
    
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var memberVM: MemberViewModel
    @ObservedObject var cafeVM: CafeViewModel
    @ObservedObject var imageVM: ImageViewModel
    @State var selectedPhotos: [PhotosPickerItem] = []
    @State var reviewImageDatas: [Data]?
    
    @State var alertType: AlertType = .noError
    @State var showAlert: Bool = false
    var photoSize: CGFloat? = screenWidth / 2
    
    @State var cancellables = Set<AnyCancellable>()
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("이미지 리뷰 등록")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.hex_4F4A44)
                        Text("사진은 총 3개까지 업로드 할 수 있습니다")
                            .font(.system(size: 15))
                            .foregroundColor(.hex_4F4A44)
                    }
                    Spacer()
                }
                .padding(.bottom)
                //모두 삭제 버튼
                HStack {
                    Spacer()
                    Button(action: {
                        reviewImageDatas?.removeAll()
                        selectedPhotos.removeAll()
                    }, label: {
                        HStack(spacing: 2) {
                            Image(systemName: "x.circle.fill")
                                .foregroundColor(.hex_B86A6A)
                                .font(.system(size: 15))
                            Text("모두 삭제")
                                .foregroundColor(.hex_B86A6A)
                                .font(.system(size: 15, weight: .medium))
                        }
                    })
                }
                .padding(.bottom, -10)
                ScrollView(.horizontal) {
                    HStack(spacing: 12) {
                            PhotosPicker(selection: $selectedPhotos, maxSelectionCount: 3, matching: .images) {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundStyle(Color.hex_4F4A44.opacity(0.3))
                                    .frame(width: photoSize, height: photoSize)
                                    .overlay {
                                        Image(systemName: "plus")
                                            .foregroundColor(.white)
                                            .font(.system(size: 30, weight: .light))
                                    }
                            }
                            .onChange(of: selectedPhotos) { newItems in
                                let dispatchGroup = DispatchGroup()
                                
                                var imageDataArray: [Data] = []
                                
                                for item in newItems {
                                    dispatchGroup.enter()
                                    
                                    item.loadTransferable(type: Data.self) { result in
                                        switch result {
                                        case .success(let data):
                                            if let data = data {
                                                imageDataArray.append(data)
                                            } else {
                                                print("Data is nil")
                                            }
                                        case .failure(let failure):
                                            fatalError("\(failure)")
                                        }
                                        
                                        dispatchGroup.leave()
                                    }
                                }
                                dispatchGroup.notify(queue: .main) {
                                    self.reviewImageDatas = imageDataArray
                                }
                            }
                        ForEach(0..<min(reviewImageDatas?.count ?? 0, 3), id: \.self) { index in
                            if let imageData = reviewImageDatas?[index],
                               let uiImage = UIImage(data: imageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: photoSize, height: photoSize)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .clipped()
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.hex_4F4A44, lineWidth: 0.4)
                                    )
                            }
                        }
                        ForEach(0..<(3 - min(reviewImageDatas?.count ?? 0, 3)), id: \.self) { _ in
                            PhotoGridTemplate()
                        }
                    }
                    .padding(.vertical)
                }
            }
            .padding(.top, -50)
            .padding(.horizontal)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }, label: {
                        Text("취소")
                    })
                    .disabled(reviewImageDatas?.first == nil)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if imageVM.isPosting == false {
                        Button(action: {
                            uploadImage()
                        }, label: {
                            Text("저장")
                        })
                        .disabled(reviewImageDatas?.first == nil || imageVM.isPosting == true)
                    } else {
                        ProgressView()
                    }
                }
            }
        }
        .background(Color.hex_FEFCF6)
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("알림"),
                message: AlertText(alertType: alertType),
                dismissButton: .default(Text("확인")) {
                    showAlert = false
                    dismiss()
                }
            )
        }
    }
    
    func AlertText(alertType: AlertType) -> Text {
        switch alertType {
        case .noError:
            return Text("이미지가 등록되었습니다")
        case .exceedMaxImageCount:
            return Text("이미지는 3개까지 등록할 수 있습니다")
        case .wrongImageFormat:
            return Text("잘못된 이미지 파일 형식입니다")
        case .emptyImageData:
            return Text("빈 이미지는 등록할 수 없습니다")
        case .imageVolumeOver10MB:
            return Text("이미지 용량이 10MG를 초과합니다")
        }
    }
    
    @ViewBuilder
    func PhotoGridTemplate() -> some View {
        RoundedRectangle(cornerRadius: 10)
            .stroke(Color.hex_4F4A44, lineWidth: 0.4)
            .frame(width: photoSize, height: photoSize)
            .overlay {
                Image(systemName: "photo")
                    .font(.system(size: 30, weight: .light))
                    .foregroundStyle(Color.hex_4F4A44.opacity(0.3))
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
        guard let imageDataArray = reviewImageDatas else { return }

        var resizedImageDataArray: [Data] = []
        for imageData in imageDataArray {
            if let imageToResize = UIImage(data: imageData) {
                let resizedImage = resizeImageMaintainingAspectRatio(image: imageToResize, newWidth: 200)
                if let compressedImageData = resizedImage.jpegData(compressionQuality: 1.0) {
                    resizedImageDataArray.append(compressedImageData)
                }
            }
        }

        if resizedImageDataArray.isEmpty { return }
        
        if let token = TokenManager.shared.getToken() {
            imageVM.isPosting = true
            imageVM.requestReviewImageDataPost(accessToken: token, mapId: cafeVM.cafeMapId, imageDataArrayToPost: resizedImageDataArray)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        print("리뷰 이미지 등록 비동기 종료")
                    case .failure(let error):
                        print("리뷰 이미지 등록 비동기 error : \(error)")
                    }
                }, receiveValue: { cafeImageReview in
                    if let code = cafeImageReview.code {
                        switch code {
                        case 2008:
                            alertType = .exceedMaxImageCount
                            showAlert = true
                        case 9003:
                            alertType = .imageVolumeOver10MB
                            showAlert = true
                            
                        case 9006:
                            alertType = .wrongImageFormat
                            showAlert = true
                            
                        case 9007:
                            alertType = .emptyImageData
                            showAlert = true
                        default :
                            alertType = .noError
                        }
                    } else {
                        alertType = .noError
                        showAlert = true
                    }
                    
                })
                .store(in: &self.cancellables)
        }
    }

}
