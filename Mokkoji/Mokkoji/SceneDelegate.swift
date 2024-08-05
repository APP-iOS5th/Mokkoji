//
//  SceneDelegate.swift
//  Mokkoji
//
//  Created by 정종원 on 6/4/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        
        //MARK: - Login View (Entry Point)
        
//        // Firebase 사용자 상태 확인 및 자동 로그인 처리
//        Auth.auth().currentUser?.reload(completion: { error in
//            if let error = error {
//                print("Auth.auth().currentUser reload failed with error: \(error.localizedDescription)")
//                self.showLoginScreen(window: window)
//                return
//            }
//
//            if let user = Auth.auth().currentUser {
//                // Firestore에서 사용자 정보 가져오기
//                self.fetchUserFromFirestore(userId: user.uid) { fetchedUser in
//                    if let fetchedUser = fetchedUser {
//                        // 로그인이 된 상태
//                        print("[SceneDelegate] 로그인 성공")
//                        UserInfo.shared.user = fetchedUser
//                        DispatchQueue.main.async {
//                            let tabBarController = self.createTabBarController()
//                            window.rootViewController = tabBarController
//                            window.makeKeyAndVisible()
//                        }
//                    } else {
//                        // Firestore에서 사용자 정보를 가져오지 못한 경우, 로그아웃 처리
//                        print("[SceneDelegate] Firestore 정보 가져오지 못함")
//                        do {
//                            try Auth.auth().signOut()
//                            self.showLoginScreen(window: window)
//                        } catch {
//                            print("[SceneDelegate] Auto Login Error: \(error.localizedDescription)")
//                            self.showLoginScreen(window: window)
//                        }
//                    }
//                }
//            } else {
//                // 로그인이 되지 않은 상태 (로그인 뷰로 이동)
//                self.showLoginScreen(window: window)
//            }
//        })
        
        
        //사용자 로그인 유무 확인
        print("[SceneDelegate currentUser]\(Auth.auth().currentUser)")
        if let user = Auth.auth().currentUser {
            
            guard let userEmail = user.email else { return }
            
            // Firestore에서 사용자 정보 가져오기
            //TODO: = userID가 로그인에 따라 다름. user.uid는 sns의 따라 다 다름
            fetchUserFromFirestore(userEmail: userEmail) { fetchedUser in
                if let fetchedUser = fetchedUser {
                    //로그인이 된 상태
                    print("[SceneDelegate] 로그인 성공")
                    UserInfo.shared.user = fetchedUser
                    let tabBarController = self.createTabBarController()
                    tabBarController.selectedIndex = 1
                    window.rootViewController = tabBarController
                } else {
                    // 사용자가 로그인되어 있지만 Firestore에서 사용자 정보를 가져오지 못한 경우, 로그아웃
                    do {
                        print("[SceneDelegate] 로그인은 되어있지만 Firestore정보 가져오지 못함")
                        try Auth.auth().signOut()
                        let loginViewController = LoginViewController()
                        let navigationVC = UINavigationController(rootViewController: loginViewController)
                        window.rootViewController = navigationVC
                    } catch {
                        print("[SceneDelegate] Auto Login Error: \(error.localizedDescription)")
                    }
                }
                window.makeKeyAndVisible()
            }
            
        } else {
            //로그인이 되지 않은 상태 (로그인 뷰로 이동)
            print("[SceneDelegate] 로그인이 되지 않은 상태 (로그인 뷰로 이동)")
            let mainViewController = LoginViewController()
            let navigationVC = UINavigationController(rootViewController: mainViewController)
            
            UINavigationBar.appearance().barTintColor = .white
            UINavigationBar.appearance().tintColor = UIColor(named: "Primary_Color")
            UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black ]
            
            window.rootViewController = navigationVC
            window.makeKeyAndVisible()
        }
        
        self.window = window
    }
    
    private func showLoginScreen(window: UIWindow) {
        let loginViewController = LoginViewController()
        let navigationVC = UINavigationController(rootViewController: loginViewController)
        
        UINavigationBar.appearance().barTintColor = .white
        UINavigationBar.appearance().tintColor = UIColor(named: "Primary_Color")
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black ]
        
        DispatchQueue.main.async {
            window.rootViewController = navigationVC
            window.makeKeyAndVisible()
        }
    }
    
    func changeRootViewController (_ viewController: UIViewController, animated: Bool) {
        guard let window = self.window else { return }
        
        // PlanListViewController가 처음보이는 화면으로 설정
        if let tabBarController = viewController as? UITabBarController {
            tabBarController.selectedIndex = 1
        }
        
        window.rootViewController = viewController // 전환
        window.makeKeyAndVisible()
    }
    
    func createTabBarController() -> UITabBarController {
        let navigationController = UINavigationController(rootViewController: PlanListViewController())
        let profilController = UINavigationController(rootViewController: ProfileViewController())
        let friendController = UINavigationController(rootViewController: FriendListViewController())
        
        let tabBarController = UITabBarController()
        tabBarController.setViewControllers([friendController, navigationController, profilController], animated: true)
        
        // 기본 색상 설정
        UINavigationBar.appearance().barTintColor = .white
        UINavigationBar.appearance().tintColor = UIColor(named: "Primary_Color")
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black ]
        
        UITabBar.appearance().barTintColor = .white
        UITabBar.appearance().tintColor = UIColor(named: "Primary_Color")
        UITabBar.appearance().unselectedItemTintColor = .lightGray
        
        if let items = tabBarController.tabBar.items {
            items[0].selectedImage = UIImage(systemName: "person.2.circle.fill")
            items[0].image = UIImage(systemName: "person.2.circle")
            items[0].title = "친구"
            
            items[1].selectedImage = UIImage(systemName: "star.fill")
            items[1].image = UIImage(systemName: "star")
            items[1].title = "약속 리스트"
            
            items[2].selectedImage = UIImage(systemName: "person.fill")
            items[2].image = UIImage(systemName: "person")
            items[2].title = "프로필"
            
            
        }
        
        return tabBarController
    }
    
    //파이어스토어 유저 정보 가져오는 메소드
    func fetchUserFromFirestore(userEmail: String, completion: @escaping (User?) -> Void) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userEmail)
        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                do {
                    let user = try document.data(as: User.self)
                    completion(user)
                } catch let error {
                    print("User Decoding Error: \(error)")
                    completion(nil)
                }
            } else {
                print("scenedelegate [FB] Firestore에 User가 존재하지 않음.")
                completion(nil)
            }
        }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    
}
