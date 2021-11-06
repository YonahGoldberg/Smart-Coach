//
//  Data.swift
//  SmartCoach
//
//  Created by Yonah Goldberg on 5/30/21.
//

import Foundation

class AppData: ObservableObject {
    @Published var trainingPlans = [TrainingPlan]()
}
