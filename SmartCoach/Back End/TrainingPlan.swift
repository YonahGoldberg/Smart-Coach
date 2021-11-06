//
//  TrainingPlan.swift
//  SmartCoach
//
//  Created by Yonah Goldberg on 5/20/21.
//

import Foundation

enum Distance: String, Identifiable, CaseIterable, Codable {
    var id: Self { self }
    //Not race distances in the plan, only for the purpose of conversions
    case eightHundredMeters = "800 Meters"
    case fifteenHundredMeters = "1500 Meters"
    case mile = "1 Mile"
    case threeKilometers = "3000 Meters"
    case twoMiles = "Two Miles"
    //-------
    
    //part of the 5k training plan
    case threeMiles = "Three Miles"
    case fiveKilometers = "Five Kilometers"
    case eightKilometers = "Eight Kilometers"
    case fiveMiles = "Five Miles"
    case sixMiles = "Six Miles"
    case tenKilometers = "Ten Kilometers"
    case twelveKilometers = "Twelve Kilometers"
    //-------
    
    //part of the half marathon training plan
    case fifteenKilometers = "Fifteen Kilometers"
    case tenMiles = "Ten Miles"
    case twentyKilometers = "Twenty Kilometers"
    case halfMarathon = "Half Marathon"
    //-------
    
    //part of the marathon training plan
    case marathon = "Marathon"
    
    //returns equivalent fraction of 5k pace
    func get5kPaceFraction() -> Double {
        switch self {
        case .eightHundredMeters: return 0.5
        case .fifteenHundredMeters: return 0.89
        case .mile: return 0.9
        case .threeKilometers: return 0.95
        case .twoMiles: return 0.952
        case .threeMiles: return 0.99
        case .fiveKilometers: return 1.0
        case .eightKilometers: return 1.02
        case .fiveMiles: return 1.021
        case .sixMiles: return 1.03
        case .tenKilometers: return 1.032
        case .twelveKilometers: return 1.04
        case .fifteenKilometers: return 1.07
        case .tenMiles: return 1.072
        case .twentyKilometers: return 1.09
        case .halfMarathon: return 1.092
        case .marathon: return 1.15
        }
    }
    //returns distance in miles
    func getDistance() -> Double {
        switch self {
        case .eightHundredMeters: return 0.5
        case .fifteenHundredMeters: return 0.93
        case .mile: return 1.0
        case .threeKilometers: return 1.86
        case .twoMiles: return 2.0
        case .threeMiles: return 3.0
        case .fiveKilometers: return 3.11
        case .eightKilometers: return 4.97
        case .fiveMiles: return 5.0
        case .sixMiles: return 5.0
        case .tenKilometers: return 6.21
        case .twelveKilometers: return 7.46
        case .fifteenKilometers: return 9.32
        case .tenMiles: return 10
        case .twentyKilometers: return 12.43
        case .halfMarathon: return 13.11
        case .marathon: return 26.22
        }
    }
}

enum PlanDifficulty: String, Identifiable, CaseIterable, Codable {
    var id: Self { self }
    
    case medium = "Medium"
    case hard = "Hard"
    case veryHard = "Very Hard"
}

//Rest weeks see a reduction in mileage in the middle of the plan, taper weeks drop mileage and sharpen
//the runner before the race. The number after taper corresponds to the number of weeks out from the race.
//It goes taper 3, then taper 2, then taper 1. Some training plans may only have 1 taper week and some may have multiple.
enum WeekType: String, Codable {
    case normal = "normal"
    case rest = "rest"
    case taper1 = "taper1"
    case taper2 = "taper2"
    case taper3 = "taper3"
    case raceWeek = "raceWeek"
    
    func toString() -> String {
        switch self {
            case .normal: return "Normal Week"
            case .rest: return "Rest Week"
            case .taper1: return "Taper Week"
            case .taper2: return "Taper Week"
            case .taper3: return "Taper Week"
            case .raceWeek: return "Race Week"
        }
    }
}

enum Run: String, Codable {
    case tempo = "Tempo Run"
    case repeat16 = "1600 Meter Repeats"
    case repeat8 = "800 Meter Repeats"
    case easy = "Easy Run"
    case longRun = "Long Run"
    case rest = "Rest Day"
    case race = "Race Day"
}

struct TrainingPlan: Identifiable, Codable {
    //Instance variables
    var startDate: Date
    var id = UUID()
    var raceName: String
    var raceDistance: Distance
    var raceDate: Date
    var recentRaceDistance: Distance
    var recentRaceTime: Int // In seconds
    var startingMilesPerWeek: Int
    var planDifficulty: PlanDifficulty
    var numDays: Int
    //Cannot exceed 16. If this is a marathon training plan there must be a minimum of 3 weeks, otherwise there is a minimum of 2 weeks.
    var numWeeks: Int
    var trainingPlanWeeks: [TrainingPlanWeek]
    
    //Computed variables
    var todayDate: Date {
        return Date()
    }
    var dayNum: Int {
        return Int((todayDate.timeIntervalSince(startDate) / 86400))
    }
}


struct TrainingPlanWeek: Identifiable, Codable {
    var startDate: Date
    var id = UUID()
    var miles: Int
    var weekType: WeekType
    var weekNum: Int
    var trainingPlanDays: [TrainingPlanDay]
}

struct TrainingPlanDay: Identifiable, Codable {
    var id = UUID()
    //seconds/mile
    var pace: Int
    var totalMiles: Int
    var runType: Run
    var date: Date
    
    //WorkoutDays
    var warmUp: Int
    var coolDown: Int
    var numRepeatsOrTempoMiles: Int
}

//Precondition: startingMilesPerWeek > 5, recentRaceTime is in seconds
                
