//
//  MapViewModel.swift
//  mocacong
//
//  Created by Suji Lee on 2023/05/10.
//

import Foundation
import Combine
import MapKit

let baseURL = Bundle.main.object(forInfoDictionaryKey: "KAKAO_BASE_URL") as? String ?? ""
let apiKey = Bundle.main.object(forInfoDictionaryKey: "KAKAO_API_KEY") as? String ?? ""

class MapViewModel: NSObject, ObservableObject {
    
    @Published var categoryKakaoResponse: KakaoResponse?
    @Published var keywordKakaoResponse: KakaoResponse?
    @Published var categoryPlaces: [Place] = []
    @Published var keywordPlaces: [Place] = []
    
    @Published var mapFilter: Filter = Filter()
    
    @Published var displayPlaces: [CafePlace] = []
    
    @Published var isSearcing: Bool = false
    @Published var isFilteringSolo: Bool = false
    @Published var isFilteringGroup: Bool = false
    @Published var isFilteringFavortie: Bool = false
    
    var extractedMapIds: [String] = []
    @Published var soloTypeCafesMapIds: [String] = []
    @Published var groupTypeCafesMapIds: [String] = []
    @Published var favoriteCafesMapIds: [String] = []
    
    var cancellables = Set<AnyCancellable>()
    
