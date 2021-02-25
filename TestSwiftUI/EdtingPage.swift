//
//  EdtingPage.swift
//  TestSwiftUI
//
//  Created by 高结 on 2021/2/23.
//

import SwiftUI

struct EdtingPage: View {
    
  @EnvironmentObject var UserData:ToDo
    
   @State var title:String = ""
    
   @State var duedate:Date = Date()
    
   @State var isFavite = false
    
    var id:Int? = nil
    
   @Environment(\.presentationMode) var presentation
    
    var body: some View {
        NavigationView {
            Form {
                Section(header:Text("事项")) {
                    TextField("事项内容", text: self.$title)
//                    DatePicker(selection: self.$duedate, label: {Text("截止时间")})
                    DatePicker("截止时间", selection: self.$duedate)
                }
                
                Section {
                    Toggle(isOn: self.$isFavite, label: {
                        Text("收藏")
                    })
                }
                
                Section() {
                    Button(action: {
                        if self.id == nil {
                            self.UserData.add(data: SingleToDo(title: self.title, date: self.duedate,isFavorite: self.isFavite))
                        } else {
                            self.UserData.edit(id: self.id!, data: SingleToDo(title: self.title, date: self.duedate,isFavorite: self.isFavite))
                        }
                        //关闭添加界面
                        self.presentation.wrappedValue.dismiss()
                    }, label: {
                        Text("确认")
                    })
                    
                    Button(action: {
                        //关闭添加界面
                        self.presentation.wrappedValue.dismiss()
                    }, label: {
                        Text("取消")
                        
                    })
                }
            }
            .navigationTitle("添加")
        }
    }
}

struct EdtingPage_Previews: PreviewProvider {
    static var previews: some View {
        EdtingPage()
    }
}