struct TrainingPlanCreator {
    func createTrainingPlan(raceName: String, raceDistance: Distance, raceDate: Date, recentRaceDistance: Distance, recentRaceTime: Int, startingMilesPerWeek: Int, planDifficulty: PlanDifficulty, startDate: Date, index: Int) -> TrainingPlan {
        
        //1 is Sunday... 7 is Saturday
        let startDateDay: Int = Calendar.current.component(.weekday, from: startDate)
        
        let raceDateDay: Int = Calendar.current.component(.weekday, from: raceDate)
        
        let numDays = Calendar.current.dateComponents([.day], from: startDate, to: raceDate).day!

        //Bulk of plan is calculated with a week starting on Sunday and ending on Saturday. If the user starts the plan on a day that is not Sunday "beginningAddedDays" is added before the bulk of the plan.
        let numBeginningAddedDays: Int
        
        if startDateDay == 1 {
            numBeginningAddedDays = 0
        }
        else {
            //dateComponents returns a number, 1 being sunday... 7 is saturday. For example if startdate is a monday we have 8 - 2 = 6 and it is true that there are 6 days we want to add (mon, tues, wed, thurs, fri, sat)
            numBeginningAddedDays = 8 - startDateDay
        }
        
        let startDateAfterBeginningAddedDays = Calendar.current.date(byAdding: .day, value: numBeginningAddedDays, to: startDate)!
        
        let numEndingAddedDays: Int
        
        if raceDateDay == 1 {
            numEndingAddedDays = 0
        }
        else {
            var lastSunday: Date = startDate // just a start point to increment
            for day in 0..<numDays {
                let dayDate: Date = Calendar.current.date(byAdding: .day, value: day, to: startDate)!
                if (Calendar.current.component(.weekday, from: dayDate) == 1) {
                    lastSunday = dayDate
                }
            }
            numEndingAddedDays = Calendar.current.dateComponents([.day], from: lastSunday, to: raceDate).day!
        }
        
        //This is the bulk of the training plan with weeks starting on sunday and ending saturday
        let numFullWeeks = (numDays - numBeginningAddedDays - numEndingAddedDays) / 7
        
        print(numDays)
        print(numFullWeeks)
        print(numBeginningAddedDays)
        print(numEndingAddedDays)
        //an array of weekTypes with a length equal to the numWeeks of the plan
        let weekTypes: [WeekType] = getWeekTypes(numWeeks: numFullWeeks, raceDistance: raceDistance)
        
        //An array of workouts, the index being the weeknum. There is one workout a week.
        let workouts: [Run] = getWorkouts(raceDistance: raceDistance, weekTypes: weekTypes)
        
        //An array of the number of repeats of a repeat workout or miles of a tempo in the same
        //order as the workouts array. AKA the index of the array represents the week the workout run is on.
        let workoutNumRepeatsOrMiles = getWorkoutNumRepeatsOrNumMiles(workouts: workouts, startingMilesPerWeek: startingMilesPerWeek, raceDistance: raceDistance, weekTypes: weekTypes)
        
        //An array containing the total mileage of each workout every week, which is essentially the workout mileage + warm up + cool down + any jogs expected between repeats. One workout a week. Index is weeknum.
        let workoutTotalMileages = getWorkoutTotalMileages(workouts: workouts, workoutNumRepeatsOrMiles: workoutNumRepeatsOrMiles)
        
        //an array of ints representing the week's mileage. The index of the array represents the weeknum.
        var weeklyMileage = getWeeklyMileage(numWeeks: numFullWeeks, startingMilesPerWeek: startingMilesPerWeek, planDifficulty: planDifficulty, workouts: workouts, workoutNumRepeatsOrMiles: workoutNumRepeatsOrMiles, weekTypes: weekTypes, raceDistance: raceDistance, workoutTotalMileages: workoutTotalMileages)
        
        //a 2D array, rows representing weeks and columns representing days.  Each index holds the type of run on the day.
        let runTypes = getRunTypes(weeklyMileage: weeklyMileage, raceDistance: raceDistance, weekTypes: weekTypes, workouts: workouts)
        
        //an array, index representing weeknum holding a numebr which represents the length of the week's long run.
        let longRunDistances: [Int] = getLongRunDistances(mpw: weeklyMileage, raceDistance: raceDistance, weekTypes: weekTypes)
        
        let runPaces = getRunPaces(runTypes: runTypes, planDifficulty: planDifficulty, recentRaceDistance: recentRaceDistance, recentRaceTime: recentRaceTime, numRepeatsOrMiles: workoutNumRepeatsOrMiles)
        
        var trainingPlanWeeks = [TrainingPlanWeek]()
        
        //Fill in incomplete week at beginning if plan does not start on sunday
        
        if startDateDay != 1 {
            
            var numFullWeekRuns: Int = 0
            var numIncompleteWeekRuns: Int = 0
            
            for day in 0..<7 {
                if runTypes[0][day] != Run.rest {
                    numFullWeekRuns+=1
                    if day >= startDateDay {
                        numIncompleteWeekRuns+=1
                    }
                }
            }
            let dailyMileage = startingMilesPerWeek / numFullWeekRuns
            var incompleteWeekTrainingPlanDays = [TrainingPlanDay]()
            
            for day in startDateDay-1..<7 {
                
                if runTypes[0][day] == Run.rest {
                    incompleteWeekTrainingPlanDays.append(TrainingPlanDay(pace: 0, totalMiles: 0, runType: Run.rest, date: Calendar.current.date(byAdding: .day, value: day - (startDateDay - 1), to: startDate)!, warmUp: 0, coolDown: 0, numRepeatsOrTempoMiles: 0))
                }
                else {
                    incompleteWeekTrainingPlanDays.append(TrainingPlanDay(pace: runPaces[0][0], totalMiles: dailyMileage, runType: Run.easy, date: Calendar.current.date(byAdding: .day, value: day - (startDateDay - 1), to: startDate)!, warmUp: 0, coolDown: 0, numRepeatsOrTempoMiles: 0))
                }
            }
            trainingPlanWeeks.append(TrainingPlanWeek(startDate: startDate, miles: (startingMilesPerWeek / numFullWeekRuns) * numIncompleteWeekRuns, weekType: WeekType.normal, weekNum: 0, trainingPlanDays: incompleteWeekTrainingPlanDays))
        }
       
        //----------------------------------------------------------------------------------
        //BULK OF PLAN
        for week in 0..<numFullWeeks {
            let milesMinusLrAndWorkout = weeklyMileage[week] - workoutTotalMileages[week] - longRunDistances[week]
            
            /*
            print("\(milesMinusLrAndWorkout) Miles-LongrunandWorkout")
            print("\(weeklyMileage[week]) weeklymileage[week]")
            print("\(workoutTotalMileages[week]) workouttotal")
            print("\(longRunDistances[week]) longrundistances")
            print(workouts[week].rawValue)
            print(workoutNumRepeatsOrMiles[week])
 */
            
            var numEasyRuns: Int = 0
            
            //Dealing with uneven mileage/day
            for day in 0..<7 {
                if runTypes[week][day] == Run.easy {
                    numEasyRuns += 1
                }
            }
            var unevenExtraMileage: Int
            var easyRunDays: [Int]
            if numEasyRuns == 0 {
                unevenExtraMileage = 0
                easyRunDays = []
            }
            else {
               unevenExtraMileage = milesMinusLrAndWorkout % numEasyRuns
                easyRunDays = Array(repeating: milesMinusLrAndWorkout / numEasyRuns, count: numEasyRuns)
            }
            
            var easyRunDaysIndex: Int = 0
            while unevenExtraMileage > 0 {
                easyRunDays[easyRunDaysIndex] += 1
                unevenExtraMileage-=1
                easyRunDaysIndex+=1
                if easyRunDaysIndex == easyRunDays.count {
                    easyRunDaysIndex = 0
                }
            }
            easyRunDaysIndex = 0
            
            var trainingPlanDays = [TrainingPlanDay]()
            for day in 0..<7 {
                if runTypes[week][day] == Run.rest {
                    trainingPlanDays.append(TrainingPlanDay(pace: 0, totalMiles: 0, runType: Run.rest, date: Calendar.current.date(byAdding: .day, value: week*7 + day, to: startDateAfterBeginningAddedDays)!, warmUp: 0, coolDown: 0, numRepeatsOrTempoMiles: 0))
                }
                else if runTypes[week][day] == Run.easy {
                        trainingPlanDays.append(TrainingPlanDay(pace: runPaces[week][day], totalMiles: easyRunDays[easyRunDaysIndex], runType: Run.easy, date: Calendar.current.date(byAdding: .day, value: week*7 + day, to: startDateAfterBeginningAddedDays)!, warmUp: 0, coolDown: 0, numRepeatsOrTempoMiles: 0))
                        easyRunDaysIndex+=1
                }
                else if runTypes[week][day] == Run.longRun {
                    trainingPlanDays.append(TrainingPlanDay(pace: runPaces[week][day], totalMiles: longRunDistances[week], runType: Run.longRun, date: Calendar.current.date(byAdding: .day, value: week*7 + day, to: startDateAfterBeginningAddedDays)!, warmUp: 0, coolDown: 0, numRepeatsOrTempoMiles: 0))
                }
                //workout
                else {
                    var warmUp: Int
                    var coolDown: Int
                    let warmUpAndCoolDownMileage = workoutTotalMileages[week] - workoutNumRepeatsOrMiles[week]
                    if warmUpAndCoolDownMileage % 2 == 0 {
                        warmUp = warmUpAndCoolDownMileage / 2
                        coolDown = warmUpAndCoolDownMileage / 2
                    }
                    else {
                        warmUp = warmUpAndCoolDownMileage / 2
                        coolDown = warmUpAndCoolDownMileage / 2 + 1
                    }
                    if warmUp == 0 {
                        warmUp+=1
                        weeklyMileage[week]+=1
                    }
                    trainingPlanDays.append(TrainingPlanDay(pace: runPaces[week][day], totalMiles: workoutTotalMileages[week], runType: runTypes[week][day], date: Calendar.current.date(byAdding: .day, value: week*7 + day, to: startDateAfterBeginningAddedDays)!, warmUp: warmUp, coolDown: coolDown, numRepeatsOrTempoMiles: workoutNumRepeatsOrMiles[week]))
                }
            }
            trainingPlanWeeks.append(TrainingPlanWeek(startDate: Calendar.current.date(byAdding: .day, value: week*7, to: startDateAfterBeginningAddedDays)!, miles: weeklyMileage[week], weekType: weekTypes[week], weekNum: week + 1, trainingPlanDays: trainingPlanDays))
        }
        
        // Adding incomplete week at the end (if race is not on a Sunday)
        //For now, daily mileage should be the same as taper1 week. Might need to shorten taper1 week in some cases just so aren't so many low mileage days at the end without any workouts.
        if raceDateDay != 1 {
            var numFullWeekRuns: Int = 0
            var numIncompleteWeekRuns: Int = 0
            
            for day in 0..<7 {
                if runTypes[numFullWeeks-1][day] != Run.rest {
                    numFullWeekRuns+=1
                    if day < raceDateDay {
                        numIncompleteWeekRuns+=1
                    }
                }
            }
            
            let dailyMileage = weeklyMileage[numFullWeeks-1] / numFullWeekRuns
            var incompleteWeekTrainingPlanDays = [TrainingPlanDay]()
            
            for day in 0..<raceDateDay - 2 {
                
                if runTypes[numFullWeeks-1][day] == Run.rest {
                    incompleteWeekTrainingPlanDays.append(TrainingPlanDay(pace: 0, totalMiles: 0, runType: Run.rest, date: Calendar.current.date(byAdding: .day, value: numFullWeeks*7 + day - (startDateDay - 1), to: startDate)!, warmUp: 0, coolDown: 0, numRepeatsOrTempoMiles: 0))
                }
                else {
                    incompleteWeekTrainingPlanDays.append(TrainingPlanDay(pace: runPaces[0][0], totalMiles: dailyMileage, runType: Run.easy, date: Calendar.current.date(byAdding: .day, value: numFullWeeks*7 + day - (startDateDay - 1), to: startDate)!, warmUp: 0, coolDown: 0, numRepeatsOrTempoMiles: 0))
                }
            }
            incompleteWeekTrainingPlanDays.append(TrainingPlanDay(pace: 0, totalMiles: 0, runType: Run.rest, date: Calendar.current.date(byAdding: .day, value: -1, to: raceDate)!, warmUp: 0, coolDown: 0, numRepeatsOrTempoMiles: 0))
            incompleteWeekTrainingPlanDays.append(TrainingPlanDay(pace: 0, totalMiles: Int(raceDistance.getDistance()), runType: Run.race, date: raceDate, warmUp: 0, coolDown: 0, numRepeatsOrTempoMiles: 0))
 
            trainingPlanWeeks.append(TrainingPlanWeek(startDate: Calendar.current.date(byAdding: .day, value: numFullWeeks*7, to: startDate)!, miles: (weeklyMileage[numFullWeeks-1] / numFullWeekRuns) * numIncompleteWeekRuns + Int(raceDistance.getDistance()), weekType: WeekType.raceWeek, weekNum: numFullWeeks + 1 , trainingPlanDays: incompleteWeekTrainingPlanDays))
        }
        else {
            trainingPlanWeeks.append(TrainingPlanWeek(startDate: Calendar.current.date(byAdding: .day, value: numFullWeeks*7 + numEndingAddedDays, to: startDate)!, miles: Int(raceDistance.getDistance()), weekType: WeekType.raceWeek, weekNum: numFullWeeks + 1, trainingPlanDays: [TrainingPlanDay(pace: 0, totalMiles: Int(raceDistance.getDistance()), runType: Run.race, date: raceDate, warmUp: 0, coolDown: 0, numRepeatsOrTempoMiles: 0)]))
        }
        
        return TrainingPlan(startDate: startDate, id: UUID(), raceName: raceName, raceDistance: raceDistance, raceDate: raceDate, recentRaceDistance: recentRaceDistance, recentRaceTime: recentRaceTime, startingMilesPerWeek: startingMilesPerWeek, planDifficulty: planDifficulty, numDays: numDays, numWeeks: numFullWeeks, trainingPlanWeeks: trainingPlanWeeks)
    }
    
    
    /*
     SC allows users to select Moderate-Hard-Very Hard training programs. These selections trigger
     rules pertaining to both mileage and pace.

     Weekly Miles: With Moderate, <30, miles increase 1 per week; 31+, 2 per week
     with Hard, <30, miles increase 2, 1, 2, R (50 percent Mara previous week, or 75 percent nonMara); 31+, 3, 2, 3, R
     with Very Hard: <30, miles increase 2, 1, 2, R (see just above); 31+, 3, 2, 3, R
     
     Returns an array of ints representing the week's mileage. The index of the array represents the weeknum.
 */
    private func getWeeklyMileage(numWeeks: Int, startingMilesPerWeek: Int, planDifficulty: PlanDifficulty, workouts: [Run], workoutNumRepeatsOrMiles: [Int], weekTypes: [WeekType], raceDistance: Distance, workoutTotalMileages: [Int]) -> [Int] {
        
        var mpw: [Int] = [startingMilesPerWeek]
        var mpwIncreaseIndex: Int = 0 // Oscilates between 0 and 1. Used in plans like marathon, hard, which will have mileage increase 2, 1, 2, 1, 2
        var weekIndex: Int = 1
        
        //Taper week mileage will be filled in after
        while weekTypes[weekIndex] == WeekType.normal || weekTypes[weekIndex] == WeekType.rest {
            
            //marathon week rest weeks have a larger decrease in mileage
            if weekTypes[weekIndex] == WeekType.rest {
                if raceDistance == Distance.marathon {
                    mpw.append(Int(0.5 * Double(mpw[weekIndex-1])))
                }
                else {
                    mpw.append(Int(0.75 * Double(mpw[weekIndex-1])))
                }
            }
            
            else if planDifficulty == PlanDifficulty.medium {
                if startingMilesPerWeek < 30 {
                    //If last week was a rest week increase mileage from 2 weeks ago to get this week's mileage
                    if weekTypes[weekIndex - 1] == WeekType.rest {
                        mpw.append(mpw[weekIndex - 2] + 1)
                    }
                    else {
                        mpw.append(mpw[weekIndex-1] + 1)
                    }
                }
                else {
                    if weekTypes[weekIndex - 1] == WeekType.rest {
                        mpw.append(mpw[weekIndex - 2] + 2)
                    }
                    else {
                        mpw.append(mpw[weekIndex-1] + 2)
                    }
                }
            }
            //hard and very hard training plans
            else {
                if startingMilesPerWeek < 30 {
                    if mpwIncreaseIndex == 0 {
                        if weekTypes[weekIndex - 1] == WeekType.rest {
                            mpw.append(mpw[weekIndex - 2] + 2)
                        }
                        else {
                            mpw.append(mpw[weekIndex-1] + 2)
                        }
                    }
                    else {
                        if weekTypes[weekIndex - 1] == WeekType.rest {
                            mpw.append(mpw[weekIndex - 2] + 1)
                        }
                        else {
                            mpw.append(mpw[weekIndex-1] + 1)
                        }
                    }
                }
                else {
                    if mpwIncreaseIndex == 0 {
                        if weekTypes[weekIndex - 1] == WeekType.rest {
                            mpw.append(mpw[weekIndex - 2] + 3)
                        }
                        else {
                            mpw.append(mpw[weekIndex-1] + 3)
                        }
                    }
                    else {
                        if weekTypes[weekIndex - 1] == WeekType.rest {
                            mpw.append(mpw[weekIndex - 2] + 2)
                        }
                        else {
                            mpw.append(mpw[weekIndex-1] + 2)
                        }
                    }
                }
            }
            
            weekIndex += 1
            if mpwIncreaseIndex == 0 {
                mpwIncreaseIndex = 1
            }
            else {
                mpwIncreaseIndex = 0
            }
        }
        
        //Dealing with taper weeks
        
        //FOR MARATHONS. Non marathons can't have taper3 and taper2 weeks
        if weekTypes[weekIndex] == WeekType.taper3 {
            mpw.append(Int(round(0.75 * Double(mpw[weekIndex-1]))))
            weekIndex += 1
            mpw.append(Int(round(0.75 * Double(mpw[weekIndex-1]))))
            weekIndex += 1
        }
        else if weekTypes[weekIndex] == WeekType.taper2 {
            mpw.append(Int(round(0.75 * Double(mpw[weekIndex-1]))))
            weekIndex += 1
        }
        
        if raceDistance == Distance.marathon {
            var taper1WeeklyMileage: Int = workoutTotalMileages[weekIndex]
            //add all the other days
            if startingMilesPerWeek < 21 {
                taper1WeeklyMileage += 4
            }
            else if startingMilesPerWeek < 40 {
                taper1WeeklyMileage += 6
            }
            else {
                taper1WeeklyMileage += 8
            }
            mpw.append(taper1WeeklyMileage)
        }
        //FOR NONMARATHONS
        else {
            var taper1WeeklyMileage: Int = workoutTotalMileages[weekIndex]
            //add all the other days
            if startingMilesPerWeek < 16 {
                taper1WeeklyMileage += 2
            }
            else if startingMilesPerWeek < 26 {
                taper1WeeklyMileage += 6
            }
            else if startingMilesPerWeek < 41 {
                taper1WeeklyMileage += 12
            }
            else {
                taper1WeeklyMileage += 15
            }
            mpw.append(taper1WeeklyMileage)
        }
        return mpw
    }
    
