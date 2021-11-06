//
//  MainMenu.swift
//  SmartCoach
//
//  Created by Yonah Goldberg on 5/20/21.
// MAKE BUTTON IN TRAININGPLANROW

import SwiftUI

struct MainMenu: View {
    @EnvironmentObject var data: AppData
    @State var showView = false
    @AppStorage("appStorage") var appStorage: Data = Data()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(data.trainingPlans) { trainingPlan in
                    HStack {
                        NavigationLink(destination: TrainingPlanInformation(trainingPlan: trainingPlan)) {
                            TrainingPlanRow(trainingPlan: trainingPlan)
                        }
                    }
                }
            }
            .navigationBarItems(
                leading: Text("Smart Coach").font(.title),
                trailing:
                    HStack {
                        NavigationLink(destination: CreateTrainingPlanMenu(), isActive: $showView) {
                        Image(systemName: "plus.square")
                            .imageScale(.large)
                        }
                        .padding()
                        NavigationLink(destination: AppInformationView()) {
                            Image(systemName: "questionmark.square")
                                .imageScale(.large)
                        }
                    }
            )
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear(perform: loadPlans)
    }
    
    func loadPlans() {
        do {
            let trainingPlans = try JSONDecoder().decode(TrainingPlans.self, from: appStorage)
            data.trainingPlans = trainingPlans.getPlans()
        } catch {
            print("ERROR")
        }
    }
    
}

struct StaticHighPriorityButtonStyle: PrimitiveButtonStyle {
    func makeBody(configuration: PrimitiveButtonStyle.Configuration) -> some View {
        let gesture = TapGesture()
            .onEnded { _ in configuration.trigger() }
        
        return configuration.label
            .highPriorityGesture(gesture)
    }
}

struct MainMenu_Previews: PreviewProvider {
    static var previews: some View {
        MainMenu()
            .environmentObject(AppData())
    }
}
