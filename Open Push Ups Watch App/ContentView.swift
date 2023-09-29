import SwiftUI
import UserNotifications


struct ContentView: View {
    @State private var pushUpsForToday: Int = UserDefaults.standard.integer(forKey: "pushUpsForToday")
    @State private var dailyPushUps: Int = UserDefaults.standard.integer(forKey: "dailyPushUps")
    @State private var navigateToPushUpView: Bool? = nil
    @State private var currentDay: Int = UserDefaults.standard.integer(forKey: "currentDay")
    @State private var startingDate: Date? = nil
    
    
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Day \(currentDay): Time for \(pushUpsForToday) Push-Ups!")
                Button("Let's Start") {
                    navigateToPushUpView = true
                }
                NavigationLink("I'm Done", destination: PushUpView(pushUps: $pushUpsForToday, totalPushUps: $dailyPushUps), tag: true, selection: $navigateToPushUpView)
                    .opacity(0).frame(width: 0, height: 0)
            }
            .onAppear {
                Task{
                    if UserDefaults.standard.object(forKey: "startingDate") == nil {
                        UserDefaults.standard.set(Date(), forKey: "startingDate")
                    }
                    await requestNotificationPermission()
                    await scheduleNotifications()
                    var daysCompleted: Int {
                        return calculateDays()
                    }
                    loadData()
                    incrementPushUps()
                }
                
                
                func incrementPushUps() {
                    if UserDefaults.standard.object(forKey: "startDate") == nil {
                           let startDate = Date()
                           UserDefaults.standard.set(startDate, forKey: "startDate")
                       }

                       // Retrieve the start date
                       if let startDate = UserDefaults.standard.object(forKey: "startDate") as? Date {
                           // Calculate the number of days passed
                           let daysPassed = Calendar.current.dateComponents([.day], from: startDate, to: Date()).day ?? 0
                           currentDay = daysPassed + 1

                           // Logic to update pushUpsForToday, e.g., increment based on daysPassed
                           pushUpsForToday = currentDay
                       }
                       
                        
                    dailyPushUps += 1
                    saveData()
                }
                
                func saveData() {
                    if UserDefaults.standard.object(forKey: "startDate") == nil {
                           let startDate = Date()
                           UserDefaults.standard.set(startDate, forKey: "startDate")
                       }
                    UserDefaults.standard.set(currentDay, forKey: "currentDay")
                    UserDefaults.standard.set(pushUpsForToday, forKey: "pushUpsForToday")
                    UserDefaults.standard.set(Date(), forKey: "lastUpdatedDate")
                    UserDefaults.standard.set(dailyPushUps, forKey: "dailyPushUps")
                }
                
                func loadData() {
                    
                }
                
               
                
                
                @Sendable func scheduleNotifications() async {
                    let content = UNMutableNotificationContent()
                    content.title = "Time for Push-Ups!"
                    content.body = "It's push-ups time."
                    
                    let repeatCycle = 60 * 60
                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(repeatCycle), repeats: true)
                    
                    let request = UNNotificationRequest(identifier: "PushUpID", content: content, trigger: trigger)
                    
                    do {
                        try await UNUserNotificationCenter.current().add(request)
                    } catch {
                        // Handle error
                    }
                }
                func requestNotificationPermission() async {
                    do {
                        let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound])
                        if granted {
                            // Schedule notifications here
                        }
                    } catch {
                        // Handle error
                    }
                }
                
            }
            
        }
        
        
    }
    
    
    struct PushUpView: View {
        @Binding var pushUps: Int
        @Binding var totalPushUps: Int
        
        var body: some View {
            VStack {
                Text("\(pushUps)")
                    .font(.system(size: 100))
                    .minimumScaleFactor(0.1)
                    .lineLimit(1)
                NavigationLink("I'm Done", destination: WellDoneView(totalPushUps: self.totalPushUps))
            }
        }
    }
    
    struct WellDoneView: View {
        @State private var showStatistics = false
            var totalPushUps: Int
            
        var body: some View {
            Text("Well Done!")
            Button("Statistics") {
                            showStatistics = true
                        }
                        .sheet(isPresented: $showStatistics) {
                            StatisticsView(totalPushUps: totalPushUps)
                        }
            // Future idea Implement GIF display here
        }
    }
    
    struct StatisticsView: View {
        var totalPushUps: Int
        
        let daysCompleted = calculateDays()
        var body: some View {
            VStack {
                Text("Statistics")
                    .font(.headline)
                    .fontWeight(.bold)
                    .minimumScaleFactor(0.5)
                
                Spacer().frame(height: 10)
                
                HStack {
                    Text("Total Push-ups:")
                        .font(.subheadline)
                        .minimumScaleFactor(0.5)
                    Spacer()
                    Text("\(totalPushUps)")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .minimumScaleFactor(0.5)
                }
                
                HStack {
                    Text("Days Completed:")
                        .font(.subheadline)
                    Spacer()
                    Text("\(daysCompleted)")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .minimumScaleFactor(0.5)
                }
                
                Spacer()
                
                // Optional: Add graph or progress bar here
                
            }
            .padding(.horizontal, 20)
            .background(Color(UIColor.black))
        }
    }
    
}