    /*
    Returns an array of the number of repeats of a repeat workout or miles of a tempo in the same
    order as the workouts array. AKA the index of the array represents the week the workout run is on.
 
    NonMarathon:
     These Workout Runs all have starting points as follows, based on original total miles/week:
     <30: 3 mi Tempo, 2 x 1600, 3 x 800
     31-45: 4 mi Tempo, 3 x 1600, 4 x 800
     46+: 5 mi Tempo, 4 x 1600, 5 x 800
     The length of the Tempo Runs increases by 1 mile/month
     The number of Repeat 1600s increases by 1/month
     The number of Repeat 800s increases by 1/month
    Marathon:
     These Workout Runs all have starting points as follows, based on original total miles/week:
     <30: 3 mi Tempo, 2 x 1600
     31-45: 4 mi Tempo, 3 x 1600
     46+: 5 mi Tempo, 4 x 1600
     The length of the Tempo Runs increases by 1 mile/month
     The number of Repeat 1600s increases by 1/month
 */


    private func getWorkoutNumRepeatsOrNumMiles(workouts: [Run], startingMilesPerWeek: Int, raceDistance: Distance, weekTypes: [WeekType]) -> [Int] {
        
        var numRepeatsOrMiles: [Int] = []
        var tempoMiles: Int
        var numRepeat8s: Int
        var numRepeat16s: Int
        
        if raceDistance == Distance.marathon {
            if startingMilesPerWeek < 30 {
                tempoMiles = 3
                numRepeat8s = 0 // No repeat8s in marathon plan
                numRepeat16s = 2
            }
            else if startingMilesPerWeek < 46 {
                tempoMiles = 4
                numRepeat8s = 0
                numRepeat16s = 3
            }
            else {
                tempoMiles = 5
                numRepeat8s = 0
                numRepeat16s = 4
            }
        }
        else {
            if startingMilesPerWeek < 30 {
                tempoMiles = 3
                numRepeat8s = 3
                numRepeat16s = 2
            }
            else if startingMilesPerWeek < 46 {
                tempoMiles = 4
                numRepeat8s = 4
                numRepeat16s = 3
            }
            else {
                tempoMiles = 5
                numRepeat8s = 5
                numRepeat16s = 4
            }
        }
        var i: Int = 0
        while weekTypes[i] == WeekType.normal || weekTypes[i] == WeekType.rest {
            if i % 4 == 0 && i != 0 {
                //marathon or half marathon plan
                if raceDistance == Distance.marathon || raceDistance == Distance.halfMarathon || raceDistance == Distance.fifteenKilometers || raceDistance == Distance.tenMiles || raceDistance == Distance.twentyKilometers {
                    tempoMiles += 1
                    numRepeat16s += 1
                }
                //5k plan
                else {
                    tempoMiles += 1
                    numRepeat16s += 1
                    numRepeat8s += 1
                }
            }
            
            if workouts[i] == Run.tempo {
                numRepeatsOrMiles.append(tempoMiles)
            }
            else if workouts[i] == Run.repeat16 {
                numRepeatsOrMiles.append(numRepeat16s)
            }
            else if workouts[i] == Run.repeat8 {
                numRepeatsOrMiles.append(numRepeat8s)
            }
            //workouts[i] == Run.easy
            else {
                numRepeatsOrMiles.append(0)
            }
            i += 1
        }
        
        //Dealing with taper weeks :)
        var lastRepeat16Index: Int = 0
        for i in 0..<workouts.count {
            if weekTypes[i] == WeekType.taper3 || weekTypes[i] == WeekType.taper2 || weekTypes[i] == WeekType.taper1 {
                break
            }
            if workouts[i] == Run.repeat16 {
                lastRepeat16Index = i
            }
        }
        
        //if there is a taper3 then it is a marathon plan and there is a taper2 and a taper 1, see weektype enum.
        if weekTypes[i] == WeekType.taper3 {
            numRepeatsOrMiles.append(numRepeatsOrMiles[lastRepeat16Index])
            numRepeatsOrMiles.append(numRepeatsOrMiles[2])
            numRepeatsOrMiles.append(numRepeatsOrMiles[0])
        }
        //if there is a taper 2 then it is a marathon plan and there is a taper 1
        else if weekTypes[i] == WeekType.taper2 {
            numRepeatsOrMiles.append(numRepeatsOrMiles[2])
            numRepeatsOrMiles.append(numRepeatsOrMiles[0])
        }
        //only a taper 1 could be marathon or nonmarathon. There is ALWAYS at least a taper 1
        else {
            numRepeatsOrMiles.append(numRepeatsOrMiles[0])
        }
        
        return numRepeatsOrMiles
    }
    
