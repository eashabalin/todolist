//
//  Notification.swift
//  ToDoList
//
//  Created by Егор Шабалин on 12.05.2021.
//

import Foundation
import UserNotifications

struct Notification: Codable {
//    private var notificationId: String
    var todo: ToDo
    
    func schedule(completion: @escaping (Bool) -> ()) {
        authorizeIfNeeded { (granted) in
            guard granted else {
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }
        }
        
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = "To-Do"
        content.body = self.todo.title
        content.sound = UNNotificationSound.default
        
        let triggerDateComponents = Calendar.current.dateComponents([.minute, .hour, .day, .month, .year], from: todo.dueDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDateComponents, repeats: false)
        
        let request = UNNotificationRequest(identifier: todo.id, content: content, trigger: trigger)
        
        center.add(request) { (error: Error?) in
            DispatchQueue.main.async {
                if let error = error {
                    print(error.localizedDescription)
                    completion(false)
                } else {
                    return
                }
            }
        }
    }
    
    static func unschedule(id: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
    }
    
    private func authorizeIfNeeded(completion: @escaping (Bool) -> ()) {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getNotificationSettings { (settings) in
            switch settings.authorizationStatus {
            case .authorized:
                completion(true)
            case .notDetermined:
                notificationCenter.requestAuthorization(options: [.alert, .sound]) { (granted, _) in
                    completion(granted)
                }
            default:
                completion(false)
            }
        }
    }
    
    init(todo: ToDo) {
        self.todo = todo
//        self.notificationId = notificationId ?? UUID().uuidString
    }
}
