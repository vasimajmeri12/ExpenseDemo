//
//  ExpenseListViewController.swift
//  ExpenseDemo
//
//  Created by VASIM AJMERI on 14/11/21.
//

import UIKit
import CoreData

class ExpenseListViewController: UIViewController {
    
    var arrExpenses = [Expense]()
    var arrCategory = [ExpenseCategory]()
    var pickerView  : UIPickerView!
    var filterDate  : Date?
    var filterCategory : Int16?
    
    @IBOutlet weak var expenceTableView: UITableView!
    @IBOutlet weak var lblNoExpense: UILabel!
    
    
//MARK: - ########## VIEW DELEGATE #########
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchExpenses()
        self.title = "Expenses"
        self.showPasscodeVC()
    }
    
    func showPasscodeVC(){
        PasscodeViewController.config.EnterCurrentPasscodeMessage = "Default PIN is 1234"

        if let vc = PasscodeViewController.instance(with: .VERIFY) {
               vc.show { (passcode, newPasscode, mode) in
                   print(passcode, newPasscode, mode)
                   vc.startProgressing()
                   DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
                   vc.stopProgress()
                    self.dismiss(animated: true, completion: nil)
               }
           }
        }
    }
    
   
//MARK: - ########## FETCH EXPENSES #########
    
    private func fetchCategories(){
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Constants.ENTITY_NAME.EXPENSE_CATEGORY.rawValue)
//        let resultPredicate2 = NSPredicate(format: "formUUID = %@", formUUID)

        do {
            let result = try Constants.MANAGED_CONTEXT.fetch(fetchRequest)
            self.arrCategory = result as! [ExpenseCategory]
            self.fetchExpenses()

        } catch {
            self.expenceTableView.isHidden = self.arrExpenses.count > 0 ? false : true
            print("Error : \(error.localizedDescription)")
        }
    }

    private func fetchExpenses(){
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Constants.ENTITY_NAME.EXPENSE.rawValue)
       // let resultPredicate = NSPredicate(format: "date = %@", (self.filterDate ?? Date()) as CVarArg)
       // fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [resultPredicate])

        do {
            let result = try Constants.MANAGED_CONTEXT.fetch(fetchRequest)
            self.arrExpenses = result as! [Expense]
            for expense in self.arrExpenses{
                let arrCategoryObj    = self.arrCategory.filter({$0.expense_id == expense.id})
                var strCategory       = ""
                var index = 0

                for cat in arrCategoryObj{
                    strCategory += (cat.name ?? "") + (index < (arrCategoryObj.count - 1) ? ", ": "")
                    index += 1
                }
                expense.category = strCategory
            }
           
            self.expenceTableView.isHidden = self.arrExpenses.count > 0 ? false : true
            self.expenceTableView.reloadData()
            
        } catch {
            print("Error : \(error.localizedDescription)")
        }
    }
    
    
    @IBAction func handleNavigation(_ sender: Any) {
        let createVC = self.storyboard?.instantiateViewController(withIdentifier: "CreateExpenseViewController") as! CreateExpenseViewController
        createVC.delegate = self
        self.navigationController?.pushViewController(createVC, animated: true)
    }
    
    @IBAction func handleFilter(_ sender: Any) {
        let filterVC = self.storyboard?.instantiateViewController(withIdentifier: "FilterViewController") as! FilterViewController
        filterVC.delegate = self
        self.navigationController?.pushViewController(filterVC, animated: true)
    }
    
}


extension ExpenseListViewController : UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.arrExpenses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "expenceCell", for: indexPath) as! ExpenseCell
        let expenseObj        = self.arrExpenses[indexPath.row]
        cell.lblName.text     = expenseObj.name
        cell.lblAmount.text   = "\(expenseObj.amount) ₹"
        cell.lblCategory.text = expenseObj.category
        cell.lblDate.text     = expenseObj.date?.toString(format: "dd MMM YYYY")
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        0.01
    }
}

extension ExpenseListViewController : UpdateExpenseDelegate{
    
    func reloadExpenseList(expense: Expense, strCategory: String) {
        expense.category = strCategory
        self.arrExpenses.append(expense)
        self.expenceTableView.isHidden = self.arrExpenses.count > 0 ? false : true
        self.expenceTableView.reloadData()
    }
}


extension ExpenseListViewController : FilterExpensesDelegate{
    
    func filterExpenses(date: Date, category: Int16) {
        self.filterDate = date
        self.filterCategory = category
        self.fetchExpenses()
        
    }

}
