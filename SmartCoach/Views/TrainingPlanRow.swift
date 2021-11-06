//
//  TrainingPlanRow.swift
//  SmartCoach
//
//  Created by Yonah Goldberg on 5/30/21.
//

import SwiftUI

struct TrainingPlanRow: View {
    @EnvironmentObject var data: AppData
    @State private var alertIsPresented = false
    @AppStorage("appStorage") var appStorage: Data = Data()
    
    var trainingPlan: TrainingPlan
    let raceDate: String
    
    init(trainingPlan: TrainingPlan) {
        self.trainingPlan = trainingPlan
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        raceDate = formatter.string(from: trainingPlan.raceDate)
    }

    var body: some View {
        HStack {
            VStack {
                if trainingPlan.raceName == "" {
                    Text("Training Plan")
                        .font(.title2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                }
                else {
                    Text(trainingPlan.raceName)
                        .font(.title2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                }
                Text("Race Distance: \(trainingPlan.raceDistance.rawValue)")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
            }
            Text("\(raceDate)")
                .padding()
            Button(action: {alertIsPresented = true}, label: {
                Image(systemName: "minus.square")
                    .foregroundColor(.red)
                    .imageScale(.large)
            })
            .buttonStyle(StaticHighPriorityButtonStyle())
            .alert(isPresented: $alertIsPresented, content: {
                Alert(title: Text("Deleting This Plan"), message: Text("Are you sure you want to delete this training plan? Once you do it can not be recovered"), primaryButton: .default(Text("Yes"), action: {
                    withAnimation(.easeOut) {
                        removeTrainingPlan()
                    }
                }), secondaryButton: .cancel())
            })
        }
    }
    
    private func removeTrainingPlan() {
        for i in 0..<data.trainingPlans.count {
            if trainingPlan.id == data.trainingPlans[i].id {
                data.trainingPlans.remove(at: i)
                
                if data.trainingPlans.count == 0 {
                    appStorage = Data()
                }
                if data.trainingPlans.count == 1 {
                    let trainingPlans = try! JSONEncoder().encode(TrainingPlans(one: data.trainingPlans[0]))
                    appStorage = trainingPlans
                }
                else if data.trainingPlans.count == 2 {
                    let trainingPlans = try! JSONEncoder().encode(TrainingPlans(one: data.trainingPlans[0], two: data.trainingPlans[1]))
                    appStorage = trainingPlans
                }
                else if data.trainingPlans.count == 3 {
                    let trainingPlans = try! JSONEncoder().encode(TrainingPlans(one: data.trainingPlans[0], two: data.trainingPlans[1], three: data.trainingPlans[2]))
                    appStorage = trainingPlans
                }
                else if data.trainingPlans.count == 4 {
                    let trainingPlans = try! JSONEncoder().encode(TrainingPlans(one: data.trainingPlans[0], two: data.trainingPlans[1], three: data.trainingPlans[2], four: data.trainingPlans[3]))
                    appStorage = trainingPlans
                }
                
                break;
            }
        }
    }
    
}

struct TrainingPlanRow_Previews: PreviewProvider {
    static var previews: some View {
        TrainingPlanRow(trainingPlan: TrainingPlan(startDate: Date(), id: UUID(), raceName: "Boston Marathon", raceDistance: Distance.marathon, raceDate: Date(), recentRaceDistance: Distance.halfMarathon, recentRaceTime: 0, startingMilesPerWeek: 0, planDifficulty: PlanDifficulty.hard, numDays: 10, numWeeks: 10, trainingPlanWeeks: [TrainingPlanWeek(startDate: Date(), miles: 0, weekType: WeekType.rest, weekNum: 1, trainingPlanDays: [TrainingPlanDay(pace: 500, totalMiles: 7, runType: Run.easy, date: Date(), warmUp: 2, coolDown: 2, numRepeatsOrTempoMiles: 2)])]))
            .environmentObject(AppData())
    }
}
