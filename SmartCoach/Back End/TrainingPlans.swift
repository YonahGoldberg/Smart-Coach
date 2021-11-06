//
//  TrainingPlans.swift
//  SmartCoach
//
//  Created by Yonah Goldberg on 8/18/21.
//

import Foundation

struct TrainingPlans: Codable {
    var one: TrainingPlan?
    var two: TrainingPlan?
    var three: TrainingPlan?
    var four: TrainingPlan?
    var five: TrainingPlan?
    
    func getPlans() -> [TrainingPlan] {
        var plans: [TrainingPlan] = []
        if let plan = one {
            plans.append(plan)
        }
        if let plan = two {
            plans.append(plan)
        }
        if let plan = three {
            plans.append(plan)
        }
        if let plan = four {
            plans.append(plan)
        }
        if let plan = five {
            plans.append(plan)
        }
        return plans
    }
    
    init(one: TrainingPlan) {
        self.one = one
    }
    init(one: TrainingPlan, two: TrainingPlan) {
        self.one = one
        self.two = two
    }
    init(one: TrainingPlan, two: TrainingPlan, three: TrainingPlan) {
        self.one = one
        self.two = two
        self.three = three
    }
    init(one: TrainingPlan, two: TrainingPlan, three: TrainingPlan, four: TrainingPlan) {
        self.one = one
        self.two = two
        self.three = three
        self.four = four
    }
    init(one: TrainingPlan, two: TrainingPlan, three: TrainingPlan, four: TrainingPlan, five: TrainingPlan) {
        self.one = one
        self.two = two
        self.three = three
        self.four = four
        self.five = five
    }
}
