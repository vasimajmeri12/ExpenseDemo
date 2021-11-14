//
//  FilterViewController.swift
//  ExpenseDemo
//
//  Created by VASIM AJMERI on 14/11/21.
//

import UIKit
import CoreData

protocol FilterExpensesDelegate : class {
   func filterExpenses(date: Date, category: Int16)
}

class FilterViewController: UIViewController {
    
    weak var delegate: FilterExpensesDelegate?
    var arrCategories = [CategoryModel]()
    var selectedCategoryID : Int16 = 0
    var pickerView: UIPickerView!
    var datePicker = UIDatePicker()

    
    @IBOutlet weak var txtDate: UITextField!
    @IBOutlet weak var txtCategory: UITextField!
    
    
//MARK: - ########## VIEW DELEGATE #########

    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchCategories()
        self.setupView()
    }
    
    private func setupView(){
        self.pickerView = UIPickerView.init()
        self.pickerView.delegate   = self
        self.pickerView.dataSource = self
        self.txtCategory.delegate  = self
        self.txtCategory.inputView = self.pickerView
        self.setupDatePicker()
    }
    
    private func setupDatePicker(){
        self.datePicker.datePickerMode = .date
        self.datePicker.maximumDate    = Date()
        self.datePicker.date           = Date()
        self.datePicker.locale         = .current
        
        if #available(iOS 14, *) {
            self.datePicker.preferredDatePickerStyle = .wheels
            self.datePicker.sizeToFit()
        }
        self.txtDate.delegate     = self
        self.txtDate.inputView    = self.datePicker
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
    
    
    //DATE PICKER
    @objc func onDatePickerValueChange(sender: UIDatePicker){
        self.txtDate.text = Constants.convertDate(date: sender.date)
    }
    
    @IBAction func onBtnFilter(_ sender: Any) {
        delegate?.filterExpenses(date: Date(), category: self.selectedCategoryID)
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension FilterViewController : UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if(textField == self.txtDate && textField.text == ""){
            self.txtDate.text = Constants.convertDate(date: Date())
        }
        if(textField == self.txtCategory && textField.text == ""){
            self.txtCategory.text = self.arrCategories[0].name
            self.selectedCategoryID = self.arrCategories[0].id
        }
    }
}


extension FilterViewController : UIPickerViewDelegate, UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        self.arrCategories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return arrCategories[row].name
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.txtCategory.text = arrCategories[row].name
        self.selectedCategoryID = arrCategories[row].id
    }
    
}
