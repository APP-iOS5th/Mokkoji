//
//  SearchResultsViewController.swift
//  Mokkoji
//
//  Created by 박지혜 on 6/11/24.
//

import UIKit

protocol SearchResultsSelectionDelegate {
    func didSelectPlace(place: MapInfo)
}

class SearchResultsViewController: UIViewController, UISearchResultsUpdating, UITableViewDelegate, UITableViewDataSource {
    
    /// 검색 결과
    var results: [MapInfo] = []
    
    var delegate: SearchResultsSelectionDelegate?
    
    /// 테이블 뷰 설정
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        self.view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    // MARK: - UISearchResultsUpdating
    func updateSearchResults(for searchController: UISearchController) {
        /// 검색어로 검색 결과 받기
        guard let searchText = searchController.searchBar.text, !searchText.isEmpty else {
            updateResults([])
            return
        }
        
        getSearchResults(searchText: searchText)
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        results.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPlace = results[indexPath.row]
        /// 부모 뷰에 선택한 행(장소) 전달
        delegate?.didSelectPlace(place: selectedPlace)
        dismiss(animated: true)
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var config = cell.defaultContentConfiguration()
        config.text = results[indexPath.row].placeName
        // TODO: - 도로명 주소 추가하기
        cell.contentConfiguration = config
       
        return cell
    }
    
    // MARK: - Methods
    
    /// 검색 결과 업데이트
    func updateResults(_ results: [MapInfo]) {
        self.results = results
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    func getSearchResults(searchText: String) {
        /// 카카오 검색 API 연결
        guard let restApiKey = Bundle.main.restApiKey else {
            print("No REST API Key")
            return
        }
        
        let userQuery = searchText
        let encodedQuery = userQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://dapi.kakao.com/v2/local/search/keyword.json?page=1&size=15&sort=accuracy&query=\(encodedQuery)"
        guard let url = URL(string: urlString) else {
            print("Invalid Search API URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("KakaoAK \(restApiKey)", forHTTPHeaderField: "Authorization")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Search Invalid response")
                return
            }
            
            if let data = data {
                do {
                    /// JSON 데이터 파싱
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let documents = json["documents"] as? [[String: Any]] {
                        
                        var places: [MapInfo] = []
                        for (index, document) in documents.enumerated() {
                            /// MapInfo에 필요한 프로퍼티 값 가져오기
                            if let id = document["id"] as? String,
                               let placeName = document["place_name"] as? String,
                               let addressName = document["road_address_name"] as? String,
                               let xString = document["x"] as? String,
                               let yString = document["y"] as? String {
                                let place = MapInfo(placeId: id, roadAddressName: addressName, placeLatitude: yString, placeLongitude: xString, placeName: placeName)
                                places.append(place)
                            }
                        }
                        self.updateResults(places)
                    }
                } catch {
                    print("JSON parsing error: \(error.localizedDescription)")
                }
            }
        }
        
        task.resume()
    }
    
}
