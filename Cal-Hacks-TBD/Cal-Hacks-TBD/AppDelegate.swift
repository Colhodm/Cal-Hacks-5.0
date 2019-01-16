//
//  AppDelegate.swift
//  Cal-Hacks-TBD
//
//  Created by ananya mukerjee on 11/2/18.
//  Copyright © 2018 Cal-Hacks-5.0. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import GoogleMobileAds
import Stripe
import UserNotifications
var token: String?
var clientID: String?
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        print("STARTING")
        // Override point for customization after application launch.
        GMSPlacesClient.provideAPIKey("AIzaSyCTGwWFydE4Sx0BoOHk4M9nGrCXC_ze-KU");
        //GMSPlacesClient.provideAPIKey("AIzaSyAsszS58jyvUp_-Q2HaBofbOIKGdarTMKc");
        GMSServices.provideAPIKey("AIzaSyAsszS58jyvUp_-Q2HaBofbOIKGdarTMKc");
        GADMobileAds.configure(withApplicationID: "ca-app-pub-3940256099942544/2934735716")
        STPPaymentConfiguration.shared().publishableKey = "pk_test_4gfNKWh57OeZteDkHtCGH7Bc"
        clientID = "ca_ELSi9YBQEbzzD7bjRZPMaLBTkaOi4eLg"
        registerForPushNotifications()
        // Check if launched from notification
        let notificationOption = launchOptions?[.remoteNotification]
        
        // 1
        if let notification = notificationOption as? [String: AnyObject],
            let aps = notification["aps"] as? [String: AnyObject] {
            print(aps)
            print("dope")
            // 2
            //NewsItem.makeNewsItem(aps)
            
            // 3
           // (window?.rootViewController as? UITabBarController)?.selectedIndex = 1
        }
        UNUserNotificationCenter.current().delegate = self
            // do any other necessary launch configuration        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        print("Z")
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        print("X")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        print("Y")
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        print("F")
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        print("IM CRASHING")
        
    }
    func registerForPushNotifications() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) {
                [weak self] granted, error in
                
                print("Permission granted: \(granted)")
                guard granted else { return }
//                // 1
//                let viewAction = UNNotificationAction(
//                    identifier: Identifiers.viewAction, title: "View",
//                    options: [.foreground])
//
//                // 2
//                let newsCategory = UNNotificationCategory(
//                    identifier: Identifiers.newsCategory, actions: [viewAction],
//                    intentIdentifiers: [], options: [])
//
//                // 3
//                UNUserNotificationCenter.current().setNotificationCategories([newsCategory])
                self?.getNotificationSettings()
        }
    }
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                print("runningXXX")
                UIApplication.shared.registerForRemoteNotifications()
            }

        }
    }
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
        ) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let tokentemp = tokenParts.joined()
        print("Device Token: \(tokentemp)")
        token = tokentemp
    }
    
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        completionHandler([.alert, .badge, .sound])
    }
//    func application(
//        _ application: UIApplication,
//        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
//        fetchCompletionHandler completionHandler:
//        @escaping (UIBackgroundFetchResult) -> Void
//        ) {
//        guard let aps = userInfo["aps"] as? [String: AnyObject] else {
//            completionHandler(.failed)
//            return
//        }
//        // logic if the notification comes while i'm logged out
//        if self.window?.rootViewController is ViewController{
//            print("login")
//        } else if self.window?.rootViewController is MainViewController {
//            print("again some stuff")
//        }
//        else {
//            print(self.window?.rootViewController)
//        }
//        print("should be doing some logic")
//        NotificationCenter.default.post(name: NSNotification.Name("orderNear"), object: nil)
//
//    }


}

