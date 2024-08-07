import UIKit
import FirebaseFirestore
import Firebase
import KakaoMapsSDK
import CoreLocation

class PlanDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let tableView = UITableView()
    var plans: [Plan] = []
    var selectedPlan: Plan?
    var user: User! // 사용자 정보를 저장할 프로퍼티
    let db = Firestore.firestore()
    var isSelectArray = [Bool]()
    var mapInfo: MapInfo?
    let contentView = UIView()
    var mapViewController = PreviewMapViewController(selectedPlaces: [])

    lazy var mainContainer: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // 네비게이션 바 설정
        self.title = "상세 약속"
        if let navigationBar = self.navigationController?.navigationBar {
            navigationBar.isTranslucent = false
            navigationBar.barTintColor = .white // 네비게이션 바 배경색 설정
            navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black] // 텍스트 색상 설정
        }

        // 기본 뷰 배경색 설정
        view.backgroundColor = .white
        mapViewController = PreviewMapViewController(selectedPlaces: generateMapInfoFromPlans())

        // 테이블 뷰 설정
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(PlanDetailViewCell.self, forCellReuseIdentifier: "PmDetailViewCell")
        tableView.backgroundColor = .white // 테이블 뷰 배경색 설정
        tableView.allowsMultipleSelection = true // 테이블 여러 개 선택되지 않게 설정

        // Add child view controller
        addChild(mapViewController)
        mapViewController.didMove(toParent: self)

        // ScrollView와 contentView 설정
        view.addSubview(mainContainer)
        mainContainer.addSubview(contentView)
        contentView.addSubview(tableView)
        contentView.addSubview(mapViewController.view)

        // Set up constraints for the scroll view
        mainContainer.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            mainContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mainContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            mainContainer.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            mainContainer.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),

            contentView.topAnchor.constraint(equalTo: mainContainer.contentLayoutGuide.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: mainContainer.contentLayoutGuide.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: mainContainer.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: mainContainer.contentLayoutGuide.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: mainContainer.widthAnchor),
        ])

        // 테이블 뷰와 맵 뷰 제약 조건 설정
        tableView.translatesAutoresizingMaskIntoConstraints = false
        mapViewController.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: contentView.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            tableView.heightAnchor.constraint(equalToConstant: 380),

            mapViewController.view.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 8),
            mapViewController.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            mapViewController.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            mapViewController.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            mapViewController.view.heightAnchor.constraint(equalToConstant: 500),
        ])
        
    }
    
    func generateMapInfoFromPlans() -> [MapInfo] {
        var mapInfos: [MapInfo] = []
        for plan in plans {
            mapInfos.append(contentsOf: plan.mapInfo)
        }
        return mapInfos
    }

    // Firestore에서 사용자의 Plan 정보를 가져오는 메서드
    func fetchPlanFromFirestore(userEmail: String, completion: @escaping (User?) -> Void) {
        let planRef = db.collection("users").document(userEmail)
        planRef.getDocument { (document, error) in
            if let document = document, document.exists {
                do {
                    let user = try document.data(as: User.self)
                    completion(user)
                } catch let error {
                    print("Plan Decoding Error: \(error)")
                    completion(nil)
                }
            } else {
                print("Firestore에 Plan이 존재하지 않음.")
                completion(nil)
            }
        }
    }

    // isSelectArray 초기화
    func initializeSelectArray() {
        if let plans = user.plan {
            isSelectArray = [Bool](repeating: false, count: plans.count)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let navigationBar = self.navigationController?.navigationBar {
            navigationBar.overrideUserInterfaceStyle = .light
        }
        
        guard let user = UserInfo.shared.user else { return }
        
        fetchPlanFromFirestore(userEmail: user.email) { user in
            if let user = user {
                UserInfo.shared.user = user
                print("PlanDetailVC FetchData")
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 전체 plans 배열에서 모든 detailTextInfo의 수를 합산하여 반환
        return plans.reduce(0) { $0 + $1.detailTextInfo.count }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PmDetailViewCell", for: indexPath) as! PlanDetailViewCell

        // plans 배열을 순회하며 detailTextInfo 배열의 항목을 가져오기 위해 인덱스 계산
        var cumulativeCount = 0
        for plan in plans {
            if indexPath.row < cumulativeCount + plan.detailTextInfo.count {
                let detailTextInfoIndex = indexPath.row - cumulativeCount
                let detailText = plan.detailTextInfo[detailTextInfoIndex]

                cell.titleLabel.text = plan.title
                cell.bodyLabel.text = plan.body
                cell.detailTextInfoLabel.text = detailText

                // 해당 place의 시간 가져오기
                let mapTimeInfo = plan.mapTimeInfo[detailTextInfoIndex]
                let timeFormatter = DateFormatter()
                timeFormatter.dateFormat = "HH:mm"
                let formattedDate = timeFormatter.string(from: mapTimeInfo!)
                cell.timeLabel.text = formattedDate

                cell.clockImage.image = UIImage(systemName: "clock.fill")

                let mapInfoIndex = detailTextInfoIndex
                if mapInfoIndex < plan.mapInfo.count {
                    let placeName = plan.mapInfo[mapInfoIndex].placeName
                    cell.placeNameLabel.text = placeName
                } else {
                    cell.placeNameLabel.text = ""
                }

                break
            }
            cumulativeCount += plan.detailTextInfo.count
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 선택된 셀의 데이터를 처리할 수 있습니다.
        if indexPath.row < plans.count {
            selectedPlan = plans[indexPath.row]

            // InformationViewController 생성
            let informationViewController = InformationViewController()

            // 선택한 Plan을 InformationViewController에 전달
            informationViewController.selectedPlan = selectedPlan

            // InformationViewController로 이동
            navigationController?.pushViewController(informationViewController, animated: true)
        }

        // 선택한 셀의 선택을 해제합니다. (원하는 경우 선택을 유지하려면 이 부분을 제거하세요)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
