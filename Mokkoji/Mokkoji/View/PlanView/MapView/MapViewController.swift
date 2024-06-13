//
//  MapViewController.swift
//  Mokkoji
//
//  Created by 박지혜 on 6/11/24.
//

import UIKit
import KakaoMapsSDK
import CoreLocation

extension Bundle {
    var nativeAppKey: String? {
        return infoDictionary?["KAKAO_NATIVE_APP_KEY"] as? String
    }
    
    var restApiKey: String? {
        return infoDictionary?["KAKAO_REST_API_KEY"] as? String
    }
}

/// 16진수 값을 입력받기 위함
extension UIColor {
    convenience init(hex: UInt32) {
        let red = CGFloat((hex & 0xFF000000) >> 24) / 255.0
        let green = CGFloat((hex & 0x00FF0000) >> 16) / 255.0
        let blue = CGFloat((hex & 0x0000FF00) >> 8) / 255.0
        let alpha = CGFloat(hex & 0x000000FF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}

protocol SelectedPlaceListDelegate {
    func didAppendPlace(places: [MapInfo])
}

class MapViewController: UIViewController, MapControllerDelegate, CLLocationManagerDelegate, SearchResultsSelectionDelegate {

    /// 카카오 지도 불러오기
    var mapContainer: KMViewContainer?
    var mapController: KMController?
    
    var _observerAdded: Bool
    var _auth: Bool
    var _appear: Bool
    
    /// 사용자 위치 가져오기
    let locationManager = CLLocationManager()
    
    /// 핀 꼽기
    var positions: [MapPoint] = []
    
    /// 검색창 만들기
    var searchController: UISearchController!
    let searchResultsViewController = SearchResultsViewController()
    
    var delegate: SelectedPlaceListDelegate?
    var selectedPlaces: [MapInfo] = []
    
    init() {
        _observerAdded = false
        _auth = false
        _appear = false
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        mapController?.pauseEngine()
        mapController?.resetEngine()
        
        print("deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped))
        
        /// 카카오 지도 API 연결
        guard let nativeAppKey = Bundle.main.nativeAppKey else {
            print("No Native App key")
            return
        }
        SDKInitializer.InitSDK(appKey: nativeAppKey)
        
        /// KMViewContainer 생성 및 추가
        let container = KMViewContainer(frame: self.view.bounds)
        container.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(container)
        mapContainer = container
        
        /// KMController 생성 및 초기화
        if let mapContainer = mapContainer {
            mapController = KMController(viewContainer: mapContainer)
            mapController?.delegate = self
            /// 엔진 초기화 - 엔진 내부 객체 생성 및 초기화 진행
            mapController?.prepareEngine()
        } else {
            print("Failed to create mapContainer")
        }
        
        /// 사용자 위치 권한
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        /// 검색창에 입력 시 검색 결과 뷰로 이동
        searchController = UISearchController(searchResultsController: searchResultsViewController)
        searchController.searchResultsUpdater = searchResultsViewController
        
        searchResultsViewController.delegate = self
        
        searchController.searchBar.placeholder = "장소를 입력하세요."
        searchController.searchBar.tintColor = .black /// 글씨색
        searchController.searchBar.searchTextField.backgroundColor = .white /// 배경색
        searchController.searchBar.searchTextField.layer.shadowColor = UIColor.black.cgColor /// 배경 그림자
        searchController.searchBar.searchTextField.layer.shadowOffset = CGSize(width: 2, height: 2)
        searchController.searchBar.searchTextField.layer.shadowOpacity = 0.25
        searchController.searchBar.searchTextField.layer.shadowRadius = 2
        
        self.navigationItem.searchController = searchController
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        addObservers()
        _appear = true
        
        if mapController?.isEngineActive == false {
            mapController?.activateEngine()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
            
    }
        
    override func viewWillDisappear(_ animated: Bool) {
        _appear = false
        mapController?.pauseEngine() /// 렌더링 중지
    }

    override func viewDidDisappear(_ animated: Bool) {
        removeObservers()
        mapController?.resetEngine() /// 엔진 정지 - 추가되었던 ViewBase들이 삭제됨
    }

    // MARK: - MapControllerDelegate
    /// 인증 실패시 호출
    func authenticationFailed(_ errorCode: Int, desc: String) {
        print("error code: \(errorCode)")
        print("desc: \(desc)")
        _auth = false
        switch errorCode {
        case 400:
            showToast(self.view, message: "지도 종료(API인증 파라미터 오류)")
            break;
        case 401:
            showToast(self.view, message: "지도 종료(API인증 키 오류)")
            break;
        case 403:
            showToast(self.view, message: "지도 종료(API인증 권한 오류)")
            break;
        case 429:
            showToast(self.view, message: "지도 종료(API 사용쿼터 초과)")
            break;
        case 499:
            showToast(self.view, message: "지도 종료(네트워크 오류) 5초 후 재시도..")
            
            /// 인증 실패 delegate 호출 이후 5초뒤에 재인증 시도
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                print("retry auth...")
                
                self.mapController?.prepareEngine()
            }
            break;
        default:
            break;
        }
    }

    func addViews() {
        /// 여기에서 그릴 View(KakaoMap, Roadview)들을 추가
        /// 초기 화면 위치(현재 위치)를 받아 지도(KakaoMap)를 그리기 위한 viewInfo를 생성
        // TODO: - 현재 위치는 검색된 위치와 다르게 표시, 검색된 위치부터 1 표시
        if let location = locationManager.location {
            let latitude: Double? = location.coordinate.latitude
            let longitude: Double? = location.coordinate.longitude
//            MapPoint(longitude: 126.977458, latitude: 37.56664)
            let position = MapPoint(longitude: longitude!, latitude: latitude!)
            createPosition(position: position)
        } else {
            let defaultPosition = MapPoint(longitude: 127.108678, latitude: 37.402001)
            createPosition(position: defaultPosition)
        }
        
    }
    
    /// addView 성공 이벤트 delegate - 추가적으로 수행할 작업을 진행
    func addViewSucceeded(_ viewName: String, viewInfoName: String) {
        print("OK")
    }

    /// addView 실패 이벤트 delegate - 실패에 대한 오류 처리를 진행
    func addViewFailed(_ viewName: String, viewInfoName: String) {
        print("Failed")
    }

    /// Container 뷰가 리사이즈 되었을때 호출 - 변경된 크기에 맞게 ViewBase들의 크기를 조절할 필요가 있는 경우 여기에서 수행
    func containerDidResized(_ size: CGSize) {
        let mapView: KakaoMap? = mapController?.getView("mapview") as? KakaoMap
        /// 지도뷰의 크기를 리사이즈된 크기로 지정
        mapView?.viewRect = CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: size)
    }

    func viewWillDestroyed(_ view: ViewBase) {
        
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    
    // MARK: - SearchResultsSelectionDelegate
    func didSelectPlace(place: MapInfo) {
        selectedPlaces.append(place)
        /// 장소 지도 뷰 생성
        if let x = Double(place.placeLongitude),
           let y = Double(place.placeLatitude) {
            let position = MapPoint(longitude: x, latitude: y)
            createPosition(position: position)
            /// Poi 생성
            createPoiStyle()
            createPois(position: position)
        } else {
            print("Invalid coordinates")
        }

        /// Route 생성
        createRouteStyleSet()
        createRouteline()
    }
    
    // MARK: - Methods
    func addObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)

        _observerAdded = true
    }
     
    func removeObservers(){
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)

        _observerAdded = false
    }

