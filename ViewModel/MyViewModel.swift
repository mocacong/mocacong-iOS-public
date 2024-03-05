//
//  MyViewModel.swift
//  mocacong
//
//  Created by Suji Lee on 2023/04/26.
//

import Foundation
import Combine
import SwiftUI

class MyViewModel: ObservableObject {
    
    @Published var myProfileData: Member = Member()
    @Published var myFavoriteData: MyFavorite = MyFavorite()
    @Published var myFavoriteCafeArray: [Cafe] = []
    @Published var myReviewData: MyReview = MyReview()
    @Published var myReviewCafeArray: [Review] = []
    @Published var myCommentData: MyComment = MyComment()
    @Published var myCommentCafeArray: [Cafe] = []
    
    @Published var currentPage: Int = 0
    
    @Published var profileImageData: Data?
    @Published var profileDataFetched: Bool = false
    
    @Published var isFetchingProfileImage: Bool = false
    @Published var isUpdatingProfileIamge: Bool = false
    
    var cancellables = Set<AnyCancellable>()
    
    func resetList() {
        currentPage = 0
        self.myReviewCafeArray.removeAll()
        self.myCommentCafeArray.removeAll()
        self.myFavoriteCafeArray.removeAll()
    }
    
    func loadMoreList(accessToken: String, tab: Tab) {
        self.currentPage += 1
        switch tab {
        case .favorite:
            self.fetchMyFavorite(accessToken: accessToken, page: currentPage)
        case .review:
            self.fetchMyReview(accessToken: accessToken, page: currentPage)
        case .comment:
            self.fetchMyComment(accessToken: accessToken, page: currentPage)
        }
    }
    
