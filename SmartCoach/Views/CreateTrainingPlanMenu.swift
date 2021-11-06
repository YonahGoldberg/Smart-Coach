//
//  CreateTrainingPlanMenu.swift
//  SmartCoach
//
//  Created by Yonah Goldberg on 5/20/21.
//

import SwiftUI

struct CreateTrainingPlanMenu: View {
    var marathonDateRange: ClosedRange<Date> = Date()...Date()
    var nonMarathonDateRange: ClosedRange<Date> = Date()...Date()
    
    @AppStorage("appStorage") var appStorage: Data = Data()
    @EnvironmentObject var data: AppData
    @Environment(\.presentationMode) var presentationMode
    @State private var raceName: String = ""
    @State private var raceDistance: Distance = Distance.marathon
    @State private var recentRaceDistance: Distance = Distance.marathon
    //[hours, minutes, seconds]
    @State private var recentRaceTime: [Int] = [0, 0, 0]
    @State private var difficulty: PlanDifficulty = PlanDifficulty.medium
    @State private var currentMilesPerWeek: Int = 6
    @State private var startDate: Date = Date()
    @State private var raceDate: Date = Calendar.current.date(byAdding: .day, value: 21, to: Date())!
    @State private var alertIsPresented = false

    init() {
        let today: Date = Date()
        self.marathonDateRange = {
            let fourWeeksFromNow = Calendar.current.date(byAdding: .day, value: 28, to: today)!
            let sixteenWeeksFromNow = Calendar.current.date(byAdding: .day, value: 112, to: today)!
            return fourWeeksFromNow...sixteenWeeksFromNow
        }()
        
        self.nonMarathonDateRange = {
            let twoWeeksFromNow = Calendar.current.date(byAdding: .day, value: 14, to: today)!
            let sixteenWeeksFromNow = Calendar.current.date(byAdding: .day, value: 112, to: today)!
            return twoWeeksFromNow...sixteenWeeksFromNow
        }()
    }
    
    var body: some View {
        Form {
            Section(header: Text("Race You Are Training For")) {
                TextField("Name", text: $raceName)
                Picker(selection: $raceDistance, label:
                    Text("Distance")) {
                    Group {
                        Text(Distance.threeMiles.rawValue).tag(Distance.threeMiles)
                        Text(Distance.fiveKilometers.rawValue).tag(Distance.fiveKilometers)
                        Text(Distance.eightKilometers.rawValue).tag(Distance.eightKilometers)
                        Text(Distance.fiveMiles.rawValue).tag(Distance.fiveMiles)
                        Text(Distance.sixMiles.rawValue).tag(Distance.sixMiles)
                        Text(Distance.tenKilometers.rawValue).tag(Distance.tenKilometers)
                        Text(Distance.twelveKilometers.rawValue).tag(Distance.twelveKilometers)
                        Text(Distance.fifteenKilometers.rawValue).tag(Distance.fifteenKilometers)
                        Text(Distance.tenMiles.rawValue).tag(Distance.tenMiles)
                    }
                    Text(Distance.twentyKilometers.rawValue).tag(Distance.twelveKilometers)
                    Text(Distance.halfMarathon.rawValue).tag(Distance.halfMarathon)
                    Text(Distance.marathon.rawValue).tag(Distance.marathon)
                }
                DatePicker("Race Date (If you choose a marathon training plan it must be between 4 and 16 weeks from now. Otherwise, it must be between 2 and 16 weeks from now.)", selection: $raceDate, in: getDateRange(), displayedComponents: [.date])
            }
            
            Section(header: Text("Recent Race To Indicate Current Fitness")) {
                Picker(selection: $recentRaceDistance, label: Text("Distance")) {
                    ForEach(Distance.allCases) { distance in
                        Text(distance.rawValue)
                    }
                }
                VStack {
                    Stepper(value: $recentRaceTime[0], in: 0...59) {
                        HStack {
                            Text("Race Time: \(formatTime(time: recentRaceTime[0])):\(formatTime(time: recentRaceTime[1])):\(formatTime(time: recentRaceTime[2]))")
                            Spacer()
                            Text("hr")
                        }
                    }
                    Stepper(value: $recentRaceTime[1], in: 0...59) {
                        Spacer()
                            .frame(maxWidth: 500)
                        Text("min")
                    }
                    Stepper(value: $recentRaceTime[2], in: 0...59) {
                        Spacer()
                            .frame(maxWidth: 500)
                        Text("sec")
                    }
                }
            }
            Section(header: Text("Other Information")) {
                Picker(selection: $difficulty, label: Text("How Hard Do You Want To Train? (Note: We suggest you select Medium, which actually becomes quite ambitious after a few weeks.)")) {
                    ForEach(PlanDifficulty.allCases) { planDifficulty in
                        Text(planDifficulty.rawValue)
                    }
                }
                Stepper(value: $currentMilesPerWeek, in: 6...60) {
                    Text("Current Weekly Mileage (Note: for marathon plans you should ideally have already built up to at least 11 miles a week before creating a plan.)")
                    
                    Text("\(currentMilesPerWeek) miles")
                }
            }
            Button("Create Training Plan") {
                if data.trainingPlans.count < 5 {
                    
                    data.trainingPlans.append(TrainingPlanCreator().createTrainingPlan(raceName: raceName, raceDistance: raceDistance, raceDate: raceDate, recentRaceDistance: recentRaceDistance, recentRaceTime: recentRaceTime[0]*3600 + recentRaceTime[1]*60 + recentRaceTime[2], startingMilesPerWeek: currentMilesPerWeek, planDifficulty: difficulty, startDate: startDate, index: data.trainingPlans.count))
                    
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
                    else if data.trainingPlans.count == 5 {
                        let trainingPlans = try! JSONEncoder().encode(TrainingPlans(one: data.trainingPlans[0], two: data.trainingPlans[1], three: data.trainingPlans[2], four: data.trainingPlans[3], five: data.trainingPlans[4]))
                        appStorage = trainingPlans
                    }
                
                    self.presentationMode.wrappedValue.dismiss()
                }
                else {
                    alertIsPresented = true
                }
            }
            .alert(isPresented: $alertIsPresented) {
                Alert(title: Text("Can Not Create Training Plan"), message: Text("You can only have five training plans at a time. Delete one to create another."), dismissButton: .cancel())
            }
        }
    }
    
    
    func formatTime(time: Int) -> String {
        if time / 10 == 0 {
            return "0\(time)"
        }
        else {
            return "\(time)"
        }
    }
    func getDateRange() -> ClosedRange<Date> {
        if raceDistance == Distance.marathon {
            return marathonDateRange
        }
        else {
            return nonMarathonDateRange
        }
    }
}

struct CreateTrainingPlanMenu_Previews: PreviewProvider {
    static var previews: some View {
        CreateTrainingPlanMenu()
            .environmentObject(AppData())
    }
}
