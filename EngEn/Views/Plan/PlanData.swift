//
//  PlanData.swift
//  EngEn
//
//  Created by Suen Lau on 2023/4/10.
//

import Foundation
import Combine

//to store each plan information
class PlanItem: Codable, Identifiable, ObservableObject{
    var beginDate: Date = Date()
    var endDate: Date = Date()
    var city: String = ""
    var state: String = ""
    var country: String = ""
    var location: String = ""
    var peopleList: [String] = []
    
    init(){}
    init(begin: Date, end: Date, city: String, persons: [String]){
        self.beginDate = begin
        self.endDate = end
        self.city = city
        self.peopleList = persons
    }

}

//to store the plan list
class PlanData: ObservableObject {
    static let shared = PlanData()
    @Published var planList: [PlanItem] = [PlanItem]()
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    let ArchiveURL = DocumentsDirectory.appendingPathComponent("PlanList")
    
    init(){}
    func addPlan(newItem: PlanItem){
        self.planList.append(newItem)
        if savePlanJSON() == true {
            print("Add to the plan list.")
            print("\(planList.count) plan(s) in the record.")
            showAlert(title: "Added✔︎", message: "Added to the plan list.")
            return
        }
        else{
            print("Unable to save the new plan.")
            showAlert(title: "Error", message: "Could not add to the plan list.")
        }
    }
    func deletePlan(item: PlanItem){
        self.planList.removeAll { element in
            return element === item
        }
        if savePlanJSON() == true {
            print("Delete from the plan list.")
            print("\(planList.count) plan(s) in the record.")
            return
        }
        else{
            print("Unable to delete the plan.")
        }
    }
    func savePlanJSON() -> Bool {//save the array to a JSON file on disk
        var outputData = Data()
        let encoder = JSONEncoder()
        
        var list = [PlanItem]()
        list = self.planList
        
        
        if let encoded = try? encoder.encode(list) {
            if let _ = String(data: encoded, encoding: .utf8) {
                outputData = encoded
            }
            else { return false }
            
            do {
                try outputData.write(to: ArchiveURL)//location of the JSON file in the Sandbox
            } catch let error as NSError {
                print (error)
                return false
            }
            return true
        }
        else { return false }
    }
    
    func loadPlanJSON() -> Bool {//load from a JSON file
        let decoder = JSONDecoder()
        var planList1 = [PlanItem]()
        let tempData: Data
        
        do {
            tempData = try Data(contentsOf: ArchiveURL)
        } catch let error as NSError {
            print(error.localizedDescription)
            return false
        }
        if let decoded = try? decoder.decode([PlanItem].self, from: tempData) {
            planList1 = decoded
            self.planList = planList1
            return true
        }
        else{
            return false
        }
    }
}
