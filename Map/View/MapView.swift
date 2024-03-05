import SwiftUI
import CoreLocation
import MapKit

enum CurrentMode {
    case solo
    case group
    case favorite
    case search
    case category
    case none
}

struct MapView: View {
    
    @State private var lastSearchWorkItem: DispatchWorkItem?
    
    @ObservedObject var memberVM: MemberViewModel
    @ObservedObject var cafeVM: CafeViewModel
    @StateObject var mapVM: MapViewModel = MapViewModel()
    @ObservedObject var myVM: MyViewModel
    @StateObject var locationManager = LocationManager()
    @State var region = MKCoordinateRegion.defaultRegion
    @State var currentMode: CurrentMode = .category
    var regionLatitude: Double {
        return region.center.latitude
    }
    var regionLongitude: Double {
        return region.center.longitude
    }
    @State private var didZoomToUserLocation = false
    @Binding var profileImageData: Data?
    @State var currentPage: Int = 1
    @State var isZoomingToKeywordPlace: Bool = false
    
    @State var openSideScreen: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                //                if let userLocation = locationManager.lastKnownLocation {
                //                }
                if let userLocation = locationManager.lastKnownLocation {
                    let latitude = userLocation.coordinate.latitude
                    let longitude = userLocation.coordinate.longitude
                    
                    Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: mapVM.displayPlaces) { place in
                        MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: Double(place.y) ?? 0, longitude: Double(place.x) ?? 0)) {
                            if !mapVM.isFilteringFavortie && !mapVM.isFilteringGroup && !mapVM.isFilteringSolo {
                                CafeAnnotation(memberVM: memberVM, cafeVM: cafeVM, mapVM: mapVM, myVM: myVM, currentMode: $currentMode ,targetPlace: place, profileImageData: $profileImageData)
                                    .id(place.id)
                            }
                        }
                    }
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            openSideScreen = false
                        }
                    }
                }
                // 검색창, 새로고침 버튼, 현위치 버튼
                VStack {
                    // 검색창
                    NavigationLink(destination: SearchView(region: $region, mapVM: mapVM, currentMode: $currentMode, isZoomingToKeywordPlace: $isZoomingToKeywordPlace)) {
                        RoundedRectangle(cornerRadius: 15)
                            .foregroundColor(.white)
                            .frame(width: screenWidth * 0.9, height: 50)
                            .shadow(radius: 2, y: 1.5)
                            .overlay(
                                HStack {
                                    Image(systemName: "magnifyingglass")
                                        .foregroundColor(.hex_7E7E7E)
                                        .font(.system(size: 20, weight: .semibold))
                                        .padding(.trailing)
                                    Text("카페 검색")
                                        .foregroundColor(.hex_7E7E7E)
                                        .font(.system(size: 17))
                                    Spacer()
                                    Button(action: {
                                        withAnimation {
                                            openSideScreen = true
                                        }
                                    }, label: {
                                        Image("Menu")
                                            .foregroundColor(.hex_4E483C)
                                            .padding(.leading)
                                    })
                                }
                                .padding(.horizontal)
                            )
                            .padding(.top, 30)
                            .padding(.bottom, 10)
                    }
                    // 새로고침 버튼
                    Button(action: {
                        isZoomingToKeywordPlace = false
                        currentMode = .category
                        if let isEnd = mapVM.categoryKakaoResponse?.meta?.isEnd {
                            if isEnd == false {
                                currentPage += 1
                            } else {
                                currentPage = 1
                            }
                        }
                        if let token = TokenManager.shared.getToken() {
                            mapVM.searchByCategory(accessToken: token, longitude: String(format: "%.6f", region.center.longitude), latitude: String(format: "%.6f", region.center.latitude), page: currentPage)
                        }
                    }, label: {
                        RoundedRectangle(cornerRadius: 50)
                            .foregroundColor(.white)
                            .frame(width: 60, height: 45)
                            .shadow(radius: 1, y: 1.5)
                            .overlay(
                                    Image(systemName: "arrow.clockwise")
                                        .font(.system(size: 25))
                                        .foregroundColor(.hex_4F4A44)
                            )
                    })
                    Spacer()
                    // 현위치 이동 버튼
                    HStack {
                        Button(action: {
                            if let location = locationManager.lastKnownLocation {
                                DispatchQueue.main.async {
                                    withAnimation {
                                        region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan.defaultSpan)
                                    }
                                }
                            }
                        }, label:  {
                            Image(systemName: "scope")
                                .font(.system(size: 20))
                                .foregroundColor(.hex_7E7E7E)
                                .frame(width: 10, height: 10)
                                .padding(14)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(radius: 2)
                        })
                        .padding()
                        .padding(.leading, 5)
                        Spacer()
                    }
                }
                if openSideScreen {
                        SideScreen(memberVM: memberVM, myVM: myVM, cafeVM: cafeVM, openSideScreen: $openSideScreen)
                }
            }
            .onAppear {
                if mapVM.displayPlaces.count == 1 {
                    if let cafeToZoom = mapVM.displayPlaces.first,
                       let latitude = Double(cafeToZoom.y),
                       let longitude = Double(cafeToZoom.x) {
                        zoomIn(to: latitude, longitude: longitude)
                    }
                }
            }
            .onAppear {
                if currentMode != .search {
                    if let token = TokenManager.shared.getToken() {
                        mapVM.searchByCategory(accessToken: token, longitude: String(format: "%.6f", region.center.longitude), latitude: String(format: "%.6f", region.center.latitude), page: currentPage)
                    }
                }
            }
            .onReceive(locationManager.$lastKnownLocation) { location in
                if let location = location, !didZoomToUserLocation {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.zoomIn(to: location.coordinate.latitude, longitude: location.coordinate.longitude)
                        if let token = TokenManager.shared.getToken() {
                            mapVM.searchByCategory(accessToken: token, longitude: String(format: "%.6f", location.coordinate.longitude), latitude: String(format: "%.6f", location.coordinate.latitude), page: currentPage)
                        }
                        didZoomToUserLocation = true
                    }
                }
            }
        }
    }
    
    func zoomIn(to latitude: Double, longitude: Double) {
        DispatchQueue.main.async {
            withAnimation {
                region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), span: MKCoordinateSpan.defaultSpan)
            }
        }
    }
}

struct MapView_Preview: PreviewProvider {
    static var previews: some View {
        MapView(memberVM: MemberViewModel(), cafeVM: CafeViewModel(), myVM: MyViewModel(), profileImageData: .constant(Data()))
    }
}

extension MKCoordinateRegion {
    static var defaultRegion: MKCoordinateRegion {
        MKCoordinateRegion(center: CLLocationCoordinate2D(), span: MKCoordinateSpan.defaultSpan)
    }
}

extension MKCoordinateSpan {
    static var defaultSpan: MKCoordinateSpan {
        MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
    }
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var lastKnownLocation: CLLocation?
    
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastKnownLocation = locations.last
    }
}
