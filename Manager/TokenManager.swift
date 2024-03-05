//
//  TokenManager.swift
//  mocacong
//
//  Created by Suji Lee on 2023/06/28.
//

import Foundation
import Combine
import CryptoKit
import SwiftKeychainWrapper

class TokenManager: ObservableObject {
    
    var cancellables = Set<AnyCancellable>()
    
    static let shared = TokenManager()
    private let keychain = KeychainWrapper.standard
    private let key = SymmetricKey(size: .bits256)
    
    private init() {}
    
    func isAccessTokenPresent() -> Bool {
        if let _ = keychain.string(forKey: "access_token") {
            // 데이터가 있을 경우
            return true
        } else {
            // 데이터가 nil일 경우
            return false
        }
    }
    
    func saveToken(token: String) {
        keychain.set(token, forKey: "access_token")
    }
    
    func getToken() -> String? {
        return keychain.string(forKey: "access_token")
    }
    
    func saveRefreshToken(token: String) {
        keychain.set(token, forKey: "refresh_token")
    }
    
    func getRefreshToken() -> String? {
        return keychain.string(forKey: "refresh_token")
        
    }
    
    func logoutUser() {
        let accessRemoved = KeychainWrapper.standard.removeObject(forKey: "access_token")
        let refreshRemoved = KeychainWrapper.standard.removeObject(forKey: "refresh_token")
        if accessRemoved && refreshRemoved {
            print("All tokens removed successfully.")
        } else {
            print("Failed to remove some tokens.")
        }
        StateManager.shared.isLoggedIn = false
    }
    
    func deleteUserAccount() {
        logoutUser()
    }
    
    func refreshAccessToken(accessInfo: AccessInfo) {
        guard let url = URL(string: "\(requestURL)/login/reissue") else {
            fatalError("Invalid Url")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        do {
            let jsonData = try JSONEncoder().encode(accessInfo)
            request.httpBody = jsonData
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        } catch {
            
        }
        
        URLSession.shared.dataTaskPublisher(for: request)
            .receive(on: DispatchQueue.main)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }
                switch httpResponse.statusCode {
                case 200:
                    print("토큰 리프레시 통신 200")
                case 401:
                    StateManager.shared.tokenExpired = true
                    print("토큰 리프레시 통신 401")
                case 500 :
                    print("토큰 리프레시 서버 에러 500")
                    StateManager.shared.serverDown = true
                default:
                    print("토큰 리프레시 상태코드: \(httpResponse.statusCode)")
                }
                return data
            }
            .decode(type: AccessInfo.self, decoder: JSONDecoder())
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
                print("토큰 리프레시 반환 데이터 : ", data)
                if let userReportCount = data.userReportCount {
                    StateManager.shared.userReportCount = userReportCount
                }
                if let accessToken = data.accessToken {
                    TokenManager.shared.saveToken(token: accessToken)
                }
            }
            .store(in: &self.cancellables)
    }
}
