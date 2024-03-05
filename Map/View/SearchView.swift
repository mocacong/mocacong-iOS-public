//
//  SearchView.swift
//  mocacong
//
//  Created by Suji Lee on 2023/05/12.
//

import SwiftUI
import MapKit

struct SearchView: View {
    
    enum FocusTextField: Hashable {
       case textField
     }
    @FocusState private var focusTextField: FocusTextField?
    
    @Environment(\.presentationMode) var presentationMode
    @Binding var region: MKCoordinateRegion
    @ObservedObject var mapVM: MapViewModel
    @Binding var currentMode: CurrentMode
    @State var query: String = ""
    @State var currentPage: Int = 1
    @State var resultArray: [CafePlace] = []
    @Binding var isZoomingToKeywordPlace: Bool
    
    var body: some View {
            VStack {
                VStack {
                    //검색창
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.hex_7E7E7E)
                            .padding(.trailing)
                        TextField("카페명, 지점명으로 검색", text: $query)
                            .font(.system(size: 18))
                            .focused($focusTextField, equals: .textField)
                            .onChange(of: query, perform: { newValue in
                                searchByKeyword(query: newValue, page: 1)
                                print(newValue)
                            })
                        Spacer()
                        Button(action: {
                            query = ""
                        }, label: {
                            Image(systemName: "x.circle.fill")
                                .font(.system(size: 15))
                        })
                    }
                    .foregroundColor(.hex_BABABA)
                    .font(.system(size: 20))
                    //구분선
                    Rectangle()
                        .frame(width: screenWidth, height: 1)
                        .foregroundColor(.hex_BABABA)
                }
                .padding(13)
                .padding(.top, 15)
                //검색 결과 리스트
                List {
                    ForEach(resultArray.filter { "\($0)".contains(self.query) || self.query.isEmpty }) { place in
                        VStack(alignment: .leading, spacing: 35) {
                            //카드 하나
                            HStack(spacing: 13) {
                                Rectangle()
                                    .frame(width: 2.45, height: 64)
                                VStack(alignment: .leading, spacing: 3) {
                                    if place.placeName == "스테인드커피로스터스" {
                                        Text("\(place.placeName) (카페온더플랜)")
                                            .font(.system(size: 15.5, weight: .medium))
                                    } else {
                                        Text(place.placeName)
                                            .font(.system(size: 15.5, weight: .medium))
                                    }
                                    Text(place.roadAddressName)
                                        .font(.system(size: 13.5))
                                        .foregroundColor(.hex_A49E99)
                                }
                            }
                            .padding(.vertical, 8)
                            .foregroundColor(.hex_4E483C)
                        }
                        .onTapGesture {
                            isZoomingToKeywordPlace = true
                            mapVM.displayPlaces.removeAll()
                            mapVM.displayPlaces.append(place)
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                    if let isEnd = mapVM.keywordKakaoResponse?.meta?.isEnd, isEnd == false && !resultArray.isEmpty {
                        Button(action: {
                            loadMoreResults()
                        }, label: {
                            RoundedRectangle(cornerRadius: 5)
                                .frame(width: screenWidth * 0.95, height: 55)
                                .foregroundColor(.clear)
                                .overlay (
                                    Text("검색 결과 더보기")
                                        .font(.system(size: 15.5, weight: .medium))
                                    
                                )
                        })
                    }
                }
                .listStyle(PlainListStyle())
            }
        .onAppear {
            currentMode = .search
            self.focusTextField = .textField
        }
    }
    
    func loadMoreResults() {
        if let isEnd = mapVM.keywordKakaoResponse?.meta?.isEnd, isEnd == false {
            if let token = TokenManager.shared.getToken() {
                mapVM.requestKeywordDataToKakao(accessToken: token, query: query, longitude: String(format: "%.6f", region.center.longitude), latitude: String(format: "%.6f", region.center.latitude), page: currentPage)
                    .sink(receiveCompletion: { completion in
                        switch completion {
                        case .failure(let error):
                            print("키워드 검색 비동기 error : \(error)")
                        case .finished:
                            print("키워드 검색 비동기 성공")
                            break
                        }
                    }, receiveValue: { data in
                        let keywokdArray = data.map { cafe in
                            CafePlace(id: cafe.id, addressName: cafe.addressName, phone: cafe.phone, placeName: cafe.placeName, roadAddressName: cafe.roadAddressName, x: cafe.x, y: cafe.y)
                        }
                        resultArray.append(contentsOf: keywokdArray)
                    })
                    .store(in: &mapVM.cancellables)
                currentPage += 1
            }
        }
    }
    
    func searchByKeyword(query: String, page: Int) {
        mapVM.isSearcing = true
        if let token = TokenManager.shared.getToken() {
            mapVM.requestKeywordDataToKakao(accessToken: token, query: query, longitude: String(format: "%.6f", region.center.latitude), latitude: String(format: "%.6f", region.center.longitude), page: page)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        print("키워드 검색 비동기 error : \(error)")
                    case .finished:
                        print("키워드 검색 비동기 성공")
                        break
                    }
                }, receiveValue: { keywords in
                    DispatchQueue.main.async {
                        resultArray.removeAll()
                        self.resultArray = keywords.map { cafe in
                            CafePlace(id: cafe.id, addressName: cafe.addressName, phone: cafe.phone, placeName: cafe.placeName, roadAddressName: cafe.roadAddressName, x: cafe.x, y: cafe.y)
                        }
                    }
                })
                .store(in: &mapVM.cancellables)
        }
    }
}
