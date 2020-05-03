//
//  AppDelegate.swift
//  XWorkerBee
//
//  Created by Chan on 2/8/19.
//  Copyright © 2019 XEP. All rights reserved.
//

import UIKit
import CoreData
//import DropDown
import OneSignal
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, OSSubscriptionObserver {
    
    var window: UIWindow?
    var nav: UINavigationController?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        registerNotification()
        let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false]
        
        // Replace 'YOUR_APP_ID' with your OneSignal App ID.
        
        //                                                                                appId: "93bca82f-e587-4ef2-b11f-00e236e6724b",
        OneSignal.initWithLaunchOptions(launchOptions,
                                        appId: "832d44c6-d906-4296-9762-1ca27c2bc1fe",
                                        handleNotificationReceived: {
                                            notification in
                                            //print(" ")
                                            let msg =  "Received Notification - " + notification!.payload.notificationID + " - " +  notification!.payload.title
                                            print("\(msg)")
                                            let db = DataManager()
                                            let addStatus = db.addNotify(id: notification!.payload.notificationID,
                                                                         title: notification!.payload.title,
                                                                         content: notification!.payload.body,
                                                                         viewed: false)
                                            if(addStatus){
                                                UserDefaults.standard.set(true, forKey: User.SHOW_NOTIFICATION_BADGE_FLAG)
                                                NotificationCenter.default.post(name: .showBadge, object: nil)
                                                NotificationCenter.default.post(name: .showBadgeAtNotificationVC, object: nil)
                                            }
        } ,
                                        handleNotificationAction:
            { result in
                
                //                                            // This block gets called when the user reacts to a notification received
                //                                            let payload: OSNotificationPayload = result!.notification.payload
                //                                            var fullMessage = payload.body
                //
                //                                            //Try to fetch the action selected
                //                                            if let additionalData = payload.additionalData, let actionSelected = additionalData["actionSelected"] as? String {
                //                                                fullMessage =  fullMessage! + "\nPressed ButtonId:\(actionSelected)"
                //                                            }
                //                                            print("fullMessage = \(fullMessage)")
                
                switch UIApplication.shared.applicationState {
                case .active:
                    //app is currently active, can update badges count here
                    break
                case .inactive:
                    //app is transitioning from background to foreground (user taps notification), do what you need when user taps here
                    break
                case .background:
                    //app is in background, if content-available key of your notification is set to 1, poll to your backend to retrieve data and update your interface here
                    break
                default:
                    let alert = UIAlertController(title: "Did you bring your towel?", message: "It's recommended you bring your towel before continuing.", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: nil))
                    alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
                    
                    self.window?.rootViewController?.present(alert, animated: true)
                    
                    let db = DataManager()
                    let addStatus = db.addNotify(id: result!.notification.payload.notificationID,
                                                 title: result!.notification.payload.title,
                                                 content: result!.notification.payload.body,
                                                 viewed: false)
                    if(addStatus){
                        UserDefaults.standard.set(true, forKey: User.SHOW_NOTIFICATION_BADGE_FLAG)
                        NotificationCenter.default.post(name: .showBadge, object: nil)
                        NotificationCenter.default.post(name: .showBadgeAtNotificationVC, object: nil)
                        
                        let alert = UIAlertController(title: "Did you bring your towel?", message: "It's recommended you bring your towel before continuing.", preferredStyle: .alert)
                        
                        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: nil))
                        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
                        
                        self.window?.rootViewController?.present(alert, animated: true)
                    }
                    break
                }
                
        }
            ,
                                        settings: onesignalInitSettings)
        
        OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification;
        
        // Recommend moving the below line to prompt for push after informing the user about
        //   how your app will use them.
        OneSignal.promptForPushNotifications(userResponse: { accepted in
            print("User accepted notifications: \(accepted)")
        })
        
        //UITabBar.appearance().tintColor = Utils.convertHexStringToUIColor(hex: Color.MAIN_COLOR)
        //UIBarButtonItem.appearance().tintColor = Utils.convertHexStringToUIColor(hex: Color.MAIN_COLOR)
        
        //DropDown.startListeningToKeyboard()
        
        //        let rv = MainTabBarController()
        //        rv.tabBar.tintColor = Utils.convertHexStringToUIColor(hex: Constant.mainColor)
        //        window = UIWindow(frame: UIScreen.main.bounds)
        //
        //        nav = UINavigationController(rootViewController: rv)
        //        nav?.navigationBar.backgroundColor = UIColor.red
        //        //self.nav?.navigationBar.tintColor = UIColor.blue
        //        //self.nav?.navigationItem.title = "XWorkerBee"
        //
        //        window?.rootViewController = nav
        //        window?.makeKeyAndVisible()
        
        return true
    }
    
    func onOSSubscriptionChanged(_ stateChanges: OSSubscriptionStateChanges!) {
        if(!stateChanges.from.subscribed && stateChanges.to.subscribed){
            UserDefaults.standard.set(stateChanges.to.userId, forKey: User.PLAYER_ID)
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        //
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("\(userInfo)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        print("\(userInfo)")
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    @available(iOS 10.0, *)
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Data")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    @available(iOS 10.0, *)
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    private func registerNotification(){
        let notification = UIUserNotificationSettings.init(types: [.alert, .badge, .sound], categories: nil)
        UIApplication.shared.registerUserNotificationSettings(notification)
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    
}