    @objc func willResignActive(){
        /// 뷰가 inactive 상태로 전환되는 경우 렌더링 중인 경우 렌더링을 중단
        mapController?.pauseEngine()
    }

    @objc func didBecomeActive(){
        /// 뷰가 active 상태가 되면 렌더링 시작. 엔진은 미리 시작된 상태여야 함
        mapController?.activateEngine()
    }

    func showToast(_ view: UIView, message: String, duration: TimeInterval = 2.0) {
        let toastLabel = UILabel(frame: CGRect(x: view.frame.size.width/2 - 150, y: view.frame.size.height-100, width: 300, height: 35))
        toastLabel.backgroundColor = UIColor.black
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = NSTextAlignment.center;
        view.addSubview(toastLabel)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        
        UIView.animate(withDuration: 0.4,
                       delay: duration - 0.4,
                       options: UIView.AnimationOptions.curveEaseOut,
                       animations: {
                                        toastLabel.alpha = 0.0
                                    },
                       completion: { (finished) in
                                        toastLabel.removeFromSuperview()
                                    })
    }
    
    func createPosition(position: MapPoint) {
        /// 지도(KakaoMap)를 그리기 위한 viewInfo를 생성
        let mapviewInfo: MapviewInfo = MapviewInfo(viewName: "mapview", viewInfoName: "map", defaultPosition: position, defaultLevel: 15)
        mapController?.addView(mapviewInfo)
    }
    
