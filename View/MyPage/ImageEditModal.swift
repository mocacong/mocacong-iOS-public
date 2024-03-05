//
//  ImageEditModal.swift
//  mocacong
//
//  Created by Suji Lee on 2023/05/10.
//

import SwiftUI
import PhotosUI

struct ImageEditModal: View {
    
    @ObservedObject var memberVM: MemberViewModel
    @ObservedObject var myVM: MyViewModel
    @Binding var profileImageData: Data?
    @State var profileImageDataToUpdate: Data?
    @State var selectedPhotos: [PhotosPickerItem] = []
    @Environment(\.dismiss) private var dismiss
    
    @State var memberToUpdate: Member = Member()
    
    @State var newNickname: String = ""
    @State var isDuplicated: Bool?
    @State var textInputAccepted: Bool = false
    @State var nicknameHasNumber: Bool = false
    @State var nicknameHasSpecial: Bool = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 15) {
                VStack(spacing: 5) {
                    Text("프로필 설정")
                        .font(.system(size: 20, weight: .semibold))
                    Text("프로필은 리뷰 댓글에 표시됩니다")
                        .foregroundColor(.hex_4E483C)
                        .font(.system(size: 16))
                        .padding(.bottom)
                }
                .padding(.top, -30)
                //이미지
                VStack {
                    if let imageData = profileImageDataToUpdate, let uiImage = UIImage(data: imageData) {
                        PhotosPicker(selection: $selectedPhotos, maxSelectionCount: 1, matching: .images) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: screenWidth * 0.465, height: screenWidth * 0.465)
                                .clipShape(Circle())
                                .clipped()
                                .overlay {
                                    Circle()
                                        .stroke(Color.hex_828282, lineWidth: 0.3)
                                }
                        }
                        .onChange(of: selectedPhotos) { newItem in
                            guard let item = selectedPhotos.first else {
                                return
                            }
                            item.loadTransferable(type: Data.self) { result in
                                switch result {
                                case .success(let data):
                                    if let data = data {
                                        self.profileImageDataToUpdate = data
                                    } else {
                                        print("data is nil")
                                    }
                                case .failure(let failure):
                                    fatalError("\(failure)")
                                }
                            }
                        }
                    } else {
                        PhotosPicker(selection: $selectedPhotos, maxSelectionCount: 1, matching: .images) {
                            Image("noProfile")
                                .resizable()
                                .scaledToFill()
                                .frame(width: screenWidth * 0.465, height: screenWidth * 0.465)
                                .clipShape(Circle())
                                .clipped()
                        }
                        .onChange(of: selectedPhotos) { newItem in
                            guard let item = selectedPhotos.first else {
                                return
                            }
                            item.loadTransferable(type: Data.self) { result in
                                switch result {
                                case .success(let data):
                                    if let data = data {
                                        self.profileImageDataToUpdate = data
                                    } else {
                                        print("data is nil")
                                    }
                                case .failure(let failure):
                                    fatalError("\(failure)")
                                }
                            }
                        }
                    }
                }
                .padding(.bottom)
                
                //닉네임 입력창
                VStack(alignment: .leading) {
                    VStack {
                        TextField(myVM.myProfileData.nickname ?? "", text: $newNickname)
                            .font(.system(size: 17.5))
                            .padding(.leading, 7)
                            .onAppear {
                                UIApplication.shared.hideKeyboard()
                            }
                            .onChange(of: newNickname, perform: { newValue in
                                checkNicknameDuplication(nickname: newValue)
                                print(newValue)
                            })
                            .onChange(of: newNickname) { val in
                                //닉네임 개수 검사
                                if val.count >= 2 && val.count <= 6 {
                                    textInputAccepted = true
                                } else {
                                    textInputAccepted = false
                                }
                                //닉네임 숫자 검사
                                let numbers = CharacterSet.decimalDigits
                                nicknameHasNumber = val.unicodeScalars.contains(where: numbers.contains)
                                if nicknameHasNumber == true {
                                    textInputAccepted = false
                                } else {
                                    textInputAccepted = true
                                }
                                //닉네임 특수문자 검사
                                let specialCharacter = CharacterSet(charactersIn: " !\"#$%&'()*+,-./:;<=>?@[]^_`{|}~")
                                nicknameHasSpecial =  val.unicodeScalars.contains(where: specialCharacter.contains)
                                if nicknameHasSpecial == true {
                                    textInputAccepted = false
                                } else {
                                    textInputAccepted = true
                                }
                            }
                        Divider()
                    }
                    VStack(alignment: .leading) {
                        if newNickname.count < 2 || newNickname.count > 6 || nicknameHasNumber == true || nicknameHasSpecial == true {
                            Text("닉네임은 한글, 영어로만 구성된 2~6자여야 합니다")
                                .font(.system(size: 13))
                                .foregroundColor(.hex_B86A6A)
                        } else {
                            if isDuplicated != nil {
                                if isDuplicated == true{
                                    Text("중복된 닉네임입니다")
                                        .font(.system(size: 13))
                                        .foregroundColor(.hex_B86A6A)
                                } else if isDuplicated == false {
                                    Text("사용할 수 있는 닉네임입니다")
                                        .font(.system(size: 13))
                                        .foregroundColor(.hex_627D41)
                                }
                            }
                        }
                    }
                    .padding(.leading, 5)
                    .padding(.bottom, 40)
                }
                .padding(.horizontal, 30)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading, content: {
                    Button("취소") {
                        dismiss()
                    }
                })
                ToolbarItem(placement: .navigationBarTrailing, content: {
                    Button(action: {
                        memberToUpdate.nickname = newNickname
                        if let token = TokenManager.shared.getToken() {
                            profileImageData = profileImageDataToUpdate
                            myVM.updateProfileNickname(accesToken: token, memberToUpdate: memberToUpdate)
                            if myVM.isUpdatingProfileIamge == false {
                                uploadImage()
                            }
                            dismiss()
                        }
                    }, label: {
                        Text("저장")
                            .foregroundStyle(newNickname.trimmingCharacters(in: .whitespaces) == "" || isDuplicated == nil || isDuplicated == true || textInputAccepted == false ? Color.hex_828282 : Color.hex_627D41)
                    })
                    .disabled(newNickname.trimmingCharacters(in: .whitespaces) == "" || isDuplicated == nil || isDuplicated == true || textInputAccepted == false)
                })
            }
        }
        .onAppear {
            memberToUpdate = myVM.myProfileData
            newNickname = myVM.myProfileData.nickname ?? "닉네임 왜 없음"
            if profileImageData != nil {
                profileImageDataToUpdate = profileImageData
            }
        }
    }
    
    func checkNicknameDuplication(nickname: String) {
        memberVM.checkNicknameDuplicationToServer(nicknameToCheck: nickname)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("중복검사 비동기 실패")
                    print("중복검사 Error: \(error.localizedDescription)")
                case .finished:
                    if let isDuplicated = memberVM.isDuplicated {
                        self.isDuplicated = isDuplicated
                    }
                }
            }, receiveValue: { isDuplicate in
                
            })
            .store(in: &memberVM.registerCancellables)
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
        if let imageDataToResize = profileImageDataToUpdate, let imageToResize = UIImage(data: imageDataToResize) {
            let resizedImage = resizeImageMaintainingAspectRatio(image: imageToResize, newWidth: 200)
            let compressedImageData = resizedImage.jpegData(compressionQuality: 1.0)
            if let token = TokenManager.shared.getToken() {
                myVM.updateProfileImage(accessToken: token, imageData: profileImageDataToUpdate)
            }
        }
    }
}