    /*
    MARATHON--16 WEEK TRAINING PLAN PROGRESSIONS, AND DATE LIMITED PLANS
    Current Marathon weeks where: n is a normal week; r is a rest week; and t weeks are taper weeks
    number after the taper represents the number of weeks away from the race.

    16> n1-2-3, r1, n4-5-6, r2, n7-8-9, r3, n10, t3, t2, t1
    15> n1-2-3-4, r1, n5-6-7, r2, n8-9-10, t3, t2, t1
    14> n1-2-3, r1, n4-5-6, r2, n7-8-9, t3, t2, t1
    13> n1-2-3, r1, n4-5-6, r2, n7-8-9, t2, t1
    12> n1-2-3-4-5, r1, n 6-7-8-9, t2, t1
    11> n1-2-3-4, r1, n5-6-7-8, t2, t1
    10> n1-2-3-4, r1, n5-6-7, t2, t1
    9> n1-2-3, r1, n4-5-6, t2, t1
    8> n1-2-3, r1, n4-5, t2, t1
    7> n1-2-3, r1, n4-5, t1
    6> n1-2-3-4-5, t1
    5> n1-2-3-4, t1
    4> n1-2-3, t1
    3>n1-2, t1

    nonMARATHON--16 WEEK TRAINING PLAN PROGRESSIONS, AND DATE LIMITED PLANS
    Current nonMarathon weeks:
    16> n123, r, n456, r, n789, r, n101112, t1
    15> n123, r, n456, r, n789, r, n1011, t1
    14> n1234, r, n5678, r, n91011, t1
    13> n1234, r, n567, r, n8910, t1
    12> n123, r, n456, r, n789, t1
    11> n12345, r, n6789, t1
    10> n1234, r, n5678, t1
    9> n1234, r, n567, t1
    8> n123, r, n456, t1
    7> n123, r, n45, t1
    6> n12345, t1
    5> n1234, t1
    4> n123, t1
    3> n12, t1
    2> n1, t1

    Returns an array of weekTypes with a length equal to the numWeeks of the plan
 */
    private func getWeekTypes(numWeeks: Int, raceDistance: Distance) -> [WeekType] {
        if raceDistance == Distance.marathon {
            if numWeeks == 16 {
                return [WeekType.normal, WeekType.normal, WeekType.normal, WeekType.rest, WeekType.normal, WeekType.normal, WeekType.normal, WeekType.rest, WeekType.normal, WeekType.normal, WeekType.normal, WeekType.rest, WeekType.normal, WeekType.taper3, WeekType.taper2, WeekType.taper1]
            }
            else if numWeeks == 15 {
                return [WeekType.normal, WeekType.normal, WeekType.normal, WeekType.normal, WeekType.rest, WeekType.normal, WeekType.normal, WeekType.normal, WeekType.rest, WeekType.normal, WeekType.normal, WeekType.normal, WeekType.taper3, WeekType.taper2, WeekType.taper1]
            }
            else if numWeeks == 14 {
                return [WeekType.normal, WeekType.normal, WeekType.normal, WeekType.rest, WeekType.normal, WeekType.normal, WeekType.normal, WeekType.rest, WeekType.normal, WeekType.normal, WeekType.normal, WeekType.taper3, WeekType.taper2, WeekType.taper1]
            }
            else if numWeeks == 13 {
                return [WeekType.normal, WeekType.normal, WeekType.normal, WeekType.rest, WeekType.normal, WeekType.normal, WeekType.normal, WeekType.rest, WeekType.normal, WeekType.normal, WeekType.normal, WeekType.taper2, WeekType.taper1]
            }
            else if numWeeks == 12 {
                return [WeekType.normal, WeekType.normal, WeekType.normal, WeekType.normal, WeekType.normal, WeekType.rest, WeekType.normal, WeekType.normal, WeekType.normal, WeekType.normal, WeekType.taper2, WeekType.taper1]
            }
            else if numWeeks == 11 {
                return [WeekType.normal, WeekType.normal, WeekType.normal, WeekType.normal, WeekType.rest, WeekType.normal, WeekType.normal, WeekType.normal, WeekType.normal, WeekType.taper2, WeekType.taper1]
            }
            else if numWeeks == 10 {
                return [WeekType.normal, WeekType.normal, WeekType.normal, WeekType.normal, WeekType.rest, WeekType.normal, WeekType.normal, WeekType.normal, WeekType.taper2, WeekType.taper1]
            }
            else if numWeeks == 9 {
                return [WeekType.normal, WeekType.normal, WeekType.normal, WeekType.rest, WeekType.normal, WeekType.normal, WeekType.normal, WeekType.taper2, WeekType.taper1]
            }
            else if numWeeks == 8 {
                return [WeekType.normal, WeekType.normal, WeekType.normal, WeekType.rest, WeekType.normal, WeekType.normal, WeekType.taper2, WeekType.taper1]
            }
            else if numWeeks == 7 {
                return [WeekType.normal, WeekType.normal, WeekType.normal, WeekType.rest, WeekType.normal, WeekType.normal, WeekType.taper1]
            }
            else if numWeeks == 6 {
                return [WeekType.normal, WeekType.normal, WeekType.normal, WeekType.normal, WeekType.normal, WeekType.taper1]
            }
            else if numWeeks == 5 {
                return [WeekType.normal, WeekType.rest, WeekType.normal, WeekType.normal, WeekType.taper1]
            }
            else if numWeeks == 4 {
                return [WeekType.rest, WeekType.normal, WeekType.normal, WeekType.taper1]
            }
            else {
                return [WeekType.normal, WeekType.normal, WeekType.taper1]
            }
        }
        else {
            if numWeeks == 16 {
                return [WeekType.normal, WeekType.normal, WeekType.normal, WeekType.rest, WeekType.normal, WeekType.normal, WeekType.normal, WeekType.rest, WeekType.normal, WeekType.normal, WeekType.normal, WeekType.rest, WeekType.normal, WeekType.normal, WeekType.normal, WeekType.taper1]
            }
            else if numWeeks == 15 {
                return [WeekType.normal, WeekType.normal, WeekType.normal, WeekType.rest, WeekType.normal, WeekType.normal, WeekType.normal, WeekType.rest, WeekType.normal, WeekType.normal, WeekType.normal, WeekType.rest, WeekType.normal, WeekType.normal, WeekType.taper1]
            }
            else if numWeeks == 14 {
                return [WeekType.normal, WeekType.normal, WeekType.normal, WeekType.normal, WeekType.rest, WeekType.normal, WeekType.normal, WeekType.normal, WeekType.normal, WeekType.rest, WeekType.normal, WeekType.normal, WeekType.normal, WeekType.taper1]
            }
            else if numWeeks == 13 {
                return [WeekType.normal, WeekType.normal, WeekType.normal, WeekType.normal, WeekType.rest, WeekType.normal, WeekType.normal, WeekType.normal, WeekType.rest, WeekType.normal, WeekType.normal, WeekType.normal, WeekType.taper1]
            }
            else if numWeeks == 12 {
                return [WeekType.normal, WeekType.normal, WeekType.normal, WeekType.rest, WeekType.normal, WeekType.normal, WeekType.normal, WeekType.rest, WeekType.normal, WeekType.normal, WeekType.normal, WeekType.taper1]
            }
            else if numWeeks == 11 {
                return [WeekType.normal, WeekType.normal, WeekType.normal, WeekType.normal, WeekType.normal, WeekType.rest, WeekType.normal, WeekType.normal, WeekType.normal, WeekType.normal, WeekType.taper1]
            }
            else if numWeeks == 10 {
                return [WeekType.normal, WeekType.normal, WeekType.normal, WeekType.normal, WeekType.rest, WeekType.normal, WeekType.normal, WeekType.normal, WeekType.normal, WeekType.taper1]
            }
            else if numWeeks == 9 {
                return [WeekType.normal, WeekType.normal, WeekType.normal, WeekType.normal, WeekType.rest, WeekType.normal, WeekType.normal, WeekType.normal, WeekType.taper1]
            }
            else if numWeeks == 8 {
                return [WeekType.normal, WeekType.normal, WeekType.normal, WeekType.rest, WeekType.normal, WeekType.normal, WeekType.normal, WeekType.taper1]
            }
            else if numWeeks == 7 {
                return [WeekType.normal, WeekType.normal, WeekType.normal, WeekType.rest, WeekType.normal, WeekType.normal, WeekType.taper1]
            }
            else if numWeeks == 6 {
                return [WeekType.normal, WeekType.normal, WeekType.normal, WeekType.normal, WeekType.normal, WeekType.taper1]
            }
            else if numWeeks == 5 {
                return [WeekType.normal, WeekType.rest, WeekType.normal, WeekType.normal, WeekType.taper1]
            }
            else if numWeeks == 4 {
                return [WeekType.rest, WeekType.normal, WeekType.normal, WeekType.taper1]
            }
            else if numWeeks == 3{
                return [WeekType.normal, WeekType.normal, WeekType.taper1]
            }
            else {
                return [WeekType.normal, WeekType.taper1]
            }
        }
    }
    /*
    All Marathon Programs include a Workout Run in midweek, either Tempo or Repeat 1600s.
    It follows this progression: Tempo Run, Repeat 1600s, Tempo Run; repeat
    
    All nonMarathon Programs include a Workout Run in midweek, either Tempo or Repeat 1600s or Repeat 800s.
    The 5K Program uses the progression: 800s, Tempo, 1600s;
    The Half M Program uses the progression: Tempo, 1600s, Tempo; --> same as marathon...
     
    Returns an array of workouts, the index being the weeknum. There is one workout a week.
 */

