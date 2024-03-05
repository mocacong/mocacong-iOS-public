//
//  MemberViewModel.swift
//  mocacong
//
//  Created by Suji Lee on 2023/04/03.
//

import Foundation
import Combine

class CommentViewModel: ObservableObject {
    
    @Published var cafeCommentsData: CafeComments = CafeComments()
    @Published var disPlayCommentArray: [Comment] = []
    @Published var commentData: Comment = Comment()
    @Published var currentPage: Int = 0
    
    @Published var completeCommentDelete: Bool = false
    @Published var completeCommentUpdate: Bool = false
    @Published var isFetchingCafeComments: Bool = false
    
    var cancellables = Set<AnyCancellable>()
    
    func loadMoreComments(accessToken: String, cafeVM: CafeViewModel) {
        self.currentPage += 1
        self.fetchCommentData(accessToken: accessToken, mapId: cafeVM.cafeMapId, page: self.currentPage)
    }
    //코멘트 작성
    func postComment(accessToken: String, mapId: String, commentToPost: Comment) {
        let future = requestCommentPost(accessToken: accessToken, mapId: mapId, commentToPost: commentToPost)
        
        future
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("코멘트 작성 비동기 성공")
                    
                case .failure(let error):
                    print("코멘트 작성 비동기 에러 : \(error)")
                }
            }, receiveValue: { commentData in
                self.commentData.id = commentData.id
            })
            .store(in: &self.cancellables)
    }
    func requestCommentPost(accessToken: String, mapId: String, commentToPost: Comment) -> Future<Comment, Error> {
        return Future { promise in
            guard let url = URL(string: "\(requestURL)/cafes/\(mapId)/comments") else {
                fatalError("Invalid URL")
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            do {
                let jsonData = try JSONEncoder().encode(commentToPost)
                request.httpBody = jsonData
                request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            } catch {
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
                        print("댓글 등록 상태코드 200")
                    case 401:
                        print("댓글 등록 상태코드 401")
                        TokenManager.shared.refreshAccessToken(accessInfo: AccessInfo(refreshToken: TokenManager.shared.getRefreshToken()))
                        if let token = TokenManager.shared.getToken() {
                            self.postComment(accessToken: token, mapId: mapId, commentToPost: commentToPost)
                        }
                    case 500 :
                        print("서버 에러 500")
                        StateManager.shared.serverDown = true
                    default:
                        print("댓글 등록 상태코드: \(httpResponse.statusCode)")
                    }
                    return data
                }
                .decode(type: Comment.self, decoder: JSONDecoder())
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
                } receiveValue: { commentData in
                    promise(.success(commentData))
//                    self.currentPage = 0
                    self.disPlayCommentArray.removeAll()
                    self.fetchCommentData(accessToken: accessToken, mapId: mapId, page: 0)
                }
                .store(in: &self.cancellables)
        }
    }
    
    //카페에 작성된 코멘트 조회 비동기 작업 처리 함수
    func fetchCommentData(accessToken: String, mapId: String, page: Int) {
        isFetchingCafeComments = true
        currentPage = page
        let request = requestCommentDataFetch(accessToken: accessToken, mapId: mapId, page: page)
        
        request
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("코멘트 조회 비동기 성공")
                case .failure(let error):
                    print("코멘트 조회 비동기 error : \(error)")
                }
                self.isFetchingCafeComments = false
            }, receiveValue: { data in
                self.cafeCommentsData = data
                if let comments = self.cafeCommentsData.comments {
                    for comment in comments {
                        /*                        if !self.disPlayCommentArray.contains(where: { $0.content == comment.content }) {  */                          self.disPlayCommentArray.append(comment)
                        //                        }
                    }
                }
            })
            .store(in: &self.cancellables)
    }
    //카페에 작성된 코멘트 조회 요청 생성 함수
    func requestCommentDataFetch(accessToken: String, mapId: String, page: Int) -> Future<CafeComments, Error> {
        return Future { promise in
            guard let url = URL(string: "\(requestURL)/cafes/\(mapId)/comments?page=\(page)&count=20") else {
                fatalError("코멘트 데이터 로드 Invalid URL")
            }
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            
            print("request: ", request)
            
            URLSession.shared.dataTaskPublisher(for: request)
                .subscribe(on: DispatchQueue.global(qos: .background))
                .receive(on: DispatchQueue.main)
                .tryMap { data, response -> Data in
                    guard let httpResponse = response as? HTTPURLResponse else {
                        throw URLError(.badServerResponse)
                    }
                    switch httpResponse.statusCode {
                    case 200:
                        print("댓글 조회 상태코드 200")
                    case 401:
                        print("댓글 조회 상태코드 401")
                        TokenManager.shared.refreshAccessToken(accessInfo: AccessInfo(refreshToken:  TokenManager.shared.getRefreshToken()))
                        if let token = TokenManager.shared.getToken() {
                            self.fetchCommentData(accessToken: token, mapId: mapId, page: page)
                        }
                    case 500 :
                        print("댓글 조회 서버 에러 500")
                        StateManager.shared.serverDown = true
                    default:
                        print(" 상태코드: \(httpResponse.statusCode)")
                    }
                    return data
                }
                .decode(type: CafeComments.self, decoder: JSONDecoder())
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
                }, receiveValue: { commentData in
                    promise(.success(commentData))
                })
                .store(in: &self.cancellables)
        }
    }
    
    //코멘트 수정
    func updateComment(accessToken: String, mapId: String, commentToEdit: Comment) {
        let future = requestCommentUpdate(accessToken: accessToken, mapId: mapId, commentToEdit: commentToEdit)
        
        future
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("코멘트 수정 비동기 성공")
                case .failure(let error):
                    print("코멘트 수정 비동기 error : \(error)")
                }
            }, receiveValue: { commentData in
                self.completeCommentUpdate = true
                self.currentPage = 0
                self.disPlayCommentArray.removeAll()
                self.fetchCommentData(accessToken: accessToken, mapId: mapId, page: 0)
            })
            .store(in: &self.cancellables)
    }
    func requestCommentUpdate(accessToken: String, mapId: String, commentToEdit: Comment) -> Future<Bool, Error> {
        return Future  { promise in
            guard let commentId = commentToEdit.id, let url = URL(string: "\(requestURL)/cafes/\(mapId)/comments/\(commentId)") else {
                fatalError("Invalid URL")
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            do {
                let jsonData = try JSONEncoder().encode(commentToEdit)
                request.httpBody = jsonData
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            } catch {
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
                        print("댓글 수정 상태코드 200")
                    case 401:
                        print("댓글 수정 상태코드 401")
                        TokenManager.shared.refreshAccessToken(accessInfo: AccessInfo(refreshToken: TokenManager.shared.getRefreshToken()))
                        if let token = TokenManager.shared.getToken() {
                            self.updateComment(accessToken: token, mapId: mapId, commentToEdit: commentToEdit)
                        }
                    case 500 :
                        print("서버 에러 500")
                        StateManager.shared.serverDown = true
                    default:
                        print("댓글 수정 상태코드: \(httpResponse.statusCode)")
                    }
                    return data
                }
                .sink { completion in
                    print("코멘트 수정 요청 Completion: \(completion)")
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        print("코멘트 수정 요청 error : \(error)")
                    }
                } receiveValue: { data in
                    promise(.success(self.completeCommentUpdate))
                }
            
                .store(in: &self.cancellables)
        }
    }
    
    //코멘트 삭제
    func deleteComment(accessToken: String, mapId: String, commentToEdit: Comment) {
        let future = requestCommentDelete(accessToken: accessToken, mapId: mapId, commentToEdit: commentToEdit)
        
        future
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("코멘트 삭제 비동기 종료")
                case .failure(let error):
                    print("코멘트 삭제 비동기 error : \(error)")
                }
            }, receiveValue: { _ in
                self.completeCommentDelete = true
                self.currentPage = 0
                self.disPlayCommentArray.removeAll()
                self.fetchCommentData(accessToken: accessToken, mapId: mapId, page: 0)
            })
            .store(in: &self.cancellables)
    }
    func requestCommentDelete(accessToken: String, mapId: String, commentToEdit: Comment) -> Future<Bool, Error> {
        return Future  { promise in
            guard let commentId = commentToEdit.id, let url = URL(string: "\(requestURL)/cafes/\(mapId)/comments/\(commentId)") else {
                fatalError("Invalid URL")
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "DELETE"
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                DispatchQueue.main.async {
                    if let error = error {
                        promise(.failure(error))
                        print("코멘트 삭제 요청 error : \(error)")
                    } else if let httpResponse = response as? HTTPURLResponse {
                        if httpResponse.statusCode == 200 {
                            promise(.success(true))
                            print("코멘트 삭제 응답 상태코드 : ", httpResponse.statusCode)
                        } else if httpResponse.statusCode == 401 {
                            TokenManager.shared.refreshAccessToken(accessInfo: AccessInfo(refreshToken: TokenManager.shared.getRefreshToken()))
                            if let token = TokenManager.shared.getToken() {
                                self.deleteComment(accessToken: token, mapId: mapId, commentToEdit: commentToEdit)
                            }
                        } else if httpResponse.statusCode == 500 {
                            StateManager.shared.serverDown = true
                        } else {
                            promise(.failure(URLError(URLError.Code.badServerResponse)))
                            print("코멘트 삭제 응답 상태코드 : ", httpResponse.statusCode)
                        }
                    }
                }
            }.resume()
        }
    }
    
    func cancelAllRequests() {
        for cancellable in cancellables {
            cancellable.cancel()
        }
        cancellables.removeAll()
    }
}
