//
//  AppDelegate.swift
//  Mokkoji
//
//  Created by 정종원 on 6/4/24.
//

import UIKit
import KakaoSDKCommon
import KakaoSDKAuth
import FirebaseCore
import GoogleSignIn

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //MARK: - kakaoSDK init
        if let nativeAppKey = Bundle.main.object(forInfoDictionaryKey: "KAKAO_NATIVE_APP_KEY") as? String {
            KakaoSDK.initSDK(appKey: nativeAppKey)
        } else {
            fatalError("KAKAO_NATIVE_APP_KEY is not set in Info.plist")
        }
        
        //MARK: - Firebase init
        FirebaseApp.configure()
        
        //MARK: - GoogleLogin 유무 확인
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
          if error != nil || user == nil {
            // Show the app's signed-out state. 로그아웃 상태
          } else {
            // Show the app's signed-in state. 로그인이 되어있는 상태
          }
        }
        
        return true
    }
    
    //MARK: - Google Login (GIDSignIn 인스턴스의 handleURL 메서드를 호출)
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        var handled: Bool
        
        handled = GIDSignIn.sharedInstance.handle(url)
        if handled {
            return true
        }
        
        // Handle other custom URL types.
        
        // If not handled by this app, return false.
        return false
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

