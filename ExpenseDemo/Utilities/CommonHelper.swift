//
//  CommonHelper.swift
//
//
//

import Foundation
import UIKit



extension UIView{
    
    //Draw under line below view
    func showUnderline(){
        let border = CALayer()
        let width  = CGFloat(1.0)
        border.borderColor = UIColor.lightGray.cgColor
        
        let frameObj = self.frame
        border.frame = CGRect(x:0, y:frameObj.size.height - width, width:frameObj.size.width, height:frameObj.size.height)
        border.borderWidth = width
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
    
}


//MARK: ========== SHOW ALERT ==========

extension UIViewController {
    
    func showAlertMessage(title:String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
           
        }))
        self.present(alert, animated: true, completion: nil)
    }
}

extension Date {

    func toString(format: String = "yyyy-MM-dd") -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}
