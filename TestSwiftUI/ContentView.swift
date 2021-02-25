//
//  ContentView.swift
//  TestSwiftUI
//
//  Created by 高结 on 2021/2/22.
//

import SwiftUI

var formatter = DateFormatter()

func initUserData() -> [SingleToDo] {
    
    formatter.dateFormat = "yyy.MM.dd HH:mm:ss"
    
    var output:[SingleToDo] = []
    if let datastored = UserDefaults.standard.object(forKey: "ListToDo") as? Data {
        let datas = try! decoders.decode([SingleToDo].self, from: datastored)
        for item in datas {
            if (!item.isDeleted) {
                output.append(SingleToDo(title: item.title, date: item.date, isChecked: item.isChecked,isFavorite: item.isFavorite, id: output.count))
            }
        }
    }
    return output
}

struct ContentView: View {
    
    @ObservedObject var UserData:ToDo = ToDo(data: initUserData())
    
    @State var ShowEditingPage:Bool = false
    
    @State var selection:[Int] = []
    
    @State var editModel = false
    
    @State var ShowLikeOnly:Bool = false
    
    
    
    var body: some View {
        
        ZStack {
            NavigationView {
                ScrollView(.vertical, showsIndicators: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/, content: {
                    VStack {
                        ForEach(self.UserData.ToDoList) {item in
        //                    SingleCardView(index:item.id).environmentObject(self.UserData)
        //                        .padding()
                            if !item.isDeleted {
                                if !self.ShowLikeOnly || item.isFavorite {
                                    SingleCardView(index:item.id,editModel: self.$editModel, selection: self.$selection).environmentObject(self.UserData)
                                        .padding(.top)
                                        .padding(.horizontal)
                                        .animation(.spring())
                                        .transition(.slide)
                                }
                            }
                        }
                    }
                })
                .navigationTitle("提醒事件")
                .navigationBarItems(trailing:
                                        HStack() {
                                            if (self.editModel) {
                                                DeleteBUtton(selction: self.$selection,editModel:self.$editModel).environmentObject(self.UserData)
                                                LikeButton(selection: self.$selection, editingMode:self.$editModel).environmentObject(self.UserData)
                                            }
                                            if (!self.editModel) {
                                                ShowLikeButton(showLikeOnly: self.$ShowLikeOnly)
                                            }
                                            EditingButton(editingMode: self.$editModel,section: self.$selection)
                                                
                                        }
                )
            }
            
            HStack {
                
                Spacer()
                
                VStack {
                    
                    Spacer()
                    
                    Button(action: {
                        self.ShowEditingPage = true
                    }
                    , label: {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80)
                            .foregroundColor(.blue)
                            .padding(.trailing)
                            .padding(.bottom)
                    })
                    .sheet(isPresented: self.$ShowEditingPage, content: {
                        EdtingPage().environmentObject(self.UserData)
                    })
                }
            }
            
        }
    }
}


struct EditingButton:View {
    
   @Binding var editingMode:Bool
   @Binding var section:[Int]
    
    var body: some View {
        Button(action: {
            self.editingMode.toggle()
            self.section.removeAll()
        }, label: {
            Image(systemName: "gear")
        })
        
    }
}

struct ShowLikeButton:View {
    
   @Binding var showLikeOnly:Bool
    
    var body: some View {
        Button(action: {
            self.showLikeOnly.toggle()
        }, label: {
            Image(systemName:self.showLikeOnly ? "star.fill" : "star")
                .imageScale(.large)
                .foregroundColor(.yellow)
        })
        
    }
}

struct LikeButton:View {
    
    @EnvironmentObject var UserData: ToDo
    @Binding var selection:[Int]
    @Binding var editingMode:Bool
    
    var body: some View {
            Image(systemName:"star.lefthalf.fill")
                .imageScale(.large)
                .foregroundColor(.yellow)
                .onTapGesture {
                    for i in self.selection {
                        self.UserData.ToDoList[i].isFavorite.toggle()
                    }
                    self.editingMode = false
                }
    }
}


