//
//  SceneDelegate.swift
//  Mokkoji
//
//  Created by 정종원 on 6/4/24.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        
        //MARK: - Login View (Entry Point)
        
        let mainViewController = LoginViewController()
        let navigationVC = UINavigationController(rootViewController: mainViewController)
        
        UINavigationBar.appearance().barTintColor = .white
        UINavigationBar.appearance().tintColor = UIColor(named: "Primary_Color")
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black ]
        
        window.rootViewController = navigationVC
        window.makeKeyAndVisible()
        self.window = window
    }
    
    func changeRootViewController (_ viewController: UIViewController, animated: Bool) {
        guard let window = self.window else { return }
        window.rootViewController = viewController // 전환
        window.makeKeyAndVisible()
    }
    
    func createTabBarController() -> UITabBarController {
        let navigationController = UINavigationController(rootViewController: PlanListViewController())
        let profilController = UINavigationController(rootViewController: ProfileViewController())
        
        let tabBarController = UITabBarController()
        tabBarController.setViewControllers([navigationController, profilController], animated: true)
        
        // 기본 색상 설정
        UINavigationBar.appearance().barTintColor = .red
        UINavigationBar.appearance().tintColor = UIColor(named: "Primary_Color")
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black ]
        
        UITabBar.appearance().barTintColor = .red
        UITabBar.appearance().tintColor = UIColor(named: "Primary_Color")
        UITabBar.appearance().unselectedItemTintColor = .lightGray
        
        if let items = tabBarController.tabBar.items {
            items[0].selectedImage = UIImage(systemName: "star.fill")
            items[0].image = UIImage(systemName: "star")
            items[0].title = "약속 리스트"
            
            items[1].selectedImage = UIImage(systemName: "person.fill")
            items[1].image = UIImage(systemName: "person")
            items[1].title = "프로필"
        }
        
        return tabBarController
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
