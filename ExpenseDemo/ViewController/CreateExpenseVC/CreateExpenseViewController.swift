//
//  CreateExpenseViewController.swift
//  ExpenseDemo
//
//  Created by VASIM AJMERI on 14/11/21.
//

import UIKit
import CoreData

protocol UpdateExpenseDelegate : class{
    func reloadExpenseList(expense: Expense, strCategory: String)
}

class CreateExpenseViewController: UIViewController {

    @IBOutlet weak var txtExpenseName: UITextField!
    @IBOutlet weak var txtAmount: UITextField!
    @IBOutlet weak var txtDate: UITextField!
    @IBOutlet weak var txtCategory: UITextField!
    @IBOutlet weak var txtViewNotes: UITextView!
    
    weak var delegate: UpdateExpenseDelegate?
    var datePicker = UIDatePicker()
    
    var arrCategories = [CategoryModel]()
    var arrSelectedCategories = [String]()
    var arrSelectedCategoriesName = [String]()

    
//MARK: - ########## VIEW DELEGATE #########
        
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupView()
    }
        
    
//MARK: - ########## SETUP VIEW #########

    private func setupView() {
        self.title = "Create Expense"
        self.fetchCategories()
        self.txtExpenseName.showUnderline()
        self.txtAmount.showUnderline()
        self.txtDate.showUnderline()
        self.txtCategory.showUnderline()
        self.txtViewNotes.showUnderline()
        self.setupDatePicker()
    }
    
    private func setupDatePicker(){
        self.datePicker.datePickerMode = .date
        self.datePicker.maximumDate = Date()
        self.datePicker.date = Date()
        self.datePicker.locale = .current
        if #available(iOS 14, *) {
            self.datePicker.preferredDatePickerStyle = .wheels
            self.datePicker.sizeToFit()
        }
        self.txtDate.inputView = self.datePicker
        self.datePicker.addTarget(self, action: #selector(self.onDatePickerValueChange(sender:)), for: .valueChanged)
    }
   
    private func fetchCategories(){
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Constants.ENTITY_NAME.CATEGORY.rawValue)
        do {
            self.arrCategories.removeAll()
            var catResult = try Constants.APP_DELEGATE.persistentContainer.viewContext.fetch(fetchRequest) as! [Category]
            catResult.sort(by: {$0.id < $1.id })
            for category in catResult{
                let catObj = CategoryModel.init(id: category.id, name: category.name ?? "")
                self.arrCategories.append(catObj)
            }
            
            print("COUNT : ",self.arrCategories.count)
        } catch {
            print("Error : \(error.localizedDescription)")
        }
    }
    
    private func validateExpense(){
        
        guard let expenseName = self.txtExpenseName.text, expenseName != "" else{
            self.showAlertMessage(title: "Create Expense", message: "Please enter expense name")
            return
        }
        guard let expenseAmount =  self.txtAmount.text, expenseAmount != "" else{
            self.showAlertMessage(title: "Create Expense", message: "Please enter expense amount")
            return
        }
        
        guard let expenseFinalAmount = Double(expenseAmount) else{
            self.showAlertMessage(title: "Create Expense", message: "Please enter valid expense amount")
            return
        }
        
        guard let expenseDate = self.txtDate.text, expenseDate != "" else{
            self.showAlertMessage(title: "Create Expense", message: "Please select expense date")
            return
        }
        
        guard let expenseCategory = self.txtCategory.text, expenseCategory != "" else{
            self.showAlertMessage(title: "Create Expense", message: "Please select expense category")
            return
        }
        self.saveExpense(name: expenseName, amount: expenseFinalAmount, date: self.datePicker.date, notes: self.txtViewNotes.text ?? "")
    }
    
    private func saveExpense(name:String, amount:Double, date: Date, notes: String){
        
        let expenseEntity = NSEntityDescription.entity(forEntityName: Constants.ENTITY_NAME.EXPENSE.rawValue, in: Constants.MANAGED_CONTEXT)!
        
        let expenseID  = Constants.getAutoIncrementExpenseID()
        let expenseObj = Expense.init(entity: expenseEntity, insertInto: Constants.MANAGED_CONTEXT)
        expenseObj.id  = expenseID
        expenseObj.name = name
        expenseObj.amount = amount
        expenseObj.date  = date
        expenseObj.notes = notes
        
        do {
            try Constants.MANAGED_CONTEXT.save()
            self.saveExpenseCategories(expense: expenseObj)
        } catch let error as NSError {
            self.showAlertMessage(title: "Create Expense", message: error.localizedDescription)
        }
    }
    
    private func saveExpenseCategories(expense: Expense){
        let expcategoryEntity = NSEntityDescription.entity(forEntityName: Constants.ENTITY_NAME.EXPENSE_CATEGORY.rawValue, in: Constants.MANAGED_CONTEXT)!
        var tempIndex = 0
        
        for categoryID in self.arrSelectedCategories{
            let expCategoryObj = ExpenseCategory.init(entity: expcategoryEntity, insertInto: Constants.MANAGED_CONTEXT)
            expCategoryObj.expense_id = expense.id
            expCategoryObj.category_id = Int16(categoryID) ?? 0
            expCategoryObj.name = self.arrSelectedCategoriesName[tempIndex]
            tempIndex += 1
        }
        
        do {
            try Constants.MANAGED_CONTEXT.save()
            delegate?.reloadExpenseList(expense: expense, strCategory: self.txtCategory.text ?? "")
            self.onSuccessCreateExpense()
        } catch let error as NSError {
            self.showAlertMessage(title: "Create Expense", message: error.localizedDescription)
        }
    }
    
    private func onSuccessCreateExpense(){
        Constants.increaseAutoIncrement()
        self.showAlertMessage(title: "Create Expense", message: "Expense has been saved successfully!")
        self.txtDate.text = ""
        self.datePicker.date = Date()
        self.txtExpenseName.text = ""
        self.txtCategory.text = ""
        self.arrSelectedCategories.removeAll()
        self.txtAmount.text = ""
        self.txtViewNotes.text = ""
    }
    
    //MARK: - ######## ACTION METHODS #########
    
    @IBAction func onBtnSave(_ sender: Any) {
        self.validateExpense()
    }
    

}