    private func getWorkouts(raceDistance: Distance, weekTypes: [WeekType]) -> [Run] {
        var order: [Run]
        //marathon or half marathon plan
        if raceDistance == Distance.marathon || raceDistance == Distance.halfMarathon || raceDistance == Distance.fifteenKilometers || raceDistance == Distance.tenMiles || raceDistance == Distance.twentyKilometers {
            order = [Run.tempo, Run.repeat16, Run.tempo]
        }
        //5k plan
        else {
            order = [Run.repeat8, Run.tempo, Run.repeat16]
        }
        
        var workouts: [Run] = []
        var weekIndex: Int = 0
        var orderIndex: Int = 0
        
        //Add week Workout runs until taper weeks
        while weekTypes[weekIndex] == WeekType.normal || weekTypes[weekIndex] == WeekType.rest  {
            if weekTypes[weekIndex] == WeekType.rest {
                workouts.append(Run.easy)
            }
            else {
                workouts.append(order[orderIndex])
                orderIndex+=1
                if orderIndex == 3 {
                    orderIndex = 0
                }
            }
            weekIndex+=1
        }
        
        //Add taper week Workout runs
        
        //Has to be a marathon plan to have more than one taper
        if(raceDistance == Distance.marathon) {
            if(weekTypes[weekIndex] == WeekType.taper3) {
                workouts.append(contentsOf: [Run.repeat16, workouts[2], workouts[0]])
            }
            else if(weekTypes[weekIndex] == WeekType.taper2) {
                workouts.append(contentsOf: [workouts[2], workouts[0]])
            }
            else {
                workouts.append(workouts[0])
            }
        }
        else {
            workouts.append(workouts[0])
        }
        
        return workouts
    }
    /*
     MARATHON--MILES PER WEEK AND TRAINING DAYS
     Marathon: the number of days of training per week remains the same throughout
     6-15: two days (Sun, Th)
     16-25: three days (Sun, Tu,Th)
     26-40: four days (Sun, Tu, Th, Fri)
     41-45: five days (Sun, Tu, Wed, Th, Fri)
     46+: six days (Sun, Tu, Wed, Th, Fri, Sat)

     nonMARATHON--MILES PER WEEK AND TRAINING DAYS
     nonMarathon: the number of days of training increases at certain mileage break points
     6-15: three days
     16-25: four days
     26-40: five days
     41+: six days
     
     returns a 2D array, rows representing weeks and columns representing days.  Each index holds the type of run on the day.
     */
    private func getRunTypes(weeklyMileage: [Int], raceDistance: Distance, weekTypes: [WeekType], workouts: [Run]) -> [[Run]] {
        var runTypes: [[Run]] = Array(repeating: Array(repeating: Run.rest, count: 7), count: weeklyMileage.count)
        
        //0 means no run, 1 means yes run
        var trainingPlanDays = [[Int]]()
        
        //holds the index of the workout/longrun for each week in the above 2D array. Theres 1 workout per week. If the array holds '69' it means there is no workout or longrun
        var workoutIndices = [Int]()
        var longRunIndices = [Int]()
        
        var marathonNonTaperDays = [Int]()
            
        if weeklyMileage[0] < 16 {
            marathonNonTaperDays = [1, 0, 0, 0, 1, 0, 0]
        }
        else if weeklyMileage[0] < 26 {
            marathonNonTaperDays = [1, 0, 1, 0, 1, 0, 0]
        }
        else if weeklyMileage[0] < 41 {
            marathonNonTaperDays = [1, 0, 1, 0, 1, 1, 0]
        }
        else if weeklyMileage[0] < 46 {
            marathonNonTaperDays = [1, 0, 1, 1, 1, 1, 0]
        }
        else {
            marathonNonTaperDays = [1, 0, 1, 1, 1, 1, 1]
        }
        
        func getNonMarathonNonTaperDays(mileage: Int) -> [Int] {
            if mileage < 15 {
                return [1, 0, 1, 0, 1, 0, 0]
            }
            else if mileage < 26 {
                return [1, 0, 1, 0, 1, 1, 0]
            }
            else if mileage < 41 {
                return [1, 0, 1, 1, 1, 1, 0]
            }
            else {
                return [1, 0, 1, 1, 1, 1, 1]
            }
        }
        var weekNum: Int = 0
        while weekTypes[weekNum] != WeekType.taper1 {
            var thisWeeksTrainingPlanDays = [Int]()
            
            //marathon running days stay constant
            if raceDistance == Distance.marathon {
                thisWeeksTrainingPlanDays = marathonNonTaperDays
            }
            else {
                thisWeeksTrainingPlanDays = getNonMarathonNonTaperDays(mileage: weeklyMileage[weekNum])
            }
            trainingPlanDays.append(thisWeeksTrainingPlanDays)
            
            //Getting run indices. Workouts should be in middle of the week
            if workouts[weekNum] != Run.easy {
                var runIndices = [Int]()
                for i in 0..<7 {
                    if thisWeeksTrainingPlanDays[i] == 1 {
                        runIndices.append(i)
                    }
                }
                if runIndices.count % 2 == 0 {
                    workoutIndices.append(runIndices[runIndices.count / 2])
                }
                else {
                    workoutIndices.append(runIndices[Int(runIndices.count / 2)])
                }
            }
            else {
                workoutIndices.append(69) // means no workout
            }
            longRunIndices.append(0)
            weekNum+=1
        }
       
        //Dealing with taper weeks
        if(raceDistance == Distance.marathon) {
            trainingPlanDays.append([0, 0, 1, 1, 0, 1, 0])
            workoutIndices.append(3)
        }
        else {
            if weeklyMileage[0] < 15 {
                trainingPlanDays.append([0, 0, 1, 0, 1, 0, 0])
            }
            else if weeklyMileage[0] < 26 {
                trainingPlanDays.append([0, 0, 1, 1, 1, 0, 0])
            }
            else {
                trainingPlanDays.append([0, 0, 1, 1, 1, 1, 0])
            }
            workoutIndices.append(4)
        }
        longRunIndices.append(69)
        
        for week in 0..<trainingPlanDays.count {
            for day in 0..<7 {
                if trainingPlanDays[week][day] == 0 {
                    runTypes[week][day] = Run.rest
                }
                else if day == workoutIndices[week] {
                    runTypes[week][day] = workouts[week]
                }
                else if day == longRunIndices[week] {
                    runTypes[week][day] = Run.longRun
                }
                else {
                    runTypes[week][day] = Run.easy
                }
            }
        }
        return runTypes
    }
    
