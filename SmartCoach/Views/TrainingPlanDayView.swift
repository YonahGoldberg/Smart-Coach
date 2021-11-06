//
//  TrainingPlanDayView.swift
//  SmartCoach
//
//  Created by Yonah Goldberg on 7/7/21.
//

import SwiftUI

struct TrainingPlanDayView: View {
    var trainingPlanDay: TrainingPlanDay
    var formattedPace: String
    var dateString: String
    
    init(trainingPlanDay: TrainingPlanDay) {
        self.trainingPlanDay = trainingPlanDay
        formattedPace = formatPace(pace: trainingPlanDay.pace)
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        dateString = formatter.string(from: trainingPlanDay.date)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(dateString)
                .font(.title3)
                //.padding(.vertical, 2)
            Text(trainingPlanDay.runType.rawValue)
            
            if trainingPlanDay.runType == Run.rest {
                Text("No run")
            }
            else if trainingPlanDay.runType == Run.easy || trainingPlanDay.runType == Run.longRun {
                Text("\(trainingPlanDay.totalMiles) miles @ \(formattedPace)")
            }
            else if trainingPlanDay.runType == Run.tempo {
                Text("Easy \(trainingPlanDay.warmUp) mile warm up")
                Text("\(trainingPlanDay.numRepeatsOrTempoMiles) mile tempo @ \(formattedPace)")
                Text("Easy \(trainingPlanDay.coolDown) mile cool down")
            }
            else if trainingPlanDay.runType == Run.race {
                Text("Warm up as needed")
                Text("\(trainingPlanDay.totalMiles) mile race")
                Text("Cool down as needed")
            }
            else {
                Text("Easy \(trainingPlanDay.warmUp) mile warm up")
                if trainingPlanDay.runType == Run.repeat16 {
                    Text("\(trainingPlanDay.numRepeatsOrTempoMiles) x 1600 @ \(formattedPace)")
                }
                else {
                    Text("\(trainingPlanDay.numRepeatsOrTempoMiles) x 800 @ \(formattedPace)")
                }
                Text("Easy \(trainingPlanDay.coolDown) mile cool down")
            }
        }
        //.padding(5)
        //.foregroundColor(.black)
        //.background(RoundedRectangle(cornerRadius: 15, style: .continuous).fill(Color.white).shadow(color: .blue, radius: 10))
    }
}

struct TrainingPlanDayView_Previews: PreviewProvider {
    static var previews: some View {
        TrainingPlanDayView(trainingPlanDay: TrainingPlanDay(pace: 500, totalMiles: 7, runType: Run.repeat16, date: Date(), warmUp: 2, coolDown: 2, numRepeatsOrTempoMiles: 2))
    }
}

//Takes in pace as seconds/mile and returns it as a string displaying it in minutes/mile
func formatPace(pace: Int) -> String {
    let minutes = String(pace / 60)
    var seconds = String(pace % 60)
    if seconds == "0" {
        seconds = "00"
    }
    else if seconds == "1" {
        seconds = "01"
    }
    else if seconds == "2" {
        seconds = "02"
    }
    else if seconds == "3" {
        seconds = "03"
    }
    else if seconds == "4" {
        seconds = "04"
    }
    else if seconds == "5" {
        seconds = "05"
    }
    else if seconds == "6" {
        seconds = "06"
    }
    else if seconds == "7" {
        seconds = "07"
    }
    else if seconds == "8" {
        seconds = "08"
    }
    else if seconds == "9" {
        seconds = "09"
    }
    return "\(minutes):\(seconds) mile pace"
}
