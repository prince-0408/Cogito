//
//  AppDelegate.swift
//  Cogito
//
//  Created by Prince Yadav on 05/03/25.
//


import UIKit
import CoreData
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // Setup notification delegate
        UNUserNotificationCenter.current().delegate = self
        
        // Setup notification categories and actions
        setupNotificationActions()
        
        return true
    }
    
    // Handle notification when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show notification banner even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
    
    // Handle notification actions
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        // Handle different actions
        switch response.actionIdentifier {
        case "VIEW_TASK":
            // Open the task detail view
            if let taskIdString = userInfo["taskId"] as? String,
               let taskId = UUID(uuidString: taskIdString) {
                // Post notification to open task detail
                NotificationCenter.default.post(
                    name: NSNotification.Name("OpenTaskDetail"),
                    object: nil,
                    userInfo: ["taskId": taskId]
                )
            }
            
        case "COMPLETE_TASK":
            // Mark task as completed
            if let taskIdString = userInfo["taskId"] as? String,
               let taskId = UUID(uuidString: taskIdString) {
                // Post notification to complete task
                NotificationCenter.default.post(
                    name: NSNotification.Name("CompleteTask"),
                    object: nil,
                    userInfo: ["taskId": taskId]
                )
            }
            
        default:
            break
        }
        
        completionHandler()
    }
    
    // Setup notification actions
    private func setupNotificationActions() {
        // Define actions
        let viewAction = UNNotificationAction(
            identifier: "VIEW_TASK",
            title: "View Task",
            options: .foreground
        )
        
        let completeAction = UNNotificationAction(
            identifier: "COMPLETE_TASK",
            title: "Mark as Complete",
            options: .authenticationRequired
        )
        
        // Define category
        let category = UNNotificationCategory(
            identifier: "TASK_REMINDER",
            actions: [viewAction, completeAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )
        
        // Register category
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
}