//MARK: - ######## CATEGORY PICKER #########

extension CreateExpenseViewController{
    
    private func showCategoryPicker(){
        if(self.arrCategories.count == 0) {return}
        
        MultiPickerDialog().show(title: "Select Category",doneButtonTitle:"Done", cancelButtonTitle:"Cancel",
                                 options: self.arrCategories, selected: self.arrSelectedCategories) { values -> Void in
            var strCategories = ""
            self.arrSelectedCategories.removeAll()
            self.arrSelectedCategoriesName.removeAll()
            var index = 0
            
            for categoryObj in values {
                self.arrSelectedCategories.append("\(categoryObj.id)")
                self.arrSelectedCategoriesName.append(categoryObj.name )
                strCategories += (categoryObj.name ) + (index < values.count - 1 ? ", ": "")
                index += 1
            }
                    
            self.txtCategory.text = strCategories
        }
    }
    
    //DATE PICKER
    @objc func onDatePickerValueChange(sender: UIDatePicker){
        self.txtDate.text = Constants.convertDate(date: sender.date)
    }
}

//MARK: - ######## TEXTFIELD/TEXTVIEW DELEGATES #########

extension CreateExpenseViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if(textField == self.txtDate && textField.text == ""){
            self.txtDate.text = Constants.convertDate(date: Date())
            return true
        }
        
        if(self.txtCategory == textField){
            self.view.endEditing(true)
            self.showCategoryPicker()
            return false
        }
        return true
    }
    
}
