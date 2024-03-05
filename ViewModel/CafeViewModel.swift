//
//  cafeViewModel.swift
//  mocacong
//
//  Created by Suji Lee on 2023/04/03.
//

import Foundation
import Combine
import SwiftUI

class CafeViewModel: ObservableObject {
    
    @Published var cafeMapId: String = "initial value"
    @Published var cafeData: Cafe = Cafe()
    @Published var myCafeReviewData: Review = Review()
    @Published var pageIndex: Int = 0
    @Published var successCafePost: Bool?
    
    var cancellables = Set<AnyCancellable>()
    var reviewCancellables = Set<AnyCancellable>()
    
    func postNewCafe(cafeToPost: Cafe) -> Future<Bool, Error> {
        return Future { promise in
            guard let url = URL(string: "\(requestURL)/cafes") else {
                fatalError("Invalid Url")
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
//            let cafeIdDict = ["id": cafeToPost.mapId, "name": cafeToPost.name, "roadAddress": cafeToPost.roadAddress, "phoneNumber": cafeToPost.phoneNumber]
            do {
//                let jsonData = try JSONEncoder().encode(cafeIdDict)
                let jsonData = try JSONEncoder().encode(cafeToPost)
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
                        print("카페 등록 상태코드 200")
                    case 500 :
                        print("서버 에러 500")
                        StateManager.shared.serverDown = true
                    default:
                        print("카페 등록 상태코드: \(httpResponse.statusCode)")
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
                        self.successCafePost = true
                        promise(.success(self.successCafePost ?? false))
                        break
                    }
                } receiveValue: { data in
                }
                .store(in: &self.cancellables)
        }
    }
    
