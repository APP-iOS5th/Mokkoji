//
//  PreviewMapViewController.swift
//  Mokkoji
//
//  Created by 박지혜 on 7/2/24.
//

import UIKit
import KakaoMapsSDK
import CoreLocation

class PreviewMapViewController: UIViewController, MapControllerDelegate, CLLocationManagerDelegate, SearchResultsSelectionDelegate {

    /// 카카오 지도 불러오기
    var mapContainer: KMViewContainer?
    var mapController: KMController?
    
    var _observerAdded: Bool
    var _auth: Bool
    var _appear: Bool
    
    /// 사용자 위치 가져오기
    let locationManager = CLLocationManager()
    
    /// 핀 꼽기
    var selectedPlaces: [MapInfo] = []
    
    let POI_LAYER_ID = "PoiLayer"
    let ROUTE_LAYER_ID = "RouteLayer"
    
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
        removeObservers()
        
        mapController?.pauseEngine()
        mapController?.resetEngine()
        
        print("deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        addObservers()
        _appear = true
        
        if mapController?.isEngineActive == false {
            mapController?.activateEngine()
            print("Engine activate")
        }
        
        /// 삭제된 poi 반영하여 다시 그리기
        clearPoi()
        /// 삭제된 route 반영하여 다시 그리기
        clearRoute()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("viewDidAppear")
            
    }
        