    //좌표는 소수점 6번째까지만
    func searchByCategory(accessToken: String, longitude: String, latitude: String, page: Int) {
        self.isFilteringFavortie = false
        self.isFilteringGroup = false
        self.isFilteringSolo = false
        self.requestCategoryDataToKakao(longitude: longitude, latitude: latitude, page: page)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("카테고리 비동기 조회 error : \(error)")
                case .finished:
                    print("카테고리 비동기 성공")
                }
            }, receiveValue: { data in
                self.displayPlaces = self.categoryPlaces.map { cafe in
                    CafePlace(id: cafe.id, addressName: cafe.addressName, phone: cafe.phone, placeName: cafe.placeName, roadAddressName: cafe.roadAddressName, x: cafe.x, y: cafe.y)
                }
                self.fetchCafeByStudyType(accessToken: accessToken, studyType: "solo")
                self.fetchCafeByStudyType(accessToken: accessToken, studyType: "group")
                self.fetchCafeByIsFavorite(accessToken: accessToken)
                self.displayPlaces.append(CafePlace(id: "388741564", addressName: "서울 광진구 화양동 90-3", phone: "02-462-1020", placeName: "카페온더플랜", roadAddressName:  "서울 광진구 능동로 161", x: "127.072849878508", y: "37.5451806205162"))
            })
            .store(in: &self.cancellables)
    }
    
    func requestCategoryDataToKakao(longitude: String, latitude: String, page: Int) -> Future<KakaoResponse, Error> {
        return Future { promise in
            guard let url = URL(string: "\(baseURL)/category.json?category_group_code=CE7&page=\(page)&sort=accuracy&size=15&radius=700&x=\(longitude)&y=\(latitude)") else {
                fatalError("Invalid URL")
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("KakaoAK \(apiKey)", forHTTPHeaderField: "Authorization")
            
            URLSession.shared.dataTaskPublisher(for: request)
                .map { $0.data }
                .decode(type: KakaoResponse.self, decoder: JSONDecoder())
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        print("Failed to search places: \(error)")
                    case .finished:
                        promise(.success(self.categoryKakaoResponse ?? KakaoResponse()))
                        print("search success")
                        break
                    }
                }, receiveValue: { data in
                    self.categoryKakaoResponse = data
                    self.categoryPlaces = data.documents?.filter { place in
                        // "가정,생활 > 여가시설"을 포함하는 경우를 제외
                        let isGeneralLeisure = place.category_name.contains("가정,생활 > 여가시설")
                        
                        // "음식점 > 카페 > 테마카페"와 정확히 일치하는 경우를 제외
                        let isExactThemeCafe = place.category_name == "음식점 > 카페 > 테마카페"
                        
                        // 위 조건에 해당하지 않는 place만 포함
                        return !(isGeneralLeisure || isExactThemeCafe)
                    } ?? []
                    self.mapFilter.mapIds = self.categoryPlaces.map { $0.id }
                })
                .store(in: &self.cancellables)
        }
    }
    
    func requestKeywordDataToKakao(accessToken: String, query: String, longitude: String, latitude: String, page: Int) -> Future<[Place], Error> {
        return Future { promise in
            var query = query
            let targetUrl = "\(baseURL)/keyword.json?page=\(page)&size=15&sort=distance&query=\(query)&category_group_code=CE7&x=\(latitude)&y=\(longitude)&radius=20000"
            let encodedUrl = targetUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            
            guard let url = URL(string: encodedUrl) else {
                fatalError("Invalid URL")
            }
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("KakaoAK \(apiKey)", forHTTPHeaderField: "Authorization")
            
            URLSession.shared.dataTaskPublisher(for: request)
                .map { $0.data }
                .decode(type: KakaoResponse.self, decoder: JSONDecoder())
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        print("Failed to search places: \(error)")
                    case .finished:
                        promise(.success(self.keywordPlaces))
                        print("search success")
                        break
                    }
                }, receiveValue: { data in
                    self.keywordKakaoResponse = data
                    self.keywordPlaces = data.documents ?? []
                    self.fetchCafeByStudyType(accessToken: accessToken, studyType: "solo")
                    self.fetchCafeByStudyType(accessToken: accessToken, studyType: "group")
                    self.fetchCafeByIsFavorite(accessToken: accessToken)
                })
                .store(in: &self.cancellables)
        }
    }
    
    func fetchCafeByStudyType(accessToken: String, studyType: String) {
        if studyType ==
            "group" {
            self.isFilteringGroup = true
        } else {
            self.isFilteringSolo = true
        }
        let future = requestCafeByStudyTypeFetch(accessToken: accessToken, studyType: studyType)
        
        future
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("스터디 타입 필터링 비동기 종료")
                    if studyType == "group" {
                        self.isFilteringGroup = false
                    } else {
                        self.isFilteringSolo = false
                    }
                case .failure(let error):
                    print("스터디 타입 필터링 에러 : \(error)")
                }
            }, receiveValue: { data in
                if studyType == "solo" {
                    self.soloTypeCafesMapIds = data.mapIds ?? []
                    self.displayPlaces = self.displayPlaces.map { place in
                        if self.soloTypeCafesMapIds.contains(place.id) {
                            var newPlace = place
                            newPlace.solo = true
                            return newPlace
                        } else {
                            return place
                        }
                    }
                } else {
                    self.groupTypeCafesMapIds = data.mapIds ?? []
                    self.displayPlaces = self.displayPlaces.map { place in
                        if self.groupTypeCafesMapIds.contains(place.id) {
                            var newPlace = place
                            newPlace.group = true
                            return newPlace
                        } else {
                            return place
                        }
                    }
                }
            })
            .store(in: &self.cancellables)
    }
    func requestCafeByStudyTypeFetch(accessToken: String, studyType: String) -> Future<Filter, Error> {
        return Future { promise in
            guard let url = URL(string: "\(requestURL)/cafes/studytypes?studytype=\(studyType)") else {
                fatalError("Invalid URL")
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            do {
                let jsonData = try JSONEncoder().encode(self.mapFilter)
                request.httpBody = jsonData
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            } catch {
                promise(.failure(error))
            }
            
            URLSession.shared.dataTaskPublisher(for: request)
                .subscribe(on: DispatchQueue.global(qos: .background))
                .receive(on: DispatchQueue.main)
                .tryMap { data, response -> Data in
                    guard let httpResponse = response as? HTTPURLResponse else {
                        throw URLError(.badServerResponse)
                    }
                    switch httpResponse.statusCode {
                    case 200:
                        print("스터디타입 필터링 상태코드 200")
                    case 401:
                        print("스터디타입 필터링 상태코드 401")
                        TokenManager.shared.refreshAccessToken(accessInfo: AccessInfo(refreshToken: TokenManager.shared.getRefreshToken()))
                        if let token = TokenManager.shared.getToken() {
                            self.fetchCafeByStudyType(accessToken: token, studyType: studyType)
                        }
                    case 500 :
                        print("서버 에러 500")
                        StateManager.shared.serverDown = true
                    default:
                        print("스터디타입 필터링 상태코드: \(httpResponse.statusCode)")
                    }
                    return data
                }
                .decode(type: Filter.self, decoder: JSONDecoder())
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
                } receiveValue: { response in
                    promise(.success(response))
                }
                .store(in: &self.cancellables)
        }
    }
    
    func fetchCafeByIsFavorite(accessToken: String) {
        let future = requestCafeByIsFavoriteFetch(accessToken: accessToken)
        self.isFilteringFavortie = true
        future
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("즐겨찾기 필터링 비동기 종료")
                    self.isFilteringFavortie = false
                case .failure(let error):
                    print("즐겨찾기 필터링 에러 : \(error)")
                }
            }, receiveValue: { data in
                self.favoriteCafesMapIds = data.mapIds ?? []
                self.displayPlaces = self.displayPlaces.map { place in
                    if self.favoriteCafesMapIds.contains(place.id) {
                        var newPlace = place
                        newPlace.favorite = true
                        return newPlace
                    } else {
                        return place
                    }
                }
            })
            .store(in: &self.cancellables)
    }
    func requestCafeByIsFavoriteFetch(accessToken: String) -> Future<Filter, Error> {
        return Future { promise in
            guard let url = URL(string: "\(requestURL)/cafes/favorites") else {
                fatalError("Invalid URL")
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            do {
                let jsonData = try JSONEncoder().encode(self.mapFilter)
                request.httpBody = jsonData
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            } catch {
                promise(.failure(error))
            }
            
            URLSession.shared.dataTaskPublisher(for: request)
                .subscribe(on: DispatchQueue.global(qos: .background))
                .receive(on: DispatchQueue.main)
                .tryMap { data, response -> Data in
                    guard let httpResponse = response as? HTTPURLResponse else {
                        throw URLError(.badServerResponse)
                    }
                    switch httpResponse.statusCode {
                    case 200:
                        print("즐겨찾기 필터링 상태코드 200")
                    case 401:
                        print("즐겨찾기 필터링 상태코드 401")
                        TokenManager.shared.refreshAccessToken(accessInfo: AccessInfo(refreshToken: TokenManager.shared.getRefreshToken()))
                        if let token = TokenManager.shared.getToken() {
                            self.fetchCafeByIsFavorite(accessToken: token)
                        }
                    case 500 :
                        print("서버 에러 500")
                        StateManager.shared.serverDown = true
                    default:
                        print("즐겨찾기 필터링 상태코드: \(httpResponse.statusCode)")
                    }
                    return data
                }
                .decode(type: Filter.self, decoder: JSONDecoder())
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
                } receiveValue: { mapIdsData in
                    promise(.success(mapIdsData))
                }
                .store(in: &self.cancellables)
        }
    }
}