struct DeleteBUtton:View {
    
   @Binding var selction:[Int]
   @Binding var editModel:Bool
  
   @EnvironmentObject var UserData: ToDo
    
    var body: some View {
        Button(action: {
            for i in self.selction {
                UserData.delete(id: i)
                self.editModel = false
            }
        }, label: {
            Image(systemName: "trash")
        })
    }
}

struct SingleCardView: View {
//    @State var isCheacked: Bool = false
//    
//    var title = ""
//    var duedate = Date()
    var index:Int
    @Binding var editModel:Bool
    @Binding var selection:[Int]
    //子视图用到父视图
  @EnvironmentObject var UserData:ToDo
    
    @State var showEditingPage:Bool = false

    var body: some View {
        
        HStack {
            
            Rectangle()
                .frame(width: 6)
                .foregroundColor(Color("Color" + String(self.index % 3)))
            
            if (self.editModel) {
                Button(action: {
                   //删除按钮点击
                    self.UserData.delete(id: self.index)
                    
                }, label: {
                    Image(systemName: "trash")
                        .imageScale(.large)
                        .padding(.leading)
                })
            }
       
            
//            Button(action: {
//
//            }, label: {
//                Text("Button")
//            })
//
            Button(action: {
                if !editModel {
                    self.showEditingPage = true
                }
            }, label: {
                Group {
                    VStack(alignment: .leading, spacing:6.0) {
                        Text(self.UserData.ToDoList[index].title)
                            .font(.headline)
                            .fontWeight(.heavy)
                            .foregroundColor(.black)
        //                    .padding(.leading)
                        Text(formatter.string(from: self.UserData.ToDoList[index].date))
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
        //                    .padding(.leading)
                    }
                    .padding(.leading)
                    Spacer()
                }
            }).sheet(isPresented: self.$showEditingPage, content: {
                EdtingPage(title:self.UserData.ToDoList[self.index].title,
                           duedate:self.UserData.ToDoList[self.index].date,
                           isFavite:self.UserData.ToDoList[self.index].isFavorite, id:self.index)
                 .environmentObject(self.UserData)
            })
            
            if (self.UserData.ToDoList[index].isFavorite) {
                Image(systemName: "star.fill")
                    .imageScale(.large)
                    .foregroundColor(.yellow)
            }
     
            
            
//            Button(action: {
//                self.UserData.check(id: index)
//            }, label: {
//                Image(systemName:self.UserData.ToDoList[index].isChecked ? "checkmark.square.fill" : "square")
//                    .imageScale(.large).foregroundColor(.black)
//            })
            
            
            
            if (!self.editModel) {
                Image(systemName:self.UserData.ToDoList[index].isChecked ? "checkmark.square.fill" : "square")
                    .imageScale(.large)
                    .padding(.trailing)
                    .onTapGesture {
                       self.UserData.check(id: index)//取反当前的bool值
                    }
            } else {
                Image(systemName: self.selection.firstIndex(where: {$0 == self.index}) == nil ? "circle":"checkmark.circle.fill")
                    .imageScale(.large)
                    .padding(.trailing)
                    .onTapGesture {
                        if self.selection.firstIndex(where: {
                            $0 == self.index
                        }) == nil {
                            self.selection.append(self.index)
                        } else {
//                           self.selection.remove(at:self.index)
                            self.selection.remove(at: self.selection.firstIndex(where: {
                                $0 == self.index
                            })!)
                        }
                    }
            }
        }
        .frame(height:80)
        .background(Color.white)
        .cornerRadius(10.0)
        .shadow(color: .gray, radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/, x: 0, y: 10)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(UserData: ToDo(data: [SingleToDo(title: "写作业", date:Date(),isFavorite:false ),SingleToDo(title: "复习", date:Date(), isFavorite:false )]))
    }
}