    func fetchMyFavorite(accessToken: String, page: Int) {
        reqeustMyFavoriteDataFetch(accessToken: accessToken, page: page)
            .sink(receiveCompletion: { result in
                switch result {
                case .failure(let error):
                    print("나의 즐겨찾기 로드 비동기 처리 error: \(error)")
                case .finished:
                    print("나의 즐겨찾기 로드 비동기 처리 종료")
                }
            }, receiveValue: { data in
                self.myFavoriteData = data
                if let favoriteCafes = self.myFavoriteData.cafes {
                    for cafe in favoriteCafes {
                        if !self.myFavoriteCafeArray.contains(where: { $0.name == cafe.name }) {                            self.myFavoriteCafeArray.append(cafe)
                        }
                    }
                }
            })
            .store(in: &cancellables)
    }
    func reqeustMyFavoriteDataFetch(accessToken: String, page: Int) -> Future<MyFavorite, Error> {
        return Future { promise in
            guard let url = URL(string: "\(requestURL)/members/mypage/stars?page=\(page)&count=20") else {
                fatalError("나의 즐겨찾기 로드 Invalid URL")
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                        
            URLSession.shared.dataTaskPublisher(for: request)
                .subscribe(on: DispatchQueue.global(qos: .background))
                .receive(on: DispatchQueue.main)
                .tryMap { data, response -> Data in
                    guard let httpResponse = response as? HTTPURLResponse else {
                        throw URLError(.badServerResponse)
                    }
                    switch httpResponse.statusCode {
                    case 200:
                        print("나의 즐겨찾는 카페 조회 상태코드 200")
                    case 401:
                        print("나의 즐겨찾는 카페 조회 상태코드 401")
                        TokenManager.shared.refreshAccessToken(accessInfo: AccessInfo(refreshToken: TokenManager.shared.getRefreshToken()))
                        if let token = TokenManager.shared.getToken() {
                            self.fetchMyFavorite(accessToken: token, page: page)
                        }
                    case 500 :
                        print("나의 즐겨찾는 카페 조회 서버 에러 500")
                        StateManager.shared.serverDown = true
                    default:
                        print("나의 즐겨찾는 카페 조회 상태코드: \(httpResponse.statusCode)")
                    }
                    return data
                }
                .decode(type: MyFavorite.self, decoder: JSONDecoder())
                .sink { completion in
                    switch completion {
                    case .failure(let error):
                        if let urlError = error as? URLError {
                            switch urlError.code {
                            case .notConnectedToInternet, .networkConnectionLost, .cannotConnectToHost:
                                StateManager.shared.serverDown = true // Handle connection-related errors
                            default:
                                break // Handle other errors if needed
                            }
                        }
                        print("Error: \(error)")
                    case .finished:
                        break
                    }
                } receiveValue: { data in
                    promise(.success(data))
                }
                .store(in: &self.cancellables)
        }
    }
    
    func fetchMyReview(accessToken: String, page: Int) {
        reqeustMyReviewDataFetch(accessToken: accessToken, page: page)
            .sink(receiveCompletion: { result in
                switch result {
                case .failure(let error):
                    if let urlError = error as? URLError {
                        switch urlError.code {
                        case .notConnectedToInternet, .networkConnectionLost, .cannotConnectToHost:
                            StateManager.shared.serverDown = true // Handle connection-related errors
                        default:
                            break // Handle other errors if needed
                        }
                    }
                    print("Error: \(error)")
                case .finished:
                    break
                }
            }, receiveValue: { data in
                self.myReviewData = data
                if let reviewdCafes = self.myReviewData.cafes {
                    for cafe in reviewdCafes {
                        if !self.myReviewCafeArray.contains(where: { $0.name == cafe.name }) {                            
                            self.myReviewCafeArray.append(cafe)
                        }
                    }
                }
            })
            .store(in: &cancellables)
    }
    func reqeustMyReviewDataFetch(accessToken: String, page: Int) -> Future<MyReview, Error> {
        return Future { promise in
            guard let url = URL(string: "\(requestURL)/members/mypage/reviews?page=\(page)&count=20") else {
                fatalError("나의 리뷰카페 로드 Invalid URL")
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                        
            URLSession.shared.dataTaskPublisher(for: request)
                .subscribe(on: DispatchQueue.global(qos: .background))
                .receive(on: DispatchQueue.main)
                .tryMap { data, response -> Data in
                    guard let httpResponse = response as? HTTPURLResponse else {
                        throw URLError(.badServerResponse)
                    }
                    switch httpResponse.statusCode {
                    case 200:
                        print("내가 리뷰한 카페 조회 상태코드 200")
                    case 401:
                        print("내가 리뷰한 카페 조회 상태코드 401")
                        TokenManager.shared.refreshAccessToken(accessInfo: AccessInfo(refreshToken: TokenManager.shared.getRefreshToken()))
                        if let token = TokenManager.shared.getToken() {
                            self.fetchMyReview(accessToken: token, page: page)
                        }
                    case 500 :
                        print("서버 에러 500")
                        StateManager.shared.serverDown = true
                    default:
                        print("내가 리뷰한 카페 조회 상태코드: \(httpResponse.statusCode)")
                    }
                    return data
                }
                .decode(type: MyReview.self, decoder: JSONDecoder())
                .sink { completion in
                    switch completion {
                    case .finished:
                        print("나의 리뷰 조회 요청 종료")
                        break
                    case .failure(let error):
                        print("나의 리뷰 조회 요청 error : \(error)")
                    }
                } receiveValue: { data in
                    promise(.success(data))
                }
                .store(in: &self.cancellables)
        }
    }
    
    func fetchMyComment(accessToken: String, page: Int) {
        reqeustMyCommentDataFetch(accessToken: accessToken, page: page)
            .sink(receiveCompletion: { result in
                switch result {
                case .failure(let error):
                    if let urlError = error as? URLError {
                        switch urlError.code {
                        case .notConnectedToInternet, .networkConnectionLost, .cannotConnectToHost:
                            StateManager.shared.serverDown = true // Handle connection-related errors
                        default:
                            break // Handle other errors if needed
                        }
                    }
                    print("Error: \(error)")
                case .finished:
                    break
                }
            }, receiveValue: { data in
                self.myCommentData = data
                if let cafes = self.myCommentData.cafes {
                    for cafe in cafes {                                            
                        self.myCommentCafeArray.append(cafe)
                    }
                }
            })
            .store(in: &cancellables)
    }
    func reqeustMyCommentDataFetch(accessToken: String, page: Int) -> Future<MyComment, Error> {
        return Future { promise in
            guard let url = URL(string: "\(requestURL)/members/mypage/comments?page=\(page)&count=20") else {
                fatalError("나의 댓글 로드 Invalid URL")
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            
            URLSession.shared.dataTaskPublisher(for: request)
                .subscribe(on: DispatchQueue.global(qos: .background))
                .receive(on: DispatchQueue.main)
                .tryMap { data, response -> Data in
                    guard let httpResponse = response as? HTTPURLResponse else {
                        throw URLError(.badServerResponse)
                    }
                    switch httpResponse.statusCode {
                    case 200:
                        print("내가 쓴 댓글 조회 상태코드 200")
                    case 401:
                        print("내가 쓴 댓글 조회 상태코드 401")
                        TokenManager.shared.refreshAccessToken(accessInfo: AccessInfo(refreshToken:  TokenManager.shared.getRefreshToken()))
                        if let token = TokenManager.shared.getToken() {
                            self.fetchMyComment(accessToken: token, page: page)
                        }
                    case 500 :
                        print("서버 에러 500")
                        StateManager.shared.serverDown = true
                    default:
                        print("내가 쓴 댓글 조회 상태코드: \(httpResponse.statusCode)")
                    }
                    return data
                }
                .decode(type: MyComment.self, decoder: JSONDecoder())
                .sink { completion in
                    switch completion {
                    case .failure(let error):
                        if let urlError = error as? URLError {
                            switch urlError.code {
                            case .notConnectedToInternet, .networkConnectionLost, .cannotConnectToHost:
                                StateManager.shared.serverDown = true // Handle connection-related errors
                            default:
                                break // Handle other errors if needed
                            }
                        }
                        print("Error: \(error)")
                    case .finished:
                        break
                    }
                } receiveValue: { data in
                    promise(.success(data))
                }
                .store(in: &self.cancellables)
        }
    }
    
    func fetchMyProfileData(accessToken: String) {
        requestMyProfileDataFetch(accessToken: accessToken)
            .sink(receiveCompletion: { result in
                switch result {
                case .failure(let error):
                    print("프로필 조회 비동기 처리 error: \(error)")
                case .finished:
                    print("프로필 조회 비동기 처리 종료")
                }
            }, receiveValue: { data in
                self.profileDataFetched = true
            })
            .store(in: &cancellables)
    }
    func requestMyProfileDataFetch(accessToken: String) -> Future<Member, Error> {
        return Future { promise in
            guard let url = URL(string: "\(requestURL)/members/mypage") else {
                fatalError("Invalid URL")
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            
            URLSession.shared.dataTaskPublisher(for: request)
                .subscribe(on: DispatchQueue.global(qos: .background))
                .receive(on: DispatchQueue.main)
                .tryMap { data, response -> Data in
                    guard let httpResponse = response as? HTTPURLResponse else {
                        throw URLError(.badServerResponse)
                    }
                    switch httpResponse.statusCode {
                    case 200:
                        print("프로필 조회 상태코드 200")
                    case 401:
                        print("프로필 조회 상태코드 401")
                        TokenManager.shared.refreshAccessToken(accessInfo: AccessInfo(refreshToken:  TokenManager.shared.getRefreshToken()))
                        if let token = TokenManager.shared.getToken() {
                            self.fetchMyProfileData(accessToken: token)
                        }
                    case 500 :
                        print("서버 에러 500")
                        StateManager.shared.serverDown = true
                    default:
                        print("프로필 조회 상태코드: \(httpResponse.statusCode)")
                    }
                    return data
                }
                .decode(type: Member.self, decoder: JSONDecoder())
                .sink { completion in
                    switch completion {
                    case .failure(let error):
                        if let urlError = error as? URLError {
                            switch urlError.code {
                            case .notConnectedToInternet, .networkConnectionLost, .cannotConnectToHost:
                                StateManager.shared.serverDown = true // Handle connection-related errors
                            default:
                                break // Handle other errors if needed
                            }
                        }
                        print("Error: \(error)")
                    case .finished:
                        break
                    }
                } receiveValue: { data in
                    promise(.success(data))
                    self.myProfileData = data
                    if let imgURL = data.imgUrl {
                        self.loadProfileImage(imageUrl: imgURL)
                    } else {
                        self.profileImageData = nil
                    }
                }
                .store(in: &self.cancellables)
        }
    }
    
    func updateProfileImage(accessToken: String, imageData: Data?) {
        self.isUpdatingProfileIamge = true
        requestProfileImageDataUpload(accessToken: accessToken, imageData: imageData)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    if let urlError = error as? URLError {
                        switch urlError.code {
                        case .notConnectedToInternet, .networkConnectionLost, .cannotConnectToHost:
                            StateManager.shared.serverDown = true // Handle connection-related errors
                        default:
                            break // Handle other errors if needed
                        }
                    }
                    print("Error: \(error)")
                case .finished:
                    break
                }
            }, receiveValue: { _ in
                self.isUpdatingProfileIamge = false
            })
            .store(in: &self.cancellables)
    }
    func requestProfileImageDataUpload(accessToken: String, imageData: Data?) -> Future<Bool, Error> {
        return Future { promise in
            guard let url = URL(string: "\(requestURL)/members/mypage/img") else {
                promise(.failure(URLError(.badURL)))
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            let boundary = UUID().uuidString
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            
            let data = self.createBody(with: ["file": imageData], boundary: boundary)
            request.httpBody = data
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                DispatchQueue.main.async {
                    if let error = error {
                        promise(.failure(error))
                        print("프로필이미지 업데이트 요청 error : \(error)")
                    } else if let httpResponse = response as? HTTPURLResponse {
                        if httpResponse.statusCode == 200 {
                            promise(.success(true))
                            print("프로필이미지 업데이트 응답 상태코드 : ", httpResponse.statusCode)
                        } else if httpResponse.statusCode == 401 {
                            TokenManager.shared.refreshAccessToken(accessInfo: AccessInfo(refreshToken: TokenManager.shared.getRefreshToken()))
                            if let token = TokenManager.shared.getToken() {
                                self.updateProfileImage(accessToken: token, imageData: imageData)
                            }
                        } else if httpResponse.statusCode == 500 {
                            StateManager.shared.serverDown = true
                    } else {
                            promise(.failure(URLError(URLError.Code.badServerResponse)))
                            print("프로필이미지 업데이트 응답 상태코드 : ", httpResponse.statusCode)
                        }
                    }
                }
            }.resume()
        }
    }
    
    //닉네임 수정
    func updateProfileNickname(accesToken: String, memberToUpdate: Member) {
        requestProfileNicknameUpdate(accesToken: accesToken, memberToUpdate: memberToUpdate)
            .sink(receiveCompletion: { completion in
            }, receiveValue: { data in

            })
            .store(in: &self.cancellables)
    }
    func requestProfileNicknameUpdate(accesToken: String, memberToUpdate: Member) -> Future<Member, Error> {
        return Future { promise in
            guard let url = URL(string: "\(requestURL)/members/info") else {
                fatalError("Invalid Url")
            }
            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            request.addValue("Bearer \(accesToken)", forHTTPHeaderField: "Authorization")
            do {
                let jsonData = try JSONEncoder().encode(memberToUpdate)
                request.httpBody = jsonData
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            } catch {
                promise(.failure(error))
            }
                        
            URLSession.shared.dataTaskPublisher(for: request)
                .receive(on: DispatchQueue.main)
                .tryMap { data, response -> Data in
                    guard let httpResponse = response as? HTTPURLResponse else {
                        throw URLError(.badServerResponse)
                    }
                    switch httpResponse.statusCode {
                    case 200:
                        print("프로필 닉네임 수정 상태코드 200")
                    case 401:
                        print("프로필 닉네임 수정 상태코드 401")
                        TokenManager.shared.refreshAccessToken(accessInfo: AccessInfo(refreshToken:  TokenManager.shared.getRefreshToken()))
                        if let token = TokenManager.shared.getToken() {
                            self.updateProfileNickname(accesToken: token, memberToUpdate: memberToUpdate)
                        }
                    case 500 :
                        print("프로필 닉네임 서버 에러 500")
                        StateManager.shared.serverDown = true
                    default:
                        print("프로필 닉네임 수정 상태코드: \(httpResponse.statusCode)")
                    }
                    return data
                }
                .sink { completion in
                    switch completion {
                    case .failure(let error):
                        if let urlError = error as? URLError {
                            switch urlError.code {
                            case .notConnectedToInternet, .networkConnectionLost, .cannotConnectToHost:
                                StateManager.shared.serverDown = true // Handle connection-related errors
                            default:
                                break // Handle other errors if needed
                            }
                        }
                        print("Error: \(error)")
                    case .finished:
                        self.fetchMyProfileData(accessToken: accesToken)
                        break
                    }
                } receiveValue: { data in
                }
                .store(in: &self.cancellables)
        }
    }
    
    private func createBody(with parameters: [String: Any], boundary: String) -> Data {
        
        var body = Data()
        
        for (key, value) in parameters {
            if key == "file" {
                if let image = value as? Data {
                    body.append(Data("--\(boundary)\r\n".utf8))
                    body.append(Data("Content-Disposition: form-data; name=\"\(key)\"; filename=\"image.jpg\"\r\n".utf8))
                    body.append(Data("Content-Type: image/jpeg\r\n\r\n".utf8))
                    body.append(image)
                    body.append(Data("\r\n".utf8))
                } else {
                    print("no image data value")
                }
            }
        }
        body.append(Data("--\(boundary)--\r\n".utf8))
        return body
    }
    
    func loadProfileImage(imageUrl: String) {
        self.isFetchingProfileImage = true
        guard let url = URL(string: imageUrl) else {
            print("Invalid URL.")
            return
        }
        loadProfileImageData(url: url)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        if let urlError = error as? URLError {
                            switch urlError.code {
                            case .notConnectedToInternet, .networkConnectionLost, .cannotConnectToHost:
                                StateManager.shared.serverDown = true // Handle connection-related errors
                            default:
                                break // Handle other errors if needed
                            }
                        }
                        print("Error: \(error)")
                    case .finished:
                        self.isFetchingProfileImage = false
                        break
                    }
                },
                receiveValue: { [weak self] data in
                    print("프로필 이미지 다운로드 응답 데이터 :", data)
                    self?.profileImageData = data
                }
            )
            .store(in: &cancellables)
    }
    
    func loadProfileImageData(url: URL) -> AnyPublisher<Data, Error> {
        URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .eraseToAnyPublisher()
    }
}