    //Returns total mileage of a workout, which is essentially the workout mileage + warm up + cool down + any jogs expected between repeats
    //It isn't expected that repeat8s will go above 8 repeats, 16s above 6, and tempos above 10
    private func getWorkoutTotalMileages(workouts: [Run], workoutNumRepeatsOrMiles: [Int]) -> [Int] {
        var workoutTotalMileages = [Int]()
        
        for i in 0..<workouts.count {
            
            if workouts[i] == Run.repeat8 {
                if workoutNumRepeatsOrMiles[i] == 3 || workoutNumRepeatsOrMiles[i] == 4 {
                    workoutTotalMileages.append(5)
                }
                else if workoutNumRepeatsOrMiles[i] == 5 {
                    workoutTotalMileages.append(6)
                }
                else if workoutNumRepeatsOrMiles[i] == 6 {
                    workoutTotalMileages.append(7)
                }
                else {
                    workoutTotalMileages.append(8)
                }
            }
            else if workouts[i] == Run.repeat16 {
                if workoutNumRepeatsOrMiles[i] == 2 {
                    workoutTotalMileages.append(5)
                }
                else if workoutNumRepeatsOrMiles[i] == 3 {
                    workoutTotalMileages.append(7)
                }
                else if workoutNumRepeatsOrMiles[i] == 4 {
                    workoutTotalMileages.append(8)
                }
                else if workoutNumRepeatsOrMiles[i] == 5 {
                    workoutTotalMileages.append(10)
                }
                else {
                    workoutTotalMileages.append(11)
                }
            }
            //Tempos
            else if workouts[i] == Run.tempo {
                if workoutNumRepeatsOrMiles[i] == 3 {
                    workoutTotalMileages.append(5)
                }
                else if workoutNumRepeatsOrMiles[i] == 4 {
                    workoutTotalMileages.append(6)
                }
                else if workoutNumRepeatsOrMiles[i] == 5 {
                    workoutTotalMileages.append(7)
                }
                else if workoutNumRepeatsOrMiles[i] == 6 {
                    workoutTotalMileages.append(8)
                }
                else if workoutNumRepeatsOrMiles[i] == 7 {
                    workoutTotalMileages.append(9)
                }
                else if workoutNumRepeatsOrMiles[i] == 8 {
                    workoutTotalMileages.append(10)
                }
                else if workoutNumRepeatsOrMiles[i] == 9 {
                    workoutTotalMileages.append(11)
                }
                else {
                    workoutTotalMileages.append(12)
                }
            }
            else {
                workoutTotalMileages.append(0)
            }
        }
        return workoutTotalMileages
    }
    