    @objc func doneTapped() {
        delegate?.didAppendPlace(places: selectedPlaces)
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Poi Methods
    /// Poi 표시 스타일 생성
    func createPoiStyle() {
        guard let mapView = mapController?.getView("mapview") as? KakaoMap else {
            print("Failed to get map view")
            return
        }
        let manager = mapView.getLabelManager()
        /// Poi생성을 위한 LabelLayer 생성
        let layerOption = LabelLayerOptions(layerID: "PoiLayer", competitionType: .none, competitionUnit: .symbolFirst, orderType: .rank, zOrder: 0)
        let _ = manager.addLabelLayer(option: layerOption)
        
        /// ZoomLevel에 따라 스타일 구분 및 PoiBadge 설정
        let iconStyle1 = PoiIconStyle(symbol: UIImage(systemName: "figure.walk.motion"), anchorPoint: CGPoint(x: 0.0, y: 0.5))
        let iconStyle2 = PoiIconStyle(symbol: UIImage(systemName: "figure.walk"), anchorPoint: CGPoint(x: 0.0, y: 0.5))
    
        /// 5~11, 12~21 에 표출될 스타일을 지정
        let poiStyle = PoiStyle(styleID: "PerLevelStyle", styles: [
            PerLevelPoiStyle(iconStyle: iconStyle1, level: 5),
            PerLevelPoiStyle(iconStyle: iconStyle2, level: 12)
        ])
        manager.addPoiStyle(poiStyle)
    }
    
    /// Poi 개별 뱃지 추가
    func createPois(position: MapPoint) {
        positions.append(position)
        
        guard let mapView = mapController?.getView("mapview") as? KakaoMap else {
            print("Failed to get map view")
            return
        }
        let manager = mapView.getLabelManager()
        let layer = manager.getLabelLayer(layerID: "PoiLayer")
        let poiOption = PoiOptions(styleID: "PerLevelStyle")
        poiOption.rank = 0
        
        let poi = layer?.addPoi(option: poiOption, at: position)
        let poiCnt: Int = layer?.getAllPois()?.count ?? 0
        
        /// Poi 개별 Badge추가 - 아래에서 생성된 Poi는 Style에 빌트인되어있는 badge와, Poi가 개별적으로 가지고 있는 Badge를 갖게 됨
        let badge = PoiBadge(badgeID: "noti\(poiCnt)", image: UIImage(systemName: "\(poiCnt).circle.fill"), offset: CGPoint(x: 1.25, y: 0), zOrder: 0)
        poi?.addBadge(badge)
        poi?.show()
        poi?.showBadge(badgeID: "noti\(poiCnt)")
    }
    
    // MARK: - Route Methods
    /// RouteStyleSet을 생성
    /// RouteSegment마다 RouteStyleSet에 있는 다른 RouteStyle을 적용할 수 있음
    func createRouteStyleSet() {
        /// RouteLines을 표시할 Layer를 생성
        let mapView = mapController?.getView("mapview") as? KakaoMap
        let manager = mapView?.getRouteManager()
        let _ = manager?.addRouteLayer(layerID: "RouteLayer", zOrder: 0)
        /// Route Pattern 종류
        let patternImage = UIImage(named: "route_pattern_arrow.png")
        
        /// 스타일셋 지정
        let styleSet = RouteStyleSet(styleID: "routeStyleSet")
        styleSet.addPattern(RoutePattern(pattern: patternImage!, distance: 60, symbol: nil, pinStart: false, pinEnd: false))
        let color = UIColor(hex: 0x7796ffff)
        let strokeColor = UIColor(hex: 0xffffffff)
        
        let routeStyle = RouteStyle(styles: [
            PerLevelRouteStyle(width: 18, color: color, strokeWidth: 4, strokeColor: strokeColor, level: 0, patternIndex: 0)
        ])
        styleSet.addStyle(routeStyle)
        
        manager?.addRouteStyleSet(styleSet)
        }
    
    /// Routeline 생성
    func createRouteline() {
        let mapView = mapController?.getView("mapview") as! KakaoMap
        let manager = mapView.getRouteManager()
        let layer = manager.addRouteLayer(layerID: "RouteLayer", zOrder: 0)
        
        let segmentPoints = routeSegmentPoints()
        var segments: [RouteSegment] = [RouteSegment]()
        let styleIndex: UInt = 0
        for points in segmentPoints {
            /// 경로 포인트로 RouteSegment 생성 - 사용할 스타일 인덱스도 지정
            let seg = RouteSegment(points: points, styleIndex: styleIndex)
            segments.append(seg)
        }
        /// route 추가
        let options = RouteOptions(routeID: "routes"+String(layer?.getAllRoutes()?.count ?? 0), styleID: "routeStyleSet", zOrder: layer?.getAllRoutes()?.count ?? 0)
        options.segments = segments
        let route = layer?.addRoute(option : options)
        route?.show()
        
        /// 특정 경로 포인트로 카메라 이동
        let pnt = segments[0].points[0]
        mapView.moveCamera(CameraUpdate.make(target: pnt, zoomLevel: 15, mapView: mapView))
    }
    
    func routeSegmentPoints() -> [[MapPoint]] {
        /// 전체 구역
        var segments = [[MapPoint]]()
        /// 각 구역의 지점들
        var points = [MapPoint]()
        for pos in positions {
            /// WGS84 좌표값
            let converted = pos.wgsCoord
            let newPoint = MapPoint(longitude: converted.longitude, latitude: converted.latitude)
            points.append(newPoint)
        }
        segments.append(points)
        return segments
    }
    
}

