//
//  UserData.swift
//  TestSwiftUI
//
//  Created by 高结 on 2021/2/22.
//

import Foundation
import UserNotifications

var encoders = JSONEncoder()
var decoders = JSONDecoder()
let NotificationContent = UNMutableNotificationContent()

class ToDo:ObservableObject {//外部用到 实时变化 准守ObservableObjec协议 检测属性要用 @Published  外部出进来的时候用@ObservedObject
    @Published var ToDoList:[SingleToDo]
    var count:Int = 0
    init() {
        self.ToDoList = []
    }
    init(data:[SingleToDo]) {
        //要手动调整ToDoList的值
        self.ToDoList = []
        for item in data {
            self.ToDoList.append(SingleToDo(title: item.title, date: item.date, isChecked: item.isChecked, isFavorite: item.isFavorite, id: self.count))
            count += 1
        }
    }
    
    func check(id:Int) {
        self.ToDoList[id].isChecked.toggle()
        self.dataSoure()
    }
    
    func add(data:SingleToDo) {
        self.ToDoList.append(SingleToDo(title: data.title, date: data.date,isFavorite: data.isFavorite, id: self.count))
        self.count += 1
        
        self.sort()
        
        self.dataSoure()
        self.sendNotification(id: self.ToDoList.count - 1)
    }
    
    func edit(id: Int,data: SingleToDo) {
        self.withdrawNotionfication(id: id)
        self.ToDoList[id].title = data.title
        self.ToDoList[id].date = data.date
        self.ToDoList[id].isChecked = data.isChecked
        self.ToDoList[id].isFavorite = data.isFavorite
        
        self.sort()
        
        self.dataSoure()
        
        self.sendNotification(id: id)
    }
    
    func delete(id:Int) {
        
        self.withdrawNotionfication(id: id)
        
        self.ToDoList[id].isDeleted = true
        
        self.sort()
        
        self.dataSoure()
    }
    
    func sort()  {
        self.ToDoList.sort { (SingleToDo1, SingleToDo2) -> Bool in
            return SingleToDo1.date.timeIntervalSince1970 < SingleToDo2.date.timeIntervalSince1970
        }
        for i in 0..<self.ToDoList.count {
            self.ToDoList[i].id = i
            
        }
    }
    
    func dataSoure() {
        let datasoure = try! encoders.encode(self.ToDoList)
        UserDefaults.standard.setValue(datasoure, forKey: "ListToDo")
    }
    
    func sendNotification(id:Int) {
        NotificationContent.title = self.ToDoList[id].title
        NotificationContent.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval:(self.ToDoList[id].date.timeIntervalSinceNow > 0 ? self.ToDoList[id].date.timeIntervalSinceNow : 5), repeats: false)
        let request = UNNotificationRequest(identifier: self.ToDoList[id].title + self.ToDoList[id].date.description, content: NotificationContent, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
        
    }
    
    func withdrawNotionfication(id:Int)  {
        //删除已发送的通知
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [self.ToDoList[id].title + self.ToDoList[id].date.description])
        //删除准备发送的通知（待发送的通知）
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [self.ToDoList[id].title + self.ToDoList[id].date.description])
    }
    
}

struct SingleToDo:Identifiable,Codable {
    var title:String = ""
    var date:Date = Date()
    var isChecked:Bool = false
    var isFavorite:Bool = false
    
    
    var id:Int = 0
    var isDeleted = false
    
}
