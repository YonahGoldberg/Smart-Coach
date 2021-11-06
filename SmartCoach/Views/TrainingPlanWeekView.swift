//
//  TrainingPlanWeekView.swift
//  SmartCoach
//
//  Created by Yonah Goldberg on 7/8/21.
//

import SwiftUI

struct TrainingPlanWeekView: View {
    var trainingPlanWeek: TrainingPlanWeek
    var startDateString: String
    
    init(trainingPlanWeek: TrainingPlanWeek) {
        self.trainingPlanWeek = trainingPlanWeek
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        startDateString = formatter.string(from: trainingPlanWeek.startDate)
    }
    
    var body: some View {
        List {
            VStack {
                Text("Week \(trainingPlanWeek.weekNum)")
                    .font(.title2)
                Text("Total Mileage: \(trainingPlanWeek.miles)")
                    .font(.title3)
                Text((trainingPlanWeek.weekType.toString()))
                    .font(.title3)
            }
            .font(.title2)
            .padding(.vertical, 2)
            .frame(maxWidth: .infinity, alignment: .center)
            
            ForEach(trainingPlanWeek.trainingPlanDays) { trainingPlanDay in
                TrainingPlanDayView(trainingPlanDay: trainingPlanDay)
            }
        }
    }
}

struct TrainingPlanWeekView_Previews: PreviewProvider {
    static var previews: some View {
        TrainingPlanWeekView(trainingPlanWeek: TrainingPlanWeek(startDate: Date(), miles: 0, weekType: WeekType.rest, weekNum: 1, trainingPlanDays: [TrainingPlanDay(pace: 500, totalMiles: 7, runType: Run.easy, date: Date(), warmUp: 2, coolDown: 2, numRepeatsOrTempoMiles: 2), TrainingPlanDay(pace: 500, totalMiles: 7, runType: Run.easy, date: Date(), warmUp: 2, coolDown: 2, numRepeatsOrTempoMiles: 2), TrainingPlanDay(pace: 500, totalMiles: 7, runType: Run.easy, date: Date(), warmUp: 2, coolDown: 2, numRepeatsOrTempoMiles: 2), TrainingPlanDay(pace: 500, totalMiles: 7, runType: Run.easy, date: Date(), warmUp: 2, coolDown: 2, numRepeatsOrTempoMiles: 2)]))
    }
}
