//
//  Constants.swift
//
//
//  
//

import Foundation
import UIKit

class Constants : NSObject{

    //APP DELEGATE
    static var APP_DELEGATE = UIApplication.shared.delegate as! AppDelegate
    static let MANAGED_CONTEXT = APP_DELEGATE.persistentContainer.viewContext

    //EXPENSE CATEGORIES
    static let arrCategory = ["Electronics","Fuel","Food","Shopping","Subscription"]

    
    //SET FIRST LAUNCH
    static func setAppFirstLaunch(){
        UserDefaults.standard.set(true, forKey: "APP_FIRST_LAUNCH")
        UserDefaults.standard.synchronize()
    }

    //GET FIRST LAUNCH
    static func getAppFirstLaunch() -> Bool{
        return UserDefaults.standard.bool(forKey: "APP_FIRST_LAUNCH")
    }
    
    
    //ENTIRY NAME
    enum ENTITY_NAME: String {
        case EXPENSE = "Expense"
        case CATEGORY = "Category"
        case EXPENSE_CATEGORY = "ExpenseCategory"
    }
    
    //CONVERT DATE TO STRING
    static func convertDate(date: Date) -> String{
        let dateFormatter = DateFormatter()
        //dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss z"
        dateFormatter.dateFormat = "dd MMM yyyy"
        return  dateFormatter.string(from: date)
    }
    
    
    //AUTO EXPENSE_ID
    static func getAutoIncrementExpenseID() -> Int16{
        return Int16(UserDefaults.standard.integer(forKey: "AUTO_EXPENSE_ID"))
    }
    
    static func increaseAutoIncrement(){
        let autoID = self.getAutoIncrementExpenseID() + 1
        UserDefaults.standard.set(autoID, forKey: "AUTO_EXPENSE_ID")
        UserDefaults.standard.synchronize()
    }
    
}