    override func viewWillDisappear(_ animated: Bool) {
        print("viewWillDisappear")
        _appear = false
        mapController?.pauseEngine() /// 렌더링 중지
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
                print("Retry auth...")
                
                self.mapController?.prepareEngine()
            }
            break;
        default:
            break;
        }
    }
    
    /// 여기에서 그릴 View(KakaoMap, Roadview)들을 추가
    func addViews() {
        print("addViews")
        
        let position: MapPoint
        let mapviewInfo: MapviewInfo
        let selectedCnt = selectedPlaces.count
        
        /// 1. 처음 맵을 만들 때(위치 허용 했을 때)
        ///     - 받아온 사용자의 위치를 기준으로 설정
        /// 2. 처음 맵을 만들 때(위치 허용 안했을 때)
        ///     - 미리 설정한 위치를 기준으로 설정
        /// 3. 이미 만든 맵을 가져올때
        ///     - 마지막 저장된 위치를 기준으로 설정
        if let location = locationManager.location, selectedCnt == 0 {
            let latitude: Double? = location.coordinate.latitude
            let longitude: Double? = location.coordinate.longitude
//            MapPoint(longitude: 126.977458, latitude: 37.56664)
            position = MapPoint(longitude: longitude!, latitude: latitude!)
        } else if selectedCnt == 0 {
            position = MapPoint(longitude: 127.108678, latitude: 37.402001)
        } else {
            position = MapPoint(
                longitude: Double(selectedPlaces[selectedCnt-1].placeLongitude) ?? 127.108678,
                latitude: Double(selectedPlaces[selectedCnt-1].placeLatitude) ?? 37.402001)
        }
        
        /// 초기 화면 위치(현재 위치)를 받아 지도(KakaoMap)를 그리기 위한 viewInfo를 생성
        mapviewInfo = MapviewInfo(viewName: "mapview", viewInfoName: "map", defaultPosition: position, defaultLevel: 15)
        mapController?.addView(mapviewInfo)
    }
    
    /// Container 뷰가 리사이즈 되었을때 호출 - 변경된 크기에 맞게 ViewBase들의 크기를 조절할 필요가 있는 경우 여기에서 수행
    func containerDidResized(_ size: CGSize) {
        print("containerDidResized")
        let mapView: KakaoMap? = mapController?.getView("mapview") as? KakaoMap
        
        /// 지도뷰의 크기를 리사이즈된 크기로 지정
        mapView?.viewRect = CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: size)
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    
    // MARK: - SearchResultsSelectionDelegate
    func didSelectPlace(place: MapInfo) {
        print("didSelectPlace")
        
        /// 선택 장소 중복 방지
        if !selectedPlaces.contains(place) {
            selectedPlaces.append(place)
        }
        
        /// Poi 생성
        createPoiStyle()
        let placeCount = selectedPlaces.count
        createPois(poiNum: placeCount, place: place)

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
        print("willResignActive")
        /// 뷰가 inactive 상태로 전환되는 경우 렌더링 중인 경우 렌더링을 중단
        mapController?.pauseEngine()
    }

    @objc func didBecomeActive(){
        print("didBecomeActive")
        /// 뷰가 active 상태가 되면 렌더링 시작. 엔진은 미리 시작된 상태여야 함
        mapController?.activateEngine()
    }
    
    /// 토스트 메세지
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
    
    func createPosition() {
        /// 지도(KakaoMap)를 그리기 위한 viewInfo를 생성
        let mapviewInfo: MapviewInfo
        /// poi 정의
        let position: MapPoint
        let placeCount = selectedPlaces.count
        
        if placeCount == 0 {
            position = MapPoint(longitude: 127.108678, latitude: 37.402001)
        } else {
            position = MapPoint(
                longitude: Double(selectedPlaces[placeCount - 1].placeLongitude) ?? 127.108678,
                latitude: Double(selectedPlaces[placeCount - 1].placeLatitude) ?? 37.402001)
        }
        mapviewInfo = MapviewInfo(viewName: "mapview", viewInfoName: "map", defaultPosition: position, defaultLevel: 15)
        mapController?.addView(mapviewInfo)
    }
    
    // MARK: - Poi Methods
    
    /// Poi 표시 스타일 생성
    func createPoiStyle() {
        guard let mapView = mapController?.getView("mapview") as? KakaoMap else {
            print("Failed to get map view")
            return
        }
        let manager = mapView.getLabelManager()
        
        /// Poi layer가 존재할때
        if let _: LabelLayer = manager.getLabelLayer(layerID: POI_LAYER_ID) {
            print("기존 Poi layer 존재-로드")
            
        } else {
            print("새로운 Poi layer 생성")
            let layerOption = LabelLayerOptions(layerID: POI_LAYER_ID, competitionType: .none, competitionUnit: .symbolFirst, orderType: .rank, zOrder: 0)
            let _ = manager.addLabelLayer(option: layerOption)
        }
        
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
    func createPois(poiNum: Int, place: MapInfo) {
        guard let mapView = mapController?.getView("mapview") as? KakaoMap else {
            print("Failed to get map view")
            return
        }
        
        let manager = mapView.getLabelManager()
        let layer = manager.getLabelLayer(layerID: POI_LAYER_ID)
        let poiOption = PoiOptions(styleID: "PerLevelStyle")
        poiOption.rank = 0
        
        /// 선택한 장소의 좌표 값으로 poi 생성 후 PoiLayer에 추가
        if let x = Double(place.placeLongitude),
           let y = Double(place.placeLatitude) {
            let position = MapPoint(longitude: x, latitude: y)
            let poi = layer?.addPoi(option: poiOption, at: position)
            
            /// Poi 개별 Badge추가 - 아래에서 생성된 Poi는 Style에 빌트인되어있는 badge와, Poi가 개별적으로 가지고 있는 Badge를 갖게 됨
            let badge = PoiBadge(badgeID: "noti\(poiNum)", image: UIImage(systemName: "\(poiNum).circle.fill"), offset: CGPoint(x: 1.25, y: 0), zOrder: 0)
            poi?.addBadge(badge)
            poi?.show()
            poi?.showBadge(badgeID: "noti\(poiNum)")
        } else {
            print("장소에 위도, 경도가 없습니다.")
        }
    }
    
    /// Poi 초기화
    func clearPoi() {
        guard let mapView = mapController?.getView("mapview") as? KakaoMap else {
            print("Failed to get map view")
            return
        }
        let manager = mapView.getLabelManager()
        let layer = manager.getLabelLayer(layerID: POI_LAYER_ID)
        
        /// Poi 모두 삭제
        layer?.clearAllItems()
        
        /// Poi 스타일 생성
        createPoiStyle()
        
        /// 현재 장소 리스트로 poi 생성
        for (i, place) in selectedPlaces.enumerated() {
            createPois(poiNum: i + 1, place: place)
        }
    }
    
    // MARK: - Route Methods
    
    /// RouteStyleSet을 생성
    /// RouteSegment마다 RouteStyleSet에 있는 다른 RouteStyle을 적용할 수 있음
    func createRouteStyleSet() {
        /// RouteLines을 표시할 Layer를 생성
        let mapView = mapController?.getView("mapview") as? KakaoMap
        let manager = mapView?.getRouteManager()
        
        /// Route layer가 존재할 때
        if let _: RouteLayer = manager?.getRouteLayer(layerID: ROUTE_LAYER_ID) {
            print("기존 Route layer 존재 / 로드")
            
        } else {
            print("새로운 Route layer 생성")
            let _ = manager?.addRouteLayer(layerID: ROUTE_LAYER_ID, zOrder: 1)
        }
        
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
        
        /// Route layer는 이전 route style set을 생성할 때 이미 생성됨
        let layer = manager.getRouteLayer(layerID: ROUTE_LAYER_ID)

        /// Point 만들기
        let segmentPoints = routeSegmentPoints()
        var segments: [RouteSegment] = [RouteSegment]()
        let styleIndex: UInt = 0
        for points in segmentPoints {
            /// 경로 포인트로 RouteSegment 생성 - 사용할 스타일 인덱스도 지정
            let seg = RouteSegment(points: points, styleIndex: styleIndex)
            segments.append(seg)
        }
        
        /// route 추가
        let options = RouteOptions(routeID: "routes" + String(layer?.getAllRoutes()?.count ?? 0), styleID: "routeStyleSet", zOrder: 1)
        options.segments = segments
        let route = layer?.addRoute(option : options)
        route?.show()
        
        /// 특정 경로 포인트로 카메라 이동
        let position: MapPoint
        if let location = locationManager.location {
            let latitude: Double? = location.coordinate.latitude
            let longitude: Double? = location.coordinate.longitude
            position = MapPoint(longitude: longitude!, latitude: latitude!)
            //            MapPoint(longitude: 126.977458, latitude: 37.56664)
        } else {
            position = MapPoint(longitude: 127.108678, latitude: 37.402001)
        }
        
        /// 마지막 선택한 장소로 카메라 이동
        let pnt: MapPoint = segments.last?.points.last ?? position
        mapView.moveCamera(CameraUpdate.make(target: pnt, zoomLevel: 15, mapView: mapView))
    }
    
    /// 구역의 지점 생성
    func routeSegmentPoints() -> [[MapPoint]] {
       
        /// 전체 구역
        var segments = [[MapPoint]]()
        
        /// 각 구역의 지점들
        var points = [MapPoint]()
        for place in selectedPlaces {
            let position = MapPoint(longitude: Double(place.placeLongitude)!, latitude: Double(place.placeLatitude)!)
            /// WGS84 좌표값
            let converted = position.wgsCoord
            let newPoint = MapPoint(longitude: converted.longitude, latitude: converted.latitude)
            points.append(newPoint)
        }
        segments.append(points)
        
        return segments
    }
    
    /// Route 초기화
    func clearRoute() {
        guard let mapView = mapController?.getView("mapview") as? KakaoMap else {
            print("Failed to get map view")
            return
        }
        let manager = mapView.getRouteManager()
        let layer = manager.getRouteLayer(layerID: ROUTE_LAYER_ID)
        layer?.clearAllRoutes()

        createRouteStyleSet()
        createRouteline()
    }
    
}