    //카페 상세 조회
    func fetchCafeData(accessToken: String, mapId: String) {
        requestCafeDataFetch(accessToken: accessToken, mapId: mapId)
            .sink { completion in
                switch completion {
                case .finished:
                    print("카페 조회 비동기 종료")
                case .failure(let error):
                    print("카페 조회 비동기 error : \(error)")
                }
            } receiveValue: { data in
                self.cafeData = data
            }
            .store(in: &self.cancellables)
    }
    func requestCafeDataFetch(accessToken: String, mapId: String) -> Future<Cafe, Error> {
        return Future { promise in
            guard let url = URL(string: "\(requestURL)/cafes/\(mapId)") else {
                fatalError("카페데이터 로드 Invalid URL")
            }
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            
            URLSession.shared.dataTaskPublisher(for: request)
                .subscribe(on: DispatchQueue.global(qos: .background))
                .receive(on: DispatchQueue.main)
                .tryMap { [self] data, response -> Data in
                    guard let httpResponse = response as? HTTPURLResponse else {
                        throw URLError(.badServerResponse)
                    }
                    switch httpResponse.statusCode {
                    case 401:
                        print("카페 조회 상태코드 401")
                        TokenManager.shared.refreshAccessToken(accessInfo: AccessInfo(refreshToken: TokenManager.shared.getRefreshToken()))
                        if let token = TokenManager.shared.getToken() {
                            self.fetchCafeData(accessToken: token, mapId: mapId)
                        }
                    case 500 :
                        print("서버 에러 500")
                        StateManager.shared.serverDown = true
                    default:
                        print(" 상태코드: \(httpResponse.statusCode)")
                    }
                    return data
                }
                .decode(type: Cafe.self, decoder: JSONDecoder())
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
                    self.fetchMyCafeReview(accesToken: accessToken, mapId: mapId)
                }
                .store(in: &self.cancellables)
        }
    }
    
    //카페 즐겨찾기
    func StarCafeData(accessToken: String, mapId: String) -> Future<Bool, Error> {
        return Future { promise in
            guard let url = URL(string: "\(requestURL)/cafes/\(mapId)/favorites") else {
                fatalError("Invalid URL")
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
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
                        print("즐겨찾기 상태코드 200")
                    case 401:
                        print("즐겨찾기 상태코드 401")
                        TokenManager.shared.refreshAccessToken(accessInfo: AccessInfo(refreshToken: TokenManager.shared.getRefreshToken()))
                        if let token = TokenManager.shared.getToken() {
                            self.StarCafeData(accessToken: token, mapId: mapId)
                        }
                    case 500 :
                        print("서버 에러 500")
                        StateManager.shared.serverDown = true
                    default:
                        print("즐겨찾기 상태코드: \(httpResponse.statusCode)")
                    }
                    return data
                }
                .decode(type: Favorite.self, decoder: JSONDecoder())
                .sink { completion in
                    
                    if let isFavorite = self.cafeData.favorite {
                        promise(.success(isFavorite))
                    }
                } receiveValue: { data in
                    self.cafeData.favorite = true
                }
                .store(in: &self.cancellables)
        }
    }
    //카페 즐겨찾기 해제
    func deleteStarData(accessToken: String, mapId: String) -> Future<Bool, Error> {
        return Future { promise in
            guard let url = URL(string: "\(requestURL)/cafes/\(mapId)/favorites") else {
                fatalError("Invalid URL")
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "DELETE"
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
                        print("즐겨찾기 삭제 상태코드 200")
                    case 401:
                        print("즐겨찾기 삭제 상태코드 401")
                        TokenManager.shared.refreshAccessToken(accessInfo: AccessInfo(refreshToken: TokenManager.shared.getRefreshToken()))
                        if let token = TokenManager.shared.getToken() {
                            self.deleteStarData(accessToken: token, mapId: mapId)
                        }
                    case 500 :
                        print("서버 에러 500")
                        StateManager.shared.serverDown = true
                    default:
                        print("즐겨찾기 삭제 상태코드: \(httpResponse.statusCode)")
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
                        if let isFavorite = self.cafeData.favorite {
                            promise(.success(isFavorite))
                        }
                        break
                    }

                } receiveValue: { data in
                    self.cafeData.favorite = false
                }
                .store(in: &self.cancellables)
        }
    }
    
    //카페 리뷰 등록
    func postMyCafeReview(accesToken: String, mapId: String, reviewToPost: Review) {
        requestMyCafeReviewPost(accesToken: accesToken, mapId: mapId, reviewToPost: reviewToPost)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("카페 리뷰 등록 비동기 종료")
                case .failure(let error):
                    print("카페 리뷰 등록 비동기 error : \(error)")
                }
            }, receiveValue: { data in
                self.cafeData.score = data.score
                self.cafeData.studyType = data.studyType
                self.cafeData.wifi = data.wifi ?? nil
                self.cafeData.parking = data.parking ?? nil
                self.cafeData.toilet = data.toilet ?? nil
                self.cafeData.desk = data.desk ?? nil
                self.cafeData.sound = data.sound ?? nil
                self.cafeData.power = data.power ?? nil
                //                self.cafeData.reviewsCount = data.commentsCount
            })
            .store(in: &self.cancellables)
    }
    func requestMyCafeReviewPost(accesToken: String, mapId: String, reviewToPost: Review) -> Future<Cafe, Error> {
        return Future { promise in
            guard let url = URL(string: "\(requestURL)/cafes/\(mapId)") else {
                fatalError("Invalid Url")
            }
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("Bearer \(accesToken)", forHTTPHeaderField: "Authorization")
            do {
                let jsonData = try JSONEncoder().encode(reviewToPost)
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
                        print("카페 리뷰 등록 상태코드 200")
                    case 401:
                        print("카페 리뷰 등록 상태코드 401")
                        TokenManager.shared.refreshAccessToken(accessInfo: AccessInfo(refreshToken: TokenManager.shared.getRefreshToken()))
                        if let token = TokenManager.shared.getToken() {
                            self.postMyCafeReview(accesToken: token, mapId: mapId, reviewToPost: reviewToPost)
                        }
                    case 500 :
                        print("서버 에러 500")
                        StateManager.shared.serverDown = true
                    default:
                        print("카페 리뷰 등록 상태코드: \(httpResponse.statusCode)")
                    }
                    return data
                }
                .decode(type: Cafe.self, decoder: JSONDecoder())
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
    
    //내가 쓴 카페 리뷰 조회
    func fetchMyCafeReview(accesToken: String, mapId: String) {
        reqeustMyCafeReviewDataFetch(accesToken: accesToken, mapId: mapId)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("내가 쓴 리뷰 조회 비동기 종료")
                case .failure(let error):
                    print("내가 쓴 리뷰 조회 비동기 error : \(error)")
                }
            }, receiveValue: { data in
                self.myCafeReviewData = data
            })
            .store(in: &self.cancellables)
    }
    func reqeustMyCafeReviewDataFetch(accesToken: String, mapId: String) -> Future<Review, Error> {
        return Future { promise in
            guard let url = URL(string: "\(requestURL)/cafes/\(mapId)/me") else {
                fatalError("Invalid Url")
            }
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("Bearer \(accesToken)", forHTTPHeaderField: "Authorization")
                        
            URLSession.shared.dataTaskPublisher(for: request)
                .receive(on: DispatchQueue.main)
                .tryMap { data, response -> Data in
                    guard let httpResponse = response as? HTTPURLResponse else {
                        throw URLError(.badServerResponse)
                    }
                    switch httpResponse.statusCode {
                    case 200:
                        print("내가 쓴 카페리뷰 조회 상태코드 200")
                    case 401:
                        print("내가 쓴 카페리뷰 조회상태코드 401")
                        TokenManager.shared.refreshAccessToken(accessInfo: AccessInfo(refreshToken:  TokenManager.shared.getRefreshToken()))
                        if let token = TokenManager.shared.getToken() {
                            self.fetchMyCafeReview(accesToken: token, mapId: mapId)
                        }
                    case 500 :
                        print("서버 에러 500")
                        StateManager.shared.serverDown = true
                    default:
                        print("내가 슨 카페리뷰 조회 상태코드: \(httpResponse.statusCode)")
                    }
                    return data
                }
                .decode(type: Review.self, decoder: JSONDecoder())
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
                })
                .store(in: &self.cancellables)
        }
    }
    
    //내가 쓴 카페 리뷰 수정
    func updateMyCafeReview(accesToken: String, mapId: String, reviewToEdit: Review) {
        
        print("수정할 리뷰 : ", reviewToEdit)
        
        requesMyCafeReviewUpdate(accesToken: accesToken, mapId: mapId, reviewToEdit: reviewToEdit)
            .sink(receiveCompletion: { completion in
            }, receiveValue: { data in
                self.cafeData.score = data.score
                self.cafeData.studyType = data.studyType
                self.cafeData.wifi = data.wifi
                self.cafeData.parking = data.parking
                self.cafeData.toilet = data.toilet
                self.cafeData.desk = data.desk
                self.cafeData.sound = data.sound
                self.cafeData.power = data.power
            })
            .store(in: &self.cancellables)
    }
    func requesMyCafeReviewUpdate(accesToken: String, mapId: String, reviewToEdit: Review) -> Future<Cafe, Error> {
        return Future { promise in
            guard let url = URL(string: "\(requestURL)/cafes/\(mapId)") else {
                fatalError("Invalid Url")
            }
            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            request.addValue("Bearer \(accesToken)", forHTTPHeaderField: "Authorization")
            do {
                let jsonData = try JSONEncoder().encode(reviewToEdit)
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
                        print("카페 리뷰 수정 상태코드 200")
                    case 401:
                        print("카페 리뷰 수정 상태코드 401")
                        TokenManager.shared.refreshAccessToken(accessInfo: AccessInfo(refreshToken:  TokenManager.shared.getRefreshToken()))
                        if let token = TokenManager.shared.getToken() {
                            self.updateMyCafeReview(accesToken: token, mapId: mapId, reviewToEdit: reviewToEdit)
                        }
                    case 500 :
                        print("서버 에러 500")
                        StateManager.shared.serverDown = true
                    default:
                        print("카페 리뷰 수정 상태코드: \(httpResponse.statusCode)")
                    }
                    return data
                }
                .decode(type: Cafe.self, decoder: JSONDecoder())
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
                    promise(.success(self.cafeData))
                }
                .store(in: &self.cancellables)
        }
    }
}
