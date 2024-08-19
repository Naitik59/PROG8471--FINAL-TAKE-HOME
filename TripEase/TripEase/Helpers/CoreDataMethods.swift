//
//  CoreDataMethods.swift
//  TripEase
//
//  Created by Naitik Ratilal Patel on 18/08/24.
//

import Foundation
import CoreData
import UIKit

class CoreDataMethods {
    
    static let shared = CoreDataMethods()
    
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    func addTrip(trip: Trip, completion: @escaping(Bool) -> Void) {
    
        if let managedContext = appDelegate?.persistentContainer.viewContext {
            let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "TripDB")
            fetchRequest.predicate = NSPredicate(format: "if = %@", trip.id)
            
            do {
                let entity = NSEntityDescription.entity(forEntityName: "TripDB", in: managedContext)!
                
                let data = NSManagedObject(entity: entity, insertInto: managedContext)
                data.setValue(trip.id, forKey: "id")
                data.setValue(trip.title, forKey: "title")
                data.setValue(trip.from, forKey: "from")
                data.setValue(trip.to, forKey: "to")
                data.setValue(trip.startDate, forKey: "startDate")
                data.setValue(trip.endDate, forKey: "endDate")
                data.setValue(trip.thingsToDo, forKey: "thingsToDo")
                
                try managedContext.save()
                
                completion(true)
            } catch let error as NSError {
                print("🆘 Could not save. \(error), \(error.userInfo)")
                completion(false)
            }
        } else {
            completion(false)
        }
    }
    
    func fetchTrips() -> [Trip] {
        
        if let managedContext = appDelegate?.persistentContainer.viewContext {
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "TripDB")
            
            do {
                let trips = try managedContext.fetch(fetchRequest)
                var listOfTrips: [Trip] = []
                
                for trip in trips {
                    let id = trip.value(forKey: "id") as? String ?? ""
                    let title = trip.value(forKey: "title") as? String ?? ""
                    let from = trip.value(forKey: "from") as? String ?? ""
                    let to = trip.value(forKey: "to") as? String ?? ""
                    let startDate = trip.value(forKey: "startDate") as? Date ?? Date()
                    let endDate = trip.value(forKey: "endDate") as? Date ?? Date()
                    let thingsToDo = trip.value(forKey: "thingsToDo") as? String ?? ""
                    
                    var item = Trip(title: title, from: from, to: to, startDate: startDate, endDate: endDate, thingsToDo: thingsToDo)
                    item.mutateID(id: id)
                    
                    listOfTrips.append(item)
                }
                
                return listOfTrips
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
        }
        return []
    }
    
    func deleteTrip(with id: String) {
        if let managedContext = appDelegate?.persistentContainer.viewContext {
            let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "TripDB")
            fetchRequest.predicate = NSPredicate(format: "id = %@", id)
            
            do {
                let result = try managedContext.fetch(fetchRequest)
                if let result = result as? [NSManagedObject], let entity = result.first {
                    managedContext.delete(entity)
                }
                
                try managedContext.save()
            } catch let error as NSError {
                print("🆘 Could not save. \(error), \(error.userInfo)")
            }
        }
    }
    
    //MARK: - Expense Section
    
    func addExpense(expense: Expense, completion: @escaping(Bool) -> Void) {
        
        if let managedContext = appDelegate?.persistentContainer.viewContext {
            let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "TripExpense")
            fetchRequest.predicate = NSPredicate(format: "if = %@", expense.tripId)
            
            do {
                let entity = NSEntityDescription.entity(forEntityName: "TripExpense", in: managedContext)!
                
                let data = NSManagedObject(entity: entity, insertInto: managedContext)
                data.setValue(expense.tripId, forKey: "id")
                data.setValue(expense.title, forKey: "title")
                data.setValue(expense.amount, forKey: "amount")
                
                try managedContext.save()
                
                completion(true)
            } catch let error as NSError {
                print("🆘 Could not save. \(error), \(error.userInfo)")
                completion(false)
            }
        } else {
            completion(false)
        }
    }
    
    func fetchExpenses(for tripId: String) -> [Expense] {
        
        if let managedContext = appDelegate?.persistentContainer.viewContext {
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "TripExpense")
            
            do {
                let expenses = try managedContext.fetch(fetchRequest)
                var listOfExpenses: [Expense] = []
                
                for expense in expenses {
                    let id = expense.value(forKey: "id") as? String ?? ""
                    let title = expense.value(forKey: "title") as? String ?? ""
                    let amount = expense.value(forKey: "amount") as? Double ?? 0.0
                    
                    let expenseData = Expense(tripId: id, title: title, amount: amount)
                    
                    if id == tripId {
                        listOfExpenses.append(expenseData)
                    }
                }
                
                return listOfExpenses
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
        }
        
        return []
    }
    
    func deleteExpense(with id: String) {
        if let managedContext = appDelegate?.persistentContainer.viewContext {
            let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "TripExpense")
            fetchRequest.predicate = NSPredicate(format: "id = %@", id)
            
            do {
                let result = try managedContext.fetch(fetchRequest)
                
                if let result = result as? [NSManagedObject] {
                    result.forEach { entity in
                        managedContext.delete(entity)
                    }
                }
                
                try managedContext.save()
            } catch let error as NSError {
                print("🆘 Could not save. \(error), \(error.userInfo)")
            }
        }
    }
}
