//
//  TrainingPlanInformation.swift
//  SmartCoach
//
//  Created by Yonah Goldberg on 5/31/21.
//

import SwiftUI

struct TrainingPlanInformation: View {
    var trainingPlan: TrainingPlan
    
    var body: some View {
            TabView {
                ForEach(trainingPlan.trainingPlanWeeks) { trainingPlanWeek in
                    TrainingPlanWeekView(trainingPlanWeek: trainingPlanWeek)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
            .navigationBarTitle(getTrainingPlanName())
            .navigationBarTitleDisplayMode(.inline)
        }
     
    
    func getTrainingPlanName() -> String {
        if trainingPlan.raceName == "" {
            return "Training Plan"
        }
        return "\(trainingPlan.raceName) Training Plan"
    }
}

struct TrainingPlanInformation_Previews: PreviewProvider {
    static var previews: some View {
        TrainingPlanInformation(trainingPlan: TrainingPlan(startDate: Date(), id: UUID(), raceName: "Boston Marathon", raceDistance: Distance.marathon, raceDate: Date(), recentRaceDistance: Distance.halfMarathon, recentRaceTime: 0, startingMilesPerWeek: 0, planDifficulty: PlanDifficulty.hard, numDays: 10, numWeeks: 10, trainingPlanWeeks: [TrainingPlanWeek(startDate: Date(), miles: 0, weekType: WeekType.rest, weekNum: 1, trainingPlanDays: [TrainingPlanDay(pace: 500, totalMiles: 7, runType: Run.tempo, date: Date(), warmUp: 2, coolDown: 2, numRepeatsOrTempoMiles: 2), TrainingPlanDay(pace: 500, totalMiles: 7, runType: Run.easy, date: Date(), warmUp: 2, coolDown: 2, numRepeatsOrTempoMiles: 2), TrainingPlanDay(pace: 500, totalMiles: 7, runType: Run.easy, date: Date(), warmUp: 2, coolDown: 2, numRepeatsOrTempoMiles: 2), TrainingPlanDay(pace: 500, totalMiles: 7, runType: Run.easy, date: Date(), warmUp: 2, coolDown: 2, numRepeatsOrTempoMiles: 2)]), TrainingPlanWeek(startDate: Date(), miles: 0, weekType: WeekType.rest, weekNum: 2, trainingPlanDays: [TrainingPlanDay(pace: 500, totalMiles: 7, runType: Run.easy, date: Date(), warmUp: 2, coolDown: 2, numRepeatsOrTempoMiles: 2), TrainingPlanDay(pace: 500, totalMiles: 7, runType: Run.easy, date: Date(), warmUp: 2, coolDown: 2, numRepeatsOrTempoMiles: 2), TrainingPlanDay(pace: 500, totalMiles: 7, runType: Run.easy, date: Date(), warmUp: 2, coolDown: 2, numRepeatsOrTempoMiles: 2), TrainingPlanDay(pace: 500, totalMiles: 7, runType: Run.easy, date: Date(), warmUp: 2, coolDown: 2, numRepeatsOrTempoMiles: 2)])]))
    }
}