    /*
    MARATHON--MILES PER WEEK  AND LONG RUNS
    Marathon: Long Runs increase by 6, 7, 8, 9, 10, 12, 14, 16, 18, 20, 16, 20....always ending
    at 20 as a final long run, even if this yields two 20s in a row at the end, and just one t3 taper week
    <15: 6, 7, 8
    15-20: 8, 9, 10
    21-30: 10, 12, 14
    31-40: 12, 14, 16
    41+: 14, 16, 18, 20, 16, 20...

    nonMARATHON--MILES PER WEEK  AND LONG RUNS
    nonMarathon: Long Runs increase by 6, 6, 7, 7, 8, 8, 9, 9, etc
    <15: 6
    15-24: 8
    25-40: 10
    41-49: 12
    51+: 14
 */

    //returns an array, index representing weeknum holding a numebr which represents the length of the week's long run.
    private func getLongRunDistances(mpw: [Int], raceDistance: Distance, weekTypes: [WeekType]) -> [Int] {
        var lr = [Int]()
        var lrOrder = [Int]()
        var lrStartIndex: Int
        if raceDistance == Distance.marathon {
            lrOrder = [6, 7, 8, 9, 10, 12, 14, 16, 18, 20, 16, 20, 16, 20, 16, 20, 16, 20, 16, 20, 16, 20
            , 16] //16 weeks max and they can start at index 6 latest so we need 23 slots in array
            if mpw[0] < 15 {
                lrStartIndex = 0
            }
            else if mpw[0] < 21 {
                lrStartIndex = 2
            }
            else if mpw[0] < 31 {
                lrStartIndex = 4
            }
            else if mpw[0] < 41 {
                lrStartIndex = 5
            }
            else {
                lrStartIndex = 6
            }
        }
        else {
            lrOrder = [6, 6, 7, 7, 8, 8, 9, 9, 10, 10, 11, 11, 12, 12, 13, 13, 14, 14, 15, 15, 16, 16, 17, 17, 18, 18, 19, 19, 20, 20, 21, 21, 22]
            if mpw[0] < 15 {
                lrStartIndex = 0
            }
            else if mpw[0] < 25 {
                lrStartIndex = 4
            }
            else if mpw[0] < 41 {
                lrStartIndex = 8
            }
            else if mpw[0] < 51 {
                lrStartIndex = 12
            }
            else {
                lrStartIndex = 16
            }
        }
        var weekIndex: Int = 0
        while weekTypes[weekIndex] == WeekType.rest || weekTypes[weekIndex] == WeekType.normal {
            if weekTypes[weekIndex] == WeekType.rest {
                if raceDistance == Distance.marathon {
                    lr.append(Int(0.5 * Double(lrOrder[lrStartIndex])))
                }
                else {
                    lr.append(Int(0.75 * Double(lrOrder[lrStartIndex])))
                }
                lrStartIndex+=1
            }
            else {
                lr.append(lrOrder[lrStartIndex])
            }
            weekIndex+=1
        }
        //Taper weeks
        if raceDistance == Distance.marathon {
            lr[lr.count-1] = 20 // last week before taper weeks should be a 20 mile run for marathon plans
            if weekTypes[weekIndex] == WeekType.taper3 {
                lr.append(contentsOf: [12, 8, 0])
            }
            else if weekTypes[weekIndex] == WeekType.taper2 {
                lr.append(contentsOf: [8, 0])
            }
        }
        lr.append(0)
        
        return lr
    }
    //returns a 2D array. Get the pace of a training day by calling runPaces[week][day]. Rows are weeks, columns are days. Paces are in seconds.
    private func getRunPaces(runTypes: [[Run]], planDifficulty: PlanDifficulty, recentRaceDistance: Distance, recentRaceTime: Int, numRepeatsOrMiles: [Int]) -> [[Int]] {
        
        var runPaces: [[Int]] = Array(repeating: Array(repeating: 0, count: 7), count: runTypes.count)
        
        //converting to 5k pace
        let fiveKilometersPace: Double = (Double(recentRaceTime) / recentRaceDistance.getDistance()) * recentRaceDistance.get5kPaceFraction()
        //Training Pace Fractions (of 5k pace)
        var repetition: Double = 0.96
        var interval: Double = 1.04
        var tempo3To4: Double = 1.07
        var tempo5To6: Double = 1.09
        var tempo7To8: Double = 1.105
        var tempo9To10: Double = 1.12
        var easyOrLong: Double = 1.26
        
        var monthlyDecrease: Double
        if planDifficulty == PlanDifficulty.medium || planDifficulty == PlanDifficulty.hard {
            monthlyDecrease = 0.01
        }
        else {
            monthlyDecrease = 0.02
        }
        
        for week in 0..<runPaces.count {
            for day in 0..<7 {
                if week != 0 && week % 4 == 0 && day == 0 {
                    easyOrLong-=monthlyDecrease
                    repetition-=monthlyDecrease
                    interval-=monthlyDecrease
                    tempo3To4-=monthlyDecrease
                    tempo5To6-=monthlyDecrease
                    tempo7To8-=monthlyDecrease
                    tempo9To10-=monthlyDecrease
                }
                if runTypes[week][day] == Run.easy || runTypes[week][day] == Run.longRun {
                    runPaces[week][day] = Int(easyOrLong * fiveKilometersPace)
                }
                else if runTypes[week][day] == Run.repeat16 {
                    runPaces[week][day] = Int(interval * fiveKilometersPace)
                }
                else if runTypes[week][day] == Run.repeat8 {
                    runPaces[week][day] = Int(repetition * fiveKilometersPace)
                }
                else if runTypes[week][day] == Run.tempo {
                    if numRepeatsOrMiles[week] == 3 || numRepeatsOrMiles[week] == 4 {
                        runPaces[week][day] = Int(tempo3To4 * fiveKilometersPace)
                    }
                    else if numRepeatsOrMiles[week] == 5 || numRepeatsOrMiles[week] == 6 {
                        runPaces[week][day] = Int(tempo5To6 * fiveKilometersPace)
                    }
                    else if numRepeatsOrMiles[week] == 7 || numRepeatsOrMiles[week] == 8 {
                        runPaces[week][day] = Int(tempo7To8 * fiveKilometersPace)
                    }
                    else {
                        runPaces[week][day] = Int(tempo9To10 * fiveKilometersPace)
                    }
                }
                //Run.rest
                else {
                    runPaces[week][day] = 0
                }
            }
        }
        return runPaces
    }
}

