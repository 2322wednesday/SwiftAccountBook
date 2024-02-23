//
//  SwiftAccountBookApp.swift
//  SwiftAccountBook
//
//  Created by 권성한 on 2/1/24.
//

import SwiftUI
import Firebase
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    print("AccountBook이 이미 실행 중입니다.")
    FirebaseApp.configure()
    return true
  }
}

@main
struct SwiftAccountBookApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup{
            AuthenticationView()
        }
    }
}
