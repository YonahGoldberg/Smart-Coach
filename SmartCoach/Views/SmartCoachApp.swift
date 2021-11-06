//
//  SmartCoachApp.swift
//  SmartCoach
//
//  Created by Yonah Goldberg on 5/20/21.
//

import SwiftUI


@main
struct SmartCoachApp: App {
    
    @StateObject var data = AppData()
    var body: some Scene {
        
        
        WindowGroup {
            MainMenu()
                .environmentObject(data)
        }
        
        
    }
}
