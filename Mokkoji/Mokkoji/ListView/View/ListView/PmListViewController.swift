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

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        
        self.navigationItem.title = "약속 리스트"
        
        let tabBarCtr = UITabBarController()

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

        // isSelectArray 초기화
        initializeSelectArray()
        
    }

    func initializeSelectArray() {
        var numberOfRowsInAllSections = 0
        
        // 각 섹션의 행 수를 계산하여 총 행 수를 계산합니다.
        let sections = numberOfSections(in: tableView)
        for section in 0..<sections {
            numberOfRowsInAllSections += tableView.numberOfRows(inSection: section)
        }
        
        // isSelectArray를 적절한 행 수로 초기화합니다.
        isSelectArray = [Bool](repeating: false, count: numberOfRowsInAllSections)
    }



    // Add 버튼 클릭 시 실행될 메서드
    @objc func addButtonTapped() {
        print("Add button tapped")
        // 추가뷰로 이동
        // let PmDetailView = PmDetailViewController()
        // navigationController?.pushViewController(PmDetailView, animated: true)
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
            let section = index < tableView.numberOfRows(inSection: 0) ? 0 : 1
            let adjustedIndex = index % tableView.numberOfRows(inSection: section)
            isSelectArray.remove(at: index)
            let indexPath = IndexPath(row: adjustedIndex, section: section)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        // 테이블 뷰의 데이터 업데이트
        tableView.reloadData()
        
        // UI 업데이트
        editButtonTapped() // Edit 모드 종료
        initializeSelectArray() // isSelectArray 다시 초기화
    }




    
    //체크박스 추가
    func setNeedsUpdateConfiguration(_ cell: CustomTableViewCell, at indexPath: IndexPath) {
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
        if indexPath.section == 0 && indexPath.row == 0 {
            let pmDetailViewController = PmDetailViewController()
            navigationController?.pushViewController(pmDetailViewController, animated: true)
        }

    }

    // 섹션 수 설정
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    // 각 섹션의 행 수 설정
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            // 첫 번째 섹션일 때는 3개의 행 반환
            return isEditMode ? 3 : 3 - isSelectArray.filter({ $0 }).count
        } else {
            // 두 번째 섹션일 때는 다른 값으로 수정 가능
            return 5 // 예: 두 번째 섹션에는 5개의 행 반환
        }
    }

    // 셀 구성
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
        cell.titleLabel.text = "title"
        cell.dateLabel.text = "Date"
        cell.profileimage.image = UIImage(systemName: "person.crop.circle")
        setNeedsUpdateConfiguration(cell, at: indexPath)
        return cell
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