func calculateDays() -> Int {
    let startingDate = UserDefaults.standard.object(forKey: "startingDate") as? Date ?? Date()
    return Calendar.current.dateComponents([.day], from: startingDate, to: Date()).day ?? 0
}
////
////  ContentView.swift
////  Open Push Ups Watch App
////
////  Created by Eran on 28/09/2023.
////
//
//import SwiftUI
//import UserNotifications
//
//
//struct ContentView: View {
//    @State private var currentDay = 1
//    @State private var pushUpsForToday = 1
//    @State private var lastUpdatedDate: Date? = nil
//    @State private var navigateToPushUpView = false
//    
//    var body: some View {
//        VStack {
//            Text("Time for \(pushUpsForToday) Push-Ups!")
//            Button("Let's Start") {
//                navigateToPushUpView = true
//            }
//            .navigationDestination(isPresented: $navigateToPushUpView) {
//                PushUpView(pushUps: $pushUpsForToday)
//            }
//        }.padding().onAppear(){
//            Task{
//                await requestNotificationPermission()
//                await scheduleNotifications()
//                loadData()
//                
//                if let lastDate = lastUpdatedDate,
//                   !Calendar.current.isDate(lastDate, inSameDayAs: Date()) {
//                    incrementPushUps()
//                }
//            }
//        }
//    }
//    
//    func incrementPushUps() {
//        currentDay += 1
//        saveData()
//        Task {
//            await scheduleNotifications()
//        }
//    }
//    
//    func saveData() {
//            UserDefaults.standard.set(currentDay, forKey: "currentDay")
//            UserDefaults.standard.set(pushUpsForToday, forKey: "pushUpsForToday")
//            UserDefaults.standard.set(Date(), forKey: "lastUpdatedDate")
//        }
//        
//    func loadData() {
//        if let savedDay = UserDefaults.standard.value(forKey: "currentDay") as? Int,
//               let savedDate = UserDefaults.standard.value(forKey: "lastUpdatedDate") as? Date {
//                currentDay = savedDay
//                lastUpdatedDate = savedDate
//            }
//    }
//}
//
//
//
//struct PushUpView: View {
//    @Binding var pushUps: Int
//    
//    var body: some View {
//        VStack {
//            Text("\(pushUps)")
//                .font(.system(size: 100))
//            NavigationLink("I'm Done", destination: WellDoneView())
//        }
//    }
//}
//
//struct WellDoneView: View {
//    var body: some View {
//        // For the GIF, you could use a WebView or other methods to display it
//        Text("Well Done!")
//    }
//}
//
//func requestNotificationPermission() async {
//    do {
//        let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound])
//        if granted {
//            // Schedule notifications here
//        }
//    } catch {
//        // Handle error
//    }
//}
//
//func scheduleNotifications() async {
//    let content = UNMutableNotificationContent()
//    content.title = "Time for Push-Ups!"
//    content.body = "Do X push-ups now."
//    let repeatCycle = 60 * 60 * 2.5
//    //let repeatCycleTest = 60
//    
//    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(repeatCycle), repeats: true)
//    
//    let request = UNNotificationRequest(identifier: "PushUpID", content: content, trigger: trigger)
//    
//    do {
//        try await UNUserNotificationCenter.current().add(request)
//    } catch {
//        // Handle error
//    }
//}
//
//
//#Preview {
//    ContentView()
//}
