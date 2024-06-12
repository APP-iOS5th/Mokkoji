//
//  PmListViewController.swift
//  Mokkoji
//
//  Created by 차지용 on 6/10/24.
//

import UIKit


class PmListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let tableView = UITableView()
    var isEditMode = false // Edit 모드 여부를 추적
    var isSelectArray = [Bool]()
    
    var plans: [Plan] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        
        self.navigationItem.title = "약속 리스트"
        
        // 왼쪽에 Add 버튼 추가
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        self.navigationItem.leftBarButtonItem = addButton

        // 오른쪽에 Edit 버튼 추가
        let editButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonTapped))
        self.navigationItem.rightBarButtonItem = editButton

        // 테이블 뷰 설정
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.frame = view.bounds
        view.addSubview(tableView)

        // 임시 데이터
        plans = [
            Plan(uuid: UUID(), order: 1, title: "시간순삭", body: "만교역", date: Date(), time: Date(), mapInfo: [], currentLatitude: nil, currentLongitude: nil, participant: nil),
            Plan(uuid: UUID(), order: 2, title: "Lunch", body: "Team lunch", date: Date(), time: Date(), mapInfo: [], currentLatitude: nil, currentLongitude: nil, participant: nil),
            Plan(uuid: UUID(), order: 3, title: "Call", body: "Client call", date: Date(), time: Date(), mapInfo: [], currentLatitude: nil, currentLongitude: nil, participant: nil)
        ]
        
        // isSelectArray 초기화
        initializeSelectArray()
    }


    func initializeSelectArray() {
        isSelectArray = [Bool](repeating: false, count: plans.count)

    }



    // Add 버튼 클릭 시 실행될 메서드
    @objc func addButtonTapped() {
        print("Add button tapped")
        // 추가뷰로 이동
        // let addPlanViewController = AddPlanViewController()
        // navigationController?.pushViewController(addPlanViewController, animated: true)
    }

    // Edit 버튼 클릭 시 실행될 메서드
    @objc func editButtonTapped() {
        isEditMode.toggle()
        if isEditMode {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonTapped))
        }
        tableView.reloadData()
    }
    
    //체크되면 삭제될 메서드
    @objc func doneButtonTapped() {
        var indexesToDelete = [Int]() // 삭제할 인덱스 배열
        
        // 선택된 항목 삭제
        for (index, isSelected) in isSelectArray.enumerated() {
            if isSelected {
                indexesToDelete.append(index)
            }
        }
        
        // 선택된 항목 삭제
        for index in indexesToDelete.reversed() {
            plans.remove(at: index)
            isSelectArray.remove(at: index)
            let indexPath = IndexPath(row: index, section: 0)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        // isSelectArray 초기화
        initializeSelectArray()
        
        // 테이블 뷰의 데이터 업데이트
        tableView.reloadData()
        
        // UI 업데이트
        editButtonTapped() // Edit 모드 종료
    }
    
    //체크박스 추가
    func setNeedsUpdateConfiguration(_ cell: CustomTableViewCell, at indexPath: IndexPath) {
        if indexPath.section == 0 {
            if isEditMode {
                let checkBox = UIButton(type: .custom)
                let imageName = isSelectArray[indexPath.row] ? "checkmark.square.fill" : "checkmark.square"
                checkBox.setImage(UIImage(systemName: imageName), for: .normal)
                checkBox.addTarget(self, action: #selector(checkBoxTapped(_:)), for: .touchUpInside)
                checkBox.tag = indexPath.row
                
                // accessoryView의 frame을 설정하여 셀의 accessoryView로 추가
                checkBox.frame = CGRect(x: 0, y: 0, width: 20, height: 20) // 적절한 크기 및 위치를 설정하세요
                cell.accessoryView = checkBox
            } else {
                cell.accessoryView = nil
            }
        } else {
            cell.accessoryView = nil
        }
    }

    //체크박스 생성
    @objc func checkBoxTapped(_ sender: UIButton) {
        let row = sender.tag
        isSelectArray[row].toggle()
        let imageName = isSelectArray[row] ? "checkmark.square.fill" : "checkmark.square"
        sender.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    //선택한 셀을 tap하면 이동
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let pmDetailViewController = PmDetailViewController()
            navigationController?.pushViewController(pmDetailViewController, animated: true)
        }
        else {
            let pmDetailViewController = PmDetailViewController()
            navigationController?.pushViewController(pmDetailViewController, animated: true)
        }

    }

    // 섹션 수 설정
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return plans.count
        } else {
            // 공유 받은 약속 섹션의 행 수를 설정합니다. (현재는 예제로 5를 반환)
            return 3
        }
    }

    // 셀 구성
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let plan = plans[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
            cell.titleLabel.text = plan.title
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let formattedDate = dateFormatter.string(from: plan.date)
            cell.dateLabel.text = formattedDate
            
            cell.profileimage.image = UIImage(systemName: "person.crop.circle")
            setNeedsUpdateConfiguration(cell, at: indexPath)
            return cell
        } else {
            // 공유 받은 약속 셀 구성
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
            cell.titleLabel.text = "Shared Plan \(indexPath.row + 1)"
            cell.dateLabel.text = "2024-06-11" // 예제 날짜
            cell.profileimage.image = UIImage(systemName: "person.crop.circle")
            setNeedsUpdateConfiguration(cell, at: indexPath)
            return cell
        }
    }


    // 섹션 헤더 타이틀 설정
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "나의 약속"
        } else {
            return "공유 받은 약속"
        }
    }
}
