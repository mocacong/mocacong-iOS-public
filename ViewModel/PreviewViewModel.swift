//
//  PreviewViewModel.swift
//  mocacong
//
//  Created by Suji Lee on 2023/07/26.
//

import Foundation
import Combine
import SwiftUI

class PreviewViewModel: ObservableObject {
    
    @Published var cafePreviewData: CafePreview = CafePreview()
    var cancellables = Set<AnyCancellable>()
    
    func fetchCafePreview(accessToken: String, mapId: String) {
        requestCafePreviewFetch(accessToken: accessToken, mapId: mapId)
            .sink(receiveCompletion: { completion in
                print("카페 미리보기 비동기 작업 completion : \(completion)")
            }, receiveValue: { previewData in
                self.cafePreviewData = previewData
            })
            .store(in: &self.cancellables)
    }
    func requestCafePreviewFetch(accessToken: String, mapId: String) -> Future<CafePreview, Error> {
        return Future { promise in
            guard let url = URL(string: "\(requestURL)/cafes/\(mapId)/preview") else {
                fatalError("카페 미리보기 Invalid URL")
            }
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                        
            URLSession.shared.dataTaskPublisher(for: request)
                .receive(on: DispatchQueue.main)
                .tryMap { data, response -> Data in
                    guard let httpResponse = response as? HTTPURLResponse else {
                        throw URLError(.badServerResponse)
                    }
                    switch httpResponse.statusCode {
                    case 200:
                        print("카페 미리보기 상태코드 200")
                    case 401:
                        print("카페 미리보기 상태코드 401")
                        TokenManager.shared.refreshAccessToken(accessInfo: AccessInfo(refreshToken: TokenManager.shared.getRefreshToken()))
                        if let token = TokenManager.shared.getToken() {
                            self.fetchCafePreview(accessToken: token, mapId: mapId)
                        }

                    case 500 :
                        print("서버 에러 500")
                        StateManager.shared.serverDown = true
                    default:
                        print("상태코드: \(httpResponse.statusCode)")
                    }
                    return data
                }
                .decode(type: CafePreview.self, decoder: JSONDecoder())
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
                } receiveValue: { previewData in
                    promise(.success(previewData))
                }
                .store(in: &self.cancellables)
        }
    }
}

