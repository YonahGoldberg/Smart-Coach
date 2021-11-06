//
//  AppInformationView.swift
//  SmartCoach
//
//  Created by Yonah Goldberg on 8/15/21.
//

import SwiftUI

struct AppInformationView: View {
    var body: some View {
        ScrollView {
            VStack {
                Text("About SmartCoach")
                    .font(.title)
                    .padding()
                Text("Development")
                    .font(.title)
                    .underline()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                Text("SmartCoach is a custom running training plan creator developed by Yonah Goldberg, current computer science student at Carnegie Mellon University. It uses an algorithm designed by Amby Burfoot, former Executive Editor of Runner's World magazine, author, and 1968 Boston Marathon champion.")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                Text("Algorithm")
                    .font(.title)
                    .underline()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                Text("Overview")
                    .font(.title3)
                    .underline()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                Text("SmartCoach takes in 6 variables: race distance, race date, plan difficulty, current weekly mileage, and a recent race's distance and time.")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                Text("The recent race's distance and time are used as a fitness indicator and determine paces of runs in conjunction with the plan's difficulty. All plans start with weekly mileage at the user's current weekly mileage. Weekly mileage then increases throughout the plan before tapering off a number of weeks before the race.")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                Text("A training week consists of a number of easy runs, a tempo or repeat workout, and a long run, which is always on Sunday")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                Text("Run Types")
                    .font(.title3)
                    .underline()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                Text("Rest Day: contains no run. Cross train or stretch and foam roll and let your body recover")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
            }
            VStack {
                Text("Easy Run: easy days are flexible. They contain a recommended pace, but there is leeway to slow down or go a bit faster depending on how you feel. It is also recommended to include strides (short 50 to 100 meter sprints) on soft surfaces occasionally at the end of easy runs. Effort on strides can be up to 90% of max speed. The goal is to focus on form and power and loosen up.")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                Text("Long Run: a longer run to cap off the week. Recommended pace is the same as easy runs, but if you feel great then challenge yourself to finish off strongly in the last few miles.")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                Text("Tempo Run: effort should be \"comfortably hard.\" Find a relatively flat loop (or include some hills if you really want to challenge yourself.)")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                Text("Repeat 1600s and Repeat 800s: a harder effort than tempo runs where the runner should start to feel some lactic acid build up towards the end of each repetition. Repeats should ideally be done on a track or a flat loop. Between repeats rest, walk, or jog a time equivalent to the repeat.")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                Text("Recommendations")
                    .font(.title)
                    .underline()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                Text("Before creating a marathon training plan build up to at least running 11 miles a week and for all other distances build up to at least 6 miles a week.")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                Text("When inputting a recent race result try to choose a race distance as close to the one you are training for as possible. It will yield a more suitable plan.")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                Text("Although it is not explicitly stated in the training plan, dynamic stretching before runs (especially tempos and repeats) and static stretching after runs is highly recommended. Core, strength, and hip exercises throughout the week will also improve results and help prevent injuries.")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
        }
    }
}

struct AppInformationView_Previews: PreviewProvider {
    static var previews: some View {
        AppInformationView()
    }
}
