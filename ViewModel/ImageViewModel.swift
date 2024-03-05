//
//  ImageViewModel.swift
//  mocacong
//
//  Created by Suji Lee on 2023/05/24.
//

import Foundation
import Combine
import SwiftUI

class ImageViewModel: ObservableObject {
    
    @Published var overLimitErrorOccurred = false

    @Published var cafeImageReview: CafeImageReview = CafeImageReview()
    @Published var cafeImageArray: [CafeImage] = []
    @Published var currentPage: Int = 0

    @Published var isFetching: Bool = false
    @Published var isPosting: Bool = false
    
    @Published var showAlert: Bool = false
    
    var cancellables = Set<AnyCancellable>()
    
    func loadMorePhotos(accessToken: String, cafeVM: CafeViewModel) {
        self.currentPage += 1
        self.fetchCafeReviewImageData(accessToken: accessToken, mapId: cafeVM.cafeMapId, page: self.currentPage)
    }
    
    //리뷰 이미지 등록
    func requestReviewImageDataPost(accessToken: String, mapId: String, imageDataArrayToPost: [Data]?) -> Future<CafeImageReview, Error> {
        return Future { promise in
            guard let url = URL(string: "\(requestURL)/cafes/\(mapId)/img") else {
                promise(.failure(URLError(.badURL)))
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            let boundary = UUID().uuidString
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            
            let data = self.createBody(with: ["files": imageDataArrayToPost as Any], boundary: boundary)
            request.httpBody = data
            URLSession.shared.dataTaskPublisher(for: request)
                .subscribe(on: DispatchQueue.global(qos: .background))
                .receive(on: DispatchQueue.main)
                .tryMap { data, response -> Data in
                    guard let httpResponse = response as? HTTPURLResponse else {
                        throw URLError(.badServerResponse)
                    }
                    switch httpResponse.statusCode {
                    case 200:
                        print("이미지 리뷰 등록 상태코드 200")
                        self.currentPage = 0
                        self.cafeImageArray.removeAll()
                        self.fetchCafeReviewImageData(accessToken: accessToken, mapId: mapId, page: 0)
                    case 400:
                        print("이미지 리뷰 등록 상태코드 400")
                    case 401:
                        print("이미지 리뷰 등록 상태코드 401")
                        TokenManager.shared.refreshAccessToken(accessInfo: AccessInfo(refreshToken: TokenManager.shared.getRefreshToken()))
                        if let token = TokenManager.shared.getToken() {
                            self.requestReviewImageDataPost(accessToken: token, mapId: mapId, imageDataArrayToPost: imageDataArrayToPost)
                        }
                    case 500 :
                        print("서버 에러 500")
                        StateManager.shared.serverDown = true
                    default:
                        print("이미지 리뷰 등록 상태코드: \(httpResponse.statusCode)")
                    }
                    return data
                }
                .decode(type: CafeImageReview.self, decoder: JSONDecoder())
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
                }, receiveValue: { data in
                    promise(.success(data))
                    if let code = data.code {
                        self.cafeImageReview.code = code
                    }
                    self.isPosting = false
                })
                .store(in: &self.cancellables)
        }
    }
    
    //리뷰 이미지 조회
    func fetchCafeReviewImageData(accessToken: String, mapId: String, page: Int) {
        self.isFetching = true
        requestCafeReviewImageDataFetch(accessToken: accessToken, mapId: mapId, page: page)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { result in
                switch result {
                case .failure(let error):
                    print("카페 리뷰 이미지 조회 비동기 처리 error: \(error)")
                case .finished:
                    print("카페 리뷰 이미지 조회 비동기 처리 종료")
                    self.isFetching = false
                }
            }, receiveValue: { data in
                self.cafeImageReview = data
                if let images = self.cafeImageReview.cafeImages {
                    for image in images {
                        if !self.cafeImageArray.contains(image) {
                            self.cafeImageArray.append(image)
                        }
                    }
                }
            })
            .store(in: &cancellables)
    }
    func requestCafeReviewImageDataFetch(accessToken: String, mapId: String, page: Int) -> Future<CafeImageReview, Error> {
        return Future { promise in
            guard let url = URL(string: "\(requestURL)/cafes/\(mapId)/img?page=\(page)&count=10") else {
                fatalError("Invalid URL")
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            
            print("카페 리뷰 이미지 조회 요청 : ", request)
            
            URLSession.shared.dataTaskPublisher(for: request)
                .subscribe(on: DispatchQueue.global(qos: .background))
                .receive(on: DispatchQueue.main)
                .tryMap { data, response -> Data in
                    guard let httpResponse = response as? HTTPURLResponse else {
                        throw URLError(.badServerResponse)
                    }
                    switch httpResponse.statusCode {
                    case 200:
                        print("카페 리뷰 이미지 조회 상태코드 200")
                    case 401:
                        print("카페 리뷰 이미지 조회 상태코드 401")
                        TokenManager.shared.refreshAccessToken(accessInfo: AccessInfo(refreshToken:  TokenManager.shared.getRefreshToken()))
                        if let token = TokenManager.shared.getToken() {
                            self.fetchCafeReviewImageData(accessToken: token, mapId: mapId, page: page)
                        }
                    case 500 :
                        print("서버 에러 500")
                        StateManager.shared.serverDown = true
                    default:
                        print("카페 리뷰 이미지 조회 상태코드: \(httpResponse.statusCode)")
                    }
                    return data
                }
                .decode(type: CafeImageReview.self, decoder: JSONDecoder())
                .sink { completion in
                    //데이터가 도착하면
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
    
    //리뷰 이미지 수정
    func updateReivewImage(accessToken: String, mapId: String, reviewImageToUpdate: CafeImage, imageDataToUpdate: Data) {
        self.isPosting = true
        requestReivewImageDataUpdate(accessToken: accessToken, mapId: mapId, reviewImageToUpdate: reviewImageToUpdate, imageDataToUpdate: imageDataToUpdate)
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
                    self.isPosting = false
                    self.showAlert = true
                    break
                }
            }, receiveValue: { _ in
                self.currentPage = 0
                self.cafeImageArray.removeAll()
                self.fetchCafeReviewImageData(accessToken: accessToken, mapId: mapId, page: 0)
            })
            .store(in: &self.cancellables)
    }
    func requestReivewImageDataUpdate(accessToken: String, mapId: String, reviewImageToUpdate: CafeImage, imageDataToUpdate: Data) -> Future<Bool, Error> {
        return Future { promise in
            guard let url = URL(string: "\(requestURL)/cafes/\(mapId)/img/\(reviewImageToUpdate.id)") else {
                promise(.failure(URLError(.badURL)))
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            let boundary = UUID().uuidString
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            
            let data = self.createBody(with: ["file": imageDataToUpdate], boundary: boundary)
            request.httpBody = data
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                DispatchQueue.main.async {
                    if let error = error {
                        promise(.failure(error))
                        print("리뷰 이미지 업데이트 요청 error : \(error)")
                    } else if let httpResponse = response as? HTTPURLResponse {
                        if httpResponse.statusCode == 200 {
                            promise(.success(true))
                            print("리뷰 이미지 업데이트 응답 상태코드 : ", httpResponse.statusCode)
                        } else if httpResponse.statusCode == 401 {
                            print("리뷰 이미지 업데이트 상태코드 401")
                            TokenManager.shared.refreshAccessToken(accessInfo: AccessInfo(refreshToken: TokenManager.shared.getRefreshToken()))
                            if let token = TokenManager.shared.getToken() {
                                self.updateReivewImage(accessToken: token, mapId: mapId, reviewImageToUpdate: reviewImageToUpdate, imageDataToUpdate: imageDataToUpdate)
                            }
                        } else if httpResponse.statusCode == 500 {
                            print("서버 에러 500")
                            StateManager.shared.serverDown = true
                    } else {
                            promise(.failure(URLError(URLError.Code.badServerResponse)))
                            print("리뷰 이미지 업데이트 응답 상태코드 : ", httpResponse.statusCode)
                        }
                    }
                }
            }.resume()
        }
    }
    
    private func createBody(with parameters: [String: Any], boundary: String) -> Data {
        var body = Data()
        
        for (key, value) in parameters {
            if key == "files", let imageDataArray = value as? [Data] {
                for imageData in imageDataArray {
                    body.append(Data("--\(boundary)\r\n".utf8))
                    body.append(Data("Content-Disposition: form-data; name=\"\(key)\"; filename=\"image.jpg\"\r\n".utf8))
                    body.append(Data("Content-Type: image/jpeg\r\n\r\n".utf8))
                    body.append(imageData)
                    body.append(Data("\r\n".utf8))
                }
            } else if key == "file", let image = value as? Data {
                body.append(Data("--\(boundary)\r\n".utf8))
                body.append(Data("Content-Disposition: form-data; name=\"\(key)\"; filename=\"image.jpg\"\r\n".utf8))
                body.append(Data("Content-Type: image/jpeg\r\n\r\n".utf8))
                body.append(image)
                body.append(Data("\r\n".utf8))
            }
        }
        body.append(Data("--\(boundary)--\r\n".utf8))
        return body
    }
}
